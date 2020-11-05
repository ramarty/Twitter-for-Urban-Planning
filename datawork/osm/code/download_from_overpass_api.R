# Download OSM Data from Overpass API

# Overpass API: Extraction -----------------------------------------------------
buildings <- opq("nairobi, kenya") %>% 
  add_osm_feature(key = 'building') %>%
  osmdata_sf()
buildings_points <- buildings$osm_points %>% as("Spatial")
buildings_polygons <- buildings$osm_polygons %>% as("Spatial")

public_transport <- opq ("nairobi, kenya") %>% 
  add_osm_feature(key = 'bus_stop') %>%
  osmdata_sf()
buildings_points <- buildings$osm_points %>% as("Spatial")
buildings_polygons <- buildings$osm_polygons %>% as("Spatial")

buildings_points <- buildings_points[!is.na(buildings_points$name),]
buildings_polygons <- buildings_polygons[!is.na(buildings_polygons$name),]

buildings_points$type <- "building"
buildings_polygons$type <- "building"

buildings_points <- subset(buildings_points, select=c(type, name))
buildings_polygons <- subset(buildings_polygons, select=c(type, name))

buildings_points <- as.data.frame(buildings_points) %>%
  dplyr::rename(lon = coords.x1) %>%
  dplyr::rename(lat = coords.x2)

buildings_polygons_centroid <- gCentroid(buildings_polygons, byid=T) %>% 
  as.data.frame %>%
  dplyr::rename(lon = x) %>%
  dplyr::rename(lat = y)
buildings_polygons <- as.data.frame(buildings_polygons)
buildings_polygons <- cbind(buildings_polygons, buildings_polygons_centroid)

buildings <- bind_rows(buildings_polygons, buildings_points)

# Export -----------------------------------------------------------------------
saveRDS(landmark.df, file.path(osm_dir, "data", "processed_data", "overpass_api_extracts", "buildings.Rds"))
