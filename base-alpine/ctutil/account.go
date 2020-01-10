package main

import (
	"fmt"
	"os/exec"
	"os/user"
	"strconv"
	"strings"
)

const baseHomePath = "/home"

type AccountCmd struct {
	Name string `kong:"required,arg,help='Desired account name'"`
	Home string `kong:"optional,short=h,help='Path to home directory for user'"`
	UID  int    `kong:"optional,short=u,default=-1,placeholder=UID,help='Force specific UID for account'"`
	GID  int    `kong:"optional,short=g,default=-1,placeholder=GID,help='Force specific GID for account'"`
}

func (c *AccountCmd) Run() error {
	userArgs := []string{
		c.Name,
		"-D", "-G", c.Name,
		"-g", strings.ToTitle(c.Name) + " Service Account",
		"-h", c.Home,
		"-s", "/sbin/nologin",
	}
	groupArgs := []string{
		c.Name,
	}

	if _, err := user.Lookup(c.Name); err == nil {
		if _, err := exec.Command("deluser", c.Name).Output(); err != nil {
			return fmt.Errorf("could not remove existing user: %w", enrichExitErr(err))
		}
	}

	if _, err := user.LookupGroup(c.Name); err == nil {
		if _, err := exec.Command("delgroup", c.Name).Output(); err != nil {
			return fmt.Errorf("could not remove existing group: %w", enrichExitErr(err))
		}
	}

	if c.UID != -1 {
		userArgs = append(userArgs, "-u", strconv.Itoa(c.UID))
	}
	if c.GID != -1 {
		groupArgs = append(groupArgs, "-g", strconv.Itoa(c.GID))
	}
	if c.Home != "" {
		userArgs = append(userArgs, "-h", c.Home)
	} else {
		userArgs = append(userArgs, "-h", baseHomePath+"/"+c.Name)
	}

	if _, err := exec.Command("addgroup", groupArgs...).Output(); err != nil {
		return fmt.Errorf("call to addgroup failed: %w", enrichExitErr(err))
	}
	if _, err := exec.Command("adduser", userArgs...).Output(); err != nil {
		return fmt.Errorf("call to adduser failed: %w", enrichExitErr(err))
	}

	if c.Home == "" {
		if err := c.setupHomeDirectory(); err != nil {
			return err
		}
	}

	return nil
}

func (c *AccountCmd) setupHomeDirectory() error {
	baseDirCmd := &DirectoryCmd{
		Paths: []string{baseHomePath},
		Mode:  "0755",
		User:  "root",
		Group: "root",
	}
	if err := baseDirCmd.Run(); err != nil {
		return fmt.Errorf("could not create base home directory: %w", err)
	}

	userDirCmd := &DirectoryCmd{
		Paths: []string{baseHomePath + "/" + c.Name},
		Mode:  "0700",
		User:  c.Name,
		Group: c.Name,
	}
	if err := userDirCmd.Run(); err != nil {
		return fmt.Errorf("could not create home directory: %w", err)
	}

	return nil
}
