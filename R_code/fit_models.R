# ===========================================================================
#  fit_models.R
#  Build every data file and fitted model object that the commuting-example
#  slides load. Run this ONCE from the project root (with the .Rproj open),
#  then Slides_Part1.qmd and Slides_Part2.qmd render without refitting.
#
#      source("R_code/fit_models.R")
#
#  Expect roughly 10-20 minutes, most of it Stan compiling and sampling.
# ===========================================================================

library(here)
library(tidyverse)
library(brms)

FORCE <- FALSE   # set TRUE to refit models whose .RDS already exists

dir.create(here("Presentations", "Output"), showWarnings = FALSE, recursive = TRUE)

fit_if_needed <- function(path, expr) {
  if (!FORCE && file.exists(path)) {
    message("  already there, skipping: ", basename(path))
    return(invisible(readRDS(path)))
  }
  message("  fitting: ", basename(path))
  obj <- force(expr)
  saveRDS(obj, file = path)
  invisible(obj)
}

# ---------------------------------------------------------------------------
# 1. The dataset
# ---------------------------------------------------------------------------
message("1/6  building CommuteData")

CommuteData <- read_csv(here("Presentations", "CommuteData.csv"),
                        show_col_types = FALSE) |>
  mutate(
    Mode        = factor(Mode, levels = c("Car", "Bike", "PublicTransport")),
    Distance_c  = Distance - mean(Distance, na.rm = TRUE),  # centred on the mean
    Departure_c = DepartureHour - 7                          # hours after 07:00
  )

save(CommuteData, file = here("Presentations", "CommuteData.RData"))
save(CommuteData, file = here("Data", "CommuteData.RData"))

print(summarise(CommuteData,
                n          = n(),
                mean_time  = mean(CommuteTime),
                sd_time    = sd(CommuteTime),
                mean_dist  = mean(Distance),
                min_per_km = sum(CommuteTime) / sum(Distance)))

# ---------------------------------------------------------------------------
# 2. Part 1 - the ten hand-typed commutes (Mod_CT1)
#    This is the toy model on slide "Let's retake the example on commuting".
# ---------------------------------------------------------------------------
message("2/6  Mod_CT1 (the ten-value vector)")

CT     <- c(22, 35, 18, 47, 12, 29, 38, 25, 55, 31)
DataCT <- data.frame(CT)

fit_if_needed(
  here("Presentations", "Part1", "Mod_CT1.RDS"),
  brm(CT ~ 1,
      data    = DataCT,
      backend = "cmdstanr",
      seed    = 1975)
)

# ---------------------------------------------------------------------------
# 3. Part 1 - the model shown as mcmc_areas on the "Bayesian inference" slide
#    The slide plots the posterior of b_Distance_c, so the model needs that
#    coefficient by that exact name.
# ---------------------------------------------------------------------------
message("3/6  Model1_commute (CommuteTime ~ Distance_c)")

fit_if_needed(
  here("Presentations", "Output", "Model1_commute.RDS"),
  brm(CommuteTime ~ 1 + Distance_c,
      data    = CommuteData,
      backend = "cmdstanr",
      seed    = 1975)
)

# ---------------------------------------------------------------------------
# 4. The two models compared with loo in Part 1
# ---------------------------------------------------------------------------
message("4/6  CommuteTimes_Mod1 (intercept only)")

fit_if_needed(
  here("Presentations", "Output", "CommuteTimes_Mod1.RDS"),
  brm(CommuteTime ~ 1,
      data    = CommuteData,
      backend = "cmdstanr",
      seed    = 1975)
)

# ---------------------------------------------------------------------------
# 5. The workhorse model for Part 2 (WAMBS, convergence, priorsense)
#    save_pars(all = TRUE) so priorsense can power-scale the prior.
# ---------------------------------------------------------------------------
message("5/6  CommuteTimes_Mod2 (Distance_c + Departure_c)")

fit_if_needed(
  here("Presentations", "Output", "CommuteTimes_Mod2.RDS"),
  brm(CommuteTime ~ 1 + Distance_c + Departure_c,
      data      = CommuteData,
      chains    = 4,
      iter      = 4000,
      cores     = 4,
      save_pars = save_pars(all = TRUE),
      backend   = "cmdstanr",
      seed      = 1975)
)

# ---------------------------------------------------------------------------
# 6. Prior predictive fit for the Part 2 prior-predictive-check slides
#    Same custom priors as the slides show.
# ---------------------------------------------------------------------------
message("6/6  Fit_Model_priors (sample_prior = 'only')")

Custom_priors <-
  c(
    set_prior("normal(1.5,0.5)", class = "b", coef = "Distance_c"),
    set_prior("normal(0,10)",    class = "b", coef = "Departure_c")
  )

fit_if_needed(
  here("Presentations", "Output", "Fit_Priors_Commute.RDS"),
  brm(CommuteTime ~ 1 + Distance_c + Departure_c,
      data         = CommuteData,
      prior        = Custom_priors,
      backend      = "cmdstanr",
      cores        = 4,
      sample_prior = "only",
      seed         = 1975)
)

# ---------------------------------------------------------------------------
# Check that everything the slides ask for is now on disk
# ---------------------------------------------------------------------------
message("\nchecking the files the slides load:")

needed <- c(
  here("Presentations", "CommuteData.csv"),
  here("Presentations", "CommuteData.RData"),
  here("Presentations", "Part1",  "Mod_CT1.RDS"),
  here("Presentations", "Output", "Model1_commute.RDS"),
  here("Presentations", "Output", "CommuteTimes_Mod1.RDS"),
  here("Presentations", "Output", "CommuteTimes_Mod2.RDS"),
  here("Presentations", "Output", "Fit_Priors_Commute.RDS")
)

for (f in needed) {
  message(if (file.exists(f)) "  OK      " else "  MISSING ", basename(f))
}

if (all(file.exists(needed))) {
  message("\nAll set. Render the decks with: quarto render Presentations/Part1/Slides_Part1.qmd")
} else {
  warning("Some files are missing - see the list above.")
}
