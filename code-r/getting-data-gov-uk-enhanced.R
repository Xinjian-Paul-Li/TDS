# Enhanced tidyverse version of getting data from UK gov sources
library(tidyverse)
library(sf)
library(mapview)

# First stage: search and data acquisition
# URL for the data source
data_url <- "https://datamillnorth.org/download/bring-sites/97bd60ae-ced3-4ddc-996e-f1ebe5d21136/tonnage%20to%20Sept%2020.csv"

# Read data with better error handling and column specification
waste_sites_raw <- read_csv(
  data_url,
  locale = locale(encoding = "UTF-8"),
  na = c("", "NA", "N/A", "NULL"),
  show_col_types = FALSE
) %>%
  # Clean column names immediately after reading
  janitor::clean_names()

# Explore the data structure
waste_sites_raw %>%
  glimpse()

# Enhanced data cleaning pipeline
waste_sites_clean <- waste_sites_raw %>%
  # Remove rows with missing coordinates
  filter(!is.na(longitude), !is.na(latitude)) %>%
  # Remove invalid coordinates (basic validation)
  filter(
    between(longitude, -8, 2),    # Rough UK longitude bounds
    between(latitude, 49, 61)     # Rough UK latitude bounds
  ) %>%
  # Group by location and calculate totals
  group_by(site_name, longitude, latitude) %>%
  summarise(
    tonnes_glass_total = sum(
      c_across(contains("glass_tonnage")), 
      na.rm = TRUE
    ),
    n_records = n(),
    .groups = "drop"
  ) %>%
  # Filter out sites with no glass tonnage
  filter(tonnes_glass_total > 0) %>%
  # Arrange by tonnage (largest first)
  arrange(desc(tonnes_glass_total))

# Convert to spatial data
waste_sites_sf <- waste_sites_clean %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# View the cleaned data
waste_sites_sf %>%
  slice_head(n = 10) %>%
  select(site_name, tonnes_glass_total, n_records)

# Interactive map
mapview(waste_sites_sf, zcol = "tonnes_glass_total")

# Filter to Leeds region using spatial operations
pct_regions <- pct::pct_regions

# More robust spatial filtering
waste_sites_leeds <- waste_sites_sf %>%
  st_filter(pct_regions) %>%
  # Add additional metrics
  mutate(
    tonnage_category = case_when(
      tonnes_glass_total < 100 ~ "Low",
      tonnes_glass_total < 500 ~ "Medium", 
      tonnes_glass_total < 1000 ~ "High",
      TRUE ~ "Very High"
    ),
    tonnage_category = factor(tonnage_category, 
                             levels = c("Low", "Medium", "High", "Very High"))
  )

# Summary statistics by category
waste_sites_leeds %>%
  st_drop_geometry() %>%
  count(tonnage_category, sort = TRUE) %>%
  mutate(
    percentage = scales::percent(n / sum(n))
  )

# Create visualization using tmap
library(tmap)

tm_shape(waste_sites_leeds) +
  tm_dots(
    size = "tonnes_glass_total",
    col = "tonnage_category",
    palette = "viridis",
    title.size = "Glass Tonnage",
    title.col = "Category",
    scale = 2
  ) +
  tm_layout(
    title = "Glass Recycling Sites in Leeds",
    legend.outside = TRUE
  )

# Export results
waste_sites_leeds %>%
  select(site_name, tonnes_glass_total, tonnage_category) %>%
  write_sf("waste_sites_leeds.geojson")

# Summary report
summary_stats <- waste_sites_leeds %>%
  st_drop_geometry() %>%
  summarise(
    total_sites = n(),
    total_tonnage = sum(tonnes_glass_total),
    mean_tonnage = mean(tonnes_glass_total),
    median_tonnage = median(tonnes_glass_total),
    max_tonnage = max(tonnes_glass_total),
    min_tonnage = min(tonnes_glass_total)
  )

# Print summary
cat("Leeds Glass Recycling Sites Summary:\n")
cat("===================================\n")
cat(glue::glue("Total sites: {summary_stats$total_sites}"), "\n")
cat(glue::glue("Total tonnage: {round(summary_stats$total_tonnage, 1)} kg"), "\n") 
cat(glue::glue("Average tonnage per site: {round(summary_stats$mean_tonnage, 1)} kg"), "\n")
cat(glue::glue("Range: {summary_stats$min_tonnage} - {summary_stats$max_tonnage} kg"), "\n")