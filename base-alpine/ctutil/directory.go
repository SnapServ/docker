package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"syscall"
)

type DirectoryCmd struct {
	Paths   []string `kong:"required,arg,help='Path to directory, can be specified multiple times'"`
	Mode    string   `kong:"optional,default=0755,short=m,help='Ensure directory has given octal mode'"`
	User    string   `kong:"optional,short=u,help='Ensure directory is owned by user id'"`
	Group   string   `kong:"optional,short=g,help='Ensure directory is owned by group id'"`
	Parents bool     `kong:"optional,default=true,short=p,help='Create missing parent directories'"`
}

func (c *DirectoryCmd) Run() error {
	for _, path := range c.Paths {
		if err := c.run(path); err != nil {
			return err
		}
	}

	return nil
}

func (c *DirectoryCmd) run(path string) error {
	mode, err := strconv.ParseUint(c.Mode, 8, 32)
	if err != nil {
		return fmt.Errorf("could not parse mode [%s] as octal: %w", c.Mode, err)
	}

	if c.Parents {
		parentPath := filepath.Dir(path)
		if _, err := os.Stat(parentPath); os.IsNotExist(err) {
			if err := c.run(parentPath); err != nil {
				return err
			}
		}
	}

	if err := os.Mkdir(path, os.FileMode(mode)); err != nil && !os.IsExist(err) {
		return fmt.Errorf("could not create directory [%s] recursively: %w", path, err)
	}

	stat, err := os.Stat(path)
	if err != nil {
		return fmt.Errorf("could not stat created directory [%s]: %w", path, err)
	}
	sys, sysOk := stat.Sys().(*syscall.Stat_t)

	if !sysOk || sys.Mode != uint32(mode) {
		if err := syscall.Chmod(path, uint32(mode)); err != nil {
			return fmt.Errorf("could not set mode for directory [%s]: %w", path, err)
		}
	}

	uid, gid, err := resolveUserGroup(c.User, c.Group)
	if err != nil {
		return fmt.Errorf("could not lookup owner: %w", err)
	}

	if (uid != -1 || gid != -1) && (!sysOk || sys.Uid != uint32(uid) || sys.Gid != uint32(gid)) {
		if err := syscall.Chown(path, uid, gid); err != nil {
			return fmt.Errorf("could not change owner of [%s] to [%d:%d]: %w", path, uid, gid, err)
		}
	}

	return nil
}
