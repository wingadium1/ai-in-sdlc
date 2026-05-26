# CASAN Framework Analysis — OpenStack RHOSO DBaaS PoC Mapping Rubric

> **Source**: FPT CASAN Methodology (`refs/Phương-pháp-luận-FPT-CASAN.md`)  
> **Effective Date**: 19/5/2026  
> **Document Code**: ALPHA/LD/HDCV/FPT  
> **Purpose**: Reference-only mapping of PoC activities to CASAN maturity levels. No critical analysis.

---

## 1. Overview

CASAN (Khung Năng lực AI-Native 5 Cấp độ) is FPT's AI-native capability framework for assessing and guiding enterprise AI transformation. It answers four practical questions:

1. Where is the enterprise/FPT on the AI journey?
2. What must the enterprise/FPT do to reach the next level?
3. What services, platforms, workforce, and IP does FPT provide at each level?
4. How does AI create business and operational value rather than remain a technology experiment?

Each CASAN level reflects organizational maturity across:
- Strategy and business outcomes
- Data and integration
- Processes and workflows
- Technology, platforms, and architecture
- Governance, security, and compliance
- People, skills, and new roles
- Value measurement, risk, and scalability

---

## 2. The Five CASAN Levels

### 2.1 Level 1 — Curious (xưởng thủ công / The Workshop)

**Definition**: The enterprise is newly exploring and experimenting with AI. AI usage occurs at the individual or small-group level, with no common standard, no prepared data, no clear governance, and no strong enough business case.

**Key Characteristics**:
- Employees use ChatGPT, Claude, Copilot, or public tools on a personal-need basis
- Use cases are fragmented: writing, summarizing, translating, drafting, brainstorming, creating slides
- No formal Harness; each person writes their own prompts
- No validation, no logging, no integration with enterprise systems
- No clear policy on sensitive data, intellectual property, copyright, or accountability when AI makes mistakes

**Technical Features**:
- Minimal Harness — mainly vendor-default Acceptable Use Policy and basic prompts
- No enterprise data connectors
- No DLP or sensitivity labeling
- Public LLMs used without data restrictions

**Human Roles**:
- Individual explorers
- No dedicated AI roles
- Informal sharing of "good prompts"

**Goal of Level Transition**: Move from fragmented personal experimentation to formal, safe, productivity-oriented AI usage.

---

### 2.2 Level 2 — Augmented (dây chuyền lắp ráp / The Assembly Line)

**Definition**: Humans are augmented by AI in daily work. AI has not changed the entire process, but has become a productivity tool for each role, each functional group, and each specific workflow.

**Key Characteristics**:
- AI tools are officially licensed: Microsoft 365 Copilot, GitHub Copilot, Gemini Workspace, Notion AI, or equivalents
- Some processes are improved by AI: scheduling, testing, documentation, drafting proposals/RFPs, contract review, tier-1 customer support, candidate screening
- Internal data begins connecting through official connectors
- Effectiveness is mainly at the individual and some small-group level

**Technical Features**:
- Uses vendor-provided Harness (Copilot Harness)
- DLP at the endpoint device level
- Acceptable Use Policy formally issued
- Licensed and managed tools only
- Some workflow-specific connectors

**Human Roles**:
- AI tool users across all functions
- IT admin for license management
- Early AI champions

**Goal of Level Transition**: Move from fragmented individual productivity to repeatable, controllable organizational capability.

---

### 2.3 Level 3 — Standard (nhà máy thông minh / The Smart Factory)

**Definition**: The enterprise has standardized data, processes, policies, platforms, and AI use cases. AI is no longer a fragmented experiment but becomes a repeatable, controllable operational capability.

**Key Characteristics**:
- Formal AI governance framework in place
- Use case catalog managed by impact, feasibility, and risk
- Data classification, sensitivity labels, data lineage, and audit logs
- Reusable prompt library, Agent templates, validation sets, reference architecture
- Dedicated roles: AI Product Owner, Data Owner, Validator, Security Owner, AI Governance Lead

**Technical Features**:
- Enterprise-owned shared Harness
- Agent registry
- Tool catalog with schemas
- Validation pipeline before deployment
- Standard RAG architecture
- Cost and quality monitoring
- ISO 42001 readiness

