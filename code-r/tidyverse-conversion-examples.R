# Tidyverse Conversion Examples
# ============================
# 
# This file demonstrates common R code patterns and their tidyverse equivalents
# 
# Author: R to Tidyverse Conversion Guide
# Date: 2024

library(tidyverse)

# =============================================================================
# 1. DATA FRAME CREATION
# =============================================================================

# BEFORE: Traditional R approach
# -------------------------------
person_name <- c("Alice", "Bob", "Charlie")
age <- c(25, 30, 35)
salary <- c(50000, 60000, 70000)
df_old <- data.frame(person_name, age, salary)

# AFTER: Tidyverse approach
# -------------------------
df_new <- tribble(
  ~person_name, ~age, ~salary,
  "Alice",      25,   50000,
  "Bob",        30,   60000,
  "Charlie",    35,   70000
)

# Alternative tibble approach
df_tibble <- tibble(
  person_name = c("Alice", "Bob", "Charlie"),
  age = c(25, 30, 35),
  salary = c(50000, 60000, 70000)
)

# =============================================================================
# 2. COLUMN OPERATIONS
# =============================================================================

# BEFORE: Base R column selection and modification
# ------------------------------------------------
df_subset <- df_old[, c("person_name", "salary")]
df_old$salary_k <- df_old$salary / 1000
df_old$age_group <- ifelse(df_old$age < 30, "Young", "Older")

# AFTER: Tidyverse approach
# -------------------------
df_processed <- df_new %>%
  select(person_name, salary) %>%
  mutate(
    salary_k = salary / 1000,
    age_group = if_else(age < 30, "Young", "Older")
  )

# =============================================================================
# 3. FILTERING AND SORTING
# =============================================================================

# BEFORE: Base R filtering and sorting
# ------------------------------------
high_earners <- df_old[df_old$salary > 55000, ]
sorted_by_age <- df_old[order(df_old$age), ]
sorted_desc <- df_old[order(-df_old$salary), ]

# AFTER: Tidyverse approach
# -------------------------
high_earners_tidy <- df_new %>%
  filter(salary > 55000)

sorted_by_age_tidy <- df_new %>%
  arrange(age)

sorted_desc_tidy <- df_new %>%
  arrange(desc(salary))

# =============================================================================
# 4. AGGREGATION AND GROUPING
# =============================================================================

# Sample data with groups
employees <- tribble(
  ~name,      ~department, ~salary, ~years_experience,
  "Alice",    "Engineering", 80000, 5,
  "Bob",      "Engineering", 75000, 3,
  "Charlie",  "Marketing",   60000, 7,
  "Diana",    "Marketing",   65000, 4,
  "Eve",      "Engineering", 90000, 8,
  "Frank",    "Sales",       55000, 2
)

# BEFORE: Base R aggregation
# --------------------------
dept_stats <- aggregate(salary ~ department, data = employees, FUN = mean)
dept_counts <- table(employees$department)

# AFTER: Tidyverse approach
# -------------------------
dept_summary <- employees %>%
  group_by(department) %>%
  summarise(
    n_employees = n(),
    avg_salary = mean(salary),
    median_salary = median(salary),
    total_experience = sum(years_experience),
    .groups = "drop"
  )

# =============================================================================
# 5. CONDITIONAL OPERATIONS
# =============================================================================

# BEFORE: Base R conditional operations
# -------------------------------------
employees$salary_level <- ifelse(employees$salary > 70000, "High", 
                                ifelse(employees$salary > 60000, "Medium", "Low"))

employees$bonus <- employees$salary * 0.1
employees$bonus[employees$department == "Sales"] <- employees$salary[employees$department == "Sales"] * 0.15

# AFTER: Tidyverse approach
# -------------------------
employees_enhanced <- employees %>%
  mutate(
    salary_level = case_when(
      salary > 70000 ~ "High",
      salary > 60000 ~ "Medium",
      TRUE ~ "Low"
    ),
    bonus = case_when(
      department == "Sales" ~ salary * 0.15,
      TRUE ~ salary * 0.1
    )
  )

# =============================================================================
# 6. DATA RESHAPING
# =============================================================================

# Sample wide data
sales_wide <- tribble(
  ~salesperson, ~Q1, ~Q2, ~Q3, ~Q4,
  "John",       100, 120, 130, 140,
  "Jane",       110, 125, 135, 145,
  "Jim",        90,  100, 110, 120
)

# BEFORE: Base R reshaping (using reshape function)
# -------------------------------------------------
# sales_long_base <- reshape(sales_wide, 
#                           varying = c("Q1", "Q2", "Q3", "Q4"),
#                           v.names = "sales",
#                           timevar = "quarter",
#                           times = c("Q1", "Q2", "Q3", "Q4"),
#                           direction = "long")

