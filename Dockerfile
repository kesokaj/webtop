FROM debian:stable-slim
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y \
        curl sudo apt-transport-https gnupg net-tools \
        tigervnc-standalone-server xauth tigervnc-common novnc dbus-x11 lightdm \
        task-kde-desktop && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
EXPOSE 8080
ENV DISPLAY :0
COPY init.sh /init.sh
ENTRYPOINT [ "/init.sh" ]
