package main

import (
	"context"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"syscall"

	"github.com/erikdubbelboer/gspt"
	"golang.org/x/sync/errgroup"
)

type InitCmd struct {
	Cmd     string   `kong:"required,arg,help='Name of executable to run, resolved using $PATH if relative'"`
	CmdArgs []string `kong:"optional,arg,help='Additional arguments for executable'"`
}

func (c *InitCmd) Run() error {
	// Change process title
	gspt.SetProcTitle("ctutil: init process")

	// Register signal handler
	sigCh := make(chan os.Signal, 1)
	defer close(sigCh)
	signal.Notify(sigCh)
	defer signal.Reset()

	// Create channel for triggering zombie reaping
	reapCh := make(chan struct{}, 1)
	defer close(reapCh)

	// Prepare execution environment
	cancelCtx, cancel := context.WithCancel(context.Background())
	g, ctx := errgroup.WithContext(cancelCtx)
	childCmd := c.prepareChildCmd(ctx)

	// Start goroutines for forwarding signals and reaping zombies
	g.Go(func() error {
		return c.forwardSignals(ctx, childCmd, sigCh, reapCh)
	})
	g.Go(func() error {
		return c.reapZombies(ctx, reapCh)
	})

	// Start goroutine which waits for child to exit
	g.Go(func() error {
		if err := childCmd.Start(); err != nil {
			return fmt.Errorf("could not start child: %w", err)
		}
		if err := childCmd.Wait(); err != nil {
			return fmt.Errorf("child execution failed: %w", err)
		}

		cancel()
		return nil
	})

	// Wait until execution has ended
	err := g.Wait()

	// In case of ExitError, propagate the original error code
	var exitErr *exec.ExitError
	if errors.As(err, &exitErr) {
		os.Exit(exitErr.ExitCode())
	}

	return err
}

func (c *InitCmd) prepareChildCmd(ctx context.Context) *exec.Cmd {
	cmd := exec.CommandContext(ctx, c.Cmd, c.CmdArgs...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}

	return cmd
}

func (c *InitCmd) forwardSignals(ctx context.Context, cmd *exec.Cmd, sigCh <-chan os.Signal, triggerReap chan<- struct{}) error {
	for {
		select {
		case sig := <-sigCh:
			if sig == syscall.SIGCHLD || cmd.Process == nil {
				break
			}

			err := syscall.Kill(-cmd.Process.Pid, sig.(syscall.Signal))
			if err != nil && err != syscall.ESRCH {
				return fmt.Errorf("could not forward signal [%s] to child: %w", sig, err)
			}

			triggerReap <- struct{}{}
		case <-ctx.Done():
			return nil
		}
	}
}

func (c *InitCmd) reapZombies(ctx context.Context, trigger <-chan struct{}) error {
	for {
		select {
		case <-trigger:
			var status syscall.WaitStatus
			_, err := syscall.Wait4(-1, &status, syscall.WNOHANG, nil)

			if err != nil && !errors.Is(err, syscall.ECHILD) {
				return fmt.Errorf("could not wait for child: %w", err)
			}
		case <-ctx.Done():
			return nil
		}
	}
}
