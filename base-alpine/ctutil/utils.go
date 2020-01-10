package main

import (
	"errors"
	"fmt"
	"github.com/opencontainers/runc/libcontainer/user"
	"os/exec"
	"strconv"
	"strings"
)

func containsIntSlice(haystack, needle []int) bool {
	for _, value := range needle {
		if !containsInt(haystack, value) {
			return false
		}
	}

	return true
}

func containsInt(haystack []int, needle int) bool {
	for _, value := range haystack {
		if value == needle {
			return true
		}
	}

	return false
}

func resolveUserGroup(userSpec, groupSpec string) (uid, gid int, err error) {
	uid, err = resolveUser(userSpec)
	if err != nil {
		return
	}

	gid, err = resolveGroup(groupSpec)
	if err != nil {
		return
	}

	return
}

func resolveUser(userSpec string) (int, error) {
	if userSpec == "" {
		return -1, nil
	}

	if uid, err := strconv.Atoi(userSpec); err == nil {
		return uid, nil
	}

	if usr, err := user.LookupUser(userSpec); err == nil {
		return usr.Uid, nil
	} else {
		return -1, fmt.Errorf("could not lookup user [%s]: %w", userSpec, err)
	}
}

func resolveGroup(groupSpec string) (int, error) {
	if groupSpec == "" {
		return -1, nil
	}

	if gid, err := strconv.Atoi(groupSpec); err == nil {
		return gid, nil
	}

	if grp, err := user.LookupGroup(groupSpec); err == nil {
		return grp.Gid, nil
	} else {
		return -1, fmt.Errorf("could not lookup group [%s]: %w", groupSpec, err)
	}
}

func stringsToValues(strings []string) []interface{} {
	values := make([]interface{}, 0, len(strings))
	for _, arg := range strings {
		if b, err := strconv.ParseBool(arg); err == nil {
			values = append(values, b)
		} else if i, err := strconv.ParseInt(arg, 10, 64); err == nil {
			values = append(values, i)
		} else if u, err := strconv.ParseUint(arg, 10, 64); err == nil {
			values = append(values, u)
		} else if f, err := strconv.ParseFloat(arg, 64); err == nil {
			values = append(values, f)
		} else {
			values = append(values, arg)
		}
	}

	return values
}

func sanitizeEnvName(name string) string {
	name = strings.ToUpper(strings.ReplaceAll(name, "-", "_"))
	name = reEnvName.ReplaceAllString(name, "")
	return name
}

func enrichExitErr(err error) error {
	var exitErr *exec.ExitError
	if errors.As(err, &exitErr) {
		return fmt.Errorf("%w: %s", exitErr, exitErr.Stderr)
	}

	return err
}
