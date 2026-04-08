# Project Type Guide: Data / ML Pipeline

Data and Machine Learning (ML) pipelines present unique SDLC challenges. Correctness is often probabilistic rather than binary. Experiments are first-class work items. Data drift can silently degrade production performance. Infrastructure components like Spark, Airflow, or Ray are tightly coupled to the code itself.

Common technology stacks include:
- **Batch Processing**: Python + dbt + Apache Airflow
- **Machine Learning**: Python + PyTorch/Hugging Face + MLflow
- **Data Engineering**: PySpark + Delta Lake + Great Expectations

## Phase Variations for Data / ML

| Phase | SDLC Variation for Data/ML |
| :--- | :--- |
| **Intake** | Two primary sources: engineering tickets and data science experiments ready for production. For experiments, the intake artifact is the experiment result (notebook, MLflow run ID, and metric report), not just a feature description. |
| **Define** | Acceptance criteria must include: input data schema (nullable vs. non-nullable), output schema, performance metrics (precision, recall, RMSE with thresholds), latency/throughput SLAs, data freshness requirements, and backfill requirements. |
| **Decide** | **Pipelines**: partitioning strategy, idempotency design, failure/retry semantics, backfill strategy, and monitoring approach. **Models**: serving infrastructure (batch vs. real-time), versioning strategy, A/B rollout plan, and shadow mode deployment. |
| **Produce** | Notebook-first is not the production pattern. Production code is modular Python with unit tests. AI generates the pipeline scaffold while the data scientist reviews and fills in domain logic. |
| **Verify** | Four mandatory checks: unit tests on transformation logic, data quality tests (Great Expectations or dbt tests), regression tests on fixed datasets (metrics must meet thresholds), and integration tests on sample data through the full pipeline. |
| **Approve** | Human gates are required for changes to training data schemas, feature definitions, or model architectures (signed off by Data Scientist or ML Lead). Model serving changes require MLOps sign-off. |
| **Integrate** | Model artifacts are published to the registry with version tags. Pipeline DAG diffs are reviewed. Monitoring alert thresholds are updated to reflect new baseline performance. |

## Experiment vs. Production Boundary

The boundary is clear:
- **Experimentation**: Data scientists explore in notebooks. This phase is not managed by the framework.
- **Productionizing**: Once an experiment is ready for the framework, it must be ported from notebooks to modular Python. The framework takes over once the code enters the `src/` directory.

## Data Schema as a First-Class Artifact

Schema definitions are critical. Store all input/output schemas in `.sdlc/artifacts/design-artifact/` to ensure contract stability between pipeline stages.

## Common Conventions

1.  **Idempotent Transforms**: Every step must yield the same result if rerun on the same input.
2.  **Schema Validation**: Validate schemas at the pipeline entry point and every handoff.
3.  **No Notebooks in Production**: Port all logic to modular Python classes or functions.
4.  **Synthetic Fixtures**: Use generated fixtures, never real PII data, for unit tests.
5.  **Log Data Lineage**: Capture where data came from and where it is going.
6.  **Version Everything**: All model artifacts must be versioned in a registry.
7.  **Stateless Features**: Keep feature transformations as pure functions when possible.
8.  **Explicit Side Effects**: Log all database writes or API calls clearly.
9.  **Drift Detection**: Monitor value distributions to detect feature or label drift.
10. **Hard Failures**: Schema violations should stop the pipeline, not just log warnings.

## Work Type Overrides

Data/ML teams often need stronger task-specific guidance than a generic software workflow provides. In this template, `debugging` requires fixed datasets and metric comparisons, `requirement-analysis` requires explicit schema and threshold definition, and `code-review` checks reproducibility and model-version evidence. See [project.yaml](project.yaml) for the concrete `work_type_overrides` examples.

## Brownfield Reconstruction Priorities

When onboarding into an existing data/ML system, the biggest risk is usually not missing class/module diagrams — it is missing understanding of schemas, metric expectations, pipeline flow, and runtime placement. Start with `/reconstruct-architecture <scope>` for the active pipeline or model slice, not the whole platform.

Recommended priority order:

1. **`contract-view`** — recover input/output schema contracts, feature definitions, model registry interfaces, and data handoff expectations first.
2. **`interaction-view`** — recover the end-to-end pipeline or model-serving flow, especially where data enters, transforms, serves, and triggers downstream effects.
3. **`deployment-view`** — recover where batch jobs, Airflow/Ray/Spark components, model serving, storage, and monitoring actually run.
4. **`container-view`** — recover the static runtime/tooling units if the pipeline/service decomposition is unclear.
5. **`context-view`** — recover the broader system boundary when external data sources, downstream consumers, or platform ownership are unclear.

Typical starting points:

- **Metric regression investigation** → `interaction-view` + `contract-view`
- **Schema or feature change** → `contract-view` + `deployment-view`
- **Productionizing a legacy pipeline** → `container-view` + `deployment-view`
- **Model serving review** → `interaction-view` + `deployment-view`

## Team Checklist

- [ ] Is the transformation logic idempotent?
- [ ] Are input and output schemas defined and validated?
- [ ] Has the model been registered in MLflow or an equivalent registry?
- [ ] Are unit tests running against synthetic data fixtures?
- [ ] Does the pipeline include Great Expectations or dbt tests?
- [ ] Is the Airflow DAG or pipeline scaffold modular and tested?
- [ ] Has the Data Scientist or ML Lead signed off on the architecture?
