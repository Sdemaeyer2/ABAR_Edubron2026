# Live prior elicitation — how to run it

## The shape of the exercise

The point is not "collect a prior". It is to let the room *watch the data take
over*, in stages. That is why the reveal happens in four steps rather than one.

| # | Moment | What is on screen | What you say |
|:--|:--|:--|:--|
| 1 | **Ask** | the question only, aggregate hidden | "Low and high you'd bet on. Write it down before you hear anyone else's." |
| 2 | **Collect** | still hidden | go round the room, type as they call out — ~20 people takes 2 minutes |
| 3 | **Reveal the prior** | the range bars + pooled prior | "This is what we collectively believe before seeing any data." |
| 4 | **Update, twice** | posterior after 5, then after everyone | "Five people already moved us this far. Everyone moves us here." |
| 5 | **Then the real data** | switch to `CommuteData` (n = 90) | "And 90 observations do this." |

Step 4 is the one that earns the exercise, and it is worth being deliberate
about — see the caveat below.

## Why step 4 matters (and an honest caveat)

I checked this by grid approximation. With a typical elicited prior of
35–55 min (→ μ₀ ≈ 45, σ₀ ≈ 7.8):

| updated with | posterior μ | posterior sd |
|:---|---:|---:|
| first 5 answers | 28.4 | 4.53 |
| the whole room (n = 20) | 25.0 | 2.07 |
| the prepared dataset (n = 90) | 30.8 | 1.25 |

The **shift** is dramatic at every step. But here is the caveat worth knowing
before you build a session around it: once you have 20 observations, *which*
prior the room gave barely matters. Eliciting 20–30 instead of 45–75 moves the
n = 20 posterior only from 23.8 to 24.6.

So if you want the room to feel that **priors matter**, you must stop at the
five-person step, where the prior is still visibly doing work. If you only show
the full-room update, the honest lesson is the opposite one — "with enough data
the prior washes out" — which is also worth teaching, but it is a different
point. Decide which one you are making.

## Anchoring

People who hear someone else's number before writing their own will converge on
it, and your "disagreement" spread collapses. Two precautions:

- Have everyone write their low–high on paper *first*, then read them out.
- Keep the console's aggregate hidden until step 3 — the **Hide aggregate**
  button blurs the whole right-hand panel, and **Reveal to the room** brings it
  back.

## Getting the numbers into the console

The console is a **presenter tool**: you drive it, participants don't open it.
That is deliberate — published artifacts only accept writes from people inside
your own organisation, so external workshop participants would land on it
read-only. Driving it yourself also removes any dependence on 20 phones finding
the WiFi.

Three ways in, in order of robustness:

1. **Type as they call out.** Tab through low / high / own-minutes / own-km,
   Enter, next person. This is the default and it is fast.
2. **Paste from a form.** If you'd rather they submit on their phones, put the
   four questions in a Microsoft Form (you have this through UAntwerpen),
   export the responses, and paste the columns into the *Or paste from a form*
   box — one person per line, comma-separated.
3. **Paper slips**, then type them in during the coffee break.

The console keeps its state across a page reload, so nothing is lost if you
close the tab mid-session.

## Getting the numbers into the slides

The console writes the `brm()` call for you, with the room's actual μ₀ and σ₀
substituted in, plus a `tibble()` of the room's own commutes. **Copy R code**
puts it on the clipboard. Paste it into a chunk in Part 1 and run it live.

For the slides themselves, the cleanest wiring is a small block near the top of
`Slides_Part1.qmd`:

```r
# Filled in live during the session
room_low  <- 35   # <- replace
room_high <- 55   # <- replace

mu_prior <- (room_low + room_high) / 2
sd_prior <- (room_high - room_low) / 2.56
```

Then every later slide refers to `mu_prior` / `sd_prior` rather than a
hardcoded number, and you re-render the deck once during the break. If
re-rendering mid-workshop feels risky, keep the deck static and do the live
update in a separate Quarto document or straight in the console.

## Timing

| | |
|:--|:--|
| ask + write down | 2 min |
| go round the room | 2–3 min |
| reveal prior, discuss the spread | 3 min |
| prior predictive check (the negative commutes) | 4 min |
| the two updates | 4 min |
| **total** | **~15 min** |

## Fallback if the room is small

Below about 8 people the pooled σ₀ gets unstable — one outlying range dominates
it. If that happens, drop the pooling and just use the median low and median
high as the prior interval; the console shows you the individual bars so you
can see whether one person is driving it.
