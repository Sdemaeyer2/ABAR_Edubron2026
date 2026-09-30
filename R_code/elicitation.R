# ===========================================================================
#  elicitation.R
#
#  ONE source of truth for everything in Part 1 that depends on the room:
#  their two elicited ranges and their own commuting times.
#
#  Sourced by the setup chunk of Slides_Part1.qmd, and by build_console.R.
#  You should never have to edit this file. Edit the CSV instead:
#
#      Data/room_2026.csv        columns: ilo,ihi,lo,hi,own
#
#  If that file is absent the deck still renders, using the placeholder room
#  below, and every affected slide carries a visible "placeholder" marker.
# ===========================================================================

suppressMessages(library(here))

ROOM_FILE <- here("Data", "room_2026.csv")

# ---------------------------------------------------------------------------
# 1. The room
# ---------------------------------------------------------------------------
if (file.exists(ROOM_FILE)) {

  room <- utils::read.csv(ROOM_FILE, stringsAsFactors = FALSE)
  ROOM_IS_REAL <- TRUE

  needed <- c("ilo", "ihi", "lo", "hi", "own")
  missing <- setdiff(needed, names(room))
  if (length(missing))
    stop("room_2026.csv is missing column(s): ", paste(missing, collapse = ", "),
         "\nExpected header: ilo,ihi,lo,hi,own")

  for (v in needed) room[[v]] <- suppressWarnings(as.numeric(room[[v]]))

  # a stated range given the wrong way round is a typo, not an opinion
  flip <- function(a, b) list(lo = pmin(a, b), hi = pmax(a, b))
  f <- flip(room$lo,  room$hi);  room$lo  <- f$lo; room$hi  <- f$hi
  f <- flip(room$ilo, room$ihi); room$ilo <- f$lo; room$ihi <- f$hi

} else {

  # Placeholder room, so the deck renders before the responses are in.
  room <- data.frame(
    ilo = c(10, 15,  8, 12, 20,  5, 10, 15),
    ihi = c(55, 70, 50, 60, 75, 45, 65, 60),
    lo  = c(30, 40, 25, 35, 45, 20, 30, 40),
    hi  = c(45, 60, 40, 55, 70, 35, 50, 55),
    own = c(24, 38, 15, 31, 42, 19, 27, 35)
  )
  ROOM_IS_REAL <- FALSE
  message("elicitation.R: ", ROOM_FILE, " not found - using the placeholder room.")
}

# ---------------------------------------------------------------------------
# 2. The two questions
#    Both are asked as the same stated coverage, so one divisor serves both.
# ---------------------------------------------------------------------------
COVERAGE <- 0.80
Z        <- 2 * qnorm(0.5 + COVERAGE / 2)    # 2.563, the width of an 80% interval

# --- Q1: how spread out are INDIVIDUAL commutes?  -> prior on sigma ---------
q1 <- room[is.finite(room$ilo) & is.finite(room$ihi) & room$ihi > room$ilo, ]
if (!nrow(q1)) stop("No usable answers to Q1 (the ilo/ihi columns).")

ind_low     <- mean(q1$ilo)
ind_high    <- mean(q1$ihi)
sigma_each  <- (q1$ihi - q1$ilo) / Z
sigma_prior <- mean(sigma_each)               # == (ind_high - ind_low) / Z

# How unsure we are about that spread, on the log scale. Deriving this from
# the room was tried and rejected: across seven test rooms the derived value
# always hit its own floor, which just tightened the prior without telling
# anyone. A fixed, deliberately loose value is honest.
sigma_logsd <- 0.30

# --- Q2: where is the AVERAGE?  -> prior on mu -----------------------------
q2 <- room[is.finite(room$lo) & is.finite(room$hi) & room$hi > room$lo, ]
if (!nrow(q2)) stop("No usable answers to Q2 (the lo/hi columns).")

mu_low   <- mean(q2$lo)
mu_high  <- mean(q2$hi)

# Pooling across people has TWO sources of uncertainty, and the console shows
# both: how much people disagree with each other, and how unsure each person
# says they are. Variances add.
mids       <- (q2$lo + q2$hi) / 2
mu_prior   <- mean(mids)
sd_between <- if (nrow(q2) > 1) stats::sd(mids) else 0
sd_within  <- sqrt(mean(((q2$hi - q2$lo) / Z)^2))
sd_prior   <- sqrt(sd_between^2 + sd_within^2)

N_ROOM <- nrow(room)

# ---------------------------------------------------------------------------
# 3. Their own commuting times - the data of the worked example
# ---------------------------------------------------------------------------
CT <- room$own[is.finite(room$own) & room$own > 0]
if (length(CT) < 4)
  stop("Fewer than four usable commuting times in the 'own' column.")

