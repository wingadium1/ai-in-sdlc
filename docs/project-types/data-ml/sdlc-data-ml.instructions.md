---
applyTo: "src/**"
name: "SDLC Data/ML Rules"
---

# SDLC Data / ML Pipeline Phase Rules

## 1. Phase Contract
All changes must flow through the standard intake, define, decide, produce, verify, approve, and integrate phases. The input to the production phase is a validated design artifact, including schemas and experiment reports.

## 2. Production Code Rule
Notebooks are for experimentation and exploration only. Production pipelines must be written in modular Python classes or functions. All production code requires full test coverage. Never reference or import from a notebook file in a production environment.

## 3. Data Contracts
Every pipeline function must declare its input schema using a Pydantic model, a dataclass, or a schema definition. Validate all inputs before processing begins. Schema violations are treated as critical hard errors, not warnings.

## 4. Idempotency
Every pipeline step must be idempotent. Running the same step twice on the same data must produce the identical result. Always design for reruns and backfills from the start of the development cycle.

## 5. Feature Engineering
Feature transformations should be stateless, pure functions whenever possible. Side effects, such as writing to a database or calling an external API, must be explicitly declared and logged.

## 6. Model Artifacts
Never load a model from a local file path in a production environment. Always load models from a centralized model registry, such as MLflow or SageMaker, using a versioned reference. Pin the specific model version in the configuration.

## 7. Testing
Unit tests must verify transformation logic using synthetic fixture data. Never use real data containing Personal Identifiable Information (PII) in tests. Data quality tests, such as Great Expectations or dbt tests, must run against actual pipeline outputs in the CI/CD environment.

## 8. Experiment Tracking
All training runs must log the following metadata:
- Dataset version
- Feature set
- Hyperparameters
- Performance metrics
- Model artifact URI
Use MLflow or Weights & Biases for tracking. Never just print metrics to the console.

## 9. Data Quality
Validate the data schema and basic statistics at the pipeline entry point. Set up alerts for null rates or value distribution shifts that exceed defined thresholds to detect data drift early.

## 10. Prohibited Practices
- No notebooks in the production path.
- No hardcoded dataset paths.
- No loading of unversioned model artifacts.
- No PII in test fixtures.
- No missing or optional schema validation.
- No silent data quality failures.

## 11. Artifact Traceability Rule
Every production model or dataset must be traceable back to the specific code version, configuration, and raw data used to create it. Use Git SHAs and registry version tags to maintain this lineage.
