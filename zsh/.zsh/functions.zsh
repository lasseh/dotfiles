cd() {
    builtin cd $@
    ls
}

function jcurl() {
    curl -s "$1" | jq
}

function mcom() {
    echo -n -e "\033]0;minicom\007"
    minicom -D $(ls -1 /dev/tty.usbserial-*) | ct
}

function cssh() {
    echo -n -e "\033]0;$@\007"
    /usr/bin/ssh "$@" | ct
}

function rs232() {
    echo -n -e "\033]0;rs232 port ${1}\007"
    ssh username+port${1}@2001:x:x:x:x::b | ct
}

# Network troubleshooting function
function netcheck() {
    local host=${1:-google.com}
    echo "=== Network Connectivity Check for $host ==="
    echo "Ping test:"
    ping -c 3 $host
    echo -e "\nTraceroute:"
    traceroute $host
    echo -e "\nDNS lookup:"
    nslookup $host
}

# Go project setup
function gonew() {
    local name=$1
    if [[ -z $name ]]; then
        echo "Usage: gonew <project-name>"
        return 1
    fi
    mkdir $name && cd $name
    go mod init $name
    echo "package main\n\nimport \"fmt\"\n\nfunc main() {\n    fmt.Println(\"Hello, $name!\")\n}" >main.go
    echo "Created Go project: $name"
}
