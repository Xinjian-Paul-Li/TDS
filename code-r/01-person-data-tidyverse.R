# Tidyverse version of person data creation
library(tidyverse)

# Using tribble() for cleaner data frame creation
# Group 1
personal_data1 <- tribble(
  ~person_name, ~n_coffee, ~like_bus_travel,
  "robin",      5,         TRUE,
  "malcolm",    1,         FALSE,
  "richard",    0,         TRUE
)

# Group 2  
personal_data2 <- tribble(
  ~person_name, ~n_coffee, ~like_bus_travel,
  "Zi",         4,         FALSE,
  "Ignacio",    0,         TRUE
)

# Group 3
personal_data3 <- tribble(
  ~person_name, ~n_coffee, ~like_bus_travel,
  "Caroline",   6,         FALSE,
  "Tatjana",    8,         FALSE
)

# Group 4
personal_data4 <- tribble(
  ~person_name, ~n_coffee, ~like_bus_travel,
  "Hawah",      2,         FALSE,
  "Colin",      0,         TRUE,
  "Eugeni",     7,         FALSE
)

# Combine all data using bind_rows() (already tidyverse!)
everyone <- bind_rows(personal_data1, personal_data2, personal_data3, personal_data4)

# Calculate mean using tidyverse approach
coffee_mean <- everyone %>% 
  summarise(mean_coffee = mean(n_coffee)) %>% 
  pull(mean_coffee)

# Print result
cat("Mean coffee consumption:", coffee_mean, "\n")

# Write data using readr (already done correctly in original!)
write_csv(everyone, "sample-data/everyone.csv")

# Alternative: create all data in one tribble for even cleaner code
everyone_alt <- tribble(
  ~person_name, ~n_coffee, ~like_bus_travel, ~group,
  "robin",      5,         TRUE,             1,
  "malcolm",    1,         FALSE,            1,
  "richard",    0,         TRUE,             1,
  "Zi",         4,         FALSE,            2,
  "Ignacio",    0,         TRUE,             2,
  "Caroline",   6,         FALSE,            3,
  "Tatjana",    8,         FALSE,            3,
  "Hawah",      2,         FALSE,            4,
  "Colin",      0,         TRUE,             4,
  "Eugeni",     7,         FALSE,            4
)

# Show summary by group using tidyverse
everyone_alt %>%
  group_by(group) %>%
  summarise(
    n_people = n(),
    mean_coffee = mean(n_coffee),
    prop_like_bus = mean(like_bus_travel),
    .groups = "drop"
  )