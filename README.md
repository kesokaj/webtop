````
docker build -t ghcr.io/kesokaj/webtop:v<VERSION> -t ghcr.io/kesokaj/webtop:latest .
docker run -it --privileged  -d -p 8080:8080 -v "$PWD/home:/home" -e SHELL_USER=user -e SHELL_PASSWORD=user ghcr.io/kesokaj/webtop:latest
docker push ghcr.io/kesokaj/webtop --all-tags
````
