# Tidyverse version of p4 lecture code
library(tidyverse)

# Read data using readr (more consistent than read.csv)
# d <- read_csv("wu03ew_v2.csv")
# For demonstration, let's assume we have the data loaded

# Create sample data for demonstration
d <- tibble(
  `Area of residence` = paste0("E", sprintf("%08d", 1:10)),
  `Area of workplace` = paste0("E", sprintf("%08d", 11:20)),
  `All categories: Method of travel to work` = sample(1000:2000, 10),
  `Work mainly at or from home` = sample(0:100, 10),
  `Underground, metro, light rail, tram` = sample(0:50, 10),
  `Train` = sample(0:200, 10),
  `Bus, minibus or coach` = sample(0:150, 10),
  `Taxi` = sample(0:20, 10),
  `Motorcycle, scooter or moped` = sample(0:30, 10),
  `Driving a car or van` = sample(200:800, 10),
  `Passenger in a car or van` = sample(0:100, 10),
  `Bicycle` = sample(0:100, 10),
  `On foot` = sample(0:200, 10),
  `Other method of travel to work` = sample(0:50, 10)
)

# Tidyverse approach to column renaming using janitor package or manual rename
# Option 1: Using janitor::clean_names() for automatic snake_case conversion
# d_clean <- d %>% janitor::clean_names()

# Option 2: Manual renaming with rename() - more explicit and controlled
d_clean <- d %>%
  rename(
    area_of_residence = `Area of residence`,
    area_of_workplace = `Area of workplace`,
    all = `All categories: Method of travel to work`,
    work_mainly_at_or_from_home = `Work mainly at or from home`,
    metro = `Underground, metro, light rail, tram`,
    train = `Train`,
    bus_minibus_or_coach = `Bus, minibus or coach`,
    taxi = `Taxi`,
    motorcycle_scooter_or_moped = `Motorcycle, scooter or moped`,
    driving_a_car_or_van = `Driving a car or van`,
    passenger_in_a_car_or_van = `Passenger in a car or van`,
    bicycle = `Bicycle`,
    on_foot = `On foot`,
    other_method_of_travel_to_work = `Other method of travel to work`
  )

# View column names
names(d_clean)

# Select specific columns and create derived variables in one pipeline
d_small <- d_clean %>%
  select(area_of_residence, area_of_workplace, all, bicycle) %>%
  mutate(pcycle = bicycle / all)

# Check object size (unchanged from original)
object.size(d_small) / 1e6

# Save data using tidyverse approach
write_rds(d_small, "d_small.rds")

# Display the results
d_small

# Alternative approach: Use across() for multiple column operations
d_proportions <- d_clean %>%
  select(area_of_residence, area_of_workplace, all, bicycle, train, bus_minibus_or_coach, on_foot) %>%
  mutate(
    across(c(bicycle, train, bus_minibus_or_coach, on_foot), 
           ~ .x / all, 
           .names = "prop_{.col}")
  )

# Show first few rows
d_proportions %>% slice_head(n = 5)

# Summary statistics using tidyverse
d_small %>%
  summarise(
    n_rows = n(),
    mean_bicycle = mean(bicycle, na.rm = TRUE),
    mean_pcycle = mean(pcycle, na.rm = TRUE),
    median_pcycle = median(pcycle, na.rm = TRUE),
    max_pcycle = max(pcycle, na.rm = TRUE)
  )