FROM rocker/r-ver:4.0.0

RUN apt-get update && apt-get install -yq \
    libfreetype6-dev \
    libglu1-mesa-dev \
    libnetcdf-dev \
    libpng-dev \
    zlib1g-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN Rscript \
    -e 'install.packages("remotes")' \
    -e 'remotes::install_version("doParallel", version = "1.0.15")' \
    -e 'remotes::install_version("e1071", version = "1.7-3")' \
    -e 'remotes::install_version("foreach", version = "1.5.0")' \
    -e 'remotes::install_version("gbm", version = "2.1.5")' \
    -e 'remotes::install_version("iterators", version = "1.0.12")' \
    -e 'remotes::install_version("MASS", version = "7.3-51.5")' \
    -e 'remotes::install_version("randomForest", version = "4.6-14")' \
    -e 'remotes::install_version("Rcpp", version = "1.0.4")' \
    -e 'remotes::install_version("rgl", version = "0.100.50")' \
    -e 'remotes::install_version("ROCR", version = "1.0-7")' \
    -e 'remotes::install_version("ROCS", version = "1.3")' \
    -e 'remotes::install_version("snow", version = "0.4-3")' \
    -e 'remotes::install_version("BiocManager", version = "1.30.10")' \
    -e 'BiocManager::install(version = "3.11")' \
    -e 'BiocManager::install("mzR")'

RUN Rscript -e 'remotes::install_version("hdf5r", version = "1.3.2")'

ADD apLCMS /apLCMS
RUN R CMD INSTALL /apLCMS \
 && rm -rf /apLCMS
