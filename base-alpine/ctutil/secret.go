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
	envName := sanitizeEnvName(c.Name)
	envDirect := os.Getenv(envName)
	envFile := os.Getenv(envName + "_FILE")

	if envFile != "" {
		contents, err := ioutil.ReadFile(envFile)
		if err != nil {
			return fmt.Errorf("could not read secret [%s] from file [%s]: %w", envName, envFile, err)
		}

		fmt.Print(string(contents))
		return nil
	}

	if envDirect != "" {
		fmt.Printf(envDirect)
		return nil
	}

	return fmt.Errorf("no secret data available for [%s]", envName)
}
