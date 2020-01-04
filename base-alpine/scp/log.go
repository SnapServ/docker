package main

import (
	"log"
)

type LogCmd struct {
	Message string   `kong:"required,arg,help='Message to print with optional format verbs'"`
	Args    []string `kong:"optional,arg,help='Optional format arguments'"`
}

func (c *LogCmd) Run() error {
	log.Printf(c.Message, stringsToValues(c.Args)...)
	return nil
}
