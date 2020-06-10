Cohort <- R6Class("Cohort",

    public = list(
      pop0 = NULL,
      births = NULL,
      deaths = NULL,
      inflow = NULL,
      outflow = NULL,

      initialize = function(pop0 = NA) {
        self$pop <- pop0
      },
      year_age = function() {
        pop <- mutate(pop, years = year + 1)
      },
      birth = function(x) {
        pop <- merge(pop, births)
        pop <- mutate(dat,
                      pop = pop + birth)
        self$pop <- pop
        invisible(pop)
      },
      death = function() {
        pop <- merge(pop, deaths)
        pop <- mutate(dat, pop = pop - deaths)
        self$pop <- pop
        invisible(pop)
      },
    )
)

#q <- Cohort$new()
