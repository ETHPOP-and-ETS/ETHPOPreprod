
# population pyramid plots
#
#


require(ggplot2)
library(dplyr)


sim_pop <- read.csv(file = here::here("output_data/run_model_output_ons2011.csv"))


dat <-
  sim_pop %>%
  filter(ETH.group == "Bangladeshi",
         year == 2016,
         sex == "M") %>%
  mutate(pop = ifelse(CoB == "UK born", -pop, pop))


ggplot(dat, aes(x = age, y = pop, fill = CoB)) +
  geom_bar(data = subset(dat, CoB == "UK born"), stat = "identity") +
  geom_bar(data = subset(dat, CoB == "Non-UK born"), stat = "identity") +
  # geom_bar(aes(y = pop*(-1)))# +
  scale_y_continuous(breaks = seq(-10000, 100000, 1000),
                     labels = abs(seq(-10000, 100000, 1000))) +
  coord_flip()


