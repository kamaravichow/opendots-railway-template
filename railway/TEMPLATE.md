# OpenDots on Railway

This folder holds everything needed to publish OpenDots as a Railway template. Railway templates are composed in the dashboard (there is no template file to commit), so this guide is the exact spec to enter in the composer.

## Architecture

| Service    | Dockerfile                  | Public | Volume  | Healthcheck |
| ---------- | --------------------------- | ------ | ------- | ----------- |
| `OpenDots` | `railway/Dockerfile.app`    | yes    | `/data` | `/`         |
| `Browser`  | `railway/Dockerfile.browser`| no     | none    | none        |

`OpenDots` reaches `Browser` over Railway private networking. `Browser` is optional: it only powers the public-page reading tool, and its `/health` route requires the bearer secret, so Railway cannot healthcheck it.

## Create the template

1. Push this repo to your own GitHub account (Railway deploys from GitHub).
2. Open **Workspace settings → Templates → New Template** and add two services from that GitHub repo, named exactly `OpenDots` and `Browser` (the references below depend on the names).
3. Configure each service as below, then click **Create Template**.
4. Deploy it once from the template URL and verify (see "Verify" below).
5. Click **Publish** on the Templates page and fill out the form. Use the overview text from the last section.

## `OpenDots` service

Settings: public HTTP networking on, healthcheck path `/`, volume mounted at `/data`.

| Variable                | Value                                          | Description                                                                              |
| ----------------------- | ---------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `RAILWAY_DOCKERFILE_PATH` | `railway/Dockerfile.app`                     | Selects the app image (hide from users).                                                 |
| `RAILWAY_RUN_UID`       | `0`                                            | Railway volumes are root-owned; without this the `node` user cannot write `/data`.       |
| `PORT`                  | `4310`                                         | Port the server listens on and Railway healthchecks.                                     |
| `OWNER_TOKEN`           | `${{secret(48)}}`                              | Password to unlock OpenDots. Find it in this service's Variables tab.                    |
| `APP_ORIGIN`            | `https://${{RAILWAY_PUBLIC_DOMAIN}}`           | Exact public origin; required, or the app rejects requests behind Railway's TLS proxy.   |
| `BROWSER_SECRET`        | `${{secret(48)}}`                              | Shared secret between the app and the Browser service.                                   |
| `BROWSER_URL`           | `http://${{Browser.RAILWAY_PRIVATE_DOMAIN}}:4311` | Private-network address of the Browser service.                                       |
| `OWNER_ID`              | `opendots-owner`                               | Stable identity that owns your conversations. Do not change after first use.             |
| `INTELLIGENCE_API_KEY`  | _(empty, required)_                            | CopilotKit Intelligence project key, from https://cloud.copilotkit.ai.                   |
| `OPENAI_API_KEY`        | _(empty, required)_                            | API key for the model provider.                                                          |
| `OPENAI_MODEL`          | _(empty, required)_                            | Model identifier, for example `gpt-5`.                                                   |
| `OPENAI_BASE_URL`       | `https://api.openai.com/v1`                    | Optional. Any OpenAI-compatible endpoint.                                                |
| `VOICE_API_KEY`         | _(empty)_                                      | Optional. Enables realtime voice.                                                        |
| `VOICE_MODEL`           | _(empty)_                                      | Optional. Realtime voice model.                                                          |
| `SLACK_CHANNEL_NAME`, `SLACK_TEAM_ID`, `SLACK_USER_IDS` | _(empty)_      | Optional Slack channel. See `docs/SETUP.md#slack`.                                       |

Mark the three required variables as required in the composer so users are prompted at deploy time.

## `Browser` service

Settings: no public networking, no volume.

| Variable                  | Value                         | Description                                          |
| ------------------------- | ----------------------------- | ---------------------------------------------------- |
| `RAILWAY_DOCKERFILE_PATH` | `railway/Dockerfile.browser`  | Selects the browser image (hide from users).         |
| `BROWSER_SECRET`          | `${{OpenDots.BROWSER_SECRET}}`| Same secret as the app; requests without it get 401.|

## Verify

1. Both services deploy; `OpenDots` shows a public domain.
2. Open the domain, enter `OWNER_TOKEN` when prompted. With the three required keys set the setup banner disappears.
3. Check the `Browser` logs show it is listening, then ask a Dot to read a public URL.
4. Redeploy `OpenDots` and confirm pages and settings persist (volume check).

Known risk to confirm on first deploy: Chromium runs as the non-root `node` user with its default sandbox. If the browser tool fails with a sandbox or user-namespace error in the `Browser` logs, the Browser service needs a different runtime setup; the rest of OpenDots is unaffected.

## Template overview (paste into the publish form)

# Deploy and Host OpenDots with Railway

OpenDots is a self-hosted personal-agent workspace from CopilotKit. It gives you Dots (specialist agents), Spaces, collaborative pages, scheduled tasks, voice, Slack channels and an isolated browser tool, backed by CopilotKit Intelligence threads.

## About Hosting OpenDots

This template deploys two services: the OpenDots app (Node server plus React UI, SQLite on a persistent volume) and a sandboxed Playwright browser reachable only over Railway's private network. Access secrets are generated for you. Add your CopilotKit Intelligence key and model credentials and the app is ready to use.

## Common Use Cases

- A private personal assistant with persistent conversations
- Research tasks that read public web pages on a schedule
- A document workspace where agents read and edit pages
- A Slack-connected agent for you or a small allowlisted team

## Dependencies for OpenDots Hosting

- CopilotKit Intelligence (conversation persistence)
- An OpenAI-compatible model provider
- Playwright Chromium (bundled in the Browser service)

### Deployment Dependencies

- https://github.com/CopilotKit/OpenDots
- https://cloud.copilotkit.ai

### Why Deploy OpenDots on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying OpenDots on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
