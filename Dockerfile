FROM fredhutch/r-shiny-base:4.2.0

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION

RUN apt-get --allow-releaseinfo-change update -y

RUN apt-get install -y curl python3-pip libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libcairo2-dev cmake

RUN pip install --break-system-packages scanpy

# workaround: https://stackoverflow.com/a/72469586/470769
RUN pip install --break-system-packages pip==21.3.1

RUN pip install awscli

EXPOSE 3838


RUN echo break cache2

RUN R --vanilla -q -e 'print(.libPaths())'



RUN R --vanilla -e "install.packages(c('feather', 'anndata', 'dichromat', 'dplyr', 'scattermore', 'DT', 'ggplot2', 'ggpubr', 'shiny', 'shinycssloaders', 'shinydashboard', 'shinyWidgets', 'reticulate', 'tibble', 'viridis', 'hrbrthemes', 'sccore', 'RColorBrewer', 'pals'), repos='https://cran.rstudio.com/')"


ADD . /app

WORKDIR /app

# make sure all packages are installed
# because R does not fail when there's an error installing a package.
RUN R --vanilla -f check.R --args feather anndata dichromat dplyr scattermore DT ggplot2 ggpubr shiny shinycssloaders shinydashboard shinyWidgets reticulate tibble viridis hrbrthemes sccore RColorBrewer pals

# get data
RUN mkdir data

RUN aws s3 sync s3://fh-pi-dudakov-j-eco/thymosight-data/ data/

CMD R --vanilla -f app.R
