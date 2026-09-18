# ---------------------------------------------------------------------------
# Simulate a realistic Belgian home-to-work commute dataset.
#
# Anchored on published figures:
#   average ONE-WAY distance   18.5 km  (SD Worx HR & Payroll Pulse, Feb 2025,
#                                        n = 1000 Belgian workers)
#   average round-trip time    57 min   (same survey)  -> ~28.5 min one way
#   modal split of commutes    car 61.4% / bike 16.5% / rail ~10%
#                              (FPS Mobility federal home-to-work survey 2024)
#                              -> car .614 / bike .165 / public transport .221
#
# Generating process:
#   time = overhead[mode] + pace[mode] * distance + rush_penalty + noise
# Each mode has a fixed OVERHEAD (parking, walking to the stop, waiting) and a
# PACE in minutes per km, so mode shifts the intercept a lot and the slope less.
#
# This is the R twin of commute_sim.py. Both use the same parameters; the RNGs
# differ, so the rows differ. Use the shipped CommuteData.csv if you want the
# exact numbers the prototype refers to.
# ---------------------------------------------------------------------------

library(tidyverse)

set.seed(20261001)          # the workshop date
N <- 90                     # ~ the n = 87 of the marathon data

modes  <- c("Car", "Bike", "PublicTransport")
p_mode <- c(.614, .165, .221)

# distance: lognormal per mode -- median km, sd on the log scale
dist_par <- list(Car             = c(med = 17, sdlog = .45),
                 Bike            = c(med =  5, sdlog = .40),
                 PublicTransport = c(med = 26, sdlog = .45))

# time: overhead (min), pace (min per km), residual sd (min)
time_par <- list(Car             = c(oh =  3.0, pace = 1.25, sd = 4.0),
                 Bike            = c(oh =  2.5, pace = 3.40, sd = 2.5),
                 PublicTransport = c(oh = 14.0, pace = 0.95, sd = 5.0))

Mode <- sample(modes, N, replace = TRUE, prob = p_mode)

Distance <- map_dbl(Mode, \(m) {
  p <- dist_par[[m]]
  rlnorm(1, log(p["med"]), p["sdlog"])
}) |> pmin(70) |> pmax(0.8) |> round(1)

CommuteTime <- map2_dbl(Mode, Distance, \(m, d) {
  p <- time_par[[m]]
  p["oh"] + p["pace"] * d + rnorm(1, 0, p["sd"])
})

# a second continuous predictor: departure time, with a rush-hour penalty
DepartureHour <- rnorm(N, 8.0, 0.9) |> pmin(10.5) |> pmax(5.5) |> round(1)
rush    <- exp(-0.5 * ((DepartureHour - 8.3) / 0.8)^2)
penalty <- case_when(Mode == "Car" ~ 7.0,
                     Mode == "PublicTransport" ~ 2.5,
                     TRUE ~ 0)

CommuteData <- tibble(
  id            = seq_len(N),
  CommuteTime   = round(pmax(CommuteTime + penalty * rush, 3), 1),
  Distance      = Distance,
  Mode          = factor(Mode, levels = modes),
  DepartureHour = DepartureHour
)

# ---- sanity checks against the published anchors --------------------------
CommuteData |>
  summarise(n          = n(),
            mean_time  = mean(CommuteTime),      # target ~28.5
            sd_time    = sd(CommuteTime),
            mean_dist  = mean(Distance),         # target  18.5
            min_per_km = sum(CommuteTime) / sum(Distance)) |>
  print()

count(CommuteData, Mode) |> mutate(prop = round(n / sum(n), 3)) |> print()

write_csv(CommuteData, "CommuteData.csv")
