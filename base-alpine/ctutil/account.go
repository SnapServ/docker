package main

import (
	"fmt"
	"os/exec"
	"strconv"
	"strings"
)

const baseHomePath = "/run/home"

type AccountCmd struct {
	Name string `kong:"required,arg,help='Desired account name'"`
	UID  int    `kong:"optional,short=u,default=-1,placeholder=UID,help='Force specific UID for account'"`
	GID  int    `kong:"optional,short=g,default=-1,placeholder=GID,help='Force specific GID for account'"`
}

func (c *AccountCmd) Run() error {
	userArgs := []string{
		c.Name,
		"-D", "-G", c.Name,
		"-g", strings.ToTitle(c.Name) + " Service Account",
		"-h", baseHomePath + "/" + c.Name,
		"-s", "/sbin/nologin",
	}
	groupArgs := []string{
		c.Name,
	}

	if c.UID != -1 {
		userArgs = append(userArgs, "-u", strconv.Itoa(c.UID))
	}
	if c.GID != -1 {
		groupArgs = append(groupArgs, "-g", strconv.Itoa(c.GID))
	}

	if _, err := exec.Command("addgroup", groupArgs...).Output(); err != nil {
		return fmt.Errorf("call to addgroup failed: %w", enrichExitErr(err))
	}
	if _, err := exec.Command("adduser", userArgs...).Output(); err != nil {
		return fmt.Errorf("call to adduser failed: %w", enrichExitErr(err))
	}
	if err := c.setupHomeDirectory(); err != nil {
		return err
	}

	return nil
}

func (c *AccountCmd) setupHomeDirectory() error {
	baseDirCmd := &DirectoryCmd{
		Path:  baseHomePath,
		Mode:  "0755",
		User:  "root",
		Group: "root",
	}
	if err := baseDirCmd.Run(); err != nil {
		return fmt.Errorf("could not create base home directory: %w", err)
	}

	userDirCmd := &DirectoryCmd{
		Path:  baseHomePath + "/" + c.Name,
		Mode:  "0700",
		User:  c.Name,
		Group: c.Name,
	}
	if err := userDirCmd.Run(); err != nil {
		return fmt.Errorf("could not create home directory: %w", err)
	}

	return nil
}
