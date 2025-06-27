#!/opt/homebrew/bin/bash
set -eo pipefail

# Path to your Go bin directory
GOBIN="${GOBIN:-$(go env GOPATH)/bin}"
if [[ -z "$GOBIN" ]]; then
    GOBIN="$(go env GOBIN)"
fi

# toolname => module path
declare -A TOOL_MODULES=(
    [air]="github.com/air-verse/air"
    [cobra]="github.com/spf13/cobra/cobra"
    [dlv]="github.com/go-delve/delve/cmd/dlv"
    [go - cleanarch]="github.com/roblaszczak/go-cleanarch"
    [go - outline]="github.com/ramya-rao-a/go-outline"
    [gocritic]="github.com/go-critic/go-critic/cmd/gocritic"
    [gofumpt]="mvdan.cc/gofumpt"
    [goimports]="golang.org/x/tools/cmd/goimports"
    [golines]="github.com/segmentio/golines"
    [gomodifytags]="github.com/fatih/gomodifytags"
    [gonew]="golang.org/x/tools/cmd/gonew"
    [gopls]="golang.org/x/tools/gopls"
    [gotests]="github.com/cweill/gotests/..."
    [govulncheck]="golang.org/x/vuln/cmd/govulncheck"
    [gowitness]="github.com/sensepost/gowitness"
    [nvcat]="https://github.com/brianhuster/nvcat"
    [staticcheck]="honnef.co/go/tools/cmd/staticcheck"
)

echo "🔍 Found tools in $GOBIN:"
for tool in "$GOBIN"/*; do
    [[ -f "$tool" ]] || continue
    toolname=$(basename "$tool")

    echo " - $toolname"

    module="${TOOL_MODULES[$toolname]:-}"
    if [[ -n "$module" ]]; then
        echo "   ↪️  Updating $toolname from $module..."
        go install "$module@latest"
    else
        echo "   ⚠️  No module path set for $toolname. Please add it to the TOOL_MODULES map."
    fi
done

echo "✅ Done updating Go tools."
