# Commute example — what changed, and how to run the live prior

## Before the workshop (once)

1. Open the `.Rproj` and run:

   ```r
   source("R_code/fit_models.R")
   ```

   It builds `CommuteData.RData` and fits the five model objects the decks
   load. ~10–20 minutes, mostly Stan compiling. It skips anything already on
   disk; set `FORCE <- TRUE` at the top to refit.

2. Render the decks to check:

   ```bash
   quarto render Presentations/Part1/Slides_Part1.qmd
   quarto render Presentations/Part2/Slides_Part2.qmd
   ```

## The live prior — run of show

### Two questions, not one

This is the heart of it. The room is asked **two separate things**, both phrased
as 80% ranges so the same arithmetic serves both:

| | question | what it is | what it gives |
|:--|:--|:--|:--|
| **Q1** | "8 out of 10 people here commute between ___ and ___" | a statement about the **observations** | `sigma_prior` |
| **Q2** | "If we averaged everyone's commute in this room, what would that average be?" | a statement about a **parameter** | `mu_prior`, `sd_prior` |

Concrete first, abstraction second: thinking about the people sitting next to
you is easy, and it makes the step up to "now the average" feel like a real
change of object rather than a rewording.

They are not the same question, and conflating them is the classic beginner
error. Q1's range comes out roughly twice as wide as Q2's — the slide puts the
two curves side by side, Q1 on the left, so the room sees that immediately.

Everything downstream reads four numbers, set in one chunk near the top of
`Slides_Part1.qmd`:

```r
COVERAGE <- 0.80
Z <- 2 * qnorm(0.5 + COVERAGE / 2)     # 2.563

ind_low  <- 10    # Q1 - individuals
ind_high <- 55
mu_low   <- 35    # Q2 - the average
mu_high  <- 55
```

`mu_prior`, `sd_prior` and `sigma_prior` derive from those, and every slide that
uses them prints the arithmetic in small print underneath, with the live numbers.
Change the four, re-render, and the whole deck is about the room's own priors.

### Where the console lives

There are two copies and neither needs rendering.

**The hosted one** is a page on claude.ai. Find it in your artifacts gallery at
`claude.ai/code/artifacts`, or from the card in the chat where it was made.
Bookmark it. It syncs across your devices and remembers entries between
sessions, but it needs a network connection and your Claude login.

**The offline one** is `Prior_console/prior_console_offline.html`, right
here in the workshop folder. Double-click it and it opens in your browser
straight from disk. No network, no login, nothing to render. It keeps its data
in that browser's local storage, so entries survive a page reload but do not
follow you to another machine.

For a live room, open the offline copy. It has one less thing that can fail at
09:05 in a room you have never presented in. Have it open in a second browser
tab before you start.

### During Part 1

The elicitation now opens the example — it happens **before** anyone sees the
frequentist model, so nobody is anchored by a fitted number.

| Slide | What you do |
|:--|:--|
| *Why statistical inference?* | The usual opener: population, sample, uncertainty. |
| **Write it down** (navy slide) | Everyone writes down **two** ranges on paper — Q1 and Q2. No discussion. The word "prior" has not been used yet, deliberately. |
| *(you leave the deck)* | Open the console. Go round the room and type each pair in. 20 people ≈ 2 minutes. Keep the aggregate hidden with **Hide aggregate** while you collect. |
| | Hit **Reveal to the room** and show the console. Use the three view tabs above the chart to take it in stages: **Q1 · individuals** alone, then **Q2 · the average** alone, then **Both** overlaid. Leave the **Posterior** button off — it starts hidden, and showing it here gives the game away. |
| | **Copy R code** — it emits `mu_low`/`mu_high`/`ind_low`/`ind_high` ready to paste into the deck chunk, plus the derived values as comments so you can sanity-check them out loud. |
| **What the room believes** | Back in the deck. Two panels and one line, nothing else: Q1 (individuals, wide) on the left, Q2 (the average, narrow) on the right. *Same centre, very different width, and they mean different things.* |
| **What the two numbers mean** | The interpretation, on its own slide: what each of the two statements is about, and the arithmetic in small print. |
| *an example* → *Frequentistic…* → *Bayesian…* | The existing detour, unchanged. They now meet the frequentist machinery **after** having already produced a belief of their own. |
| **Prior** (in Bayesian Inference) | The payoff: "you already did this — the range you wrote down was a prior on μ." |
| **Let's apply this idea** → grid | The worked example uses *their* priors on μ and σ. Two combos (C1, C2) are scored by hand, then the grid does it systematically. A note on the grid slide says why we switch to `log = TRUE`. |
| **Grid approximation applied** × 3 | The 2-D posterior, then the marginal of μ and of σ. On all three, C1 and C2 are marked and labelled — C1 in UA blue, C2 in UA red. |
| **Watching the data take over** | Prior → after 5 → after 10. Five observations do most of the work. |

