# Example 03 – Adaptive backstepping with three unknown parameters

## Input
`input_document.docx` is a short abstract test document. Part of its text is in Turkish; translated, it reads:

> **Adaptive backstepping – three unknown parameters**
>
> System:
> ẋ1 = x2 + θ1·x1²
> ẋ2 = x3 + θ2·x1·x2
> ẋ3 = θ3·x3 + u
>
> θ1, θ2, θ3 are unknown constant parameters. x1, x2, x3 are measured. u is the control input.
> Goal: x1 → 0 and all signals stay bounded.
>
> Define z2 = φ2 − x2, z3 = φ3 − x3 (φ2, φ3: virtual controls); θ̂i: estimate of θi, θ̃i = θi − θ̂i.
> Choose V = ½x1² + ½z2² + ½z3² + Σ θ̃i²/(2γi).
> Take derivative of V, subs x2 = φ2 − z2, x3 = φ3 − z3, and rearrange into TERM brackets.
> Solve for φ2, φ3 and u such that each TERM gives −kᵢzᵢ² (θ̂i is used in place of θi).
> Choose the adaptation laws such that every TERM_θi = 0. Then V̇ = −k1x1² − k2z2² − k3z3² ≤ 0.

The difficulty: θ1 appears in the first equation and θ2 in the second. The document's step-by-step recipe therefore cannot cancel every θ̃ term, and a full tuning-function design is needed.

## What was asked and answered
| Question | Answer |
|---|---|
| θ̂̇ enters φ̇2 and φ̇3, so the plain step-by-step laws do not give V̇ ≤ 0 | (a) Tuning functions. Also show the residual of the plain laws |
| V and error sign | As in the document |
| Cross terms | −x1·z2 → TERM2, z2·z3 → TERM3 |
| Assumptions | k, γ > 0; θ constant, sign unknown; regulation x1 → 0; no projection needed (no division by θ̂) |
| Output and test | `u_fun.m`, `thetahat_dot_fun.m`, `phi2_fun.m`, `phi3_fun.m`; ode45 comparison with θ = (1, −0.5, 2), k = γ = 1, θ̂(0) = 0, x(0) = (1, 0.5, −0.5) |

The full list is in `agent_output/inventory.md`.

## Result
- The closed-loop check gives V̇ + k1x1² + k2z2² + k3z3² = 0. It was confirmed independently.
- The law is a pure polynomial: no singularities, and no signal derivatives needed.
- In simulation, V decreases monotonically with tuning functions. With the plain laws V rises from 10.4 to 28.
- The tuning-function law reaches |u| ≈ 4.7·10⁴ in the first 0.5 s, from high powers of x1. On a real actuator this would saturate.
- θ̂ does not converge to θ, as expected without persistent excitation.
- The same document was run in two separate sessions. The two laws were numerically identical, even though one session wrote u in 12 kB and the other in 2 kB.

## Where to look
1. `agent_output/REPORT.md`: method note (§2), final law (§4), comparison with the plain laws (§5).
2. `agent_output/u_fun.m`, `thetahat_dot_fun.m`: the laws for Simulink. Input order: `(x1, x2, x3, th1h, th2h, th3h, k1, k2, k3, g1, g2, g3)`, where `g1..g3` are γ1..γ3.
3. `agent_output/sim_adaptive.png`: the comparison plot.

The agent wrote its report in Turkish (the user's language); `REPORT.md` is a translation. Internal name: `D13_b_model.docx` is `input_document.docx` here.
