# Spike: BA to Dev Artifact Flow Feasibility

## Objective
Validate if `agent-for-ba` output artifacts can be cleanly consumed by `AI-in-sdlc` dev skills.

## Findings

1. **Format Differences**: 
   - `agent-for-ba` typically outputs markdown files with YAML frontmatter to a `wiki/` directory.
   - `AI-in-sdlc` expects structured JSON artifacts (`ArtifactVersion` schema) stored in `.sdlc/artifacts/`.
2. **Data Mapping**:
   - The markdown frontmatter and body structure (Title, Actors, Steps, Acceptance Criteria) from BA outputs can be reliably parsed and mapped to the Dev JSON schema.
   - Dev schema fields like `kind`, `metadata.source`, and `content` map well to the extracted BA data.
3. **Unmappable Fields**:
   - Visual or unsupported formats (like PlantUML diagrams) in BA outputs cannot be directly mapped into the strict Dev JSON schema without specialized extraction/conversion.
   - We must employ graceful degradation: extract the text components and warn about unsupported elements.

## Conclusion
**FEASIBLE.** The artifact flow is possible via an adapter script that reads the BA markdown file, extracts frontmatter and key sections, and serializes it into the `.sdlc/artifacts/` JSON format. The prototype script (`scripts/spike-ba-dev-artifact-flow.sh`) validates this conversion approach.