**Human Roles**:
- AI Product Owner
- Data Owner / Data Steward
- Validator / Validation Engineer
- Security Owner
- AI Governance Lead
- AI Champions (spread AI across the organization)

**Goal of Level Transition**: Move from standardization to workflow automation with controlled AI Agents.

---

### 2.4 Level 4 — Automated (doanh nghiệp tự động hóa / The Automated Enterprise)

**Definition**: AI Agents operate workflows with control at scale. AI not only supports drafting or analyzing information but can execute business, technical, or operational processes within an authorized scope.

**Key Characteristics**:
- AI Agents operate workflows: customer request handling, software testing, code review, incident classification, financial reconciliation, procurement, compliance monitoring, document processing, contract review
- AgentOps monitors performance, cost, latency, hallucination, error patterns, and user satisfaction
- AI control plane manages identity, data, tools, policy, approval, rollback, and audit
- Human validators focus on exceptions and high-risk decisions
- Old processes are redesigned to leverage AI Agents

**Technical Features**:
- Multi-Agent orchestration
- Agent identity service
- Tool calling with audit logging
- Memory layer (short-term and long-term)
- Cost orchestration
- Error classification and rollback procedures
- Validation-based deployment

**Human Roles**:
- Harness Engineer
- AgentOps Engineer
- Validator Engineer
- AIX Chief Architect
- Exception handlers (humans handle edge cases)

**Goal of Level Transition**: Move from workflow automation to redesigning the operating model around AI.

---

### 2.5 Level 5 — Native (sinh vật thông minh vận hành trên hệ điều hành AI / The AI-Native Organism)

**Definition**: The enterprise is re-architected around AI as the core operating system. At lower levels, the enterprise mainly improves on top of old systems. At Level 5, the enterprise redesigns operations from the ground up with AI at the core.

**Key Characteristics**:
- AI plays the role of the organization's operating system
- Operating model is designed around AI
- Core processes follow event-driven logic, rich in context, and orchestrated by Agents
- Enterprise knowledge layer and Agent memory layer become true architectural layers
- Data pipelines serve real-time inference, feedback loops, and continuous learning
- Clear separation between computational core and inference layer
- Multi-Agent orchestration for complex processes
- Adaptive governance
- KPIs shift from automation efficiency to business model innovation, revenue growth, customer experience, and organizational learning speed

**Technical Features**:
- Full 7-component Harness at enterprise scale
- Complex Multi-Agent orchestration
- Enterprise knowledge layer
- Long-term Agent memory
- Adaptive governance
- Real-time inference data pipelines
- Continuous learning loops
- AI-native product/service catalog

**Human Roles**:
- AIX Chief Architect
- Harness Architect (Level 3)
- Context Engineer
- Industry AIX Consultant
- Engagement Manager (customer relationship and accountability)
- Humans focus on design, architecture, validation, and customer collaboration

---

## 3. Four Original Thinking Layers of CASAN

CASAN contains four original thinking layers that differentiate it from other international maturity frameworks:

### 3.1 Harness Engineering

Harness is the technical framework surrounding the model that turns it into a results-producing system in real enterprise operations. Harness includes: context, tools, validation, security, governance, AgentOps, and orchestration.

Harness is not a single prompt or a loose set of instructions. It is a system that helps AI act in a controlled, designed environment. Martin Fowler emphasizes two mechanisms: guidance before AI acts (rules, structure, architecture standards, context) and feedback sensors after AI acts (testing, logs, static analysis, quality assessment, AI review).

**Seven Harness Components**:
1. **Context Harness**: Delivers the right information at the right time in the right scope — RAG architecture, chunking strategy, embedding model, vector store, reranker, Agent memory, tool schema, system state
2. **Tool Harness**: Helps Agent call the right tool with the right permission, right workflow — tool registry, schema, least privilege, rate limiting, quotas, idempotency, retry policy, audit log
3. **Validation Harness**: Validates output against standards — golden dataset, LLM-as-judge, metric-based validation, regression test suite, A/B testing, production feedback loop
4. **Security Harness**: Prevents prompt injection, data leakage, jailbreak, unsafe content risks, credential misuse, unsafe tool usage
5. **Governance Harness**: Approval flow, immutable audit log, policy engine, compliance reporting, risk registry
6. **AgentOps Harness**: Monitors performance, latency, throughput, cost per task, accuracy, completion rate, hallucination rate, rejection rate, error classification, drift detection, feedback loop
7. **Orchestration Harness**: Workflow engine, DAG or state machine, Agent-to-Agent protocol, model routing, time limits, retries, fallback, parallel execution, error recovery, transaction boundaries

