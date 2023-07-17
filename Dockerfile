FROM fredhutch/r-shiny-base:4.2.0

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION

RUN apt-get --allow-releaseinfo-change update -y

RUN apt-get install -y curl unzip python3-pip libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev


RUN pip install scanpy

EXPOSE 3838



RUN R -e "install.packages(c('dichromat', 'dplyr', 'scattermore', 'DT', 'ggplot2', 'ggpubr', 'shiny', 'shinycssloaders', 'shinydashboard', 'shinyWidgets', 'reticulate', 'tibble', 'viridis', 'hrbrthemes', 'sccore', 'RColorBrewer', 'pals'), repos='https://cran.rstudio.com/')"


# make sure all packages are installed
# because R does not fail when there's an error installing a package.
RUN R -e 'if(!all(commandArgs(TRUE) %in% installed.packages()[,"Package"])) q("no", 1)' --args dichromat dplyr scattermore DT ggplot2 ggpubr shiny shinycssloaders shinydashboard shinyWidgets reticulate tibble viridis hrbrthemes sccore RColorBrewer pals


ADD . /app

WORKDIR /app


CMD R -f app.R

