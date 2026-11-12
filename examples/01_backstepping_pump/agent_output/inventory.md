# Inventory: Deneme_14_model.docx

Run folder: `Deneme_14_model_2026-11-12_233140/` (an earlier run folder `Deneme_14_model_2026-11-12_231529/`
exists next to it; it was not opened, so this run is independent).
Reference code `ref.m` exists in the working folder; it is opened only after the derivation is verified.

## Sections
The document has one plain-text line between equations: **"Define"**. Everything before it is the
physical model; everything after it is the strict-feedback form. There is **no list of remaining
steps** (no "Choose V ...", "Solve for ..." text). A figure (mock circulatory loop: LVAD, gear pump,
two tanks, compressor, vacuum pump) is at the top; the valves in the figure are also labelled g1..g6
(same names as the model coefficients g1..g6, but unrelated).

## Solved part
| No. | Equation |
|---|---|
| E1 | ΔP = P_T,pre − P_T,after |
| E2 | ΔV_h = V_h1 − V_h2 → ΔV̇_h = V̇_h1 − V̇_h2 |
| E3a, E3b | V̇_h1 = Q_vad − Q_gp, V̇_h2 = Q_gp − Q_vad |
| E4 | ΔV̇_h = 2(Q_vad − Q_gp) |
| E5 | Q_gp = α_ω ω − ΔP/R_bf |
| E6 | ω̇ = −τ(ω)/J + (K_i/J) i_gp − (α_P/J) ΔP |
| E7 | i̇_gp = −(K_emf/L) ω − (R_gp/L) i_gp + V_in/L |
| E8 | τ(ω) = τ1 sgn(ω) + τ2 ω |
| E9 | J = 0.293e-3, L = 1.44e-3, K = 72.4e-3, R_bf = 2.399e9, R_gp = 0.48, α_ω = 1.59e-6, α_P = 3.625e-6, τ1 = 44.9e-6, τ2 = 0.3e-3 (units line) |
| E10 | ΔV̇_h = 2Q_vad + (2/R_bf) ΔP − 2α_ω ω |
| E11 | ω̇ = −(τ1/J) sgn(ω) − (α_P/J) ΔP − (τ2/J) ω + (K/J) i_gp |
| E12 | i̇_gp = −(K/L) ω − (R_gp/L) i_gp + v_in/L |
| E13 | x1 = ΔV, x2 = ω, x3 = i_gp |
| E14a, E14b | f1 = 2Q_vad + (2/R_bf) ΔP, f2 = −τ1 sgn(ω)/J − (α_P/J) ΔP |
| E15a–c | g1 = −2α_ω, g2 = −τ2/J, g3 = K/J |
| E16a–c | g4 = −K/L, g5 = −R_gp/L, g6 = 1/L |
| E17 | ẋ1 = f1 + g1 x2 |
| E18 | ẋ2 = f2 + g2 x2 + g3 x3 |
| E19 | ẋ3 = g4 x2 + g5 x3 + g6 u |

## Step list (proposed, the document has none)
Proposed by the agent following the standard backstepping recipe of this lab; **to be confirmed (S2)**.
| No. | Proposed step | MATLAB operation |
|---|---|---|
| T1 | Choose V1 = ½z1², V2 = ½z2², V3 = ½z3² with z1 = x1, z2 = φ2 − x2, z3 = φ3 − x3 | define `z2`, `z3`; `x2 = phi2 - z2`, `x3 = phi3 - z3` |
| T2 | Solve for V̇ | `V_dot = x1*x1_dot + z2*z2_dot + z3*z3_dot` |
| T3 | Subs and rearrange: TERM1 only x1, φ2 terms; cross term g1·x1·z2 moved to TERM2; cross term g3·z2·z3 moved to TERM3 | `term1 = f1 + g1*phi2`, `term2 = phi2_dot - f2 - g2*x2 - g3*phi3 - g1*x1`, `term3 = phi3_dot - g4*x2 - g5*x3 - g6*u + g3*z2` |
| T4 | Choose z_i·TERM_i = −k_i z_i² | `term1 == -k1*x1`, `term2 == -k2*z2`, `term3 == -k3*z3` |
| T5 | Solve for φ2 (= ω_ref), φ3 (= i_ref) and u | `isolate(...)` (all linear) |
| T6 | Take derivatives of φ2 and φ3 | `diff(..., t)` with dynamics substituted, placeholders resolved first |
| T7 | Subs z2, z3 so that everything is in x1, x2, x3 | `subs` |
| T8 | Subs f and g to get the final u = v_in | physical section, `simplify` |

