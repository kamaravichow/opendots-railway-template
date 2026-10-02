# Deploy and Host OpenDots on Railway

OpenDots is a self-hosted personal-agent workspace from CopilotKit. Create Dots (specialist agents), organize work into Spaces and pages, run recurring tasks, and talk to your agents from the web app, by voice, or from Slack. Conversations are persisted through CopilotKit Intelligence Threads.

## About Hosting OpenDots

This template deploys two services: the OpenDots app (a Node server plus React UI, with its SQLite database on a persistent volume) and a sandboxed Playwright browser service that is only reachable over Railway's private network. Your login token and the shared browser secret are generated automatically. After deploy, add your CopilotKit Intelligence key, model API key and model name, open the generated domain, and sign in with the `OWNER_TOKEN` shown in the OpenDots service's Variables tab.

## Common Use Cases

- A private personal assistant with persistent conversations
- Scheduled research that reads public web pages on a recurring basis
- A document workspace where agents read, draft and edit pages for you
- A Slack-connected agent for you or a small allowlisted team
- A starting point for building your own CopilotKit-powered agent app

## Dependencies for OpenDots Hosting

- OpenDots app service (Node.js 24, SQLite on a Railway volume)
- Browser service (Playwright Chromium, private networking only)
- CopilotKit Intelligence project key for conversation persistence
- An OpenAI-compatible model API key and model name

### Deployment Dependencies

- [OpenDots source repository](https://github.com/CopilotKit/OpenDots)
- [CopilotKit Intelligence](https://cloud.copilotkit.ai) for the `INTELLIGENCE_API_KEY`
- [OpenDots setup guide](https://github.com/CopilotKit/OpenDots/blob/main/docs/SETUP.md) for optional Slack and voice configuration

### Implementation Details

OpenDots refuses to start on a public address without an access token, so the template generates a 64-character `OWNER_TOKEN` for you. `APP_ORIGIN` is set to your public domain, and `BROWSER_URL` points at the Browser service's private address (`browser.railway.internal`). The Browser service rejects any request that lacks the shared `BROWSER_SECRET`.

OpenDots keeps pages and settings in SQLite on the `/data` volume, while conversation history lives in your CopilotKit Intelligence project. Back up both. This template does not include the optional persistent per-Dot computers feature, which needs a Docker socket.

## Why Deploy OpenDots on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying OpenDots on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
