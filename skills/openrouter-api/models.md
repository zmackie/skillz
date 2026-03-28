# OpenRouter Model Reference

## Recommended Defaults

| Use Case | Model | Notes |
|---|---|---|
| General coding | `anthropic/claude-sonnet-4` | Best balance of speed and quality |
| Complex reasoning | `anthropic/claude-opus-4` | Highest quality, slower |
| Fast/cheap tasks | `anthropic/claude-haiku-4` | Summaries, classification, simple transforms |
| Long context | `google/gemini-2.5-pro` | Up to 1M tokens |

## Model Selection Guidelines

- **Default to `anthropic/claude-sonnet-4`** unless there's a reason not to
- Use Opus for tasks requiring deep reasoning, complex code generation, or multi-step planning
- Use Haiku for high-volume, low-complexity tasks where cost matters
- Use Gemini for tasks requiring very long context windows

## Cost Awareness
- Always expose model choice via `--model` flag so users can trade cost for quality
- Log token counts when debug mode is enabled
- For batch processing, default to cheaper models and let users opt into expensive ones
