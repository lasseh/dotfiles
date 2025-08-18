# SSH Port Forwarding Helper Function
function sshpf() {
    # Display help if no arguments or help flag
    if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo "SSH Port Forwarding Helper"
        echo ""
        echo "Usage: sshpf <remote_host> <remote_port> [local_port]"
        echo ""
        echo "Examples:"
        echo "  sshpf server.com 8080        # Forward server.com:8080 to localhost:8080"
        echo "  sshpf server.com 8080 3000   # Forward server.com:8080 to localhost:3000"
        echo "  sshpf user@server 5432       # Forward PostgreSQL from server to local"
        echo ""
        echo "Options:"
        echo "  -N    Don't execute remote command (just forward)"
        echo "  -f    Run in background"
        echo "  -v    Verbose output"
        return 0
    fi

    local host=$1
    local remote_port=$2
    local local_port=${3:-$remote_port}  # Use same port if not specified
    
    echo "🔗 Forwarding ${host}:${remote_port} → localhost:${local_port}"
    echo "Press Ctrl+C to stop forwarding"
    
    # -L for local port forwarding
    # -N to not execute remote command
    # -T to disable pseudo-terminal allocation
    ssh -L ${local_port}:localhost:${remote_port} -N -T ${host}
}

# List active SSH tunnels
alias sshpf-list='ps aux | grep "ssh -L" | grep -v grep'

# Kill all SSH tunnels
alias sshpf-kill='pkill -f "ssh -L"'