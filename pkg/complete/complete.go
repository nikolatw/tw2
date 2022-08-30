package complete

import (
	"os"
	"runtime"
	"strings"

	"github.com/mpvl/unique"
	"github.com/nikolatw/taskwire2/pkg/term"
)

const (
	winPath   = `C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem`
	linuxPath = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
	macPath   = "/usr/bin:/bin:/usr/sbin:/sbin"
)

func Complete(termID, snippet string) ([]string, error) {
	t, err := term.GetTerm(termID)
	if err != nil {
		return nil, err
	}

	snippet = strings.TrimSpace(snippet)

	suggestions := make([]string, 0)

	if strings.Contains(snippet, " ") {
		args := strings.Split(snippet, " ")

		files, err := os.ReadDir(".")
		if err != nil {
			return nil, err
		}

		snippetStart := strings.Join(args[:len(args)-1], " ") + " "

		for _, f := range files {
			if strings.HasPrefix(f.Name(), args[len(args)-1]) {
				suggestions = append(suggestions, snippetStart+f.Name())
			}
		}
	} else {
		if strings.HasPrefix(snippet, "./") {
			localSuggestions := appendFromPath(".", "", strings.TrimPrefix(snippet, "./"), suggestions)
			for _, s := range localSuggestions {
				suggestions = append(suggestions, "./"+s)
			}
		} else {
			suggestions = appendPathBinaries(t, snippet, suggestions)
		}
	}

	unique.Strings(&suggestions)

	return suggestions, nil
}

func appendPathBinaries(t *term.TerminalModel, snippet string, suggestions []string) []string {
	t.Lock.Lock()
	defer t.Lock.Unlock()
	envPath := t.Shell.Env.Get("PATH").Str

	delimeter := ":"

	switch runtime.GOOS {
	case "windows":
		delimeter = ";"
		userprofile := t.Shell.Env.Get("USERPROFILE").Str
		envPath = winPath + delimeter + envPath
		envPath = strings.ReplaceAll(envPath, `%USERPROFILE%`, userprofile)
	case "linux", "netbsd", "openbsd":
		envPath = envPath + delimeter + linuxPath
	case "darwin":
		envPath = envPath + delimeter + macPath
	}

	suggestions = appendFromPath(envPath, delimeter, snippet, suggestions)

	return suggestions
}

func appendFromPath(envPath string, delimeter string, snippet string, suggestions []string) []string {
	paths := strings.Split(envPath, delimeter)
	for _, path := range paths {
		binaries, _ := os.ReadDir(path)
		for _, binary := range binaries {
			if binary.IsDir() {
				continue
			}

			info, _ := binary.Info()
			if info.Mode()&0o111 == 0 {
				continue
			}

			if strings.HasPrefix(binary.Name(), snippet) {
				suggestions = append(suggestions, binary.Name())
			}
		}
	}

	return suggestions
}
