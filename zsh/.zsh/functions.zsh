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
