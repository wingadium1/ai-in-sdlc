---
title: "GSD/OMO Enablers & Technical Challenges"
subtitle: "OpenStack RHOSO DBaaS PoC Case Study"
date: 2026-05-26
---

# Slide 1: GSD/OMO Enablers for Natural AI Collaboration

## Enabler 1: Natural Language Interaction
- From "tool" to "teammate" — AI understands intent from chat
- Example: "fake GSD" → AI adapts narrative strategy on the fly

## Enabler 2: Handoff & Context Persistence
- Solves 200K token window limit
- Session→Task handoff + Notepad as shared memory

## Enabler 3: Automated Planning-to-Execution
- AI plans detailed validation steps (Opus-class models)
- AI executes plan with cheaper models (Haiku-class)
- Result: 35-40% cost optimization

---

# Slide 2: Technical Challenge: Context & Cost

## Challenge: Context is Expensive & Fleeting

1. Token Window Ceiling (200K)
   - Cannot fit entire project context in one session
   - Mitigation: Wave-based decomposition, notepad persistence

2. Context Loss Between Sessions
   - Compact/handoff is "lossy" — critical details are lost
   - Real impact: agents repeated mistakes until human intervened
   - Human-in-the-loop is still essential to bridge context gaps

3. High Cost of Bare-Metal (EC2 c5d.metal)
   - Manual validation would be prohibitively expensive
   - Forced adoption of "auto-pilot" agentic workflow
   - AI completed 14 retest cycles in minutes, not days

---

# Slide 3: Technical Challenge: Real-World Bottlenecks

## Challenge: AI Cannot Bypass Physical Reality

1. Physical Infrastructure Blockers
   - **FAILED**: Dell R640 server bond configuration
   - **MISSING**: Cisco Nexus 9300 Data VLAN SVI
   - Result: Physical OCP install STALLED, forcing document-based PoC

2. Customer Decision Bottlenecks
   - **UNRESOLVED**: 3 blocking decisions (KP-02: storage, KP-03: NIC mapping, KP-05: control plane)
   - Result: Architecture path blocked at customer level

Key Insight: AI can automate infrastructure work at incredible speed, but it's still gated by hardware procurement, network setup, and human decision-making.
