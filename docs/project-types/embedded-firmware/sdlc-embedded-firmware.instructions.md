---
applyTo: "src/**"
name: "SDLC Embedded / Firmware Rules"
---

## 1. Phase Contract

All firmware development must follow the ai-in-sdlc phase model. Every work item requires a corresponding PhasePacket in the `.sdlc/phases/` directory.

## 2. Hardware Boundary Rule

Code that accesses hardware registers must reside exclusively within the Hardware Abstraction Layer (HAL). Do not write direct register access in the application or business logic layers. The HAL is the only layer exempt from host-based unit testing.

## 3. Memory Safety

Do not use dynamic memory allocation (`malloc`, `new`) in Interrupt Service Routines (ISRs) or time-critical paths. Prefer static allocation with fixed-size pools. Always verify return values for all memory operations to prevent null pointer dereferences.

## 4. ISR Constraints

Keep ISR functions as short as possible. Never use blocking calls or RTOS API functions that can cause a task to block. Avoid floating-point operations unless a hardware FPU is present and explicitly configured. Use flags, semaphores, or queues to signal tasks from ISR context.

## 5. RTOS Tasks

Every RTOS task must define a specific stack size, which must be verified to prevent overflows. Each task must also have an assigned priority and a defined worst-case execution time (WCET). Do not use task suspension as a synchronization mechanism. Use semaphores, queues, or event groups instead.

## 6. Volatile Correctness

Declare any variable shared between an ISR and a task context as `volatile`. Any variable mapped directly to a hardware register must also be `volatile`. Accessing a non-volatile shared variable from an ISR results in undefined behavior.

## 7. Error Handling

Embedded systems must handle all error paths gracefully. Since there is no "crash and restart" mechanism in production firmware, every function must define its behavior on failure. Valid responses include returning an error code, setting a fault flag, or entering a safe state.

## 8. Testing Strategy

Run unit tests on the host machine using a mocked HAL. Focus on testing the logic rather than the hardware. Verify hardware-dependent behavior, such as timing and electrical states, during Hardware-in-the-loop (HIL) tests rather than unit tests.

## 9. Resource Budget

Check the current RAM and flash usage (e.g., using `arm-none-eabi-size`) before implementing any new feature. Acceptance criteria for any change include remaining within the resource budget defined in `project.yaml`.

## 10. Prohibited Practices

- No dynamic memory allocation in ISRs.
- No blocking calls or long loops in ISRs.
- No uninitialized variables.
- No missing `volatile` qualifiers on hardware-mapped registers.
- No magic numbers for register addresses; use named constants instead.
- No untested changes to the bootloader or Over-the-Air (OTA) update mechanism.

## 11. Artifact Traceability Rule

Every firmware binary must be traceable to the specific commit and PhasePacket that produced it. Include version information and build timestamps within the binary metadata.
