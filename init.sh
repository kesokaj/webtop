#!/bin/bash
## Start logging
service rsyslog start

## Create user
if [ "${SHELL_USER}" ] && [ "${SHELL_PASSWORD}" ]; then
  useradd -rm -d /home/${SHELL_USER} -s /bin/bash -G sudo,docker -u 666 ${SHELL_USER}
  echo "${SHELL_USER} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
  echo -e "${SHELL_PASSWORD}\n${SHELL_PASSWORD}" | passwd ${SHELL_USER}
else
  exit 1
fi

## Add to subuid & subgid
echo "${SHELL_USER}:666:65536" > /etc/subuid
echo "${SHELL_USER}:666:65536" > /etc/subgid

## Fix docker config
cat << EOF > /etc/docker/daemon.json
{
  "userns-remap": "${SHELL_USER}",
  "data-root": "/home/${SHELL_USER}/.docker"
}
EOF

## Start user services
service ssh start
service docker start

## Start vnc + web
cp /usr/share/novnc/vnc_auto.html /usr/share/novnc/index.html
sed -i 's/<div id="noVNC_status_bar">/<div id="noVNC_status_bar" style="display:none;">/g' /usr/share/novnc/index.html
sed -i "s/('resize', false)/('resize', true)/g" /usr/share/novnc/index.html
sed -i "s/('scale', false)/('scale', true)/g" /usr/share/novnc/index.html
sed -i "s/('title', 'noVNC')/('title', '${HOSTNAME}')/g" /usr/share/novnc/index.html
websockify --web=/usr/share/novnc/ 8080 localhost:5900 -D
su - ${SHELL_USER} -c "vncserver $DISPLAY -port 5900 -SecurityTypes None"

## Set permissions
su - ${SHELL_USER} -c "docker ps" > /dev/null 2>&1 &
sleep 5
chmod -R 755 /home/${SHELL_USER}/.docker

## Start output logging
touch /var/log/auth.log && touch /var/log/user.log
tail -f /dev/stdout -f /dev/stderr -f /var/log/auth.log -f /var/log/user.log
