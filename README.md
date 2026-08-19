# Elm + Astryx Admin Dashboard

A framework-safe example of using Elm 0.19.2 with Astryx.

## Important architecture note

Astryx's official UI components require React 19+, so this example does **not**
try to render React components inside Elm.

Instead it uses the framework-independent parts that Astryx publishes:

- `reset.css`
- `astryx.css`
- `@astryxdesign/theme-neutral/theme.css`
- Astryx CSS custom properties / design tokens

Elm remains responsible for:

- state
- tabs
- modal behavior
- table rendering
- search
- form validation
- order creation

This avoids running two competing UI state systems.

## Features

- Admin sidebar
- Overview, Orders, Products tabs
- Responsive KPI cards
- Searchable orders table
- Status badges
- Create-order modal
- Form validation
- Priority-order checkbox
- Product cards
- Astryx theme tokens
- Responsive layout

## Install

```bash
npm install
```

## Build

```bash
npm run build
```

The build performs:

```text
copy Astryx CSS/theme -> dist/
compile Elm -> dist/elm.js
```

## Run

```bash
npm run dev
```

or:

```bash
elm make src/Main.elm --output=dist/elm.js
elm reactor
```

Open:

```text
http://localhost:8000/index.html
```

## Project structure

```text
elm-astryx-admin-dashboard/
├── elm.json
├── package.json
├── index.html
├── README.md
├── scripts/
│   └── copy-astryx.mjs
├── src/
│   └── Main.elm
├── styles/
│   └── app.css
└── dist/
```

## Why copy the CSS?

Browsers cannot resolve npm package imports such as:

```css
@import '@astryxdesign/core/astryx.css';
```

without a bundler.

The small Node script copies Astryx's published pre-built CSS into `dist/`.
That keeps the project simple and avoids introducing Vite, Webpack, Sass, or React.

## Production direction

For a larger Elm admin app, split `Main.elm` into:

```text
src/
├── Main.elm
├── Route.elm
├── Domain/
├── Api/
├── Pages/
│   ├── Dashboard.elm
│   ├── Orders.elm
│   └── Products.elm
└── Ui/
    ├── Modal.elm
    ├── Tabs.elm
    ├── Table.elm
    ├── Button.elm
    └── Badge.elm
```

Astryx can continue providing tokens and visual foundations while Elm owns
application behavior.
