package tests

import (
	"path/filepath"
	"testing"

	"github.com/jenkins-x/helm-unit-tester/pkg"
	"github.com/jenkins-x/jx/pkg/util"
)

func TestChartsWithDifferentValues(t *testing.T) {
	chart := "../charts/tekton-pipeline"

	cmd := util.Command{
		Name: "helm",
		Args: []string{"version"},
	}
	helmVersion, err := cmd.RunWithoutRetry()
	if err != nil {
		t.Logf("helm not on the PATH so skipping: %s", helmVersion)
		t.SkipNow()
		return
	}

	_, testcases := pkg.RunTests(t, chart, filepath.Join("test_data"))

	for _, tc := range testcases {
		t.Logf("ran test case %s", tc.Name)
	}
}
