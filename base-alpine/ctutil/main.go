package main

import (
	"log"

	"github.com/alecthomas/kong"
)

var cli struct {
	Account   AccountCmd   `kong:"cmd,help='Create a service account with sane defaults'"`
	Directory DirectoryCmd `kong:"cmd,help='Ensure a directory exists with given attributes'"`
	Exec      ExecCmd      `kong:"cmd,help='Exec into another process, optionally changing privileges'"`
	Log       LogCmd       `kong:"cmd,help='Print a log message with optional format arguments'"`
	Relocate  RelocateCmd  `kong:"cmd,help='Relocate a directory from an old to a new path and add a symlink'"`
	Secret    SecretCmd    `kong:"cmd,help='Read secret from environment, either directly or from file'"`
}

func main() {
	log.SetFlags(log.Ldate | log.Lmicroseconds)

	ctx := kong.Parse(&cli)
	err := ctx.Run()
	ctx.FatalIfErrorf(err)
}
