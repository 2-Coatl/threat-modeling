# Threat Modeling UI

This package provides the browser interface for the platform using a modular monolith approach on top of React and webpack.

## Project layout

```
ui/
├── public/               # Static assets copied as-is (HTML entry point, favicons, etc.)
├── src/
│   ├── app/              # Application bootstrap and global providers
│   ├── components/       # Layout primitives shared by feature modules
│   ├── hooks/            # Shared hooks (configuration, data, etc.)
│   ├── modules/          # Feature slices that register themselves with the shell
│   └── pages/            # Route-level React components composed from modules
├── babel.config.cjs      # Babel presets (React + modern JavaScript)
├── webpack.config.cjs    # Bundler entry point and shared build settings
└── package.json          # npm metadata, scripts, and dependency manifest
```

Each feature module exposes its public surface through an `index.js` barrel file so the shell can mount it without creating tight coupling between packages. Shared styling lives in `src/styles/global.css` to keep feature-specific styles colocated with the module code.

## Local development

```bash
cd ui
npm install
npm run start
```

The dev server starts on port `3000` by default and hot-reloads React components while preserving state between edits.

> **Note:** Some sandboxed environments inject `HTTP_PROXY` / `HTTPS_PROXY` variables that block direct access to the npm registry. If you encounter HTTP 403 errors during `npm install`, unset those variables for the current shell: `unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY npm_config_http_proxy npm_config_https_proxy`.

## Production build & tests

```bash
cd ui
npm install
npm run test   # wraps `npm run build` to ensure production bundles compile
```

The production build emits hashed assets to `dist/` and validates that all modules can be bundled together. CI systems can call `npm run test` to catch regressions introduced by module registration or webpack configuration changes.
