# REPORT: Deneme_14_model.docx → backstepping law for the gear pump

## 1. Document, scope, decisions
- Document: `Deneme_14_model.docx` (copy in `source/`, pandoc output `source/equations.md`, figure `source/image1.png`).
- Output folder: `Deneme_14_model_2026-11-12_233140/`. The earlier folder `..._231529` was not opened.
- The document contains the model (E1–E16) and the strict-feedback form (E17–E19). **There is no list of
  remaining steps**; the standard lab recipe T1–T8 was proposed and accepted (S2).
- Decisions (user: "önerilerin hepsi tamam", i.e. all recommendations accepted): regulation ΔV → 0 with z1 = x1; z2 = φ2 − x2, z3 = φ3 − x3;
  V = ½x1² + ½z2² + ½z3²; target V̇ = −k1x1² − k2z2² − k3z3², k_i > 0; ω > 0 so sgn(ω) = +1;
  Q_vad and ΔP are exogenous signals; K_i = K_emf = K, J = J_gp, L = L_gp, ΔV = ΔV_h, u = v_in;
  all constants positive; no numeric values in the law. Details in `inventory.md`.

## 2. Hand-solved part (`chk_document.m`, `side_by_side.md`)
All consistency checks give residual 0: E3 → E4, E4 + E5 → E10, E6 + E8 → E11, E7 = E12, and
E17–E19 with f1, f2, g1..g6 reproduce E10–E12. The system is in strict-feedback form (g1 = −2α_ω,
g3 = K/J, g6 = 1/L are nonzero). V is positive definite. **No error that changes the derivation.**

Minor findings (notation only):
| Equation | Finding | Proposed correction |
|---|---|---|
| E6, E7, E11, E12 | K_i, K_emf, K for one constant; J/J_gp; L/L_gp | one name each |
| E2, E13 | ΔV_h vs ΔV | one name |
| E7, E12 | `\dot{\dot{i}}_{gp}` (dot over a dotted i) | `\dot{i}_{gp}` |
| E9 | τ1 in N, τ2 in N·s·m⁻¹, but they are torques | τ1 in N·m, τ2 in N·m·s·rad⁻¹ |
| Figure | valves are labelled g1..g6, same as the model coefficients | rename valves (v1..v6) |

## 3. Steps (`deriv_backstepping.m`, `verify_backstepping.m`)
| Step | Done | Result | Verification |
|---|---|---|---|
| T1 | V = ½x1² + ½z2² + ½z3², x2 = φ2 − z2, x3 = φ3 − z3 | | |
| T2 | V̇ = x1ẋ1 + z2ż2 + z3ż3 | | |
| T3 | TERM1 = f1 + g1φ2; TERM2 = φ̇2 − f2 − g2x2 − g3φ3 − g1x1; TERM3 = φ̇3 − g4x2 − g5x3 − g6u + g3z2 | | V̇ − Σ z_i·TERM_i = 0 |
| T4, T5 | z_i·TERM_i = −k_i z_i², `isolate` | φ2 = −(f1 + k1x1)/g1; φ3 = (φ̇2 − f2 − g2x2 − g1x1 + k2z2)/g3; u = (φ̇3 − g4x2 − g5x3 + g3z2 + k3z3)/g6 | TERM1, TERM2, TERM3 conditions: 0 |
| T6 | φ̇2, φ̇3 by `diff` along the dynamics (placeholders resolved and asserted before each `diff`) | needs f1dot, f1ddot, f2dot | chain-rule comparison: 0 |
| T7 | z2, z3 substituted, all in x1, x2, x3 | | |
| T8 | physical f, g substituted, sgn(ω) = +1, f2dot = −(α_P/J)ΔṖ | W_ref, i_ref, Vin | full closed loop V̇ + k1ΔV² + k2z2² + k3z3² = **0** (abstract and physical) |

## 4. Final law
With Q_e = Q_vad + ΔP/R_bf (= f1/2), S = k1+k2+k3, P = k1k2 + k1k3 + k2k3 (checked equal to the full
expression in `compact_form.m`):

```
W_ref = (Qe + k1*DV/2)/a_w

i_ref = ( J*Qe_dot + J*(k1+k2)*Qe + a_P*a_w*DP + a_w*t1 + a_w*t2*W
          + (2*J*a_w^2 + J*k1*k2/2)*DV - J*a_w*(k1+k2)*W ) / (K*a_w)

Vin = K*W + Rgp*i + L/(J*K*a_w) * N
N   = J^2*Qe_ddot + J^2*S*Qe_dot + (K^2 + 4*J^2*a_w^2 + J^2*P)*Qe
    + (K^2*k1/2 + 2*J^2*a_w^2*k3 + J^2*k1*k2*k3/2)*DV
    - a_w*(K^2 + t2^2 + 4*J^2*a_w^2 + J^2*P - J*t2*S)*W
    + a_w*t1*(J*S - t2) + a_P*a_w*(J*DP_dot + (J*S - t2)*DP)
    + K*a_w*(t2 - J*S)*i
```
The fully expanded MATLAB form (`Vin_simp`) is in `results.mat` and `analysis_results.md`.

