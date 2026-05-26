# Slide Deck: Challenges & AI-Augmented Work
# For import into Gemini App → PowerPoint

---

## Slide 1: Why GSD/OMO Over GitHub Copilot

**Title**: Why GitHub Copilot Wasn't Enough — Why GSD/OMO Was Needed

**Key Message**: GitHub Copilot operates at CASAN Level 1-2 (individual developer assistance). This project required CASAN Level 3-4 (structured planning, multi-agent orchestration, governance).

**Comparison Table** (6 rows):

| Dimension | GitHub Copilot | GSD + OMO |
|-----------|---------------|-----------|
| Context scope | Single file only | Full repo access (explore/librarian agents) |
| Planning | None | 11 tasks across 5 waves with dependency matrix |
| Parallel execution | No | 3-4 agents dispatched simultaneously per wave |
| Verification | No | Agent-executed QA with evidence files |
| Context persistence | No | Notepad files bridging 15 task dispatches |
| Audit trail | No | Handoffs (HO-001 to HO-005), decisions (D01-D10) |

**Bottom Line**: "AI-assisted development" (Copilot) ≠ "AI-orchestrated delivery" (GSD/OMO)

---

## Slide 2: AI-Augmented Work That Required Thinking

**Title**: Repetitive ≠ Simple — AI That Debugged Its Own Failures

**Key Examples**:

**1. Validation Retest Cycles (14 iterations)**
- AI: Test → Fail → Diagnose root cause → Fix → Retest → Evidence → Commit
- Example: V26 `NoValidHost` → AI mapped AZ to wrong hostname → corrected → retested
- This was NOT "run this command 14 times" — each cycle required diagnostic reasoning

**2. OVS Flow Automation**
- AI wrote script → script failed (SSH timeout) → AI diagnosed batching issue → fixed → parameterized for reuse
- Required understanding: OVS, RHOSO topology, SSH behavior, bash patterns

**3. Patroni HA Stack (Zero → Production)**
- Zero prior knowledge → AI self-educated (librarian) → designed stack → generated 5 Ansible docs → validated 16/16 critical tests
- PostgreSQL 16 + Patroni + etcd + VIP + pgBackRest — all chosen and configured by AI

---

## Slide 3: Technical Challenges

**Title**: What Made This Hard — And How We Solved It

**Challenge 1: Model Tier Optimization**

| Model Tier | Task Profile | Why |
|-----------|-------------|-----|
| Haiku-class (fast/cheap) | File checks, grep, metadata | No reasoning needed |
| Sonnet-class (balanced) | Templates, handoffs, logs | Pattern-following |
| Opus-class (deep reasoning) | Architecture analysis, CASAN mapping | Cross-domain synthesis |

**Result**: ~60% token cost savings by routing tasks appropriately.

**Challenge 2: 200K Context Window**

- All source docs: ~50K+ tokens → ❌ Doesn't fit
- Mitigation: Wave-based decomposition (each wave loads only its subset)
- Notepad persistence for cross-wave context bridging

**Challenge 3: Context Loss Between Sessions**

- Compact/handoff mechanism was lossy
- Validation retest cycles (14 commits) occurred because agents forgot prior fixes
- Mitigation: Notepad files (`.sisyphus/notepads/`) as explicit knowledge anchors

**Challenge 4: Physical Infrastructure Bottlenecks**

- 3 blocking decisions (KP-02/03/05) at customer level
- AI cannot bypass hardware procurement or customer decision-making
- Forced reliance on AWS reference environment

---

## Slide 4: Key Takeaways

**Title**: What We Learned

1. **Structured AI-assisted SDLC works**
   - GSD/OMO enabled efficient, governed execution with full audit trail
   - 11 tasks across 5 waves, 3-4 agents parallel per wave

2. **Document-based validation is viable**
   - When live infrastructure unavailable, comprehensive document validation works
   - 150+ screenshots, 15 evidence files, full git trail

3. **CASAN Level 3 is achievable in single PoC**
   - With proper Harness engineering (wave structure, handoffs, decision log, evidence trail)
   - Teams can elevate from Level 1 to Level 3 in one cycle

4. **Human-led, AI-first balance is critical**
   - Success came from clear delegation architecture
   - Humans defining scope, AI executing bounded tasks

5. **Harness is the differentiator**
   - Not the AI tools themselves
   - But the Harness surrounding them (governance, validation, security, orchestration)

---

## Slide 5: Evidence & Verification

**Title**: Proof It Worked — Git-Committed Evidence

**Validation Retest Commits** (openstack-101):
- `fc99609` — V4 retest with 2-terminal downtime measurement
- `31ebb4b` — V11-PB retest with VIP ping during resize
- `10b6554` — V12 full pg_dump/pg_restore retest
- `f3a7cf2` — V19 retest with 2-terminal VIP stability
- `360de45` — V26 retest with host aggregate overcommit
- `5092899` — V32 retest with multi-terminal rolling restart
- `dbe06e8` — V33-PB retest with 2-terminal VIP ping
- `04a70be` — OVS flow script batch SSH fix
- `f5d5e82` — OVS flow script parameterization

**Evidence Files** (ai-in-sdlc):
- `.sisyphus/evidence/task-1-validation-file.txt`
- `.sisyphus/evidence/task-2-baseline-doc.txt`
- `.sisyphus/evidence/task-3-casan-rubric.txt`
- `.sisyphus/evidence/task-8-dbaas-tests.txt`
- 10 total evidence files committed

**Result**: 94.4% validation pass rate (34/36 items), 100% Tier 1/MUST (16/16)
