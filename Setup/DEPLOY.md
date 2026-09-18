# Shipping the site: GitHub + Netlify

Everything below is run in **Terminal on your Mac**, from the project folder:

```bash
cd ~/Library/CloudStorage/OneDrive-UniversiteitAntwerpen/Praatjes/Workshops/BSTAT_Edubron26
```

The deployment model is: **you render locally, Netlify just hosts the result.**
Netlify never runs R or Stan, so nothing can break in a build server you cannot
debug. GitHub holds the source; `_site/` is never committed.

---

## Step 0 - decide about OneDrive first

This folder lives inside OneDrive. Git and OneDrive both want to manage every
file in `.git/`, and OneDrive occasionally locks or re-writes files mid-commit,
which can corrupt a repository. It often works, until one day it doesn't.

Three options, best first:

1. **Move the project out of OneDrive.** Once it is on GitHub, GitHub *is* the
   backup, and you no longer need OneDrive for this folder:
   ```bash
   mv ~/Library/CloudStorage/OneDrive-UniversiteitAntwerpen/Praatjes/Workshops/BSTAT_Edubron26 \
      ~/Documents/BSTAT_Edubron26
   cd ~/Documents/BSTAT_Edubron26
   ```
2. **Exclude just this folder from syncing** in the OneDrive preferences.
3. **Do nothing** and accept the small risk. If you go this way and git ever
   reports a corrupt object, re-clone from GitHub.

Whichever you pick, run the rest from wherever the folder now is.

---

## Step 1 - tell git who you are

Only needed once per machine. Check first:

```bash
git config --global user.name
git config --global user.email
```

If either is empty:

```bash
git config --global user.name  "Sven De Maeyer"
git config --global user.email "sven.demaeyer@uantwerpen.be"
git config --global init.defaultBranch main
```

---

## Step 2 - create the repository locally

```bash
git init
git add .
git status --short | head -30      # sanity check before committing
```

`git status` should show around **90 files**. If you see `_site/`, `_archive/`
or hundreds of `.png` files under `*_files/`, stop - `.gitignore` is not being
picked up, and committing 60 MB of build output is hard to undo.

```bash
git commit -m "Edubron 2026 workshop site: UAntwerpen branding, commuting example"
```

---

## Step 3 - create the GitHub repository

Your `_quarto.yml` already links the sidebar GitHub icon to
`https://github.com/Sdemaeyer2/ABAR_Edubron2026`, so use exactly that name.

**With the GitHub CLI** (install once with `brew install gh`):

```bash
gh auth login                      # first time only
gh repo create Sdemaeyer2/ABAR_Edubron2026 --public --source=. --remote=origin --push
```

That creates the repo and pushes in one go - skip to step 4.

**Without the CLI:** create the repository at
<https://github.com/new>, named `ABAR_Edubron2026`, **empty** - no README, no
`.gitignore`, no licence, or the first push will be rejected. Then:

```bash
git remote add origin https://github.com/Sdemaeyer2/ABAR_Edubron2026.git
git branch -M main
git push -u origin main
```

If it asks for a password, that is a personal access token, not your GitHub
password: <https://github.com/settings/tokens> -> "Generate new token
(classic)" -> tick `repo`. Paste the token as the password.

---

## Step 4 - publish to Netlify

```bash
quarto publish netlify
```

On the first run this opens a browser to authorise Netlify, then asks you to
confirm creating a new site. It renders the whole site and uploads `_site/`.
Say **yes** when it offers to render before publishing.

It writes a small file, `_publish.yml`, holding the site's id. **Commit it** -
without it, the next publish creates a *second* site rather than updating this
one:

```bash
git add _publish.yml
git commit -m "Record Netlify site id"
git push
```

### Fix the site name

Netlify invents a random name like `spontaneous-pavlova-4f2a91`. Your Part 2
slides hard-code `bar-edubron2026.netlify.app`, so rename it:

Netlify dashboard -> the site -> **Site configuration** -> **Site details** ->
**Change site name** -> `bar-edubron2026`.

Then check that the links on the Part 2 slides resolve.

---

## Day-to-day, from here on

```bash
quarto preview                     # live preview while editing

git add -A
git commit -m "what changed"
git push                           # source to GitHub

quarto publish netlify             # rendered site to Netlify
```

The two are independent: pushing to GitHub does not update the live site, and
publishing does not commit anything. Do both.

---

## Before 1 October

- [ ] `quarto render` from a clean state and click through every page
- [ ] Check that each dataset and script link on Parts 1-4 downloads
- [ ] Open `Prior_console/prior_console_offline.html` from the live site:
      `bar-edubron2026.netlify.app/Prior_console/prior_console_offline.html`
- [ ] Confirm the three decks open and advance

### One thing to know about Netlify

Netlify's servers are **case-sensitive**; macOS is not. A link written as
`R_code/HOP_Script.R` pointing at a file actually named `HOP_script.R` works
perfectly on your laptop and returns 404 on the live site. Two such links on
the Part 3 page have already been fixed. If a download link ever 404s in
production but works locally, check the capitalisation first.
