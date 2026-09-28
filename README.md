# Atelier — Vue gallery storefront

A small Vue 3 storefront for the KZ-CR art gallery API. The first slice renders
the full artwork catalogue from `GET /api/items` as a responsive product grid.

## Run locally

Start the backend on port 5000, then launch the frontend with the setup script:

```bash
./run.sh
```

Open <http://localhost:5173>. Vite proxies `/api` and `/static` to
`http://127.0.0.1:5000`, so local development does not require extra CORS or
URL configuration.

The script installs dependencies on its first run. Use `./run.sh --help` for
host, port, and setup-only options.

For a deployed frontend, set `VITE_API_BASE_URL` to the public backend origin:

```bash
VITE_API_BASE_URL=https://api.example.com npm run build
```

## Commands

```bash
npm run dev       # local development server
npm run build     # production bundle
npm run preview   # preview the production bundle
```
