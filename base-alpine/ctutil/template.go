package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"reflect"
	"strconv"
	"strings"
	"text/template"
)

type TemplateContext struct{}

type TemplateCmd struct {
	Templates  map[string]string `kong:"required,arg,placeholder=/SRC:/DST,help='Template paths as key/value pairs in format /src=/dst'"`
	Delimiters []string          `kong:"optional,help='Custom template tag delimiters, defaults to {{ and }}'"`
}

func (c *TemplateCmd) Run() error {
	tmpl := template.New("").Funcs(template.FuncMap{
		"contains":  c.contains,
		"default":   c.defaultValue,
		"env":       c.envValue,
		"quote":     c.quote,
		"split":     c.split,
		"ternary":   c.ternary,
		"toBool":    c.toBool,
		"trim":      c.trim,
		"trimSpace": c.trimSpace,
	}).Option("missingkey=error")

	if len(c.Delimiters) == 2 {
		tmpl.Delims(c.Delimiters[0], c.Delimiters[1])
	} else if len(c.Delimiters) != 0 {
		return fmt.Errorf("invalid amount of template tag delimiters, expected 2 got %d", len(c.Delimiters))
	}

	for srcPath, dstPath := range c.Templates {
		if err := c.run(tmpl, srcPath, dstPath); err != nil {
			return err
		}
	}

	return nil
}

func (c *TemplateCmd) run(tmpl *template.Template, srcPath, dstPath string) error {
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

func (c *TemplateCmd) quote(value string) string {
	return fmt.Sprintf("%q", value)
}

func (c *TemplateCmd) ternary(trueValue, falseValue, condition interface{}) interface{} {
	if truth, ok := template.IsTrue(condition); truth && ok {
		return trueValue
	}

	return falseValue
}

func (c *TemplateCmd) split(separator, value string) []string {
	result := strings.Split(value, separator)
	if len(result) == 1 && result[0] == "" {
		return []string{}
	}

	return result
}

func (c *TemplateCmd) toBool(value interface{}) bool {
	if b, ok := value.(bool); ok {
		return b
	}

	if s, ok := value.(string); ok {
		if b, err := strconv.ParseBool(s); err == nil {
			return b
		} else {
			return false
		}
	}

	refValue := reflect.Indirect(reflect.ValueOf(value))
	switch refValue.Kind() {
	case reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64, reflect.Int:
		return refValue.Int() == 1
	case reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64, reflect.Uint:
		return refValue.Uint() == 1
	case reflect.Float32, reflect.Float64:
		return refValue.Float() == 1
	}

	return false
}

func (c *TemplateCmd) trim(cutset string, value interface{}) (interface{}, error) {
	if strSlice, ok := value.([]string); ok {
		result := make([]string, 0, len(strSlice))
		for _, str := range strSlice {
			result = append(result, strings.Trim(str, cutset))
		}
		return result, nil
	}

	if str, ok := value.(string); ok {
		return strings.Trim(str, cutset), nil
	}

	return nil, fmt.Errorf("unsupported argument type %T for value: %+v", value, value)
}

func (c *TemplateCmd) trimSpace(value interface{}) (interface{}, error) {
	if strSlice, ok := value.([]string); ok {
		result := make([]string, 0, len(strSlice))
		for _, str := range strSlice {
			result = append(result, strings.TrimSpace(str))
		}
		return result, nil
	}

	if str, ok := value.(string); ok {
		return strings.TrimSpace(str), nil
	}

	return nil, fmt.Errorf("unsupported argument type [%T] for value: %+v", value, value)
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
