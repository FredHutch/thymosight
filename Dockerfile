FROM fredhutch/r-shiny-base:4.6.0

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION
ARG AWS_SESSION_TOKEN

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib/

RUN apt-get --allow-releaseinfo-change update -y

RUN apt-get install -y curl libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libcairo2-dev cmake build-essential zlib1g-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev libbz2-dev libglpk-dev

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


COPY python-requirements.txt /tmp/
RUN python3.8 -m pip install -r /tmp/python-requirements.txt

RUN rm -rf /tmp/Python-3.8.8

EXPOSE 3838


RUN echo break cache2

RUN R -q -e 'print(.libPaths())'


# RUN R -e "install.packages('renv', repos='https://cran.rstudio.com/')"

# RUN R -e "install.packages(c('readxl', 'arrow', 'feather', 'anndata', 'dichromat', 'dplyr', 'scattermore', 'DT', 'ggplot2', 'ggpubr', 'shiny', 'shinycssloaders', 'shinydashboard', 'shinyWidgets', 'reticulate', 'tibble', 'viridis', 'hrbrthemes', 'sccore', 'RColorBrewer', 'pals'), repos='https://cran.rstudio.com/')"

RUN R -e "install.packages('systemfonts')"

RUN R -e "install.packages('Matrix')"

RUN R -e "install.packages(c('renv', 'ggpubr'))"

RUN R -e "install.packages(c('arrow', 'anndata', 'reticulate', 'sccore'))"


# "arrow", "anndata", "reticulate", "sccore"
# RUN R -e "renv::install('readxl@1.4.0', 'feather@0.3.5', 'dichromat@2.0-0.1', 'dplyr@1.0.10', 'scattermore@0.8', 'DT@0.26', 'ggplot2@3.4.0', 'shiny@1.7.3', 'shinycssloaders@1.0.0', 'shinydashboard@0.7.2', 'shinyWidgets@0.7.4', 'tibble@3.1.8', 'viridis@0.6.2', 'hrbrthemes@0.8.0', 'RColorBrewer@1.1-3', 'pals@1.7', library=.libPaths())"

RUN R -e "install.packages(c('readxl', 'feather', 'dichromat', 'dplyr', 'scattermore', 'DT', 'ggplot2', 'shiny', 'shinycssloaders', 'shinydashboard', 'shinyWidgets', 'tibble', 'viridis', 'hrbrthemes', 'RColorBrewer', 'pals' ))"

# make sure all packages are installed
# because R does not fail when there's an error installing a package.
COPY check.R /tmp/
RUN R -f /tmp/check.R --args renv readxl arrow feather anndata dichromat dplyr scattermore DT ggplot2 ggpubr shiny shinycssloaders shinydashboard shinyWidgets reticulate tibble viridis hrbrthemes sccore RColorBrewer pals

ADD . /app

WORKDIR /app

# get data
RUN mkdir -p data

RUN aws s3 sync s3://fh-pi-dudakov-j-eco/thymosight-data/ data/

CMD R -f app.R
