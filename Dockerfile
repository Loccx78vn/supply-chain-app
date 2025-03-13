# Base R Shiny image
FROM rocker/shiny:latest

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory for the application
WORKDIR /home/shiny-app

# Install Renv
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

# Copy Renv files first to leverage Docker caching
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

# Restore R dependencies (this installs the required R packages)
RUN R -e "renv::restore()"

# Copy the Shiny app code into the container
COPY . /home/shiny-app/

# Expose the port that Shiny uses (default: 3838)
EXPOSE 3838

# Run the Shiny app - using JSON array format for better signal handling
CMD ["R", "-e", "shiny::runApp('/home/shiny-app', host = '0.0.0.0', port = 3838)"]
