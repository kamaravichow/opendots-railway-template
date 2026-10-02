# OpenDots on Railway

How this Railway template is built and published. Railway templates are cloned from a working project, so the source of truth is a tested project plus the cleanup in the template editor.

## Architecture

| Service    | Dockerfile                   | Public | Volume  | Healthcheck |
| ---------- | ---------------------------- | ------ | ------- | ----------- |
| `OpenDots` | `railway/Dockerfile.app`     | yes    | `/data` | `/`         |
| `Browser`  | `railway/Dockerfile.browser` | no     | none    | none        |

Service names must stay exactly `OpenDots` and `Browser`; variable references depend on them. Railway cannot select a Docker build target, so each service has its own Dockerfile, chosen with `RAILWAY_DOCKERFILE_PATH`. `Browser` has no healthcheck because its `/health` route requires the bearer secret.

## Build and publish

1. Build a project with both services from this repo, set the variables below, attach a volume at `/data` to `OpenDots`, and generate a public domain (target port `4310`) for `OpenDots` only.
2. Deploy and verify (see "Verify").
3. Clone it into a draft: `railway templates create --project <id> --json`.
4. Open the returned `editorUrl` and fix the draft (next section). The clone copies the test project's variable values, so this step is mandatory.
5. Publish: `railway templates publish <template-id> --category AI/ML --description "Deploy OpenDots, CopilotKit's personal-agent workspace, with a private browser and persistent storage" --readme-file railway/OVERVIEW.md`

## Template editor cleanup

Replace every copied value and add a description to each variable. Railway rejects publishing while any variable lacks one.

### `OpenDots` service

| Variable                  | Template value                                      | Description                                                                                            |
| ------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `RAILWAY_DOCKERFILE_PATH` | `railway/Dockerfile.app`                            | Selects the OpenDots app image. Do not change.                                                         |
| `PORT`                    | `4310`                                              | Port the OpenDots server listens on and Railway checks. Do not change.                                 |
| `OWNER_ID`                | `${{RAILWAY_PROJECT_ID}}`                           | Stable identity that owns your conversations. Unique per deployment; do not change after first use.    |
| `OWNER_TOKEN`             | `${{secret(64)}}`                                   | Password for signing in to OpenDots. Generated for you; find it in this service's Variables tab.       |
| `APP_ORIGIN`              | `https://${{RAILWAY_PUBLIC_DOMAIN}}`                | Exact public URL of this app. Update it if you add a custom domain.                                    |
| `BROWSER_SECRET`          | `${{secret(64)}}`                                   | Shared secret the app uses to call the Browser service. Generated for you; do not change.             |
| `BROWSER_URL`             | `http://${{Browser.RAILWAY_PRIVATE_DOMAIN}}:4311`   | Private-network address of the Browser service. Do not change.                                         |
| `INTELLIGENCE_API_KEY`    | _(empty, required input)_                           | CopilotKit Intelligence project key for conversation storage. Create one at https://cloud.copilotkit.ai. |
| `OPENAI_API_KEY`          | _(empty, required input)_                           | API key for your model provider (OpenAI or any OpenAI-compatible service).                             |
| `OPENAI_MODEL`            | _(empty, required input)_                           | Model identifier to use, exactly as your provider names it.                                            |
| `OPENAI_BASE_URL`         | `https://api.openai.com/v1`                         | Model API endpoint. Change it only to use another OpenAI-compatible provider.                          |

### `Browser` service

| Variable                  | Template value                  | Description                                                                |
| ------------------------- | ------------------------------- | -------------------------------------------------------------------------- |
| `RAILWAY_DOCKERFILE_PATH` | `railway/Dockerfile.browser`    | Selects the Browser service image. Do not change.                          |
| `BROWSER_SECRET`          | `${{OpenDots.BROWSER_SECRET}}`  | Shared secret that authorizes requests from the app. Do not change.        |

Also in the editor: mark `INTELLIGENCE_API_KEY`, `OPENAI_API_KEY` and `OPENAI_MODEL` as required, confirm the `/data` volume, the `/` healthcheck on `OpenDots`, that `Browser` has no public domain, and add 1:1 transparent icons for the template and both services.

## Verify

1. Both services deploy and `OpenDots` serves its public domain with `200`.
2. `/api/state` returns `401` without the token and `200` with `Authorization: Bearer <OWNER_TOKEN>`.
3. From the `OpenDots` container, a request with the browser secret to `$BROWSER_URL/browse` captures a public page. This checks private networking and Chromium's default sandbox as the non-root `node` user.
4. Redeploy `OpenDots` and confirm it boots again against the existing volume.

Test the final published template once by deploying it into a fresh project.
