package main

import (
	"fmt"
	"html/template"
	"io/ioutil"
	"os"
	"strings"
)

type TemplateContext struct{}

type TemplateCmd struct {
	Templates  map[string]string `kong:"required,arg,placeholder=/SRC:/DST,help='Template paths as key/value pairs in format /src=/dst'"`
	Delimiters []string          `kong:"optional,help='Custom template tag delimiters, defaults to {{ and }}'"`
}

func (c *TemplateCmd) Run() error {
	tmpl := template.New("").Funcs(template.FuncMap{
		"contains": c.contains,
		"default":  c.defaultValue,
		"env":      c.envValue,
	})

	if len(c.Delimiters) == 2 {
		tmpl.Delims(c.Delimiters[0], c.Delimiters[1])
	} else if len(c.Delimiters) != 0 {
		return fmt.Errorf("invalid amount of template tag delimiters, expected 2 got %d", len(c.Delimiters))
	}

	for srcPath, dstPath := range c.Templates {
		if err := c.generate(tmpl, srcPath, dstPath); err != nil {
			return err
		}
	}

	return nil
}

func (c *TemplateCmd) generate(tmpl *template.Template, srcPath, dstPath string) error {
	srcText, err := ioutil.ReadFile(srcPath)
	if err != nil {
		return fmt.Errorf("could not read template from [%s]: %w", srcPath, err)
	}

	srcTmpl, err := tmpl.Parse(string(srcText))
	if err != nil {
		return fmt.Errorf("could not parse template from [%s]: %w", srcPath, err)
	}

	dst := os.Stdout
	if dstPath != "" {
		dst, err = os.Create(dstPath)
		if err != nil {
			return fmt.Errorf("could not create destination path [%s]: %w", dstPath, err)
		}
		defer dst.Close()
	}

	err = srcTmpl.Execute(dst, &TemplateContext{})
	if err != nil {
		return fmt.Errorf("template execution of [%s] failed: %w", srcPath, err)
	}

	return nil
}

func (c *TemplateCmd) contains(items map[string]string, key string) bool {
	if _, ok := items[key]; ok {
		return true
	}

	return false
}

func (c *TemplateCmd) defaultValue(defaultValue, value interface{}) interface{} {
	if truth, ok := template.IsTrue(value); truth && ok {
		return value
	}

	return defaultValue
}

func (c *TemplateCmd) envValue(key, defaultValue string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}

	return defaultValue
}

func (c *TemplateContext) Env() map[string]string {
	env := make(map[string]string)
	for _, value := range os.Environ() {
		parts := strings.SplitN(value, "=", 2)
		if len(parts) == 2 {
			env[parts[0]] = parts[1]
		}
	}

	return env
}
