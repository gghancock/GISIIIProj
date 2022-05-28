# Set up working directory
setwd("~/UChicago/2022 Spring/GIS III/Project")

# Call necessary packages
library(sf)
library(tidyverse)
library(tidytransit)

# Load in GTFS data
nsw_gtfs <- read_gtfs("~/UChicago/2022 Spring/GIS III/Project/Data/GTFS/full_greater_sydney_gtfs_static.zip")

# Convert GTFS to sf object containing stop locations
nsw_stops <- stops_as_sf(nsw_gtfs$stops)

# Load in project boundary
proj_bound <- st_read("~/UChicago/2022 Spring/GIS III/Project/Data/Proj Boundary/NSWProjBound.shp")

# Ensure crs are the same for both objects
sf::st_crs(nsw_stops) <- 4326
sf::st_crs(proj_bound) <- 4326

# Crop stops to proj area
nsw_proj_stops <- st_intersection(nsw_stops,proj_bound)

# Write stops data to shapefile
write_sf(nsw_proj_stops, "~/UChicago/2022 Spring/GIS III/Project/Data/GTFS/proj_stops.shp")
