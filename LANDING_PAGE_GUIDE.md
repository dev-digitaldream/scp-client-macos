# Landing Page Deployment Guide

## Overview

The landing page showcases SCP Client and provides download/installation instructions.

## File: `index.html`

Modern, responsive landing page built with Tailwind CSS.

## Deployment Options

### Option 1: GitHub Pages (Recommended)

```bash
git add index.html
git commit -m "docs: Add landing page"
git push
```

Then enable in repository Settings → Pages → main branch

### Option 2: Custom Domain

Update DNS to point to your server and configure web server (nginx/Apache).

### Option 3: Self-Hosted

Copy `index.html` and `dist/SCP-Client-macOS.dmg` to your web server.

## Customization

### Update Links

Replace these in `index.html`:
- `https://github.com` → your GitHub repository URL
- `dist/SCP-Client-macOS.dmg` → your DMG download URL

### Change Colors

Edit the gradient in `<style>`:
```css
background: linear-gradient(135deg, #3b82f6 0%, #1e40af 100%);
```

Available colors:
- Blue: `#3b82f6` (500), `#1e40af` (700)
- Purple: `#a855f7` (500), `#6d28d9` (700)
- Cyan: `#06b6d4` (500), `#0369a1` (700)

## SEO

The page includes:
- Meta description
- Mobile viewport
- Semantic HTML structure

Add social sharing meta tags if needed.

## Performance

- Uses Tailwind CDN (fast CDN delivery)
- Minimal CSS/JS
- Responsive design
- Optimized for all devices

## Accessibility

- Semantic HTML
- Color contrast compliant
- Keyboard navigation supported
- Alt text on images

## Testing

Test on:
- Desktop browsers (Chrome, Safari, Firefox)
- Mobile (iPhone, Android)
- Tablet (iPad)

## Update Frequency

Update when:
- New version released
- Features change
- Design refresh needed

Just replace `dist/SCP-Client-macOS.dmg` for new versions.

---

**Last Updated:** November 2024
