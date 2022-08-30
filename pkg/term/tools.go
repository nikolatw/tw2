package term

import (
	"fmt"
	"os"
	"os/user"
	"strings"

	"mvdan.cc/sh/v3/interp"
)

var colors map[string]string = map[string]string{
	"</>":      "\x1B[0m",
	"<black>":  "\x1B[0;30m",
	"<red>":    "\x1B[0;31m",
	"<green>":  "\x1B[0;32m",
	"<yellow>": "\x1B[0;33m",
	"<blue>":   "\x1B[0;34m",
	"<purple>": "\x1B[0;35m",
	"<cyan>":   "\x1B[0;36m",
	"<white>":  "\x1B[0;37m",
}

func Format(s string) string {
	for tag, color := range colors {
		s = strings.ReplaceAll(s, tag, color)
	}
	return s
}

func BuildPrompt(tm *TerminalModel) string {
	prompt := strings.Builder{}

	user, err := user.Current()
	if err == nil {
		prompt.WriteString("<cyan>")
		prompt.WriteString(user.Username)
		host, err := os.Hostname()
		if err == nil {
			prompt.WriteString("@")
			prompt.WriteString(host)
		}
		prompt.WriteString(" </>")
	}

	prompt.WriteString("<blue>")
	prompt.WriteString(collapseDir(tm.Shell))
	prompt.WriteString("</>")

	if tm.LastExitCode == 0 {
		prompt.WriteString(" <green>")
		fmt.Fprintf(&prompt, "%d", tm.LastExitCode)
		prompt.WriteString("</>")
	} else {
		prompt.WriteString(" <red>")
		fmt.Fprintf(&prompt, "%d", tm.LastExitCode)
		prompt.WriteString("</>")
	}

	prompt.WriteString(" $ ")

	return Format(prompt.String())
}

func collapseDir(sh *interp.Runner) string {
	cwd := sh.Dir

	user, err := user.Current()
	if err == nil {
		if strings.HasPrefix(cwd, user.HomeDir) {
			cwd = "~/" + strings.TrimPrefix(cwd, user.HomeDir)
		}
	}

	if strings.Contains(cwd, "\\") {
		cwd = strings.ReplaceAll(cwd, "\\", "/")

		if strings.Contains(cwd, ":/") {
			withDiskInfo := strings.SplitN(cwd, ":/", 2)
			cwd = "DISK<" + withDiskInfo[0] + ">/" + withDiskInfo[1]
		}
	}

	cwd = strings.ReplaceAll(cwd, "//", "/")

	if strings.Count(cwd, "/") > 3 {
		path := strings.Split(cwd, "/")
		cwd = ""

		for i, v := range path {
			if i > len(path)-1 {
				continue
			}
			cwd = cwd + "/" + string([]rune(v)[0])
		}

		cwd = cwd + "/" + path[len(path)-1] + "/"
	}

	return strings.Trim(cwd, "/")
}
