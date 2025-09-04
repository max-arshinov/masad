# GitHub Copilot Prompts for adrs, arc42, and C4

This directory contains prompts for generating arc42 documentation and C4 models using AI agents.

## Workflow

- Check [prompt file support](https://code.visualstudio.com/docs/copilot/customization/prompt-files)
- Use the prompts in order to iteratively build out architecture documentation. 
- Each prompt focuses on a specific aspect of the architecture, from initial estimates to detailed C4 diagrams.

### 1. Foundation (100-series)
- `100-extract-boe-numbers.prompt.md` - Extract estimates from requirements
- `110a-boe-calculations.prompt.md` or `110b-csv-to-md.prompt.md` - Back-of-envelope calculations
- `120-quality-requirements.prompt.md` - Generate quality trees and scenarios

### 2. Planning (200-series)  
- `200-add-iteration-plan.prompt.md` - Create ADD3.0 iteration plan
- `210-add-iteration.prompt.md` - Add specific iteration details
- `220-qa-coverage-review.prompt.md` - Review quality attribute coverage
- `230-solution-strategy.prompt.md` - Summarize ADRs into strategy

### 3. C4 Modeling (300-series)
- `300-c4-context.prompt.md` - Add persons and software systems
- `310-c4-container.prompt.md` - Add containers and relationships

## Prompt Engineering
- https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview
- https://cookbook.openai.com/examples/gpt-5/gpt-5_prompting_guide
- meta prompting

## TODO
- MCP server for GoogleSpreadsheet/Excel
- MCP servers for making better decisions
- Optimize prompts
- Custom company-wide RAG?
