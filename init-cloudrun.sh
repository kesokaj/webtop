#!/bin/bash
# No set -e — we need the container to stay alive for diagnostics

## Fix PAM limits — Cloud Run doesn't allow setting process limits
sed -i 's/^session.*pam_limits.so/#&/' /etc/pam.d/su /etc/pam.d/su-l 2>/dev/null || true

## Create user
if [ "${SHELL_USER}" ] && [ "${SHELL_PASSWORD}" ]; then
  useradd -rm -d /home/${SHELL_USER} -s /bin/bash -u 666 ${SHELL_USER}
  echo "${SHELL_USER} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
  echo -e "${SHELL_PASSWORD}\n${SHELL_PASSWORD}" | passwd ${SHELL_USER}
else
  echo "SHELL_USER and SHELL_PASSWORD must be set"
  exit 1
fi

## Pre-create dirs that X/KDE expect (must be done as root)
mkdir -p /tmp/.X11-unix /tmp/.ICE-unix
chmod 1777 /tmp/.X11-unix /tmp/.ICE-unix
mkdir -p /tmp/runtime-${SHELL_USER}
chmod 700 /tmp/runtime-${SHELL_USER}
chown ${SHELL_USER}:${SHELL_USER} /tmp/runtime-${SHELL_USER}

## Start system dbus (needed for KDE)
mkdir -p /run/dbus
dbus-daemon --system --fork 2>/dev/null || true

## Create VNC xstartup for KDE
mkdir -p /home/${SHELL_USER}/.vnc
cat > /home/${SHELL_USER}/.vnc/xstartup <<'XSTARTUP'
#!/bin/bash
export XDG_SESSION_TYPE=x11
export XDG_RUNTIME_DIR=/tmp/runtime-$(whoami)
export DISPLAY=:0

# Start a session dbus
eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS

# Start KDE
exec startplasma-x11
XSTARTUP
chmod +x /home/${SHELL_USER}/.vnc/xstartup
chown -R ${SHELL_USER}:${SHELL_USER} /home/${SHELL_USER}/.vnc

## Pre-configure KDE panel with pinned app launchers
mkdir -p /home/${SHELL_USER}/.config
cat > /home/${SHELL_USER}/.config/plasma-org.kde.plasma.desktop-appletsrc <<'PANELCFG'
[ActionPlugins][0]
RightButton;NoModifier=org.kde.contextmenu

[Containments][1]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=4
plugin=org.kde.panel
wallpaperplugin=org.kde.image

[Containments][1][Applets][2]
immutability=1
plugin=org.kde.plasma.kickoff

[Containments][1][Applets][3]
immutability=1
plugin=org.kde.plasma.icontasks

[Containments][1][Applets][3][Configuration][General]
launchers=applications:google-chrome.desktop,applications:org.kde.konsole.desktop,applications:antigravity.desktop,applications:com.microsoft.VSCode.desktop

[Containments][1][Applets][4]
immutability=1
plugin=org.kde.plasma.systemtray

[Containments][1][Applets][5]
immutability=1
plugin=org.kde.plasma.digitalclock

[Containments][1][General]
AppletOrder=2;3;4;5

[Containments][2]
activityId=
formfactor=0
immutability=1
lastScreen=0
location=0
plugin=org.kde.desktopcontainment
wallpaperplugin=org.kde.image
PANELCFG
chown -R ${SHELL_USER}:${SHELL_USER} /home/${SHELL_USER}/.config

## Start noVNC websocket proxy
cp /index.html /usr/share/novnc/index.html
sed -i "s/<title>Webtop<\/title>/<title>${HOSTNAME}<\/title>/g" /usr/share/novnc/index.html
sed -i "s/document.title = \"Webtop\"/document.title = \"${HOSTNAME}\"/g" /usr/share/novnc/index.html
sed -i "s/document.title = \"Webtop (disconnected)\"/document.title = \"${HOSTNAME} (disconnected)\"/g" /usr/share/novnc/index.html
websockify --web=/usr/share/novnc/ 8080 localhost:5900 -D

## Start VNC server — run Xtigervnc directly instead of through vncserver wrapper
# The wrapper has issues with startup detection on Cloud Run.
# Run as user, with xstartup.
echo "=== Starting Xtigervnc directly ==="
su - ${SHELL_USER} -c "
  export DISPLAY=:0
  export HOME=/home/${SHELL_USER}
  
  # Generate xauth cookie
  xauth generate :0 . trusted 2>/dev/null || true
  
  # Start Xtigervnc in background
  /usr/bin/Xtigervnc :0 \
    -rfbport 5900 \
    -localhost=1 \
    -SecurityTypes None \
    -geometry 1920x1200 \
    -depth 24 \
    -auth /home/${SHELL_USER}/.Xauthority \
    -desktop '${HOSTNAME}:0 (${SHELL_USER})' &
  
  XVNC_PID=\$!
  echo \"Xtigervnc PID: \$XVNC_PID\"
  
  # Wait for X to be ready
  for i in 1 2 3 4 5 6 7 8 9 10; do
    if xdpyinfo -display :0 >/dev/null 2>&1; then
      echo \"X server ready after \${i}s\"
      break
    fi
    sleep 1
  done
  
  if ! xdpyinfo -display :0 >/dev/null 2>&1; then
    echo 'ERROR: X server did not start!'
    exit 1
  fi
  
  # Now start the desktop session
  export XDG_SESSION_TYPE=x11
  export XDG_RUNTIME_DIR=/tmp/runtime-${SHELL_USER}
  eval \$(dbus-launch --sh-syntax)
  export DBUS_SESSION_BUS_ADDRESS
  
  echo \"Starting KDE Plasma...\"
  startplasma-x11 &
"

## Wait for KDE to start, then verify
sleep 15
echo "=== Process check ==="
ps aux | grep -E 'plasma|kwin|plasmashell|Xtigervnc' | grep -v grep || echo "WARNING: No KDE processes found!"

## Keep the container alive no matter what
exec tail -f /dev/null
