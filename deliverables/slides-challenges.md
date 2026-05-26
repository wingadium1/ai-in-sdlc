# Slide Content: Challenges & AI-Augmented Work

## Slide 1: Why GSD/OMO Over GitHub Copilot

```
## Why GSD/OMO Over GitHub Copilot

GitHub Copilot → CASAN Level 1-2 (individual developer assistance)
GSD/OMO → CASAN Level 3-4 (structured enterprise delivery)

| Capability | Copilot | GSD/OMO |
|-----------|---------|---------|
| Scope | Single file completion | Multi-file orchestrated pipeline |
| Planning | None | 11 tasks, 5 waves, dependency matrices |
| Agents | 1 dev + AI | 4 agent categories simultaneously |
| Verification | Manual | Automated QA with evidence files |
| Context | Lost on restart | Persistent notepads across sessions |
| Governance | None | Handoffs, decision logs, audit trail |

Key Insight: Copilot assists. GSD/OMO orchestrates.
```

---

## Slide 2: AI-Augmented Repetitive Work

```
## AI-Augmented Work: Repetitive but Requires Thinking

Example 1 — Validation Retest Cycles (14 cycles)
  • AI: run test → detect failure → diagnose root cause → propose fix → retest → commit
  • Human: review diagnosis, authorize retest
  • Why it matters: Script can run tests. Only AI can diagnose WHY they fail.

Example 2 — Script Debug & Parameterize
  • AI wrote OVS automation script → timeout failure
  • AI diagnosed SSH batch issue → fix → parameterize
  • Evidence: git log openstack-101 "fix(scripts): batch SSH..."

Example 3 — Model Tiering Strategy
  • Quick tasks → budget models (70% cost savings)
  • Deep research → premium models (required for 800-line document analysis)
  • Overall: 35-40% cost optimization
```