### If re-rendering mid-session feels risky

It takes about a minute and the models are cached, so it usually isn't. But if
you'd rather not: leave the placeholder numbers in the deck, and do the live
part entirely in the console, switching to it at the three moments above. The
deck then tells the generic version of the story and the console tells the
room's version.

### If the room is small

Below about 8 people the pooled spread gets unstable — one wide range
dominates. Use the median low and median high instead; the console shows the
individual bars so you can see whether that's happening.

## What changed in the materials

| File | Change |
|:--|:--|
| `Slides_Part1.qmd` | 40 edits. Marathon → commuting throughout, plus 4 new slides: *Write it down*, *Your prior pooled*, *What does that prior actually say?*, *Watching the data take over*. |
| `Slides_Part2.qmd` | 16 edits. `CommuteTimes_Mod2`, `Distance_c` + `Departure_c` everywhere, a real slope prior `normal(1.5, 0.5)` instead of `normal(0,10)`. |
| `Slides_Part3.qmd` | 3 stale marathon comments fixed (they were wrong before — the code operates on `FirstVersion_GM`). |
| `Part1.qmd`, `Part2.qmd` | Data section and sources rewritten. |
| `WAMBS.qmd`, `Slides_Part2.qmd` | Links point at the commuting template; the old note about the marathon example is gone. |
| `Presentations/CommuteData.csv`, `Data/CommuteData.csv` | The dataset. |
| `R_code/` | `fit_models.R` (fits every model the slides load), `simulate_commute.R` (regenerates the dataset). |
| `Setup/` | This file and `INTEGRATION_PLAN.md`. |
| `Prior_console/` | `prior_console_offline.html` — the elicitation console. |
| `_archive/` | Superseded material (Zurich branding, marathon-era models, the patch scripts). Not in git. |

## Models

- **Part 1 exercise:** `CommuteTime ~ 1`, then `CommuteTime ~ 1 + Distance_c + Departure_c`
- **Part 2 workhorse:** the same two-predictor model

`Distance_c` is distance centred on its mean (17.7 km); `Departure_c` is hours
after 07:00. Both centred, so the intercept is "expected commute for an
average-distance trip leaving at 7am" — about 26.5 minutes.

Fitted by OLS for orientation: intercept 26.5, `Distance_c` 1.08 min/km
(se 0.06), `Departure_c` 4.28 min per hour later (se 0.86), residual sd 5.2.

### Why not `Distance + Mode`