## Notation
| Document | MATLAB | Meaning |
|---|---|---|
| ε_i, error | `z1(=x1)`, `z2`, `z3` | errors |
| x_ref, φ | `phi2`, `phi3` | virtual controls ω_ref, i_ref |
| ΔV, ΔV_h | `X1`, physical `DV` | volume difference (same quantity, two names) |
| ω | `X2`, `W` | gear-pump speed |
| i_gp | `X3`, `i` | gear-pump current |
| u, v_in, V_in, v_in,gp | `u`, `Vin` | gear-pump input voltage (assumed same, S5) |
| K_i, K_emf, K | `K` | motor constant (three names, one value) |
| J, J_gp / L, L_gp | `J`, `L` | |
| α_ω, α_P | `a_w`, `a_P` | |
| τ1, τ2 | `t1`, `t2` | |
| Q_vad, ΔP | `Qvad`, `DP` | exogenous signals |

## Symbol table
| LaTeX | MATLAB | Meaning | Kind | Time-dep. | Assumption |
|---|---|---|---|---|---|
| x_1 | `x1(t)` / `X1` / `DV` | ΔV | state | yes | real |
| x_2 | `x2(t)` / `X2` / `W` | ω | state | yes | real (>0, S7) |
| x_3 | `x3(t)` / `X3` / `i` | i_gp | state | yes | real |
| f_1, f_2 | `f1(t)`, `f2(t)` + `f1dot f2dot f1ddot` | lumped signals | signal | yes | real |
| g_1..g_6 | `g1..g6` | coefficients | constant | no | real, nonzero |
| k_1..k_3 | `k1 k2 k3` | gains | constant | no | positive |
| Q_vad | `Qvad`, `Qvad_dot`, `Qvad_ddot` | LVAD flow | signal | yes | real |
| ΔP | `DP`, `DP_dot`, `DP_ddot` | pressure difference | signal | yes | real |
| J, L, K, R_bf, R_gp, α_ω, α_P, τ1, τ2 | `J L K Rbf Rgp a_w a_P t1 t2` | physical constants | constant | no | positive |
| u | `u` / `Vin` | gear-pump voltage | input | yes | real |

## Questions and decisions
User answer (2026-11-12): "önerilerin hepsi tamam" (all recommendations accepted).

| No. | Question | Decision |
|---|---|---|
| S1 | Scope | The single system x1 = ΔV, x2 = ω, x3 = i_gp |
| S2 | Step list | T1–T8 as proposed above |
| S3 | Control goal | Regulation ΔV → 0, z1 = x1 |
| S4 | Error sign | z2 = φ2 − x2, z3 = φ3 − x3 |
| S5 | Lyapunov function | V = ½x1² + ½z2² + ½z3² (positive definite) |
| S6 | Target V̇ | −k1x1² − k2z2² − k3z3², k_i > 0 |
| S7 | sgn(ω) | ω > 0, sgn(ω) = +1 (no dirac term) |
| S8 | Signals | Q_vad, ΔP exogenous, time-only; derivatives up to 2nd order |
| S9 | Names | K_i = K_emf = K; J = J_gp; L = L_gp; ΔV = ΔV_h; u = v_in = V_in; all constants and gains positive |
| S10 | Output | Simplified law + `Vin_fun.m`, `W_ref_fun.m`, `i_ref_fun.m`; no numeric values |
