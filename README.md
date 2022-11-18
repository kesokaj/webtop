````
docker build -t ghcr.io/kesokaj/webtop:v<VERSION> .
docker run -it --privileged  -d -p 8080:8080 -v "$PWD/home:/home" -e SHELL_USER=user -e SHELL_PASSWORD=user ghcr.io/kesokaj/webtop:v<VERSION>
docker push ghcr.io/kesokaj/webtop:v<VERSION>
````
