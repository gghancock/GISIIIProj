# Set up working directory
setwd("~/UChicago/2022 Spring/GIS III/Project")

# Call necessary packages
library(dplyr)
library(sf)
library(stplanr)
library(raster)
library(slopes)
library(geodist)

# Load in project boundary and transform to proj crs
proj_bound <- st_read("~/UChicago/2022 Spring/GIS III/Project/Data/Proj Boundary/NSWProjBound.shp")
proj_bound <- st_transform(proj_bound, crs = 4283)

# Load in track data and transform to proj crs
nsw_tracks <- st_read("~/UChicago/2022 Spring/GIS III/Project/Data/Tracks/NPWS_TrackSection.shp")
nsw_tracks <- st_transform(nsw_tracks, crs = 4283)

# Clip track data to proj boundary
nsw_tracks_bound <- st_intersection(nsw_tracks, proj_bound)

# Write track data to shapefile (cropped area) for visualisations
write_sf(nsw_tracks_bound, "~/UChicago/2022 Spring/GIS III/Project/Data/Tracks/proj_tracks.shp")

# Convert track data to LINESTRING
nsw_tracks_ls <- st_cast(nsw_tracks_bound, "LINESTRING")

# Load in DEM raster data
dem_nsw = raster::raster("~/UChicago/2022 Spring/GIS III/Project/Data/DEM/NSW_DEM.tif")

# Clip DEM to proj boundary
dem_nsw_bound <- crop(dem_nsw,proj_bound)

# Plot DEM and track data to ensure they are projecting correctly
plot(dem_nsw_bound)
plot(sf::st_geometry(nsw_tracks_bound), add = TRUE) #check if they overlay

# Get slope values for each Section
nsw_tracks_ls$slope = slope_raster(nsw_tracks_ls, dem_nsw_bound)
nsw_tracks_ls$slope = nsw_tracks_ls$slope*100 #percentage
summary(nsw_tracks_ls$slope) #check the values

# Classify slopes
nsw_tracks_ls$slope_class = nsw_tracks_ls$slope %>%
  cut(
    breaks = c(0, 3, 5, 8, 10, 20, Inf),
    labels = c("0-3: flat", "3-5: mild", "5-8: medium", "8-10: hard", 
               "10-20: extreme", ">20: impossible"),
    right = F
  )

# Slope summary
round(prop.table(table(nsw_tracks_ls$slope_class))*100,1)

# Track grades summary
round(prop.table(table(nsw_tracks_bound$d_AssetTyp))*100,1)

# Plot sections and slopes
palredgreen = c("#267300", "#70A800", "#FFAA00", "#E60000", "#A80000", "#730000") #color palette

tmap_mode("view")
tm_shape(nsw_tracks_ls) +
  tm_lines(
    col = "slope_class",
    palette = palredgreen,
    lwd = 2, #line width
    title.col = "Slope [%]",
    popup.vars = c("Length" = "LengthM",
                   "Slope: " = "slope",
                   "Class: " = "slope_class"),
    id = "AssetName")
