# R到Tidyverse代码转换指南

本项目包含了将传统R代码转换为现代tidyverse风格的示例和改进版本。

## 📂 转换后的文件

### 核心转换文件
- `01-person-data-tidyverse.R` - 数据创建的tidyverse版本
- `p4-lecture-code-tidyverse.R` - 数据处理和列操作的tidyverse版本  
- `getting-data-gov-uk-enhanced.R` - 数据获取和清理的增强版本
- `tidyverse-conversion-examples.R` - 完整的前后对比示例

## 🔄 主要改进点

### 1. 数据创建
**传统R方式:**
```r
person_name = c("robin", "malcolm", "richard")
n_coffee = c(5, 1, 0)
personal_data1 = data.frame(person_name, n_coffee, like_bus_travel)
```

**Tidyverse方式:**
```r
personal_data1 <- tribble(
  ~person_name, ~n_coffee, ~like_bus_travel,
  "robin",      5,         TRUE,
  "malcolm",    1,         FALSE,
  "richard",    0,         TRUE
)
```

### 2. 列操作和重命名
**传统R方式:**
```r
names_new = snakecase::to_snake_case(names_old)
names(d) = names_new
d2 = mutate(d_small, pcycle = bicycle / all)
```

**Tidyverse方式:**
```r
d_clean <- d %>%
  rename(
    area_of_residence = `Area of residence`,
    area_of_workplace = `Area of workplace`,
    bicycle = `Bicycle`
  ) %>%
  mutate(pcycle = bicycle / all)
```

### 3. 数据清理管道
**传统R方式:**
```r
waste_sites = read_csv(u)
waste_sites_unique = waste_sites[!is.na(waste_sites$Longitude), ]
# 多个步骤...
```

**Tidyverse方式:**
```r
waste_sites_clean <- read_csv(data_url) %>%
  filter(!is.na(longitude), !is.na(latitude)) %>%
  filter(between(longitude, -8, 2), between(latitude, 49, 61)) %>%
  group_by(site_name, longitude, latitude) %>%
  summarise(tonnes_glass_total = sum(c_across(contains("glass_tonnage")), na.rm = TRUE))
```

## 🛠️ Tidyverse核心优势

### 1. 管道操作符 (`%>%`)
- 使代码更易读，从左到右的逻辑流
- 避免嵌套函数调用
- 更容易调试和修改

### 2. 一致的函数命名
- `select()` - 选择列
- `filter()` - 筛选行  
- `mutate()` - 创建/修改列
- `arrange()` - 排序
- `summarise()` - 汇总统计

### 3. 强大的分组操作
```r
employees %>%
  group_by(department) %>%
  summarise(
    n_employees = n(),
    avg_salary = mean(salary),
    .groups = "drop"
  )
```

### 4. 现代数据操作
- `tribble()` - 创建数据框的直观方式
- `case_when()` - 多条件判断
- `across()` - 对多列应用函数
- `pivot_longer()`/`pivot_wider()` - 数据重塑

## 📊 数据类型支持

### 日期处理 (lubridate)
```r
events %>%
  mutate(
    event_date = ymd(event_date),
    day_of_week = wday(event_date, label = TRUE),
    is_weekend = wday(event_date) %in% c(1, 7)
  )
```

### 字符串处理 (stringr)
```r
customers %>%
  mutate(
    first_name = str_extract(full_name, "^\\w+"),
    domain = str_extract(email, "(?<=@)[^.]+"),
    is_commercial = str_detect(email, "\\.(com|org|net)$")
  )
```

### 数据连接
```r
orders %>%
  left_join(customer_info, by = "customer_id")
```

## 🚀 如何开始使用

### 1. 安装tidyverse
```r
install.packages("tidyverse")
library(tidyverse)
```

### 2. 运行示例文件
```r
# 查看完整示例
source("code-r/tidyverse-conversion-examples.R")

# 运行特定转换
source("code-r/01-person-data-tidyverse.R")
source("code-r/p4-lecture-code-tidyverse.R")
```

### 3. 逐步转换现有代码
1. 从`library(tidyverse)`开始
2. 将`data.frame()`替换为`tibble()`或`tribble()`
3. 使用管道操作符连接操作
4. 用tidyverse函数替换base R函数

## 📚 推荐资源

- [R for Data Science](https://r4ds.had.co.nz/) - tidyverse官方教程
- [Tidyverse官网](https://www.tidyverse.org/) - 包文档和参考
- [RStudio Cheat Sheets](https://rstudio.com/resources/cheatsheets/) - 快速参考卡

## 🔧 常用转换模式

| 传统R | Tidyverse | 功能 |
|-------|-----------|------|
| `data.frame()` | `tibble()`, `tribble()` | 创建数据框 |
| `subset()`, `[,]` | `filter()`, `select()` | 筛选数据 |
| `$`, `[[]]` | `pull()`, `pluck()` | 提取单列 |
| `ifelse()` | `if_else()`, `case_when()` | 条件操作 |
| `aggregate()` | `group_by() + summarise()` | 分组汇总 |
| `merge()` | `*_join()` | 数据连接 |
| `apply()` family | `across()`, `map()` | 函数应用 |

## 💡 最佳实践

1. **使用有意义的变量名** - `customers_clean` 而不是 `df2`
2. **管道不要太长** - 超过10个步骤考虑分解
3. **添加注释** - 解释复杂的数据转换逻辑
4. **保持一致性** - 在项目中统一使用tidyverse风格
5. **错误处理** - 使用`safely()`和`possibly()`处理错误

享受更清洁、更可读的R代码体验！🎉