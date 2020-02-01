package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

type ElfDepsCmd struct {
	Path string `kong:"required,arg,help='Path to directory which should be scanned'"`
}

func (c *ElfDepsCmd) Run() error {
	args := []string{"--needed", "--nobanner", "--format", "%n#p", "--recursive", c.Path}
	output, err := exec.Command("scanelf", args...).Output()
	if err != nil {
		return fmt.Errorf("could not execute scanelf: %w", enrichExitErr(err))
	}

	allDeps := uniqueStrings(strings.Split(strings.ReplaceAll(string(output), ",", "\n"), "\n"))
	systemDeps := make([]string, 0)

	for _, dep := range allDeps {
		if dep == "" {
			continue
		}

		if _, err := os.Stat("/usr/local/lib/" + dep); os.IsNotExist(err) {
			systemDeps = append(systemDeps, dep)
		}
	}

	fmt.Println(strings.Join(systemDeps, "\n"))
	return nil
}