- **Signals needed:** ΔV, ω, i_gp; Q_vad, Q̇_vad, Q̈_vad; ΔP, ΔṖ, ΔP̈.
- **Simulink:** `Vin_fun(DV, W, i, Qvad, DP, Qvad_dot, DP_dot, Qvad_ddot, DP_ddot, a_P, a_w, Rbf, Rgp, L, J, K, t1, t2, k1, k2, k3)`;
  also `W_ref_fun(DV, Qvad, DP, consts...)` and `i_ref_fun(DV, W, Qvad, DP, Qvad_dot, DP_dot, consts...)`
  with the same constant order (a_P … k3). `Vin_fun` matches the symbolic law (relative difference 1e-16).
- **Singularities:** only physical constants are in denominators (a_w, K, J, Rbf; L only as a factor).
  Their zero values are real singularities (L = 0 is removable: Vin → Kω + R_gp·i). All are positive, so
  no singularity in operation. No state or signal is in a denominator. Simplified and unsimplified
  forms agree at 5 random points (relative difference 0).
- **Assumption ω > 0:** the law uses sgn(ω) = +1. It is valid only while ω stays positive, which needs
  **W_ref > 0, i.e. Q_vad + ΔP/R_bf + k1·ΔV/2 > 0**. For a large negative ΔV (or small Q_vad) W_ref becomes
  negative and the pump would have to reverse.
- **Simulation (`sim_check.m`, test signals and gains k = 1, 20, 200, true sgn in the plant):**
  ΔV0 = +1e-4 m³: ω stays ≥ 40 rad/s, ΔV(5 s) = 6.8e-7 m³, max |Vin| = 22.6 V, max |i| = 29 A (start transient).
  ΔV0 = −3e-4 m³: W_ref reaches −39 rad/s, ω reaches −55 rad/s, so the proof does not hold there
  (it still converged in this test). Max |Vin| = 29.4 V, max |i| = 47 A. **Check against the motor's
  voltage and current limits**; the peaks come from the initial error, mostly through k3.

## 5. Reference comparison (`compare_reference.m`, copy `ref_copy.m`)
With sign(W) = 1: ref − agent = **0** for W_ref, i_ref and Vin, and the closed-loop check of the reference
law is 0. Notes on `ref.m`:
- It keeps `sign(W)` in Vin but drops its derivative (F2dot has no dirac term). This is correct only for W ≠ 0
  and is the same as sgn = +1 for W > 0.
- `syms x1(t) ... real` does not set assumptions on functions (MATLAB warnings).
- The cross-term coefficients are computed with `*x1/z2`, `*z2/z3` (division by an error variable). Here it
  cancels symbolically, but it would give 0/0 if z2 or z3 were set to 0 first.
- There is no closed-loop check in `ref.m`.

## 6. Questions for the author
1. The document has no step list. Are T1–T8 (standard backstepping, regulation ΔV → 0) the intended steps?
2. Is ΔP really independent of ΔV (hydrostatic head between tanks)? If ΔP depends on ΔV, f1 and f2 depend on the
   state and the derivatives change.
3. How are Q̈_vad and ΔP̈ obtained in the test rig (filter or differentiator)? The law needs them.
4. What are the voltage and current limits of the gear pump?
5. Should the law handle ω ≤ 0 (pump reversal), or should W_ref be limited to positive values?

## 7. Files
- `source/` — copy of the Word file, `equations.md`, figure (`media/image1.emf`, `image1.png`)
- `inventory.md` — sections, solved part, steps, symbols, decisions S1–S10
- `side_by_side.md` — document LaTeX vs MATLAB, notation findings
- `chk_document.m` — consistency checks of the hand-solved part
- `deriv_backstepping.m` — derivation T1–T8 in the author's style
- `verify_backstepping.m` — closed-loop checks, abstract and physical
- `analyze_simplification.m` — denominators, 0/0, random points, Simulink functions
- `compact_form.m` — readable form of the law, asserted equal
- `sim_check.m` — ode45 test inside and outside the ω > 0 region
- `compare_reference.m`, `ref_copy.m`, `ref_results.mat` — reference comparison
- `run_and_log.m` — runs a script and appends its output to `analysis_results.md`
- `analysis_results.md` — raw output of all runs with time stamps
- `results.mat` — all symbolic results, abstract and physical
- `Vin_fun.m`, `i_ref_fun.m`, `W_ref_fun.m` — Simulink-ready functions
