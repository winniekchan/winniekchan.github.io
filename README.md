# Winnie Chan — personal website

Live at **https://winniekchan.github.io**

A single-page site in plain HTML and CSS. There's no build step: edit the files and refresh the browser.

## Files

| File | What it is |
| --- | --- |
| `index.html` | All page content. Edit text here. |
| `styles.css` | Colors, fonts, layout. The tokens (colors, fonts) are at the top. |
| `script.js` | Mobile menu, sticky Kepler heading offset, footer year. |
| `assets/Winnie_Chan_Resume.pdf` | The downloadable resume (phone number removed). |
| `assets/headshot.jpg` | Your photo, cropped from the original (which isn't published). |
| `assets/favicon.svg` | Browser tab icon. |
| `start-dev.cmd` / `dev-server.ps1` | Local preview server with live reload (not needed for hosting). |

## To-do

1. **About me:** rewrite the draft in the `#about` section in your own voice.
2. **Resume PDF:** it still has older wording and your graduation date. When you update your Word resume, remove your phone number, then save it as a PDF over `assets/Winnie_Chan_Resume.pdf` (Word → File → Save As → PDF).

## Preview locally (with live reload)

Double-click **`start-dev.cmd`**. It opens http://localhost:5500 in your browser, and the page updates whenever you save a file:
- **CSS changes** show up immediately, with no page reload.
- **HTML, JS, and image changes** reload the page.

To stop the server, close the window or press Ctrl+C. If port 5500 is busy, run it from a terminal with a different port:

```
powershell -ExecutionPolicy Bypass -File dev-server.ps1 -Port 5501
```

The server is the `dev-server.ps1` file. It uses only built-in Windows PowerShell, so there's nothing to install.

## Publishing updates

The site is hosted by GitHub Pages from the `main` branch of
[winniekchan/winniekchan.github.io](https://github.com/winniekchan/winniekchan.github.io).
Any change pushed to `main` goes live within a minute or two:

```
git add .
git commit -m "Describe the change"
git push
```

### Custom domain (optional)

Buy a domain (e.g. `winniechan.com`), add it under **Settings → Pages → Custom domain**, and follow GitHub's DNS instructions.
