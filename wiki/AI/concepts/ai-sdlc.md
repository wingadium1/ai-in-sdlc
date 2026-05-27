# AI-Assisted SDLC Framework

## The Stack
```
User → GSD (meta-prompting) → OMO (agent harness) → OpenCode (runtime) → AI Models
```

## How GSD + OMO Work Together
- **GSD** provides the structured workflow: project initialization, phase discussion, planning, execution, verification, shipping
- **OMO** provides the agent orchestration: category-based model routing, specialized agents (Sisyphus, Prometheus, Atlas, Oracle, Librarian, Explore)
- Both run on top of **OpenCode** as the runtime environment
- Together they form a complete AI-assisted software delivery pipeline

## Key Benefits
1. **Context engineering** — Fresh context per agent prevents context rot
2. **File-based state** — .planning/ directory persists across sessions
3. **Category-based model routing** — Right model for the right task automatically
4. **Wave-based execution** — Parallel task execution with dependency management
5. **Evidence-based verification** — Each task produces verifiable outputs

## References
- [[frameworks/gsd/README|GSD Documentation]]
- [[frameworks/omo/README|OMO Documentation]]
