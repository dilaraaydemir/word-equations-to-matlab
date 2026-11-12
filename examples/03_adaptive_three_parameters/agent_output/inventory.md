# Inventory - D13_b_model.docx

Source: `source/D13_b_model.docx` (copy), `source/equations.md` (pandoc 3.13).
MATLAB R2025b, Symbolic Math Toolbox 25.2.

## Sections
Only one section: "Adaptive backstepping -- üç bilinmeyen parametre" (adaptive backstepping, three unknown parameters).
Sub-headings in the text: "Sistem", "Define", "Choose V", "Take derivative", "Rearrange", "Solve", "Choose the adaptation laws", "Then", "Take derivative of φ2 and φ3".

## Solved part (equations given by the author)
| No | Equation |
|----|----------|
| E1a | ẋ1 = x2 + θ1·x1² |
| E1b | ẋ2 = x3 + θ2·x1·x2 |
| E1c | ẋ3 = θ3·x3 + u |
| E2 | θ1, θ2, θ3 unknown, constant; x1, x2, x3 measured; u is the input |
| E3 | Goal: x1 → 0, all signals bounded |
| E4a | z2 = φ2 − x2 |
| E4b | z3 = φ3 − x3 |
| E5a | θ̃i = θi − θ̂i |
| E5b | dθ̃i/dt = −dθ̂i/dt |
| E6 | V = ½x1² + ½z2² + ½z3² + Σ θ̃i²/(2γi) |
| E7 | V̇ = −k1x1² − k2z2² − k3z3² (target) |

## Step list
| No | Document text | MATLAB operation |
|----|---------------|------------------|
| T1 | Choose V (E6) | `V = x1^2/2 + z2^2/2 + z3^2/2 + sum(tht.^2./(2*gam))` |
| T2 | Take derivative of V, subs x2 = φ2 − z2, x3 = φ3 − z3 | chain rule along E1 with θ = θ̂ + θ̃, θ̂̇ kept as symbols `th1h_dot ...` |
| T3 | Rearrange into x1·TERM1 + z2·TERM2 + z3·TERM3 + Σ θ̃i·TERM_θi | `diff(Vdot, tht_i)` for TERM_θi (linear), remainder split by x1, z2, z3 |
| T4 | Solve φ2, φ3, u from x1·TERM1 = −k1x1², z2·TERM2 = −k2z2², z3·TERM3 = −k3z3² (θ̂ instead of θ) | `isolate(TERM1 == -k1*x1, phi2)` etc. |
| T5 | Adaptation laws from TERM_θi = 0 | `isolate(TERM_thi == 0, thih_dot)` |
| T6 | Take derivative of φ2, φ3; express u and adaptation laws in x1, x2, x3, θ̂1..θ̂3 | `diff` with dynamics substituted, placeholders resolved |

No `f_i`, `g_i` and no physical values in this document, so "Subs f and g" does not apply.

## Notation
| Document | MATLAB | Meaning | Kind | Time dep. | Assumption |
|---|---|---|---|---|---|
| x1, x2, x3 | `x1(t) x2(t) x3(t)` → `X1 X2 X3` | states | state | yes | real |
| u | `u` | input | input | yes | real |
| θi | `th1 th2 th3` | true parameters | constant | no | real |
| θ̂i | `th1h(t) ...` → `TH1h ...` | estimates | adaptive state | yes | real |
| θ̃i | `tht1 tht2 tht3` | estimation errors | | yes | real |
| φ2, φ3 | `phi2 phi3` | virtual controls (x_ref) | placeholder | yes | real |
| z2, z3 | `z2 z3` | errors ε | | yes | real |
| ki | `k1 k2 k3` | gains | constant | no | positive |
| γi | `g1 g2 g3` (`gam`) | adaptation gains | constant | no | positive |

## Questions and decisions (answered 2026-11-13)
| No | Question | Decision |
|----|----------|----------|
| S1 | Scope | Whole document (one section) |
| S2 | Restatement T1–T6 | Accepted as written above |
| S3 | θ̂̇ enters φ̇2, φ̇3 (θ1, θ2 appear before the last equation) | (a) Tuning functions: TERM_θi collects all θ̃i terms; φ3 uses τ2 (z3 = 0 part); cross term z2·∂φ2/∂θ̂·Γ·ω3·z3 goes to TERM3. The residual of the document's plain laws is shown in the report. |
| S4 | V and sign convention | V as in E6 (valid for γi > 0); z = φ − x as in the document |
| S5 | Cross terms | −x1·z2 → TERM2; z2·z3 → TERM3; target V̇ as E7 |
| S6 | Assumptions | k1..k3, γ1..γ3 > 0; θi constant, sign unknown; regulation x1 → 0; no projection needed (no division by θ̂) |
| S7 | Outputs | u, θ̂̇ simplified; `u_fun.m`, `thetahat_dot_fun.m`, plus `phi2_fun.m`, `phi3_fun.m` (inputs x1,x2,x3,θ̂1..3,k1..3,γ1..3); symbolic closed-loop check; ode45 comparison tuning vs plain laws with θ = (1, −0.5, 2), k = γ = 1, θ̂(0) = 0, x(0) = (1, 0.5, −0.5); assert that true θ is absent from u and adaptation laws. No reference code. |

"Plain laws" (document reading without tuning functions): each θ̃i is cancelled only by the term of its own step: θ̂̇1 = γ1·x1³, θ̂̇2 = −γ2·z2·x1·x2, θ̂̇3 = −γ3·z3·x3, and φ3, u use these laws for θ̂̇ (certainty equivalence).
