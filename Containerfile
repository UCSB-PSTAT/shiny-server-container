FROM r-base

# Update the images
RUN apt-get update &&\ 
    apt-get -y upgrade && \
    apt-get -y install \ 
    curl \
    wget \
    xtail \
    gdebi-core \
    build-essential \ 
    libssl-dev \
    gdal-bin \
    libgdal-dev \
    libfontconfig1-dev \
    libcurl4-openssl-dev \
    libudunits2-dev  && \
    apt-get clean

# Install R Packages
RUN R -e "install.packages(c('shiny','shinythemes','maps','mapproj','leaflet','dplyr','sf','sp','flexdashboard','plotly','stringr','knitr'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"

# Install shiny-server deb package
RUN SHINYVER=`curl https://download3.rstudio.org/ubuntu-18.04/x86_64/VERSION` && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-$SHINYVER-amd64.deb" && \
    gdebi -n "shiny-server-$SHINYVER-amd64.deb" && \
    rm -f "shiny-server-$SHINYVER-amd64.deb" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ && \
    mkdir -p /var/log/shiny-server && \
    chown shiny:shiny /var/lib/shiny-server && \
    sed -i 's/listen 3838/listen 3838 0.0.0.0/g' /etc/shiny-server/shiny-server.conf

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]
