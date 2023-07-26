FROM fredhutch/r-shiny-base:4.2.2

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib/

RUN apt-get --allow-releaseinfo-change update -y

RUN apt-get install -y curl libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libcairo2-dev cmake build-essential zlib1g-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev libbz2-dev

RUN curl -LO https://www.python.org/ftp/python/3.8.8/Python-3.8.8.tgz
RUN tar -xf Python-3.8.8.tgz
RUN rm Python-3.8.8.tgz

WORKDIR  Python-3.8.8

RUN ./configure --enable-optimizations --enable-shared

RUN make -j `nproc`

RUN make altinstall

RUN python3.8 -m ensurepip

# RUN python3.8 -m pip install scanpy awscli
# RUN python3.8 -m pip install numpy==1.24

ADD . /app

WORKDIR /app


RUN python3.8 -m pip install -e python-requirements.txt

RUN rm -rf /tmp/Python-3.8.8

EXPOSE 3838


RUN echo break cache2

RUN R --vanilla -q -e 'print(.libPaths())'



RUN R --vanilla -e "install.packages(c('readxl', 'arrow', 'feather', 'anndata', 'dichromat', 'dplyr', 'scattermore', 'DT', 'ggplot2', 'ggpubr', 'shiny', 'shinycssloaders', 'shinydashboard', 'shinyWidgets', 'reticulate', 'tibble', 'viridis', 'hrbrthemes', 'sccore', 'RColorBrewer', 'pals'), repos='https://cran.rstudio.com/')"





# make sure all packages are installed
# because R does not fail when there's an error installing a package.
RUN R --vanilla -f check.R --args readxl arrow feather anndata dichromat dplyr scattermore DT ggplot2 ggpubr shiny shinycssloaders shinydashboard shinyWidgets reticulate tibble viridis hrbrthemes sccore RColorBrewer pals

# get data
RUN mkdir data

RUN aws s3 sync s3://fh-pi-dudakov-j-eco/thymosight-data/ data/

CMD R --vanilla -f app.R