**Four Simplified Groups** (for communication):
- Context and Tools
- Validation and Security
- AgentOps and Orchestration
- Governance and Accountability

**Harness Across 5 CASAN Levels**:
- **Level 1**: Minimal Harness — Acceptable Use Policy and basic prompts; mainly vendor-default
- **Level 2**: Copilot Harness — Licensing, DLP, official connectors; still heavily vendor-dependent
- **Level 3**: Standardized Harness — Enterprise validation, reusable prompt library, Agent templates, governance framework
- **Level 4**: Agent Operations Harness — All 7 components at production level, especially tools, security, governance, AgentOps, and orchestration
- **Level 5**: Enterprise-wide Harness — Complex Multi-Agent orchestration, knowledge layer, long-term Agent memory, adaptive governance, operates like an OS

### 3.2 Computational × Inferential Blend

CASAN does not advocate replacing the entire enterprise system with LLMs. It combines the **Computational layer** (characterized by precision, verifiability, repeatability — ERP, core banking, SAP, rule engines, transaction databases) with the **Inferential layer** (capable of understanding context, processing unstructured data, generating options, and coordinating tasks — LLMs, AI Agents).

A good AI-native workflow must know clear boundaries: what to hand to deterministic logic, what to hand to AI inference, and what needs human review. If only computational is used, the enterprise struggles with natural language, unstructured knowledge, and complex situations. If only inferential is used, the enterprise risks errors, audit difficulties, and compliance issues.

**Key Principle**: AI reasons, computational systems control; AI proposes, transaction systems confirm; AI orchestrates, governance and audit maintain operational discipline.

### 3.3 Human-led, AI-first

Humans keep goals, values, ethics, judgment, accountability, and final decision-making authority. AI is the direct execution capability layer, helping expand human capability within a controlled technical framework (Harness).

This principle avoids two extremes:
- **Extreme 1**: Viewing AI only as a small辅助 tool, trapping the enterprise at individual productivity gains without transforming the operating model
- **Extreme 2**: Delegating too quickly to AI, letting Agents act in operations, production, and business without human review, validation, rollback, or accountability

**Human Role Evolution**:
- Programmers, BAs, testers, consultants, operations, legal, and finance do less repetitive work
- Increased roles in design, validation, exception handling, trade-off evaluation, and final accountability
- New roles emerge: Harness Engineer, Context Engineer, Validation Engineer, AgentOps Engineer, Industry AIX Consultant, AIX Chief Architect

**Key Insight**: AI does not replace humans as living entities; AI expands human capability as a delegated system.

### 3.4 AI Delegation Architecture

When AI begins to be delegated actions, the organization must clearly define: what AI is allowed to do, what data it can use, what tools it can call, what autonomy level it has, who approves, how to rollback, and who is accountable.

**Mandatory Questions Before Production Deployment**:
- What objectives are given to AI? What are the specific boundaries? What is it NOT allowed to do?
- What systems does AI read/write? What tools can it call with what permissions?
- Which steps does the Agent decide autonomously, which steps need human approval?
- Who approves output? Does the validator have real capability to check?
- When wrong, how to rollback? Is there an emergency stop switch? Who is responsible?
- Has the Agent been risk-modeled? Have cross-layer attack chains been identified and mitigated? When was the last adversarial testing (MITRE ATLAS) and are results still valid?

**Control Plane Requirements**: Every delegation level must include registry, permission, policy, approval gate, audit trail, kill switch, and rollback. For important workflows, a validator model determines who signs off on output per domain, along with dashboards measuring productivity, quality, override rate, incident rate, and audit findings.

---

