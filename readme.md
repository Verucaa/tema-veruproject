# VeruProject Premium Theme — Pterodactyl v1.x

Modern futuristic theme: background video, sidebar navigation, animated
logo loader, custom logo + favicon, credit footer.

## Requirements

- Pterodactyl Panel **v1.x** (Laravel)
- Blade files must be re-applied after every panel update (`php artisan view:clear`)

## How v1.x is themed (important)

The client area (login, register, 2FA, dashboard, server list, console,
files, account) is a **React SPA** mounted into `<div id="app"></div>` by
`resources/views/templates/wrapper.blade.php`. The `/admin` area is a
separate server-rendered AdminLTE layout at
`resources/views/layouts/admin.blade.php`.

This theme overrides **both**:

- `resources/views/templates/wrapper.blade.php` → login + all client pages
- `resources/views/layouts/admin.blade.php` → the `/admin` control area

## Package layout

```
veruproject-theme/
├── install.sh
├── readme.md
├── public/themes/veruproject/{css/app.css,js/app.js}
└── resources/views/
    ├── templates/wrapper.blade.php
    └── layouts/admin.blade.php
```

## Install

1. Copy the package to your panel server.
2. Run: `bash install.sh /var/www/pterodactyl` — opens an interactive menu:

   ```
   [1] Install tema
   [2] Hapus tema
   [3] Perbaiki tema
   [4] Keluar
   ```

   - **[1] Install** — copies CSS + JS, backs up the two Blade files to
     `*.bak-<timestamp>-<pid>-<rand>`, then replaces them.
   - **[2] Hapus** — removes `public/themes/veruproject` and restores the two
     Blade files from the **oldest** backup (the original pre-theme file),
     then deletes all backups.
   - **[3] Perbaiki** — re-copies assets and re-applies the Blade files after
     a panel update (same as install).
   - **[4] Keluar** — exit.

3. Non-interactive: `bash install.sh /var/www/pterodactyl --yes`
   (`--yes` first or last, both work; `VP_FORCE=1` also forces install).
4. Clear the view cache: `cd /var/www/pterodactyl && php artisan view:clear`
5. Hard-refresh the panel (Ctrl+Shift+R) to bypass cached CSS/JS.

The script refuses to run unless `<PANEL_DIR>/artisan` exists.

IMPORTANT: before replacing the Blade files, diff them against your panel's
own copies. If your panel minor version differs, keep your panel's file as
the base and port only the marked `vq-` blocks (loader, video, credit,
favicon, fonts) plus the `<link>`/`<script>` tags into it.

## What changes

- **Background video** `https://cdn.veru.qzz.io/wWG4t8.mp4` on login + all
  client pages and the admin area, with a dark gradient fallback if it fails.
- **Fonts**: Orbitron (headings) + Inter (body) via Google Fonts `<link>`.
- **Navigation**: admin area keeps its AdminLTE sidebar (restyled). The
  client-area top nav is turned into a left sidebar via gated CSS.
- **Loader**: fullscreen logo loader counting 0 → 100 on every page load
  (full once per session, fast sweep after).
- **Logo + favicon**: replaced with `https://cdn.veru.qzz.io/uDgbtf.png`.
- **Credit**: `Template oleh VeruProject` on client + admin pages.

## Client-area sidebar — known limit

The React SPA ships its own top navigation. Converting it to a sidebar is
done by CSS that is **gated**: `app.js` adds a `vq-spa-sidebar` body class
only when it finds the stock nav structure (the Tailwind classes emitted by
`resources/scripts/components/NavigationBar.tsx`). If a panel update changes
those classes, the gate simply stops applying and the default top nav
returns — no breakage, but the sidebar effect is lost until the selectors in
`css/app.css` (`body.vq-spa-sidebar …`) are updated. Best-effort by design.

## Manual URL checklist

1. Video: https://cdn.veru.qzz.io/wWG4t8.mp4
2. Logo/favicon: https://cdn.veru.qzz.io/uDgbtf.png
3. Fonts: https://fonts.googleapis.com/css2?family=Orbitron:wght@500;700;900&family=Inter:wght@400;500;600;700&display=swap

## Changing the background video / logo

- Video URL: the `<video>` tag in `resources/views/templates/wrapper.blade.php`
  and in `resources/views/layouts/admin.blade.php`.
- Logo URL: the favicon `<link>` tags in both Blade files, the admin logo
  `<img>`, and `LOGO` in `public/themes/veruproject/js/app.js` (loader).

## Uninstall

Run `bash install.sh /var/www/pterodactyl` and pick **[2] Hapus** — it
restores the original Blade files from the oldest backup and removes the
theme assets. If no backup exists it leaves the Blade files as-is.

## License

MIT — see [LICENSE](LICENSE).

## Known limits

- Loader percentage is a timed animation (0→100), not real load progress.
- Blade files break on panel updates — re-apply with **[3] Perbaiki** after each.
