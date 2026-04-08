# Project Type Guide: Embedded / Firmware

Embedded and firmware development involves writing code for microcontrollers (STM32, ESP32, Arduino), embedded Linux systems (Raspberry Pi, Yocto), RTOS environments (FreeRTOS, Zephyr), and safety-critical platforms.

This SDLC is distinct because bugs often have physical consequences. Unlike web services, you cannot hot-patch production devices easily. Testing requires hardware or high-fidelity emulators. Resource constraints like RAM and flash usage are not just metrics, they are strict acceptance criteria. Finally, toolchain setup is a non-trivial part of the development process.

## Phase Differences

| Phase | Key Considerations |
| :--- | :--- |
| **Intake** | Requirements originate from hardware specifications, electrical interface documents (pin maps, timing diagrams), field telemetry, and hardware team PRDs. |
| **Define** | Acceptance criteria must include target MCU/SoC resource budgets (RAM/Flash), interrupt latency limits, GPIO/UART timing, and power consumption budgets. |
| **Decide** | Architecture must address heap vs stack allocation, ISR safety, RTOS task priorities, HAL vs direct register access, and safety classifications like IEC 61508. |
| **Produce** | Scaffold mode is default. AI generates module structures and interfaces, while the developer fills in register manipulation and timing-sensitive logic. |
| **Verify** | 4-level verification: host unit tests (mocked hardware), emulators (QEMU/Renode), hardware-in-the-loop (HIL) simulators, and physical device smoke tests. |
| **Approve** | Changes to ISRs, memory layouts, bootloaders, safety-critical paths, or OTA mechanisms require sign-off from both embedded and hardware engineers. |
| **Integrate** | Builds produce versioned binary artifacts (.hex, .bin, .elf). Artifacts must be stored with flashing instructions and OTA compatibility checks. |

## Resource Budget Tracking

Tracking RAM and flash usage is a mandatory part of the acceptance process. Every build should output the section sizes (e.g., using `size` utility). A feature is only complete if it fits within the pre-defined resource budget in `project.yaml`. If a change exceeds the budget, it requires an architecture review or optimization phase before approval.

## Safety Classification Note

Safety-critical systems must adhere to constraints from IEC 61508 or ISO 26262. These constraints should be added to the `org.yaml` or `project.yaml` to ensure AI-generated code follows mandatory safety patterns, such as avoiding specific C features or requiring MISRA compliance checks during the Produce phase.

## Canonical Examples

- **Hardware Abstraction Layer (HAL):** A driver module that wraps register-level access in a clean C API.
- **ISR Handler:** A minimal interrupt service routine that clears flags and notifies a task.
- **RTOS Task:** A FreeRTOS or Zephyr task with defined stack size and priority.
- **Unit Test:** A host-based test using Unity or CMock to verify logic with a mocked HAL.
- **Build Config:** A `CMakeLists.txt` or Makefile configured for a specific cross-compiler.

## Common Conventions

1. No dynamic memory allocation inside ISR contexts.
2. Use the `volatile` keyword for all hardware-mapped variables.
3. Access hardware registers exclusively through the HAL layer.
4. Define explicit behavior for all possible error paths.
5. No blocking calls or long loops in ISR contexts.
6. Adhere to strict memory alignment requirements for the target MCU.
7. Use fixed-width integer types (uint32_t, int16_t) from `<stdint.h>`.
8. Ensure all shared variables between tasks and ISRs are protected by critical sections or atomics.
9. Validate all input parameters in public HAL functions.
10. Maintain a clear separation between hardware-dependent and hardware-independent code.

## Team Checklist

- [ ] Target MCU/SoC specified and resource budget defined?
- [ ] Hardware interface documents (pinout, timing) attached to the work item?
- [ ] Unit tests pass on host with mocked hardware?
- [ ] RAM/Flash usage verified against the budget?
- [ ] ISRs reviewed for length and blocking calls?
- [ ] Safety-critical paths identified and gated for human review?