The first draft used travel mode as the second predictor. It doesn't work:
cyclists only span 3–9 km and public-transport users 11–45 km, so mode and
distance are badly confounded and the parallel-slopes model collapses both mode
effects to a meaningless "+3 minutes". `DepartureHour` is clean, linear over the
06:00–09:00 window, and everyone has a prior about it ("leaving an hour later
costs you about 4 minutes"). `Mode` is still in the dataset — good for colouring
the scatterplot and for a discussion about confounding, just not as a predictor
in the headline model.

## Loose ends

- The WAMBS template is now `WAMBS_template/WAMBS_workflow_CommuteData.qmd`,
  running on `CommuteTimes_Mod2`, the same model as Part 2. The marathon
  version, its rendered html and its cache are in `_archive/marathon_wambs/`.
- Nothing outside `_archive/` mentions the marathon example any more.
- None of the R code has been executed — there is no R in the session that
  wrote it. `fit_models.R` is the first thing that will actually run it.


## Why the elicitation asks two questions

An earlier draft asked only for a range around "the average commute" and read it
as an 80% interval for μ. Three things were wrong with that:

1. **The question did not force the distinction.** Asked for "a low and a high"
   about the average, many people answer with the range *typical people* fall
   in — a statement about observations. In this dataset a genuine "most people"
   range is roughly 4 to 54 minutes, while a credible interval for the mean of
   20 people is far narrower. The two answers are indistinguishable in the
   numbers, and the code converted both as if they were about μ.
2. **The pooling inherited the confusion.** σ₀² = between-person disagreement +
   mean within-person variance. If people answered in observations-mode, that
   second term was the population σ, not uncertainty about μ.
3. **σ was never elicited at all.** The prior predictive check used
   `sigma ~ lognormal(log(12), 0.6)` — and 12 is the standard deviation of the
   dataset. The prior was being set from the data, in a workshop about setting
   priors before seeing data.

Asking both questions fixes all three, and turns the bug into the lesson.

## The divisor

Both ranges are read as **80% central intervals**, so

    sd = width / 2.563        where 2.563 = 2 × qnorm(0.90)

That constant used to be hardcoded as `2.56` with nothing explaining it. It
matters: the same two numbers read as a 50% range give an sd of 14.8, as a 95%
range 5.1. The stated coverage is now part of the question the room is asked
("a range you'd bet on 8 times out of 10"), and `COVERAGE` sits at the top of
the deck if you want to change it.


## The console's view tabs

Above the curve chart:

| control | what it does |
|:--|:--|
| **Both** | Q1 dashed and wide, Q2 solid and narrow, overlaid. The default. |
| **Q1 · individuals** | only the spread of individual commutes, filled. Caption: *a statement about the data, and it does not shrink with more data.* |
| **Q2 · the average** | only the prior on μ. Caption: *a statement about a parameter, and it does shrink as observations arrive.* |
| **Posterior** | off by default. Toggling it on adds the posterior curve **and** the posterior stat tile. Leave it off during the elicitation — it is the answer to a question you have not asked yet. |

The chosen view and the posterior setting persist across a page reload, so you
can set them up before the session and they will be as you left them.


## A slide-layout trap worth knowing

Quarto's `::: aside` is positioned **absolutely** at the bottom of a reveal
slide — it does not flow with the content. On a slide with a plot and several
paragraphs it lands *on top of* the text, which is unreadable and does not show
up in any structural check.

The deck now uses `::: {.calcnote}` for anything longer than a line or two.
That class is defined in `Presentations/edubron-slides.scss`, flows normally,
and is styled as small print on a pale panel. `::: aside` is still used, but
only for one- or two-line footnotes on slides that have room.

If you add content to a slide that already carries an aside, check it renders.
The three that were at risk (`What the room believes`, the `lm()` slide, and
the prior predictive conclusion) have been fixed — by splitting the first into
two slides, shortening the second's note, and converting the third to
`.calcnote`.


## Two things removed or corrected

**The prior predictive check is gone.** Both "What does that prior actually
say?" slides were removed — too early in Part 1 to land, and the machinery
(simulating from the prior, judging the implied data) belongs with the WAMBS
material in Part 2. The elicited σ from Q1 is still used: it is the prior on σ
in the grid approximation.

**The likelihood was being computed as a sum.** The two worked slides used
`sum(dnorm(CT, mu, sigma))`. The likelihood of a dataset is the **product** of
the per-observation densities, so those are now `prod(...)`.

This was not cosmetic. With the sum, the two combos ranked the wrong way round:

| combo | sum (wrong) | product (right) |
|:--|--:|--:|
| C1 μ=30, σ=13 — close to the data | 1.09e−04 | **3.64e−21** |
| C2 μ=45, σ=18 — the room's prior centre | **5.46e−04** | 5.23e−22 |

Under the sum, C2 won; under the correct product, C1 wins by about a factor of
7, which is what the grid plot has always shown. The slide told the opposite
story to the plot two slides later.

The correct products are around 1e−18, so `options(scipen = 1000000)` had to go
(it forced fixed notation and would have printed a wall of zeros). Why we move to logs — which is what the grid chunk was already doing with
`dnorm(..., log = TRUE)` — is now a two-line note on the **Grid approximation**
slide. That `sum()` is correct and was left alone: a sum of logs is a product of
densities.

## C1 / C2 made legible (18 Sep)

The two hand-scored parameter combinations are now colour-coded and labelled
everywhere they appear, instead of being unlabelled `blue` / `green` dotted
lines that matched nothing else in the deck:

- **C1** (μ = 30, σ = 13) — UA blue `#002e65`
- **C2** (μ = 45, σ = 18) — UA red `#ea2c38`

On the two marginal-posterior slides each dotted line carries a bold `C1` / `C2`
label pinned to the top of the panel (`y = Inf`), so the tie back to the
hand-calculated combos is visible without narration. On the 2-D grid plot the
viridis fill is too dark for navy, so C1 is white and C2 is the palette's
`#ff9aa2` red tint — the same red, lifted to stay readable on a dark ground.

The **Those numbers are tiny** slide was removed as an unnecessary side-step;
its one load-bearing sentence survives as a note on the grid slide. Part 1 is
now 69 slides.

## Running on the room's own answers (29 Sep)

Participants were emailed for their two ranges and their own commute. The deck
no longer has a single participant number typed into it.

### The one file you edit

`Data/room_2026.csv`, one row per person, header exactly:

```
ilo,ihi,lo,hi,own
10,60,35,55,28
15,70,40,60,35
```

- `ilo,ihi` — Q1, the 80% range for **individual** commutes
- `lo,hi`   — Q2, the 80% range for the **average**
- `own`     — that person's own one-way commute

Blanks are fine: someone who skipped a question is dropped from that
calculation only. Ranges typed backwards are silently corrected.
`Data/room_2026_TEMPLATE.csv` is a copy to start from.

### The three steps, the evening before

```r
source("R_code/fit_models.R")     # refits Mod_CT1 if the commutes changed
source("R_code/build_console.R")  # writes the pre-filled console
```
```bash
quarto render Presentations/Part1/Slides_Part1.qmd
```

`fit_models.R` compares the saved model's data with the CSV and refits only if
they differ, so this is fast unless the room actually changed.

### What now follows the room automatically

`R_code/elicitation.R` derives all of it and is the only place any of it lives:

| | |
|---|---|
| `sigma_prior` | Q1, pooled over everyone who answered it |
| `mu_prior`, `sd_prior` | Q2, pooled — **between**-person disagreement and **within**-person uncertainty, variances added |
| `CT` | their own commutes; the worked example runs on these |
| `C1`, `C2` | the two scored combinations: C1 = the data's own (mean, sd), C2 deliberately higher and wider |
| grid + axis limits | sized so both markers are always visible |
| "after k" labels | follow however many commutes came in |

The C1/C2 rule reproduces the combinations this example used when they were
picked by hand — fed the old ten commutes it returns (31, 13) and (47, 18)
against the hand-picked (30, 13) and (45, 18) — so the story is unchanged.

### The one thing that changed on a slide you have rehearsed

Q2 now **pools** across people instead of treating the room as one range, so
the small print shows $\sigma_0 = \sqrt{\text{between}^2 + \text{within}^2}$
rather than a single width divided by 2.563. This was forced: the console
displays the pooled number, and the slide has to agree with what is on screen
next to it.

### Watch the render message

`elicitation.R` prints a line every render:

```
elicitation.R: n = 18 | prior mu0 = 35.3 vs their actual mean = 34.1 | posterior favours C1
```

Usually C1 wins both the likelihood and the posterior. C1 always wins the
**likelihood**. But if the room's collective prior sits far from their own
data, the prior can outweigh a modest likelihood ratio and C2 shows the larger
Product on the slide. That is the prior doing its job, and it is a good moment
— but only if you knew before you were standing in front of them, which is why
it is announced. The message says so explicitly when it happens.

### The console

`source("R_code/build_console.R")` writes
`Prior_console/prior_console_filled.html` from the same CSV: it opens with
everybody already in it, with no "example data" badge, posterior still hidden.

Keep `prior_console_offline.html` for anyone answering live — type them in, or
paste `ilo, ihi, lo, hi, own` lines into the import box.

Two things worth knowing:

- The filled build gets its **own browser-storage key**. The console restores
  `localStorage` on boot, so without this it would quietly reopen on whatever
  was in it last time and ignore everything baked in. Re-running the builder
  starts clean from the new CSV; anything you add during the session is still
  remembered.
- It fetches its fonts from Google. With no wifi it still works, just in a
  system font.

If you build the console before the CSV exists it warns loudly and uses the
placeholder room — do not present that.

### While the CSV is missing

The deck still renders, on a placeholder room, and the "What the room believes"
slide carries a visible note saying so. The note disappears on its own once the
real file is there.

## Part 2 and the WAMBS template on the commuting model (30 Sep)

The template used to walk through the marathon example. It now runs on
`CommuteTimes_Mod2`, `CommuteTime ~ 1 + Distance_c + Departure_c`, the same
model Part 2 builds, so participants meet one model all day.

Everything quantitative was recomputed rather than substituted:

| | marathon | commuting |
|---|---|---|
| brms default intercept prior | `student_t(3, 199.2, 24.9)` | `student_t(3, 26.5, 12.4)` |
| brms default sigma prior | `student_t(3, 0, 24.9)` | `student_t(3, 0, 12.4)` |
| prior plot ranges | 120 to 300 | -20 to 75 |
| pp_check window | 120 to 300 | 0 to 80 |

The teaching arc survives intact. A `normal(0,10)` prior on `Distance_c` spans
the 42 km range of the data, implying predicted commutes swinging by more than
400 minutes against observed commutes of 10 to 65, so the prior predictive check
still throws up impossible negative medians and still gets fixed by tightening
to `normal(0,2)`.

Two sentences that used to assert results now compute them, because this is a
different model and a template must not state a result it has not checked:
the convergence paragraph reads the largest R-hat and smallest bulk ESS off the
summary table, and the prior sensitivity paragraph counts how many parameters
exceed 0.05 on each index. Both are phrased so they stay true whatever the
numbers turn out to be, which also makes the template safer for a participant
pointing it at their own model.

### Before rendering

`quarto render WAMBS_template/WAMBS_workflow_CommuteData.qmd` fits two
prior-only brms models, so it needs cmdstanr and takes a few minutes. The
rendered html it produces is what `WAMBS.qmd` and the Part 2 slides link to.
