#!/bin/sh
service rsyslog start
cp /usr/share/novnc/vnc_auto.html /usr/share/novnc/index.html
sed -i 's/<div id="noVNC_status_bar">/<div id="noVNC_status_bar" style="display:none;">/g' /usr/share/novnc/index.html
sed -i "s/('resize', false)/('resize', true)/g" /usr/share/novnc/index.html
sed -i "s/('scale', false)/('scale', true)/g" /usr/share/novnc/index.html
sed -i "s/('title', 'noVNC')/('title', '${HOSTNAME}')/g" /usr/share/novnc/index.html
websockify --web=/usr/share/novnc/ 8080 localhost:5900 &
vncserver $DISPLAY -port 5900 -SecurityTypes None
tail -f /var/log/*