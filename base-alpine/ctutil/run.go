package main

import (
	"fmt"
	"os"
	"os/exec"
	"syscall"

	"github.com/opencontainers/runc/libcontainer/system"
	"github.com/opencontainers/runc/libcontainer/user"
)

type RunCmd struct {
	Cmd        string   `kong:"required,arg,help='Name of executable to run, resolved using $PATH if relative'"`
	CmdArgs    []string `kong:"optional,arg,help='Additional arguments for executable'"`
	Privileges string   `kong:"optional,short=p,help='Drop privileges to given spec',placeholder='<USER|USER:GROUP|UID:GID>'"`
	Groups     []int    `kong:"optional,short=g,help='Override supplemental groups when using -u',placeholder='SGID'"`
}

func (c *RunCmd) Run() error {
	if c.Privileges != "" {
		if err := c.dropPrivileges(); err != nil {
			return err
		}
	}

	cmdPath, err := exec.LookPath(c.Cmd)
	if err != nil {
		return fmt.Errorf("could not lookup executable path for [%s]: %w", c.Cmd, err)
	}

	cmdArgv := append([]string{cmdPath}, c.CmdArgs...)
	if err := syscall.Exec(cmdPath, cmdArgv, os.Environ()); err != nil {
		return fmt.Errorf("could not exec into process [%s] with args %v: %w", c.Cmd, c.CmdArgs, err)
	}

	return nil
}

func (c *RunCmd) dropPrivileges() error {
	execUser, err := c.parsePrivileges()
	if err != nil {
		return err
	}

	groupIDs, err := os.Getgroups()
	if err == nil &&
		os.Getuid() == execUser.Uid && os.Getgid() == execUser.Gid &&
		containsIntSlice(groupIDs, execUser.Sgids) {
		return nil
	}

	if err := os.Unsetenv("HOME"); err != nil {
		return fmt.Errorf("could not unset HOME env variable: %w", err)
	}

	if err := syscall.Setgroups(execUser.Sgids); err != nil {
		return fmt.Errorf("could not change groups using setgroups(%v): %w", execUser.Sgids, err)
	}
	if err := system.Setgid(execUser.Gid); err != nil {
		return fmt.Errorf("could not change group using setgid(%d): %w", execUser.Gid, err)
	}
	if err := system.Setuid(execUser.Uid); err != nil {
		return fmt.Errorf("could not change user using setuid(%d): %w", execUser.Uid, err)
	}

	if envHome := os.Getenv("HOME"); envHome == "" {
		if err := os.Setenv("HOME", execUser.Home); err != nil {
			return fmt.Errorf("could not set HOME env variable: %w", err)
		}
	}

	return nil
}

func (c *RunCmd) parsePrivileges() (*user.ExecUser, error) {
	defaultExecUser := &user.ExecUser{
		Uid:  syscall.Getuid(),
		Gid:  syscall.Getgid(),
		Home: "/",
	}

	passwdPath, err := user.GetPasswdPath()
	if err != nil {
		return nil, fmt.Errorf("could not determine path of passwd: %w", err)
	}

	groupPath, err := user.GetGroupPath()
	if err != nil {
		return nil, fmt.Errorf("could not determine path of group: %w", err)
	}

	execUser, err := user.GetExecUserPath(c.Privileges, defaultExecUser, passwdPath, groupPath)
	if err != nil {
		return nil, fmt.Errorf("could not resolve user spec [%s]: %w", c.Privileges, err)
	}

	if len(c.Groups) >= 1 {
		execUser.Sgids = c.Groups
		if !containsInt(execUser.Sgids, execUser.Gid) {
			execUser.Sgids = append(execUser.Sgids, execUser.Gid)
		}
	}

	return execUser, nil
}