ct_mean <- mean(CT)
ct_sd   <- stats::sd(CT)

# ---------------------------------------------------------------------------
# 4. The two hand-scored parameter combinations
#
#    C1 is the combination the DATA suggest; C2 sits deliberately high and
#    wide. The offsets (+1.2 sd, x1.4 sd) are the ones that reproduce the
#    combinations this example used when it was written by hand, so the story
#    is unchanged - it just now follows the room instead of a fixed vector.
# ---------------------------------------------------------------------------
C1_mu    <- round(ct_mean)
C1_sigma <- max(1, round(ct_sd))          # sd = 0 is not a density
C2_mu    <- round(ct_mean + 1.2 * ct_sd)
C2_sigma <- round(1.4 * ct_sd)

# Guard: if C2 landed on top of C1 the contrast on the slides collapses.
if (abs(C2_mu - C1_mu) < 8)    C2_mu    <- C1_mu + 15
if (C2_sigma <= C1_sigma)      C2_sigma <- C1_sigma + 5

# ---------------------------------------------------------------------------
# 5. Plot ranges, so no slide has a hard-coded axis
# ---------------------------------------------------------------------------
# These axes show PARAMETERS, so they must be sized by how uncertain we are
# about the parameter - not by how spread out the observations are. Sizing the
# mu axis on sd(CT) is the very confusion this part of the deck is about, and
# with widely spread commutes it left the posterior as a small blob in the
# corner of a mostly empty panel.
#
# Where do the posteriors actually sit? Found with the same grid approximation
# the deck teaches, on a coarse grid, because this workshop never uses
# conjugate updating. Nothing here is shown to anyone; it exists only so the
# axes can be sized around the answer rather than around a guess.
.sd_safe <- max(ct_sd, 1)
.loc <- local({
  n  <- length(CT)
  mm <- seq(max(0, min(mu_prior - 3.5 * sd_prior, ct_mean - 3.5 * .sd_safe)),
            max(mu_prior + 3.5 * sd_prior, ct_mean + 3.5 * .sd_safe),
            length.out = 240)
  ss <- seq(max(0.2, .sd_safe * 0.1),
            max(sigma_prior * exp(3 * sigma_logsd), .sd_safe * 3),
            length.out = 240)
  S  <- vapply(mm, function(m) sum((CT - m)^2), numeric(1))
  lp <- outer(S, ss, function(q, s) -n * log(s) - q / (2 * s^2)) +
        dnorm(mm, mu_prior, sd_prior, log = TRUE) +
        rep(dlnorm(ss, log(sigma_prior), sigma_logsd, log = TRUE), each = length(mm))
  p  <- exp(lp - max(lp))
  dm <- rowSums(p); dm <- dm / sum(dm)
  ds <- colSums(p); ds <- ds / sum(ds)
  mm_m <- sum(mm * dm); ss_m <- sum(ss * ds)
  list(mu    = mm_m, mu_sd    = sqrt(sum((mm - mm_m)^2 * dm)),
       sigma = ss_m, sigma_sd = sqrt(sum((ss - ss_m)^2 * ds)),
       edge  = max(dm[1] + dm[length(dm)], ds[1] + ds[length(ds)]))
})
post_mu       <- .loc$mu
post_sd       <- .loc$mu_sd
post_sigma    <- .loc$sigma
post_sigma_sd <- .loc$sigma_sd

GRID_MU    <- c(max(0, floor(min(post_mu - 4 * post_sd, C1_mu, C2_mu) - 5)),
                ceiling(max(post_mu + 4 * post_sd, C1_mu, C2_mu) + 5))

# The "watching the data take over" slide draws the prior as well as the
# updated posteriors, so its window has to cover both.
MU_VIEW    <- c(max(0, floor(min(mu_prior - 3 * sd_prior, post_mu - 4 * post_sd) - 5)),
                ceiling(max(mu_prior + 3 * sd_prior, post_mu + 4 * post_sd) + 5))

# The slides that draw curves on the MINUTES scale - the prior on mu, and the
# two-panel "what the room believes" - were fixed at 0-90. With a room whose
# elicited spread is wide that clips the right tail off the Q1 curve, so the
# window follows the widest curve actually drawn.
X_VIEW <- c(0, ceiling(max(mu_prior + 3 * max(sigma_prior, sd_prior),
                           max(CT) * 1.05, MU_VIEW[2]) / 10) * 10)

