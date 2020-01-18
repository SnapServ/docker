package main

import (
	"fmt"
	"io/ioutil"
	"os"
)

type SecretCmd struct {
	Name string `kong:"required,arg,help='Name of secret'"`
}

func (c *SecretCmd) Run() error {
	result, err := c.resolve()
	if err != nil {
		return err
	}

	fmt.Print(result)
	return nil
}

func (c *SecretCmd) resolve() (string, error) {
	envName := sanitizeEnvName(c.Name)

	if envFile, ok := os.LookupEnv(envName + "_FILE"); ok {
		contents, err := ioutil.ReadFile(envFile)
		if err != nil {
			return "", fmt.Errorf("could not read secret [%s] from file [%s]: %w", envName, envFile, err)
		}

		return string(contents), nil
	}

	if envDirect, ok := os.LookupEnv(envName); ok {
		return envDirect, nil
	}

	return "", fmt.Errorf("no secret data available for [%s]", envName)
}
