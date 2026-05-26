# OpenStack RHOSO DBaaS Case Study - Learnings

## Conventions
- All docs use Markdown format
- Evidence saved to `.sisyphus/evidence/`
- Commit messages follow pattern: `[research|poc|doc|qa] description`
- Handoffs tracked in `docs/handoffs/handoff-register.md`

## Patterns
- Case study documents should be comprehensive but focused on PoC scope
- CASAN mapping is reference-only, not critical analysis
- No slide creation - handled externally via Gemini Advanced

## Key Context
- Greenfield project with zero OpenStack/RHOSO/DBaaS knowledge
- Using GSD (Get Shit Done Redux) and OMO (Oh My OpenAgent)
- FPT CASAN framework has 5 levels: Curious, Augmented, Standard, Automated, Native

## Task 3 Learnings (2026-05-26)

### CASAN Framework Deep Dive
- CASAN has 5 levels: Curious → Augmented → Standard → Automated → Native
- Each level has explicit technical features, human roles, and governance requirements
- The 4 original thinking layers are the true differentiators vs international frameworks:
  1. Harness Engineering (7 components) — turns model into enterprise system
  2. Computational × Inferential Blend — combines deterministic systems with AI reasoning
  3. Human-led, AI-first — humans keep goals/values, AI executes within Harness
  4. AI Delegation Architecture — L0-L5 delegation levels with control plane

### Key PoC Mapping Insights
- Most GSD/OMO activities currently map to Level 2-3 (Augmented-Standard)
- OMO agent execution is Level 3-4 depending on autonomy (L3-L4 delegation)
- Full AI-native SDLC would be Level 5 (Native)
- Harness maturity is the key differentiator between levels, not just tool usage
- Data readiness (6 criteria) is a hard gate for Level 3+

### BMAD Model
- Build More Architect Dreams (was Breakthrough Method for Agile AI-Driven Development)
- Human defines vision/constraints, AI supports analysis/generation, Human architect decides
- Roles shift up: less repetitive execution, more design/validation/orchestration

### Security Stack (6 layers)
- NIST AI RMF, OWASP LLM/Agentic Top 10, CSA MAESTRO, MITRE ATLAS, ISO 42001, EU AI Act
- Applied cumulatively: higher CASAN level = more layers activated

### File Created
- docs/research/casan-mapping-rubric.md (468 lines, comprehensive reference mapping)
- .sisyphus/evidence/task-3-casan-rubric.txt

## Task 2 Learnings (2026-05-26)

### OpenStack Research
- OpenStack is a microservices-based IaaS platform with core services: Nova, Neutron, Keystone, Glance, Cinder
- All services authenticate through Keystone and communicate via REST APIs + AMQP message bus
- OpenStack deployment models range from manual installation to containerized (RHOSO)

### RHOSO Research
- RHOSO runs OpenStack control plane as containers on OpenShift, managed by Operators
- Data plane (compute nodes) runs on external RHEL nodes managed by Ansible
- Key CRDs: OpenStackControlPlane, OpenStackDataPlaneNodeSet, OpenStackDataPlaneDeployment
- CLI access is via `oc rsh -n openstack openstackclient` then standard `openstack` commands
- Two topologies: compact (shared nodes) and dedicated nodes (separate nodes)

### DBaaS Research
- Trove is OpenStack's native DBaaS with components: trove-api, trove-taskmanager, trove-conductor, trove-guestagent
- Trove supports MySQL, MariaDB, PostgreSQL, Redis, MongoDB, Cassandra
- Alternatives: cloud-native operators (CrunchyData, Percona, CloudNativePG) running on Kubernetes
- For PoC scope, Trove is the most relevant path for OpenStack-native DBaaS

### Document Creation
- Comprehensive baseline doc created: docs/research/openstack-rhoso-baseline.md
- Word count: 4256 (well above 2000 minimum)
- Includes architecture diagrams (ASCII), CLI commands, glossary, and deployment workflow

