# shiny-server-container
This image has been archived. Creates a Containerized instance of RStudio's opensource [Shiny Server](https://www.rstudio.com/products/shiny/shiny-server/). 
This image is [available on dockerhub](https://hub.docker.com/r/ucsb/shiny-server). 

## Using This Image
You can start this image with podman like so: 
```
podman run -d --name=shiny-server --rm -p 3838:3838 ucsb/shiny-server:latest
```
You can test that the container is running by visiting http:/localhost:3838.  This is suitable for local testing, but should minimally be TLS proxied.

You can change the [shiny-server settings](https://docs.rstudio.com/shiny-server/#default-configuration) by volume mounting it to `/etc/shiny-server/shiny-server.conf` on `podman run`.  If running in Kubernetes, this can be provided mounted via ConfigMap.

The shiny sample apps are installed by default, but you can override them by mapping in your own local directory. 
This is using all of the default locations, so you need to map your shiny project into the it's own folder or override the `/srv/shiny-server/` directory completely. An example of how you might do that would be: 
```
podman run -d --name=shiny-server \
              -p 3838:3838 \
              -v /path/to/shiny-server.conf:etc/shiny-server/shiny-server.conf \
              -v /opt/myshinyapp:/srv/shiny-server \
              ucsb/shiny-server:latest
```
This should replace the example apps with just your local app. When you make changes to your local files in `/opt/myshinyapp` they should get updated on the webpage getting served at http://localhost:3838.  

Adding a folders inside the folder you mount into the container would change the url. 
For example: if you had `/opt/myshinyapp/app1` and `/opt/myshinyapp/app2`, you could view them at http://localhost:3838/app1 and http://localhost:3838/app2 

