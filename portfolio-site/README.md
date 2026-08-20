# Your Name — Portfolio

A plain HTML/CSS/JS portfolio site, ready for GitHub Pages. No build step, no framework — edit the HTML files directly.

## What's new in this version

- **Subtle interactive background on every page** — a faint constellation of connected dots (`js/main.js`) that drifts on its own and gently reacts to your cursor on desktop. Colors adapt automatically to light/dark mode, it goes still for visitors with reduced-motion settings, and it's simplified on small screens.
- **Dedicated `contact.html` page** — full contact details (email/phone with copy buttons), availability, response time, location, and LinkedIn/GitHub, not just a link back to the homepage. The homepage still keeps its own contact section in the footer, as before.
- **"Things I Build" renamed to "Fun Projects"** — the file is now `fun-projects.html`; the old `things-i-build.html` URL still works and redirects automatically, in case it's bookmarked anywhere.
- **Small profile photo slot on the About page** — shows a "YN" placeholder monogram until you drop a real photo into `assets/profile.jpg` (see below), then it displays automatically.
- **Sage-green ombre background** across every page (light + dark mode), with a subtle glow in the hero that drifts toward your cursor on desktop
- **Laptop favicon** (`favicon.svg`)
- **Scroll-reveal animations** on cards/figures/stats, plus animated count-up numbers on key stats
- **Contact info wired in** — both your emails and phone number, with copy-to-clipboard buttons, on the homepage `#contact` section, the new contact page, and in every footer
- **`resume.html` page**, linked in the nav on every page — shows a placeholder until you drop a PDF into `assets/resume.pdf` (see below)
- **All gathered images/video placed** into Riverside, Inventory, Madison, and Wearable project pages
- **Real code + data files** from the wearable build are now downloadable directly from `fun-projects.html`
- **Mobile responsiveness pass** — finer breakpoints under 480px, tables scroll horizontally instead of breaking on small screens, video/images fully fluid, and a fix for a horizontal-scroll bug on mobile caused by the hero glow effect

## File map

```
index.html              → homepage (hero + project grid + contact)
about.html               → about page (now with a small profile-photo slot)
contact.html               → dedicated contact page (full details, not just a link home)
resume.html               → resume page (auto-embeds assets/resume.pdf once you add it)
fun-projects.html          → CAD / hardware / build projects + downloadable code
things-i-build.html        → old URL, auto-redirects to fun-projects.html
projects/
  riverside.html           → private equity analytics case study
  inventory.html            → supply chain simulation case study
  madison.html                → AI research chatbot case study (includes demo video)
  balto.html                    → transit equity qualitative research case study
  wearable.html                   → AI wearable privacy research case study
css/style.css            → all styling (colors, type, layout — edit tokens at the top)
js/main.js                → theme toggle, mobile nav, scroll reveal, hero glow, ambient background, copy buttons, stat counters
favicon.svg               → laptop icon favicon
assets/                   → images, the Madison demo video, and downloadable code/data files
assets/code/               → real .ino/.pde firmware + sample CSVs from the wearable build
assets/profile.jpg         → your photo for the About page (add this file — see below)
```

## Before you publish — things to swap out

Search each HTML file for these placeholders and replace them:

- **"Your Name"** and the **"yn"** logo initials — in the `<header>` of every page
- **linkedin.com/in/yourname** and **github.com/yourname** — your real profile URLs (email and phone are already filled in)
- **about.html** — the bio is still a placeholder. Answer for yourself: what kind of analyst/researcher are you, what industries interest you, one sentence a hiring manager should remember.
- **assets/resume.pdf** — send me the PDF and I'll drop it in; the resume page is already wired to display it automatically once it's there. Same filename = zero HTML changes needed.
- **assets/profile.jpg** — add a photo of yourself with this exact filename and it'll automatically replace the "YN" placeholder circle on the About page. No HTML changes needed.

Every project page pulls directly from what you gave me — role, numbers, findings, real charts. If something reads slightly off from how you'd actually describe it, tell me which project and what to change and I'll fix that section directly.

## Publishing to GitHub Pages (free, no server needed)

1. Create a new GitHub repository. If you want your site at `https://yourusername.github.io`, name the repo exactly `yourusername.github.io`. Otherwise, name it anything (e.g. `portfolio`) and it'll be served at `https://yourusername.github.io/portfolio/`.
2. Push these files to that repository:
   ```
   git init
   git add .
   git commit -m "portfolio site"
   git branch -M main
   git remote add origin https://github.com/yourusername/REPO-NAME.git
   git push -u origin main
   ```
3. On GitHub, go to the repo's **Settings → Pages**.
4. Under "Build and deployment," set **Source** to "Deploy from a branch," branch **main**, folder **/ (root)**. Save.
5. Wait a minute or two, then visit the URL GitHub gives you (shown on that same Pages settings screen).

One thing worth knowing about GitHub's limits: the repo is currently light (a few MB total, including the demo video), well under GitHub's 1GB soft repo-size guidance and 100MB hard per-file cap — no Git LFS needed.

## Dark mode & interactivity

The circle icon in the nav toggles dark mode and remembers the visitor's choice. Cards and figures fade in as you scroll past them; this respects `prefers-reduced-motion` for visitors who've turned off animations at the OS level. The cursor-reactive glow in hero sections is desktop-only and also respects reduced-motion settings.

## Still pending from you

- **Resume PDF** for `resume.html`
- **Your photo** for `assets/profile.jpg` (About page)
- **Balto project** — no images were sent for this one yet (confidentiality means it may stay text/diagram-only, which is fine and matches the source material's own guidance)
- Any additional CAD/3D-printing files you mentioned for "Fun Projects" (ring, phone case, etc.)

