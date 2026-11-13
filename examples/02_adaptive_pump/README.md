# Example 02 – Adaptive backstepping for the same pump (J and L unknown)

## Input
`input_document.docx`: the pump model from example 01, followed by an "Adaptive Backstepping" section. The author treats the rotor inertia J and the inductance L as unknown (θ1 = 1/J, θ2 = 1/L). The section carries the derivation by hand most of the way: V, its derivative, the TERM brackets, u and the adaptation laws. It leaves φ̇2, φ̇3 and the final substitution open.

## What was asked and answered
The agent checked the hand-solved part first. Its findings changed the derivation, so it put them to the user together with its questions, on one screen:

| Question | Answer |
|---|---|
| Sign of f1: the document writes 2Q_vad − (2/R_bf)ΔP, but its own model gives + | Use the corrected sign, and report how the result differs with the document's sign |
| ½z3³ in V (not positive definite) | Use ½z3² (the document's own V̇ already assumes it) |
| Two sign errors in the z2·z3 cross terms | Use the corrected signs |
| The unknown θ1 appears in φ̇3, so the document's adaptation law cannot make V̇ = −Σkz² | Add a tuning-function term (main result). Also show the residual V̇ of the document's law |
| sgn(ω) | ω > 0 |
| Q_vad, ΔP | Measured signals up to the 2nd derivative; regulation ΔV → 0 |
| Division by θ̂1 and θ̂2 | Derive without projection; recommend projection in the report |
| Output | `Vin_fun.m`, `th1h_dot_fun.m`, `th2h_dot_fun.m` |

The full list is in `agent_output/checks/inventory.md`.

## Result
- The closed-loop check gives V̇ + k1x1² + k2z2² + k3z3² = 0 at both the abstract and the physical level. The check was also repeated outside MATLAB, by plugging the generated functions into the true dynamics: the residual was ~1e-13.
- The true J and L do not appear in any law (checked with assert).
- The agent chose ode15s because the system is stiff: the current changes in ~3 ms, the volume over seconds.
- A first simulation with very high gains drove θ̂2 to zero and the law blew up. The agent kept this result in the log and reran with realistic gains.
- With the document's law (no tuning term) V̇ deviated from the target by up to 23 %, but stayed negative in this scenario. Only the tuning-function law guarantees V̇ ≤ 0.

## Where to look
1. `agent_output/REPORT.md`: errors found in the document (§2), final law (§4), simulation (§4.5), questions for the author (§7).
2. `agent_output/Vin_fun.m`, `th1h_dot_fun.m`, `th2h_dot_fun.m`: the laws for Simulink. Input orders are listed in `agent_output/README.md`. Note that `a_w` comes before `a_P` here, the other way round from example 01.
3. `agent_output/checks/`: all checks, the simulation and its plot.

The agent wrote its report in Turkish (the user's language); `REPORT.md` and `agent_output/README.md` are translations. Internal name: `D12_b_model.docx` is `input_document.docx` here.