# AFTER: Tidyverse approach
# -------------------------
sales_long <- sales_wide %>%
  pivot_longer(
    cols = Q1:Q4,
    names_to = "quarter",
    values_to = "sales"
  )

# Converting back to wide format
sales_wide_again <- sales_long %>%
  pivot_wider(
    names_from = quarter,
    values_from = sales
  )

# =============================================================================
# 7. STRING OPERATIONS
# =============================================================================

# Sample data with text
customers <- tribble(
  ~customer_id, ~full_name,     ~email,
  1,            "John Smith",   "john.smith@email.com",
  2,            "Jane Doe",     "jane.doe@company.org", 
  3,            "Jim Brown",    "j.brown@service.net"
)

# BEFORE: Base R string operations
# --------------------------------
customers$first_name <- sapply(strsplit(customers$full_name, " "), `[`, 1)
customers$domain <- sub(".*@", "", customers$email)
customers$is_gmail <- grepl("gmail", customers$email)

# AFTER: Tidyverse approach
# -------------------------
customers_processed <- customers %>%
  mutate(
    first_name = str_extract(full_name, "^\\w+"),
    last_name = str_extract(full_name, "\\w+$"),
    domain = str_extract(email, "(?<=@)[^.]+"),
    is_commercial = str_detect(email, "\\.(com|org|net)$"),
    email_clean = str_to_lower(email)
  )

# =============================================================================
# 8. JOINING DATA
# =============================================================================

# Sample datasets
orders <- tribble(
  ~order_id, ~customer_id, ~amount,
  1,         101,          250,
  2,         102,          180,
  3,         101,          320,
  4,         103,          150
)

customer_info <- tribble(
  ~customer_id, ~name,        ~city,
  101,          "Alice",      "London",
  102,          "Bob",        "Paris", 
  103,          "Charlie",    "Berlin",
  104,          "Diana",      "Madrid"
)

# BEFORE: Base R merging
# ---------------------
merged_base <- merge(orders, customer_info, by = "customer_id", all.x = TRUE)

# AFTER: Tidyverse approach
# -------------------------
merged_tidy <- orders %>%
  left_join(customer_info, by = "customer_id")

# Different join types
inner_joined <- orders %>%
  inner_join(customer_info, by = "customer_id")

full_joined <- orders %>%
  full_join(customer_info, by = "customer_id")

# =============================================================================
# 9. WORKING WITH DATES
# =============================================================================

# Sample date data
events <- tribble(
  ~event_name,    ~event_date,
  "Conference A", "2024-03-15",
  "Workshop B",   "2024-04-22", 
  "Seminar C",    "2024-05-10"
)

# BEFORE: Base R date operations
# -----------------------------
events$event_date <- as.Date(events$event_date)
events$day_of_week <- weekdays(events$event_date)
events$month <- months(events$event_date)

# AFTER: Tidyverse approach (using lubridate)
# -------------------------------------------
events_processed <- events %>%
  mutate(
    event_date = ymd(event_date),
    day_of_week = wday(event_date, label = TRUE),
    month = month(event_date, label = TRUE),
    days_from_now = as.numeric(event_date - today()),
    is_weekend = wday(event_date) %in% c(1, 7)
  )

# =============================================================================
# 10. SUMMARY STATISTICS
# =============================================================================

# BEFORE: Base R summary statistics
# ---------------------------------
mean_salary <- mean(employees$salary)
salary_by_dept <- tapply(employees$salary, employees$department, mean)
salary_summary <- summary(employees$salary)

# AFTER: Tidyverse approach
# -------------------------
overall_stats <- employees %>%
  summarise(
    count = n(),
    mean_salary = mean(salary),
    median_salary = median(salary),
    std_dev = sd(salary),
    min_salary = min(salary),
    max_salary = max(salary),
    q25 = quantile(salary, 0.25),
    q75 = quantile(salary, 0.75)
  )

dept_detailed_stats <- employees %>%
  group_by(department) %>%
  summarise(
    across(c(salary, years_experience), 
           list(mean = mean, median = median, sd = sd),
           .names = "{.col}_{.fn}"),
    .groups = "drop"
  )

# =============================================================================
# CONCLUSION
# =============================================================================

cat("Tidyverse Conversion Examples Complete!\n")
cat("=========================================\n")
cat("Key Benefits of Tidyverse:\n")
cat("• More readable code with pipe operators\n")
cat("• Consistent function names and behavior\n") 
cat("• Better handling of grouped operations\n")
cat("• More powerful data manipulation functions\n")
cat("• Integrated ecosystem of packages\n")