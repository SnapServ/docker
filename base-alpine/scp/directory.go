package main

import (
	"fmt"
	"os"
	"strconv"
	"syscall"
)

type DirectoryCmd struct {
	Path  string `kong:"required,arg,help='Path to directory'"`
	Mode  string `kong:"optional,default=0755,short=m,help='Ensure directory has given octal mode'"`
	User  string `kong:"optional,short=u,help='Ensure directory is owned by user id'"`
	Group string `kong:"optional,short=g,help='Ensure directory is owned by group id'"`
}

func (c *DirectoryCmd) Run() error {
	mode, err := strconv.ParseUint(c.Mode, 8, 32)
	if err != nil {
		return fmt.Errorf("could not parse mode [%s] as octal: %w", c.Mode, err)
	}

	if err := os.MkdirAll(c.Path, os.FileMode(mode)); err != nil {
		return fmt.Errorf("could not create directory [%s] recursively: %w", c.Path, err)
	}

	if err := syscall.Chmod(c.Path, uint32(mode)); err != nil {
		return fmt.Errorf("could not set mode for directory [%s]: %w", c.Path, err)
	}

	uid, gid, err := resolveUserGroup(c.User, c.Group)
	if err != nil {
		return fmt.Errorf("could not lookup owner: %w", err)
	}

	if uid != -1 || gid != -1 {
		if err := syscall.Chown(c.Path, uid, gid); err != nil {
			return fmt.Errorf("could not change owner of [%s] to [%d:%d]: %w", c.Path, uid, gid, err)
		}
	}

	return nil
}
