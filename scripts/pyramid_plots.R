
# population pyramid plots
#
#


require(ggplot2)
library(dplyr)
library(grid)
library(gridExtra)


sim_pop <- read.csv(file = here::here("output_data/run_model_output_ons2011.csv"))


dat <-
  sim_pop %>%
  filter(ETH.group == "Bangladeshi",
         year == 2016,
         sex == "M") %>%
  mutate(pop = ifelse(CoB == "Non-UK born", -pop, pop))


ggplot(dat, aes(x = age, y = pop, fill = CoB)) +
  geom_bar(data = subset(dat, CoB == "UK born"), stat = "identity") +
  geom_bar(data = subset(dat, CoB == "Non-UK born"), stat = "identity") +
  # geom_bar(aes(y = pop*(-1)))# +
  scale_y_continuous(breaks = seq(-10000, 100000, 1000),
                     labels = abs(seq(-10000, 100000, 1000))) +
  coord_flip()

YEAR <- 2027

p <- list()
for (var in unique(sim_pop$ETH.group)) {

  pdat <-
    sim_pop %>%
    filter(ETH.group == var,
           year == YEAR,
           sex == "M") %>%
    mutate(pop = ifelse(CoB == "Non-UK born", -pop, pop))

  p[[var]] <-
    ggplot(pdat, aes(x = age, y = pop, fill = CoB)) +
    geom_bar(data = subset(pdat, CoB == "UK born"), stat = "identity") +
    geom_bar(data = subset(pdat, CoB == "Non-UK born"), stat = "identity") +
    # scale_y_continuous(breaks = seq(-10000, 100000, 1000),
    #                    labels = abs(seq(-10000, 100000, 1000))) +
    coord_flip() +
    ggtitle(var)
}

q <-
  gridExtra::grid.arrange(p[[1]], p[[2]], p[[3]],
                          p[[4]], p[[5]], p[[6]],
                          p[[7]], p[[8]], p[[9]],
                          ncol = 3,
                          top = textGrob(YEAR, gp = gpar(fontsize=20,font=3)))

ggsave(q, filename = "plots/all_ethgrp_UKborn_pyramids.png", scale = 3)

