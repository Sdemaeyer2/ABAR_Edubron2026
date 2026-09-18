# Branding — how the colours work

All colours for this project live in **one file**: `_uantwerpen-brand.scss`.
Change a value there and it changes on the website *and* on all three slide
decks. No other file should contain a hex code.

## Palette

Official UAntwerpen house style
(<https://www.uantwerpen.be/en/projects/uantwerp-style-guide/colours/>):

| Variable | Value | Used for |
|:--|:--|:--|
| `$ua-blue` | `#002e65` | sidebar, headings, slide text, dark slides |
| `$ua-red` | `#ea2c38` | accents, highlights, rules |
| `$ua-red-dark` | `#c41f2b` | links (AA-contrast version of the red) |
| `$ua-red-deep` | `#9c1721` | link hover |
| `$ua-red-tint` | `#ff9aa2` | red that stays readable *on* the navy |
| `$ua-red-pale` | `#fbe3e5` | inline-code and marker backgrounds |
| `$ua-blue-mid` | `#1b4a7a` | code, secondary headings |
| `$ua-blue-pale` | `#e6ecf3` | table stripes, code blocks |
| `$ua-paper` | `#f7f8fa` | page background |

Every text/background pair in the theme was checked against WCAG AA
(4.5:1 for body text, 3:1 for large text). All 21 pairs pass.

## Which file does what

| File | Purpose |
|:--|:--|
| `_uantwerpen-brand.scss` | the palette — the only place with hex codes |
| `theme.scss` | website styling (uses the palette) |
| `Presentations/edubron-slides.scss` | reveal.js styling for all 3 decks |

## The one Quarto gotcha

`_uantwerpen-brand.scss` **must be listed last** in every `theme:` list:

```yaml
# _quarto.yml
theme: [cosmo, theme.scss, _uantwerpen-brand.scss]
```

```yaml
# Presentations/PartN/Slides_PartN.qmd
theme: [default, ../edubron-slides.scss, ../../_uantwerpen-brand.scss]
```

Quarto processes the `scss:defaults` blocks of theme files in **reverse**
order, so "last in the list" means "defined first" — which is what makes the
palette variables available to the other two files. Put it first and the
render fails with `Undefined variable: $ua-blue`.

## Semantic classes instead of inline styles

The slide decks used to carry ~30 hardcoded spans like
`[text]{style="color: #d28e43"}`. Those are now:

| Markdown | Renders as |
|:--|:--|
| `[text]{.hl}` | UA red, bold — the main highlight |
| `[text]{.hl-blue}` | mid blue, bold — file names, secondary emphasis |
| `[text]{.marker}` | red on a pale red chip — parameter values |

These work on the website pages too. On dark `{background-color="#002e65"}`
slides they automatically switch to the light-on-navy variants.

## Reverting

The original Zurich versions of every changed file are in
`_backup_zurich2026/`, including the old slide SCSS files under
`_backup_zurich2026/orphaned_scss/`.