## 4. Six AI Delegation Levels (L0–L5)

| Level | Name | Meaning | Example |
|-------|------|---------|---------|
| **L0** | **Observe** | AI observes, searches, summarizes, classifies; does not change systems | Summarize meeting, classify ticket |
| **L1** | **Draft** | AI creates draft; human reviews 100% | Draft email, draft proposal, draft code |
| **L2** | **Recommend** | AI proposes options; human decides | Propose pricing, propose test strategy, shortlist suppliers |
| **L3** | **Execute bounded low-risk** | AI executes low-risk tasks within clear boundaries | Generate test case, update documentation, triage ticket |
| **L4** | **Operate bounded workflow** | AI operates workflow with control barriers and audit | Tier-1 customer support, classify incident, process document |
| **L5** | **Restricted/high-risk autonomy** | AI automates complex areas under strict control | Fraud monitoring, compliance monitoring, autonomous software maintenance |

### Design Principles for Delegation Levels:

- The closer AI is to important business decisions, the stronger the governance
- The more AI calls tools that change systems, the more identity, access control, approval, and rollback are needed
- The more AI processes sensitive data, the more DLP, encryption, logging, and data minimization are needed
- The same Agent can run at different delegation levels for different customer objects in different segments
- AI autonomy is not absolute power; it is designed, measured, and revocable power

---

## 5. Mapping Rubric: PoC Activities to CASAN Levels

### 5.1 How to Use This Rubric

For each activity in the OpenStack RHOSO DBaaS PoC, classify it against the CASAN levels using these criteria:

| Criterion | Level 1 (Curious) | Level 2 (Augmented) | Level 3 (Standard) | Level 4 (Automated) | Level 5 (Native) |
|-----------|-------------------|---------------------|--------------------|---------------------|------------------|
| **AI Role** | Individual tool use | Licensed tool, productivity gain | Standardized, governed | Agent operates workflow | AI is core OS |
| **Data** | No enterprise data prep | Basic connectors | Classified, lineage, quality | Real-time, integrated | Knowledge layer, memory layer |
| **Process** | Ad-hoc, personal | Improved specific workflows | Repeatable, validated | Redesigned around AI | Event-driven, Agent-orchestrated |
| **Governance** | None / informal | AUP, DLP | RBAC, audit, ISO 42001 | Agent identity, policy enforcement | Adaptive governance |
| **Human Role** | Explorer | Power user | Validator, owner | Exception handler | Designer, architect, strategist |
| **Harness** | Vendor default | Copilot Harness | Enterprise Harness | Full 7-component Harness | Enterprise-wide, adaptive |

### 5.2 PoC Activity Classification Examples

| PoC Activity | CASAN Level | Rationale |
|--------------|-------------|-----------|
| Individual developer uses Copilot to write OpenStack API client code | **Level 2 (Augmented)** | Licensed tool, individual productivity, no process change |
| Team uses AI to generate draft architecture document for RHOSO DBaaS | **Level 2 (Augmented)** | Draft output, human reviews 100% (L1 delegation) |
| AI suggests database topology options; human architect selects | **Level 2–3 (Augmented–Standard)** | Recommendation mode (L2 delegation), moving toward standardized decision process |
| Standardized prompt library for OpenStack troubleshooting | **Level 3 (Standard)** | Reusable, governed, cataloged |
| AI Agent auto-generates test cases for DBaaS provisioning flow | **Level 3–4 (Standard–Automated)** | Bounded execution (L3 delegation), repeatable workflow |
| AI Agent monitors RHOSO cluster health and auto-classifies incidents | **Level 4 (Automated)** | Operates workflow with control barriers (L4 delegation) |
| Multi-Agent system: one Agent plans, one executes, one validates DBaaS deployment | **Level 4–5 (Automated–Native)** | Multi-Agent orchestration, approaching AI-native architecture |
| AI redesigns DBaaS provisioning as event-driven, Agent-orchestrated process | **Level 5 (Native)** | Core process redesigned around AI |

### 5.3 GSD / OMO Workflow Mapping to CASAN

