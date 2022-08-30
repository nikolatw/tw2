package complete_test

import (
	"fmt"
	"runtime"
	"testing"

	"github.com/nikolatw/taskwire2/pkg/complete"
	"github.com/stretchr/testify/require"
)

func TestComplete(t *testing.T) {
	if runtime.GOOS != "linux" {
		t.Skipf("no tests for %s", runtime.GOOS)
		return
	}

	tests := []struct {
		snippet       string
		mustHaveLinux string
	}{
		{snippet: "gi", mustHaveLinux: "git"},
		{snippet: "go", mustHaveLinux: "gofmt"},
		{snippet: "./com", mustHaveLinux: "./completetest.sh"},
		{snippet: "cp complete_t", mustHaveLinux: "cp complete_test.go"},
		{snippet: "cp complete_test.go comple", mustHaveLinux: "cp complete_test.go complete.go"},
	}

	for _, test := range tests {
		t.Run(fmt.Sprintf("must have %s when search %s", test.mustHaveLinux, test.snippet), func(t *testing.T) {
			if runtime.GOOS == "linux" {
				suggestions, err := complete.Complete("", test.snippet)
				require.NoError(t, err)
				require.NotEmpty(t, suggestions)
				require.Contains(t, suggestions, test.mustHaveLinux)
			}
		})
	}
}
