package wired_test

import (
	"testing"

	"github.com/nikolatw/taskwire2/pkg/term/wired"
	"github.com/nikolatw/taskwire2/pkg/tree"
	"github.com/stretchr/testify/require"
)

func TestListDir(t *testing.T) {
	resp, err := wired.ListDir([]string{".."})
	require.NoError(t, err)
	require.NotEmpty(t, resp)
	require.IsType(t, tree.FileTree{}, resp)

	tree := resp.(tree.FileTree)

	require.NotNil(t, tree.Stats)
	require.Contains(t, tree.Childs, "custom.go")
	require.Contains(t, tree.Childs, "term.go")
	require.NotContains(t, tree.Childs, "")

	require.Contains(t, tree.Childs, "wired")
	require.NotNil(t, tree.Childs["wired"].Stats)
	require.Contains(t, tree.Childs["wired"].Childs, "ls_test.go")
	require.NotContains(t, tree.Childs["wired"].Childs, "")

	require.NotNil(t, tree.Childs["wired"].Childs["ls_test.go"].Stats)
	require.NotNil(t, tree.Childs["wired"].Childs["ls_test.go"].Stats.Time)
	require.NotZero(t, tree.Childs["wired"].Childs["ls_test.go"].Stats.Time)
	require.NotEmpty(t, tree.Childs["wired"].Childs["ls_test.go"].Stats.Mod)
}
