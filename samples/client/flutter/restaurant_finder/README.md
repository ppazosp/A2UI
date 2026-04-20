# Restaurant Finder (Flutter)

A Flutter client that connects to an A2UI-enabled A2A agent and renders AI-generated restaurant recommendations using the `genui` renderer.

## Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (>=3.35.7)
* [uv](https://docs.astral.sh/uv/getting-started/installation/)

## Running

### Run agent

Follow the steps in [agent's README.md](../../../../agent/adk/restaurant_finder/README.md) to run the agent.

### Run client application

Run from the root of the repository:

```bash
flutter run -d <device> samples/client/flutter/restaurant_booker
```

Or from within the `restaurant_booker` directory:

```bash
flutter run
```

The app connects to the agent at `http://localhost:10002` by default.

## Security Notice

Important: The sample code provided is for demonstration purposes and illustrates the mechanics of A2UI and the Agent-to-Agent (A2A) protocol. When building production applications, it is critical to treat any agent operating outside of your direct control as a potentially untrusted entity.

All operational data received from an external agent—including its AgentCard, messages, artifacts, and task statuses—should be handled as untrusted input. For example, a malicious agent could provide crafted data in its fields (e.g., name, skills.description) that, if used without sanitization to construct prompts for a Large Language Model (LLM), could expose your application to prompt injection attacks.

Similarly, any UI definition or data stream received must be treated as untrusted. Malicious agents could attempt to spoof legitimate interfaces to deceive users (phishing), inject malicious scripts via property values (XSS), or generate excessive layout complexity to degrade client performance (DoS). If your application supports optional embedded content (such as web views), additional care must be taken to prevent exposure to malicious external sites.

Developer Responsibility: Failure to properly validate data and strictly sandbox rendered content can introduce severe vulnerabilities. Developers are responsible for implementing appropriate security measures—such as input sanitization, strict isolation for optional embedded content, and secure credential handling—to protect their systems and users.
