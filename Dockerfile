FROM fredhutch/r-shiny-base:4.2.0

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION

RUN apt-get --allow-releaseinfo-change update -y

RUN apt-get install -y curl python3-pip libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libcairo2-dev cmake


RUN pip install --break-system-packages scanpy

EXPOSE 3838

# TODO remove this:
RUN echo break cache0

RUN R -e "install.packages(c('feather', 'anndata', 'dichromat', 'dplyr', 'scattermore', 'DT', 'ggplot2', 'ggpubr', 'shiny', 'shinycssloaders', 'shinydashboard', 'shinyWidgets', 'reticulate', 'tibble', 'viridis', 'hrbrthemes', 'sccore', 'RColorBrewer', 'pals'), repos='https://cran.rstudio.com/')"


# make sure all packages are installed
# because R does not fail when there's an error installing a package.
RUN R --vanilla -e 'if(!all(commandArgs(TRUE) %in% installed.packages()[,"Package"])) q("no", 1)' --args feather anndata dichromat dplyr scattermore DT ggplot2 ggpubr shiny shinycssloaders shinydashboard shinyWidgets reticulate tibble viridis hrbrthemes sccore RColorBrewer pals


ADD . /app

WORKDIR /app


CMD R --vanilla -f app.R

