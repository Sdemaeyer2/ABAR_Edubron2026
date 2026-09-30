# ===========================================================================
#  build_console.R
#
#  Writes Prior_console/prior_console_filled.html: the same elicitation
#  console, but opening with the room's real answers already in it.
#
#      source("R_code/build_console.R")
#
#  Run it whenever Data/room_2026.csv changes. Open the FILLED file during
#  the session; keep the empty one for a room that answers live.
# ===========================================================================

suppressMessages(library(here))

REVEAL_AT_START <- TRUE   # FALSE opens veiled, so you reveal on your cue

SRC <- here("Prior_console", "prior_console_offline.html")
OUT <- here("Prior_console", "prior_console_filled.html")

stopifnot("template console not found" = file.exists(SRC))

# the same room the slides use - one file feeds both
e <- new.env()
sys.source(here("R_code", "elicitation.R"), envir = e)

if (!e$ROOM_IS_REAL)
  warning("Data/room_2026.csv was not found - building the console from the ",
          "placeholder room. It will not match what you tell the room.",
          call. = FALSE)

room <- e$room

# ---------------------------------------------------------------------------
# rows -> the JS literal the console expects
# ---------------------------------------------------------------------------
num <- function(x) ifelse(is.finite(x), trimws(formatC(x, format = "g", digits = 6)), "null")

rows <- vapply(seq_len(nrow(room)), function(i) {
  sprintf("    {lo:%s,hi:%s,ilo:%s,ihi:%s,own:%s,km:null}",
          num(room$lo[i]),  num(room$hi[i]),
          num(room$ilo[i]), num(room$ihi[i]), num(room$own[i]))
}, character(1))

seed_js <- paste0("  var SEED = [\n", paste(rows, collapse = ",\n"), "\n  ];")

html <- readLines(SRC, warn = FALSE)

# ---------------------------------------------------------------------------
# 1. swap the SEED block
# ---------------------------------------------------------------------------
a <- grep("^\\s*var SEED = \\[", html)
stopifnot("could not find the SEED block" = length(a) == 1)
b <- a - 1 + grep("^\\s*\\];", html[a:length(html)])[1]

html <- c(html[seq_len(a - 1)], strsplit(seed_js, "\n")[[1]], html[-seq_len(b)])

# ---------------------------------------------------------------------------
# 2. these are real answers, not examples
# ---------------------------------------------------------------------------
hit <- grep("seeded: true", html, fixed = TRUE)
stopifnot("could not find the seeded flag" = length(hit) == 1)
html[hit] <- sub("seeded: true", "seeded: false", html[hit], fixed = TRUE)

if (!REVEAL_AT_START) {
  h <- grep("revealed: true", html, fixed = TRUE)
  if (length(h) == 1)
    html[h] <- sub("revealed: true", "revealed: false", html[h], fixed = TRUE)
}

# ---------------------------------------------------------------------------
# 3. give this build its own browser-storage key
#
#    The console restores localStorage on boot, which would otherwise override
#    everything baked in above with whatever was in the console the last time
#    it was opened - on the same origin, path does not matter. A per-build key
#    means this file opens on THIS room, while anything you add during the
#    session is still remembered.
# ---------------------------------------------------------------------------
stamp <- substr(paste0(format(Sys.time(), "%Y%m%d%H%M%S")), 1, 14)
key   <- paste0("priorConsole_", stamp)
n_key <- sum(grepl('"priorConsole"', html, fixed = TRUE))
stopifnot("expected exactly two storage-key uses" = n_key == 2)
html  <- gsub('"priorConsole"', paste0('"', key, '"'), html, fixed = TRUE)

writeLines(html, OUT)

cat(sprintf(
  "\nwrote %s\n  %d participants, storage key %s\n  Q1 sigma %.1f | Q2 mu0 %.1f sd0 %.1f | their mean commute %.1f\n  opens %s\n\n",
  OUT, nrow(room), key, e$sigma_prior, e$mu_prior, e$sd_prior, e$ct_mean,
  if (REVEAL_AT_START) "with the aggregate showing" else "veiled"))
