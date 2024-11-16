#!/bin/bash

function displaytime {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( $D > 0 )) && printf '%d days ' $D
  (( $H > 0 )) && printf '%d hours ' $H
  (( $M > 0 )) && printf '%d minutes ' $M
  (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
  printf '%d seconds\n' $S
}

start=$(date +%s)

export DEBIAN_FRONTEND=noninteractive

apt update -y

if [ -z "$TMUX" ]; then
  apt install -y tmux
  tmux new-session -A -s setup "$0"
  exit 0
fi

apt full-upgrade -y
apt install -y kali-desktop-xfce
apt install -y kali-tools-top10
apt install -y openvpn
apt install -y tigervnc-standalone-server
apt install -y tigervnc-xorg-extension
apt install -y smbmap
apt install -y impacket-scripts
apt install -y pypykatz
apt autoremove -y

cat > /etc/hosts <<'EOF'
# /etc/hosts
127.0.0.1	kali localhost

# The following lines are desirable for IPv6 capable hosts
::1		localhost ip6-localhost ip6-loopback
ff02::1		ip6-allnodes
ff02::2		ip6-allrouters
EOF

if [ ! -f "/root/.vnc/passwd" ]; then
  vncpasswd
fi

cat > /root/.vnc/xstartup <<'EOF'
exec startxfce4
EOF

chmod +x /root/.vnc/xstartup

vncserver -localhost yes :1

end=$(date +%s)
displaytime "$(($end-$start))"

bash -i
