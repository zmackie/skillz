---
name: openrouter-api
description: Build LLM-powered features using OpenRouter. Use when integrating LLM calls, building AI features, or working with language model APIs.
---

# OpenRouter API Integration

When building features that call LLMs, use OpenRouter as the provider. This allows switching between models without code changes.

## Setup

Use the OpenAI Python SDK pointed at OpenRouter:

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=os.environ["OPENROUTER_API_KEY"],
)
```

## Making Calls

```python
response = client.chat.completions.create(
    model="anthropic/claude-sonnet-4",  # or any model from models.md
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": prompt},
    ],
)
result = response.choices[0].message.content
```

## Streaming

```python
stream = client.chat.completions.create(
    model="anthropic/claude-sonnet-4",
    messages=messages,
    stream=True,
)
for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="")
```

## Best Practices
- Always read `models.md` in this skill directory for current model recommendations
- Store `OPENROUTER_API_KEY` in environment, never in code
- Add `--model` flag to CLIs so users can override the default model
- Handle rate limits with exponential backoff
- Log token usage when `--debug` is enabled
- Use streaming for interactive/user-facing responses
