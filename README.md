# shiny-server-container
Creates a Containerized instance of R's Shiny Server. This image is available on dockerhub. 

## Using This Image
You can start this image with podman like so: 
```
podman run -d --name=shiny-server --rm -p 3838:3838 ucsb/shiny-server:latest
```

The shiny sample apps are installed by default, but you can override them by mapping in your own local directory. This is using all of the default locations, so you need to map your shiny project into the it's own folder or override the `/srv/shiny-server/` directory completely. You can change the shiny-server settings by using a configmap, or replacing `/etc/shiny-server/shiny-server.conf` 