| GSD/OMO Workflow Element | CASAN Level | Delegation Level | Notes |
|--------------------------|-------------|------------------|-------|
| Developer uses Copilot/Claude Code for coding assistance | Level 2 | L1 (Draft) | Individual productivity augmentation |
| GSD phase planning with AI-assisted breakdown | Level 2–3 | L2 (Recommend) | AI proposes plan, human decides |
| OMO agent executes predefined task (e.g., file analysis) | Level 3 | L3 (Execute bounded) | Bounded, low-risk, within clear scope |
| OMO agent runs tests and reports results | Level 3–4 | L3–L4 | Bounded execution, workflow operation |
| AI-generated code committed after human review | Level 3 | L1–L2 | Draft/recommend, human approves |
| Autonomous agent loop (Ralph Loop, Sisyphus) with human checkpoints | Level 3–4 | L3–L4 | Agent operates with control barriers |
| AI designs architecture and human architect approves | Level 3–4 | L2 (Recommend) | AI proposes, human decides |
| Full AI-native SDLC where AI is the primary executor | Level 5 | L4–L5 | AI as core operating system |

### 5.4 Key Mapping Principles for This PoC

1. **Most PoC activities currently fall in Level 2–3**: Using licensed AI tools (Copilot, Claude Code) for productivity, with some standardized workflows (GSD phases, OMO skills)
2. **Level 4 activities are emerging**: OMO agents executing bounded tasks, test automation, incident classification
3. **Level 5 is aspirational**: Full AI-native operating model for DBaaS delivery would require re-architecting processes around AI
4. **Delegation levels should be explicit**: For each AI-assisted activity, define whether it is L0 (Observe), L1 (Draft), L2 (Recommend), L3 (Execute), or L4 (Operate)
5. **Harness maturity must match level**: Using Copilot/Claude without custom Harness = Level 2. Building reusable prompts, validation sets, and Agent templates = Level 3. Full AgentOps and orchestration = Level 4–5

---

## 6. Governance and Security by CASAN Level

### 6.1 Level 1 — Curious
- Acceptable Use Policy
- Awareness training
- Initial AI risk registry
- Restrict Public LLMs for sensitive data

### 6.2 Level 2 — Augmented
- Sensitivity labels
- DLP
- Formal AI usage policy
- License management
- Vendor security review

### 6.3 Level 3 — Standard
- Documented AI lifecycle
- Audit logs
- Role-based ownership
- RBAC
- Model security
- Safe integration patterns
- ISO 42001 readiness

### 6.4 Level 4 — Automated
- Real-time monitoring
- Continuously updated AI risk registry
- Agent identity
- Policy enforcement
- Prompt injection prevention
- Jailbreak detection
- Internal AI risk management
- Emergency stop and rollback

### 6.5 Level 5 — Native
- Adaptive AI-native governance
- Agent auditing
- Proactive red-teaming
- Autonomous incident response
- Multi-jurisdictional compliance

---

## 7. Data Readiness Standards (6 Criteria)

Organizations must meet data readiness standards to achieve Level 3 and above:

1. **Correct** (Đúng): Data reflects reality, no bias
2. **Sufficient** (Đủ): Enough fields, scope, time, frequency, granularity
3. **Clean** (Sạch): No duplicates, no garbage, no broken formats, no meaningless empty cells, single ID per entity
4. **Live** (Sống): Real-time or near real-time updates, not dead snapshots
5. **Unified** (Thống nhất): Single source of truth, not one version per department
6. **Shareable** (Dùng chung): Shareable across units with data product thinking

---

## 8. BMAD: Human–Agent Operating Model in Software

BMAD (Build More Architect Dreams), historically Breakthrough Method for Agile AI-Driven Development, is the operational model for Human-led, AI-first in CASAN:

- **Humans** define vision, business objectives, architecture constraints, acceptance criteria
- **AI Agents** support requirements analysis, propose architecture, create backlog, write code, write tests, write documentation
- **Human Architects and Product Owners** hold final decision authority on architecture, trade-offs, and priorities
- **Human Validators and CI/CD** check quality
- **AgentOps** drives continuous improvement

**Key Point**: Programmers, architects, BAs, testers, and PMs do not disappear. Their roles shift upward to design, validation, orchestration, and quality assurance.

---

