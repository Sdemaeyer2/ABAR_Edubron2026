# Introduction to Bayesian Analyses with R

Workshop for **Edubron**, Faculty of Social Sciences, University of Antwerp
**1-2 October 2026**, room S.S.004, 09:00-16:00.
Sven De Maeyer - [bar-edubron2026.netlify.app](https://bar-edubron2026.netlify.app)

This repository holds the Quarto source of the workshop website and the
three reveal.js decks.

## Building the site

```bash
quarto render                 # whole site into _site/
quarto preview                # live preview while editing
quarto publish netlify        # render and deploy
```

Rendering executes R, so you need `brms` and a working `cmdstanr` toolchain.
Fitted models are read from `.RDS` files rather than refitted; if any are
missing, run `source("R_code/fit_models.R")` once (10-20 minutes).

## Layout

| Path | What is in it |
|---|---|
| `_quarto.yml` | Site definition: render list, sidebar, theme |
| `index.qmd`, `Part1-4.qmd`, `WAMBS.qmd`, `Links.qmd`, `about.qmd` | The website pages |
| `Presentations/Part1-3/` | The three decks, plus the images each one uses |
| `Presentations/Output/` | Fitted `brms` model objects the decks load |
| `Data/` | Datasets offered to participants for download |
| `R_code/` | Scripts for participants, plus `fit_models.R` and `simulate_commute.R` |
| `Integrated_exercise/` | Part 4 exercise, its answer key and models |
| `WAMBS_template/` | The WAMBS checklist worked through on the marathon data |
| `Prior_console/` | Live prior-elicitation console used at the start of Part 1 |
| `Setup/` | Run of show and the notes on how the commuting example is built |
| `Prerequisites/` | Install instructions for participants |

### Theming

Colours live in one place, `_uantwerpen-brand.scss`. Because Quarto processes
`scss:defaults` blocks in **reverse** order, that file must stay **last** in
every `theme:` list, both in `_quarto.yml` and in each deck's header.
`theme.scss` styles the website, `Presentations/edubron-slides.scss` the decks.

### The prior-elicitation console

`Prior_console/prior_console_offline.html` opens in any browser with no server.
It is also published with the site, so during the workshop it is reachable at
`bar-edubron2026.netlify.app/Prior_console/prior_console_offline.html`.

## Not in this repository

`_archive/` holds superseded material - the Zurich 2026 branding and decks,
marathon-era model objects, orphaned stylesheets and development scratch. It
stays on disk (and in OneDrive) but is excluded by `.gitignore`.

## Licence

Content CC-BY, Sven De Maeyer, 2026.
