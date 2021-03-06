
#
# create synthetic cohort
# using joined LFS and ETHPOP in/out flow data
# including UK born/Non-UK born
#
# N Green
#


library(dplyr)
library(tidyr)
library(readxl)
library(readr)
library(tibble)
library(ggplot2)
library(demoSynthPop)


# load joined LFS and ETHPOP formatted data
dat_pop <- read_csv("~/R/demoSynthPop/output_data/joined_ETHPOP_LFS_2011.csv",
                    col_types = list(sex = col_character(),
                                     age = col_double(),
                                     year = col_double()))

# explicitly define sex so not coerced to logical
dat_inflow <- read_csv("~/R/cleanETHPOP/output_data/clean_inmigrants_Leeds2.csv",
                       col_types = list(sex = col_character()))
dat_outflow <- read_csv("~/R/cleanETHPOP/output_data/clean_outmigrants_Leeds2.csv",
                        col_types = list(sex = col_character()))
dat_births <- read_csv("~/R/cleanETHPOP/output_data/clean_births_Leeds2.csv",
                       col_types = list(sex = col_character()))
dat_deaths <- read_csv("~/R/cleanETHPOP/output_data/clean_deaths_Leeds2.csv",
                       col_types = list(sex = col_character()))


# harmonise ETHPOP with initial population -------------------------------

dat_inflow <-
  dat_inflow %>%
  mutate(ETH.group = ifelse(ETH.group %in% c("BLA","BLC","OBL"),
                            "BLA+BLC+OBL", ETH.group),
         ETH.group = ifelse(ETH.group %in% c("WBI","WHO"),
                            "WBI+WHO", ETH.group),
         ETH.group = ifelse(ETH.group %in% c("CHI","OAS"),
                            "CHI+OAS", ETH.group)) %>%
  mutate(age = ifelse(age %in% 90:100, 90, age)) %>%             # make 90 max single age
  group_by(sex, age, ETH.group, year) %>%
  summarise(inmigrants = sum(inmigrants))

dat_outflow <-
  dat_outflow %>%
  mutate(ETH.group = ifelse(ETH.group %in% c("BLA","BLC","OBL"),
                            "BLA+BLC+OBL", ETH.group),
         ETH.group = ifelse(ETH.group %in% c("WBI","WHO"),
                            "WBI+WHO", ETH.group),
         ETH.group = ifelse(ETH.group %in% c("CHI","OAS"),
                            "CHI+OAS", ETH.group)) %>%
  mutate(age = ifelse(age %in% 90:100, 90, age)) %>%
  group_by(sex, age, ETH.group, year) %>%
  summarise(outmigrants = sum(outmigrants))

dat_births <-
  dat_births %>%
  mutate(ETH.group = ifelse(ETH.group %in% c("BLA","BLC","OBL"),
                            "BLA+BLC+OBL", ETH.group),
         ETH.group = ifelse(ETH.group %in% c("WBI","WHO"),
                            "WBI+WHO", ETH.group),
         ETH.group = ifelse(ETH.group %in% c("CHI","OAS"),
                            "CHI+OAS", ETH.group)) %>%
  group_by(sex, ETH.group, year) %>%
  summarise(births = sum(births))

dat_deaths <-
  dat_deaths %>%
  mutate(ETH.group = ifelse(ETH.group %in% c("BLA","BLC","OBL"),
                            "BLA+BLC+OBL", ETH.group),
         ETH.group = ifelse(ETH.group %in% c("WBI","WHO"),
                            "WBI+WHO", ETH.group),
         ETH.group = ifelse(ETH.group %in% c("CHI","OAS"),
                            "CHI+OAS", ETH.group)) %>%
  mutate(age = ifelse(age %in% 90:100, 90, age)) %>%
  group_by(sex, age, ETH.group, year) %>%
  summarise(deaths = sum(deaths))


# -------------------------------------------------------------------------

res <-
  run_model(dat_pop,
            dat_births,
            dat_deaths,
            dat_inflow,
            dat_outflow)

sim_pop <- bind_rows(res)



########
# plot #
########

sim_plot <-
  sim_pop %>%
  filter(sex == "M",
         ETH.group == "BAN",
         year %in% c(2011, 2020, 2030, 2040, 2050, 2060)) %>%
  mutate(year = as.factor(year))
# mutate(eth_sex_year = interaction(ETH.group, sex, year))

dat_plot <-
  dat_pop %>%
  filter(sex == "M",
         ETH.group == "BAN",
         year %in% c(2011, 2020, 2030, 2040, 2050, 2060)) %>%
  mutate(year = as.factor(year))


p1 <-
  ggplot(sim_plot, aes(x=age, y=pop, colour = year)) +
  geom_line() +
  ylim(0,11000)

p2 <-
  ggplot(dat_plot, aes(x=age, y=pop, colour = year)) +
  geom_line() +
  ylim(0,11000)

gridExtra::grid.arrange(p1, p2)


## differences

diff_plot <-
  merge(dat_plot, sim_plot,
        by = c("age", "ETH.group", "sex", "year"), suffixes = c(".eth", ".sim")) %>%
  mutate(diff_pop = pop.eth - pop.sim,
         scaled_diff = diff_pop/pop.eth)

p3 <-
  ggplot(diff_plot, aes(x=age, y=diff_pop, colour = year)) +
  ggtitle("ETHPOP - estimated populations") +
  geom_line()

p3
p3 + ylim(-2000, 1000)

p4 <-
  ggplot(diff_plot, aes(x=age, y=scaled_diff, colour = year)) +
  ggtitle("(ETHPOP - estimated populations)/ETHPOP") +
  geom_line()

p4
p4 + ylim(-2, 3)