## 9. Five-Layer Technical Reference Architecture

| Layer | Name | Key Components |
|-------|------|----------------|
| **Layer 1** | Data Layer | Data lake/warehouse, feature store, vector store, metadata catalog, data quality tools, lineage tracking, DLP, data classification |
| **Layer 2** | Model Layer | Model registry, model gateway, task/cost/SLA router, per-model validation, fine-tuning pipeline, embedding service, multimodal service |
| **Layer 3** | Agent & Tool Layer | Agent registry, Agent identity service, tool registry, MCP-like protocol, sandbox for high-risk tools, transaction manager, Agent memory (short/long term) |
| **Layer 4** | Orchestration & Harness Layer | Workflow engine, Multi-Agent orchestration, context harness, tool harness, validation harness, security harness, governance harness, AgentOps harness, debugging/replay, regression detection, prompt management, A/B testing, escalation |
| **Layer 5** | Governance, Security & Experience Layer | Policy engine, approval flow service, risk registry, immutable audit log, red-teaming framework, AI app portal/marketplace, SDK for Copilot embedding, UX: chat, voice, embedded Copilot, API |

**Cross-Cutting Principles**:
- Identity: for both Humans and Agents
- Observability: full logs, metrics, traces from user input to final tool call
- Cost control: route cheap/medium/powerful models, quotas per Agent/user/tenant, budget alerts
- Compliance: attached to every layer per legal jurisdiction and industry
- Security-by-design: prompt injection prevention, secret management, encryption, RBAC, data minimization
- Validation-by-design: no Agent deployed to production without validation pipeline

---

## 10. Transition Path Between CASAN Levels

### 10.1 Curious → Augmented
- Issue Acceptable Use Policy
- Identify data that must NOT go into public AI tools
- License appropriate AI tools
- Select 5–10 easy productivity use cases
- Train on AI awareness, safe usage, basic prompting
- Establish AI champion network
- Measure time saved, task completion, usage, satisfaction

### 10.2 Augmented → Standard
- Build use case catalog by impact, feasibility, risk
- Standardize input data
- Establish data classification, sensitivity labels, DLP, access control
- Design full AI lifecycle: ideation → approval → build → test → deploy → monitor → decommission
- Create reusable prompt library, Agent templates, validation sets, reference architecture
- Establish AI governance council
- Appoint AI Product Owner, Data Owner, Validator, Security Owner, Compliance Owner

### 10.3 Standard → Automated
- Select workflows with clear ROI and controllable risk
- Design AI Delegation Architecture for each workflow
- Build control plane for Agent identity, tool access, approval, rollback, audit
- Establish AgentOps
- Integrate Agents with CRM, ERP, ITSM, HRM, SCM, code repository, CI/CD
- Shift human review from checking every result to managing exceptions
- Build internal measurement standards
- Train Harness Engineers, AgentOps Engineers, Validation Engineers, AIX Chief Architects

### 10.4 Automated → Native
- Redefine operating model around AI as an operating system
- Redesign core processes as event-driven, context-rich, Agent-orchestrated
- Build enterprise knowledge layer and Agent memory layer
- Design real-time inference data pipelines, feedback loops, continuous learning
- Separate computational core from inference layer clearly
- Build Multi-Agent orchestration
- Design adaptive governance
- Shift KPIs from automation efficiency to business model innovation, revenue, customer experience, learning speed
- Build AI-native product/service catalog

---

## 11. Change Management Across Levels

- **Level 1**: Focus on awareness. Leadership and middle management understand AI transformation is strategy, not an IT project.
- **Level 2**: Focus on knowledge and motivation. Employees understand benefits of using AI safely and know how to use it.
- **Level 3**: Focus on practical capability and deep knowledge. Roles, standard processes, data stewards, AI Champions, redesigned governance.
- **Level 4**: Focus on consolidation and organizational redesign. Organization accepts Agents operating workflows directly; humans shift to exceptions and control.
- **Level 5**: Focus on culture and continuous learning. Organization learns faster, develops more effectively through Human–Agent teams.

---

*Document extracted from FPT CASAN Methodology reference. All definitions, characteristics, and mappings are preserved verbatim from the source material.*
