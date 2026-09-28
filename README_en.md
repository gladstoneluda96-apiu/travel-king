<div align="center">
  <img src="frontend/public/icon.png" width="140" alt="Travel King" />

# Travel King (旅游大王)

**An AI travel planning assistant**: describe your destination and preferences, get an executable itinerary

[![License: GPL-2.0](https://img.shields.io/badge/license-GPL--2.0-orange)](LICENSE)
[![Vue](https://img.shields.io/badge/vue-3.5-brightgreen)](https://vuejs.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-teal)](https://fastapi.tiangolo.com/)
[![Python](https://img.shields.io/badge/python-3.10+-blue)](https://www.python.org/)

[中文](README.md) | [English](README_en.md) | [日本語](README_ja.md)

</div>

---

## Attribution

> **This project is a derivative of [1sdv/TripStar](https://github.com/1sdv/TripStar)**, released under the upstream **GPL-2.0** license.
> We redesigned the UI, added a light theme, rebuilt the itinerary preview interaction, added a fallback chain for
> attraction photos, and renamed the project. The detailed list of modifications is in [NOTICE](NOTICE).
> All copyright of the upstream project belongs to its original authors. This project is not affiliated with
> or endorsed by them.

> 📌 **Please read the [Project Declaration](DECLARATION.md) before use**: it covers attribution,
> the non-commercial usage scope, third-party service compliance and privacy.

## What it does

Planning a trip usually means jumping between platforms: reading notes, checking weather, comparing hotels,
estimating budgets, ordering routes. Travel King collapses that into one screen: **describe your destination
and preferences, and it produces an itinerary you can actually follow**.

The result is a verifiable plan rather than a static list: attractions come with addresses and suggested
durations, spots requiring advance booking are flagged, transport and meals come with concrete suggestions,
the budget is itemised, a map and a knowledge graph visualise the route, and you can keep asking follow-up
questions about the plan.

## Highlights

| Feature | Description |
| --- | --- |
| Itinerary generation | Async task with live progress (searching attractions, checking weather, generating the plan) |
| Multi-city trips | Several cities in one trip, per-city stay length, automatic totals and inter-city transport day |
| Attraction extraction | Structured extraction from real travel notes (name, reason, duration, booking tips) plus geocoded coordinates |
| Weather & hotels | Weather by city and date; hotels matched to your accommodation preference and included in the budget |
| Budget breakdown | Tickets, meals, accommodation, transport and inter-city transport, expandable per item |
| Attraction map | Real coordinates with markers and route lines, map style follows the app theme |
| Daily itinerary | Per-day ordering, durations, transport, meals, accommodation and pitfall tips |
| Knowledge graph | Interactive graph of city → days → attractions / meals / hotels / budget |
| AI travel Q&A | Follow-up questions with the full itinerary as context, plus quick prompts |
| Guide image export | One-click long-image export containing itinerary, budget, map and weather |
| i18n | Chinese, English and Japanese for both UI and generated content |
| Light / dark theme | Follows the system by default, manual toggle is persisted; map and graph follow the theme |
| Local-first | Keys and data stay on your machine, no account needed, tasks and images cached locally |

## Quick start

### Requirements

Python 3.10+ (or [uv](https://docs.astral.sh/uv/) to manage it) and Node.js 18+ with npm.

### 1. Clone and configure

```bash
git clone https://github.com/gladstoneluda96-apiu/travel-king.git
cd travel-king
cp .env.example .env
cp frontend/.env.example frontend/.env
```

Four kinds of credentials are needed. They can also be filled in later from the in-app settings dialog
(changes take effect immediately):

| Variable | Required | Purpose |
| --- | --- | --- |
| `LLM_API_KEY` / `LLM_BASE_URL` / `LLM_MODEL_ID` | Yes | Any OpenAI-compatible provider (DeepSeek in our example). Pick a model good at long structured output |
| `VITE_AMAP_WEB_KEY` | Yes | Amap Web Service key: geocoding, weather, POI, static map ([apply here](https://lbs.amap.com/)) |
| `VITE_AMAP_WEB_JS_KEY` / `VITE_AMAP_SECURITY_JS_CODE` | Yes | Amap JS API key and its security code, injected at build time for map rendering |
| `XHS_COOKIE` | Optional | Xiaohongshu (RED) web cookie. Without it the app falls back to Amap attraction photos |
| `GOOGLE_MAPS_API_KEY` / `GOOGLE_MAPS_PROXY` | Optional | Only if you want the Google Maps engine |

### 2. Install and run

```bash
# backend
uv venv backend/.venv --python 3.10
uv pip install --python backend/.venv/bin/python -r backend/requirements.txt
cd backend && npm install && cd ..

# frontend build (served by the backend on the same origin)
cd frontend && npm install && npx vite build && cd ..

# run
cd backend && .venv/bin/uvicorn app.api.main:app --host 0.0.0.0 --port 7870
```

Open <http://localhost:7870>. API docs are at `/docs`.

On macOS you can instead use the helper scripts: `bash scripts/install-service.sh` (registers a launch agent
that starts on login and restarts on failure), `scripts/local-start.sh`, `scripts/local-stop.sh`,
`scripts/uninstall-service.sh`.

> Only one process is needed: the backend serves both the API and the built frontend. The Amap MCP service
> (for weather and hotels) and the Node-based signing engine (for Xiaohongshu) are spawned on demand; there is
> no database to deploy.

## How it works

```
Browser ──POST /api/trip/plan──▶ returns task_id immediately (async task)
   │                                    │
   │                        concurrent: attractions + weather + hotels
   │                                    │
   │                        LLM aggregates a structured itinerary (with JSON repair)
   │                                    │
   └──poll /api/trip/status/{id}──◀ task persisted, returns plan + knowledge graph
```

Attraction photos use a three-step fallback: **Xiaohongshu photo → Amap POI photo → designed placeholder**,
with short negative caching and rate-limit cooldown to avoid hammering third-party endpoints.

See [项目文档/01-技术大纲.md](项目文档/01-技术大纲.md) for the full architecture, modules and design decisions (Chinese).

## FAQ

| Symptom | Cause and fix |
| --- | --- |
| Plan generation fails asking for a cookie | Set `XHS_COOKIE`; this project already degrades gracefully without it |
| Photos show as placeholders | Xiaohongshu search is rate-limited; the app falls back to Amap. Retry later or refresh the cookie |
| Xiaohongshu cookie expired | Log in again on the web, copy the `Cookie` request header (needs `a1`, `web_session`, `webId`) |
| Blank map | Check the Amap JS API key and security code, then rebuild the frontend |
| Port already in use | Change `PORT` in `.env` or stop the running service first |

## License and attribution

- Licensed under **GPL-2.0**, full text in [LICENSE](LICENSE)
- Derivative of [1sdv/TripStar](https://github.com/1sdv/TripStar); thanks to the original authors
- Third-party components and fonts: [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)

### Usage scope (important)

This project depends on **HelloAgents** (<https://github.com/jjyaoao/HelloAgents>), licensed under
**CC-BY-NC-SA-4.0 (non-commercial, share-alike)**. That conflicts with GPL-2.0's permission of commercial
use, so any distribution including that dependency must be treated as **non-commercial personal use only**,
with attribution kept and the HelloAgents-related parts shared under the same license. Replacing that
dependency is required if you want commercial use or a clean GPL-2.0-only release.
