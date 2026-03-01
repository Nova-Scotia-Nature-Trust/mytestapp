# Use your base image with R + system deps
FROM rocker/geospatial:4.4.2

# Install system dependencies (as you had)
RUN apt-get update -y && apt-get install -y \
    make pandoc libpq-dev zlib1g-dev libicu-dev libx11-dev \
    libcurl4-openssl-dev libssl-dev cmake libgdal-dev gdal-bin \
    libgeos-dev libpng-dev libproj-dev libsqlite3-dev \
    libudunits2-dev libfontconfig1-dev libfreetype6-dev \
    libfribidi-dev libharfbuzz-dev libjpeg-dev libtiff-dev \
    libwebp-dev libxml2-dev \
 && rm -rf /var/lib/apt/lists/*

# Set R options for faster installs
RUN mkdir -p /usr/local/lib/R/etc/ /usr/lib/R/etc/
RUN echo "options(renv.config.pak.enabled = FALSE, repos = c(CRAN='https://cran.rstudio.com/'), download.file.method='libcurl', Ncpus=4)" \
    | tee /usr/local/lib/R/etc/Rprofile.site \
    | tee /usr/lib/R/etc/Rprofile.site

# Install R tools
RUN R -e 'install.packages("remotes")'
RUN R -e 'remotes::install_version("renv", version = "1.0.11")'

# Restore dependencies from renv.lock
COPY renv.lock /tmp/renv.lock
RUN --mount=type=cache,id=renv-cache,target=/root/.cache/R/renv \
    R -e 'renv::restore(lockfile="/tmp/renv.lock")'

# Copy the package tarball
COPY mytestapp_*.tar.gz /tmp/app.tar.gz

# Install the package
RUN R CMD INSTALL /tmp/app.tar.gz
RUN rm /tmp/app.tar.gz

# Expose Shiny port
EXPOSE 3838

# Run the Shiny app
CMD R -e "options(shiny.port=3838, shiny.host='0.0.0.0'); library(mytestapp); mytestapp::run()"