# For sigma the posterior sits between what the room believed and what their
# data show, so the window spans both, plus the markers.
SIGMA_VIEW <- c(max(0, floor(min(sigma_prior * exp(-2 * sigma_logsd),
                                 post_sigma - 3.5 * post_sigma_sd,
                                 C1_sigma) - 2)),
                ceiling(max(sigma_prior * exp(2 * sigma_logsd),
                            post_sigma + 3.5 * post_sigma_sd,
                            C2_sigma) + 3))
GRID_SIGMA <- c(max(0.25, min(1, ct_sd * 0.2)),
                ceiling(max(SIGMA_VIEW[2], C2_sigma * 1.2)))

# Fail loudly now rather than producing a quietly wrong plot in front of a room.
stopifnot(
  "grid does not bracket C1/C2"  = GRID_MU[1] < min(C1_mu, C2_mu) &&
                                   GRID_MU[2] > max(C1_mu, C2_mu),
  "sigma window clips a marker"  = SIGMA_VIEW[1] < min(C1_sigma, C2_sigma) &&
                                   SIGMA_VIEW[2] > max(C1_sigma, C2_sigma),
  "mu view clips the curves"     = MU_VIEW[1] < mu_prior && MU_VIEW[2] > mu_prior &&
                                   MU_VIEW[1] < post_mu  && MU_VIEW[2] > post_mu,
  "C1 and C2 are not distinct"   = (C2_mu - C1_mu) >= 8 && C2_sigma > C1_sigma,
  "priors are not finite"        = all(is.finite(c(mu_prior, sd_prior, sigma_prior))),
  "locator grid is too narrow"   = .loc$edge < 0.01,
  "windows are not finite"       = all(is.finite(c(GRID_MU, GRID_SIGMA, SIGMA_VIEW,
                                                   MU_VIEW, X_VIEW))),
  "minutes axis clips a curve"   = X_VIEW[2] > mu_prior + 2.5 * max(sigma_prior, sd_prior) &&
                                   X_VIEW[2] >= max(CT)
)

# how many observations the middle panel of "Watching the data take over" uses
N_EARLY <- max(3, floor(length(CT) / 2))

# ---------------------------------------------------------------------------
# 6. A marker the slides can print while the data are still fake
# ---------------------------------------------------------------------------
ROOM_NOTE <- if (ROOM_IS_REAL) "" else
  paste0("  \n::: {.calcnote}\n**Placeholder data.** ",
         "`Data/room_2026.csv` was not found, so these are made-up answers. ",
         "Drop the real file in and re-render.\n:::")

# ---------------------------------------------------------------------------
# 7. Render-time diagnostic
#
#    The deck shows Likelihood x Prior for C1 and for C2 and lets the numbers
#    speak. Usually C1 wins both. But a room whose collective prior is well
#    off its own data can have the PRIOR overturn a modest likelihood ratio -
#    which is a real and very teachable thing, as long as you are not finding
#    out about it while standing in front of them. So it is announced here.
# ---------------------------------------------------------------------------
.L1 <- prod(dnorm(CT, C1_mu, C1_sigma)); .L2 <- prod(dnorm(CT, C2_mu, C2_sigma))
.P1 <- dnorm(C1_mu, mu_prior, sd_prior) * dlnorm(C1_sigma, log(sigma_prior), sigma_logsd)
.P2 <- dnorm(C2_mu, mu_prior, sd_prior) * dlnorm(C2_sigma, log(sigma_prior), sigma_logsd)
ROOM_VERDICT <- if (.L1 * .P1 > .L2 * .P2) "C1" else "C2"

message(sprintf(
  "elicitation.R: n = %d%s | prior mu0 = %.1f vs their actual mean = %.1f | posterior favours %s",
  N_ROOM, if (ROOM_IS_REAL) "" else " (PLACEHOLDER)", mu_prior, ct_mean, ROOM_VERDICT))
if (ROOM_VERDICT == "C2")
  message("  NOTE: the room's prior is far enough from their own data to outweigh it.\n",
          "  C2 will show the larger Product on the slide. Worth saying out loud:\n",
          "  that is the prior doing its job, not an error.")

if (interactive()) {
  cat(sprintf(
    "\nroom: n = %d %s\n  Q1  sigma_prior = %.1f  (logsd %.2f)\n  Q2  mu_prior = %.1f  sd_prior = %.1f  (between %.1f, within %.1f)\n  CT  n = %d  mean %.1f  sd %.1f\n  C1  (%g, %g)   C2  (%g, %g)\n",
    N_ROOM, if (ROOM_IS_REAL) "(real)" else "(PLACEHOLDER)",
    sigma_prior, sigma_logsd, mu_prior, sd_prior, sd_between, sd_within,
    length(CT), ct_mean, ct_sd, C1_mu, C1_sigma, C2_mu, C2_sigma))
}
