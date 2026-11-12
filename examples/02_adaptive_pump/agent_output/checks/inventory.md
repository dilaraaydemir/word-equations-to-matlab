# Inventory: D12_b_model.docx

Source: `checks/source/D12_b_model.docx` (copy), pandoc output `checks/source/equations.md`.
The first figure (`media/image1.emf`, system sketch) cannot be read by pandoc; not used.

## Sections
1. Model (physical): E1-E16
2. "Adaptive Backstepping": E17-E30
3. "1st step", "2nd step", "3rd step": E31-E36
4. "1st Adaptation law", "2nd Adaptation law": E37-E40

## Solved part
| No | Equation (document) |
|---|---|
| E1 | ΔP = P_T,pre - P_T,after |
| E2 | ΔV_h = V_h1 - V_h2, ΔV̇_h = V̇_h1 - V̇_h2 |
| E3 | V̇_h1 = Qvad - Qgp, V̇_h2 = Qgp - Qvad |
| E4 | ΔV̇_h = 2(Qvad - Qgp) |
| E5 | Qgp = α_ω ω - ΔP/Rbf |
| E6 | ω̇ = -τ(ω)/J + K_i/J i - α_P/J ΔP |
| E7 | di/dt = -K_emf/L ω - R_gp/L i + V_in/L (written as d/dt of i̇: typo) |
| E8 | τ(ω) = τ1 sgn(ω) + τ2 ω |
| E9-E13 | physical values and units |
| E14 | ΔV̇_h = 2Qvad + (2/Rbf)ΔP - 2α_ω ω |
| E15 | ω̇ = -(τ1/J)sgn(ω) - (α_P/J)ΔP - (τ2/J)ω + (K/J)i |
| E16 | di/dt = -(K/L)ω - (R/L)i + v_in/L |
| E17a,b | f1 = 2Qvad - (2/Rbf)ΔP, f2 = -τ1 sgn(ω) - α_P ΔP |
| E18 | g1 = -2α_ω, g2 = -τ2, g3 = K |
| E19 | g4 = -K, g5 = -R_gp |
| E20 | θ1 = 1/J, θ2 = 1/L |
| E21a-c | ẋ1 = f1 + g1x2, ẋ2 = θ1(f2 + g2x2 + g3x3), ẋ3 = θ2(g4x2 + g5x3 + u) |
| E22 | z2 = φ2 - x2, z3 = φ3 - x3 |
| E23 | x2 = φ2 - z2, x3 = φ3 - z3 |
| E24a-c | ẋ1, ż2, ż3 in x |
| E25a-c | ẋ1, ż2, ż3 in φ, z |
| E26 | θ̃i = θ̂i - θi, dθ̃i/dt = dθ̂i/dt |
| E27 | V = ½x1² + ½z2² + ½z3³ + θ̃1²/(2γ1) + θ̃2²/(2γ2), V̇ |
| E28 | V̇ expanded with θ = θ̂ - θ̃ |
| E29 | V̇ rearranged in brackets x1[..], z2[..], z3[..], θ̃1(..), θ̃2(..) |
| E30 | target V̇ = -k1x² - k2z2² - k3z3² |
| E31, E32 | step 1, φ2 = (-k1x1 - f1)/g1 |
| E33, E34 | step 2, φ3 |
| E35, E36 | step 3, u |
| E37, E38 | θ̃1 bracket = 0, θ̂̇1 law |
| E39, E40 | θ̃2 bracket = 0, θ̂̇2 law |

## Step list (not yet carried out in the document)
| No | Step | MATLAB operation |
|---|---|---|
| T1 | Choose V, compute V̇ (E27, E28) | `V`, `Vdot` with θ1 = θ1h - th1t, θ2 = θ2h - th2t |
| T2 | Rearrange into TERM1..3, TERM_θ1, TERM_θ2 (E29) | coefficients by `diff`, assert |
| T3 | Solve φ2, φ3, u (E31-E36) | `isolate` on TERMi = -ki·(error) |
| T4 | Adaptation laws (E37-E40) | TERM_θi = 0 → `isolate` for θ̂̇i |
| T5 | Derivatives φ̇2, φ̇3 (implicit in document) | `diff(.., t)` along estimated dynamics |
| T6 | Subs: u, θ̂̇1, θ̂̇2 in x1, x2, x3, θ̂1, θ̂2 only | `for ii = 1:5` subs + assert |
| T7 | Subs f, g → physical final Vin | one `subs`, simplify, assert allowed symbols |

## Notation
x1 = ΔV_h = DV, x2 = ω = W, x3 = i_gp = i, u = v_in = Vin, z = ε, φ = x_ref,
θ̂1 = th1h, θ̂2 = th2h, θ̃1 = th1t, θ̃2 = th2t, γ1 γ2 = gam1 gam2.
Physical: Qvad, DP (+ _dot, _ddot), a_w, a_P, Rbf, Rgp, K, t1, t2 (τ1, τ2), J, L.

## Symbol table
| LaTeX | MATLAB | meaning | kind | time-dep. | assumption |
|---|---|---|---|---|---|
| x1 | x1(t) / DV | ΔV_h | state | yes | real |
| x2 | x2(t) / W | ω | state | yes | real (sign: S6) |
| x3 | x3(t) / i | i_gp | state | yes | real |
| u | u / Vin | v_in | input | - | real |
| f1, f2 | f1(t), f2(t) | known signals | signal | yes | real |
| g1..g5 | g1..g5 | constants | const | no | real, nonzero g1, g3 |
| θ1, θ2 | th1, th2 | 1/J, 1/L (unknown) | param | no | positive |
| θ̂1, θ̂2 | th1h(t), th2h(t) | estimates | adaptive state | yes | real (≠0) |
| γ1, γ2 | gam1, gam2 | adaptation gains | const | no | positive |
| k1..k3 | k1 k2 k3 | gains | const | no | positive |
| Qvad, ΔP | Qvad, DP | VAD flow, pressure diff. | signal | yes | real |

## Questions and decisions (answers 2026-11-13)
| No | Question | Decision |
|---|---|---|
| S1 | Scope Adaptive Backstepping, steps T1-T7 | Yes |
| S2 | f1 sign (E17a) | E17a_corr: f1 = 2Qvad + (2/Rbf)ΔP; report the difference to the document sign |
| S3 | ½z3³ in V (E27) | E27_corr: ½z3² |
| S4 | z2·z3 cross-term signs (E29, E38) | _corr signs |
| S5 | Missing tuning-function term | Tuning function is the main result; show the residual V̇ term of the document law in the report |
| S6 | Sign of ω | ω > 0, sgn(ω) = +1 |
| S7 | Signals, goal | Qvad, ΔP measured signals up to 2nd derivative; f_i functions of time only; regulation x1 → 0 |
| S8 | Positive constants | k1..k3, γ1, γ2, θ1, θ2 positive; α_ω ≠ 0, K ≠ 0 |
| S9 | Projection for θ̂ | Derive and simulate without projection; propose projection in the report as a question to the author |
| S10 | Output | Vin_fun.m, th1h_dot_fun.m, th2h_dot_fun.m; no numbers substituted; no reference solution |
| extra | | Assert that true θ1, θ2 (J, L) do not appear in Vin and the adaptation laws |
| extra | | Simulation: θ̂(0) 50 % off the true value; compare document law (no tuning term) with tuning-function law |
