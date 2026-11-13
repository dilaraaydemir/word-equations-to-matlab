# Report: D12_b_model.docx – Adaptive Backstepping

*Translated from the agent's Turkish report. The content is unchanged; only the file list in §8 reflects the copy in this repository.*

## 1. Document, scope, decisions
- Document: `D12_b_model.docx` (= `../input_document.docx`; pandoc output in `checks/source/equations.md`).
- Scope: the "Adaptive Backstepping" section (E17–E40), steps T1–T7 (`checks/inventory.md`).
- Output folder: `D12_b_model_2026-11-13_005946/` (= `agent_output/` here).
- Decisions:

| No | Decision |
|---|---|
| S1 | Scope and steps T1–T7 confirmed |
| S2 | f1 = 2Qvad **+** (2/Rbf)ΔP used (E17a_corr) |
| S3 | ½z3² used in V (E27_corr) |
| S4 | Corrected signs used for the z2·z3 cross terms (E29_corr, E38_corr) |
| S5 | The main result is the tuning-function law. The V̇ residual of the document's law is given below |
| S6 | ω > 0, sgn(ω) = +1 (no dirac term) |
| S7 | Qvad and ΔP are measured signals, known up to the 2nd derivative. f_i depend on time only. Goal: regulation x1 = ΔVh → 0 |
| S8 | k1..k3, γ1, γ2, θ1, θ2 > 0; α_ω ≠ 0, K ≠ 0 |
| S9 | Derivation and simulation without projection. Projection is proposed in §7 |
| S10 | Outputs: `Vin_fun.m`, `th1h_dot_fun.m`, `th2h_dot_fun.m`. No numeric values substituted. No reference solution |
| extra | The true θ1, θ2 (J, L) do not appear in the final laws; checked with assert |
| extra | Simulation with θ̂(0) = 0.5θ and 1.5θ; the document's law compared with the tuning-function law |

## 2. Errors in the hand-solved part of the document
Check script: `checks/chk_document.m`, results in `checks/analysis_results.md`. Comparison with the document: `checks/side_by_side.md`.

| Equation | Problem | Corrected form | Consequence |
|---|---|---|---|
| E17a | f1 = 2Qvad − (2/Rbf)ΔP. E14, derived from E4 and E5, gives **+**: f1 + g1ω − E14 = −4ΔP/Rbf | f1 = 2Qvad + (2/Rbf)ΔP | Flips the sign of the ΔP, ΔṖ and ΔP̈ terms in the final Vin. With the document's f1 the model gives a wrong ẋ1; at ΔP ≈ 10⁴ Pa the error in ẋ1 is 4ΔP/Rbf ≈ 1.8·10⁻⁵ m³/s (~20 % of Qvad) |
| E27 | V contains ½z3³. V(z3 = −1) = −½, so V is not positive definite | ½z3² | The document's own V̇ (z3·ż3) already corresponds to ½z3²; a typo |
| E29 | The z3 bracket has −θ̂1g3z2 and the θ̃1 bracket has +g3z2z3. Check: E28 − E29 = 2·g3·z2·z3·(θ̂1 − θ̃1) | z3[… **+**θ̂1g3z2 …], θ̃1(… **−**g3z2z3) | — |
| E36 | Does not solve the document's z3 bracket (E35), residual −2g3θ̂1z2, but does solve the corrected bracket | no change | E36 is correct; the error is only in how E35 is written |
| E38 | θ̂̇1 = γ1(… **−** g3z2z3). Against the corrected θ̃1 bracket the residual is −2g3z2z3 | θ̂̇1 = γ1(… **+** g3z2z3) | Adds an extra residual −2K·z2·z3·θ̃1 to V̇ |
| E38/E40 (S5) | φ̇3 contains the unknown θ1 through ẋ2 = θ1(…). The document does not account for this term | Tuning function: add γ1·z3·(∂φ3/∂x2)·(f2 + g2x2 + g3x3) to θ̂̇1 | With the document's law V̇ ≠ −Σk·(error)²; the residual is in §4.3 |
| E7 | Derivative written as "i̇̇" | di/dt | notation only |
| E6, E7 / E15, E16 | E6 and E7 use K_i, K_emf, J, L; E15 and E16 use K, J_gp, L_gp | one K | notation only |
| E30 | −k1x² | −k1x1² | notation only |
| E12 | τ1 in N, τ2 in N·s·m⁻¹ | should be N·m and N·m·s/rad | does not affect the derivation |

Found correct: E4, E14, E21b,c = E15, E16; E24, E25; E32; E34; E40 (E40 = −γ2·z3·(g4x2 + g5x3 + u)). The system is in strict-feedback form.

## 3. Steps and verification
Derivation in `deriv_adaptive.m`, verification in `checks/verify_adaptive.m`. The verification is independent of the derivation: plain symbols and the chain rule.

| Step | Done | Verification |
|---|---|---|
| T1 | V = ½x1² + ½z2² + ½z3² + θ̃1²/(2γ1) + θ̃2²/(2γ2) and V̇; θ = θ̂ − θ̃ | — |
| T2 | V̇ = x1·TERM1 + z2·TERM2 + z3·TERM3 + θ̃1·TERM_θ1 + θ̃2·TERM_θ2. Coefficients taken with `diff` | assert: rearrangement correct; V̇ linear in θ̃ |
| T3 | φ2, φ3 and u found with `isolate` | bracket conditions 1 and 2 = 0. u equals E36 |
| T4 | θ̂̇1 and θ̂̇2 from TERM_θ1 = 0 and TERM_θ2 = 0. TERM_θ1 contains the term a32 = ∂φ3/∂x2 | θ̂̇1 = E38_corr + γ1·z3·a32·F (difference 0); θ̂̇2 = E40 (difference 0) |
| T5 | φ̇2 computed (no parameters). φ̇3 computed with the estimated dynamics (θ̂1) and the full θ̂̇1 law | both agree with the chain rule (difference 0) |
| T6 | u, θ̂̇1 and θ̂̇2 written in x1, x2, x3, θ̂1, θ̂2 only. Placeholders resolved before every `diff` | assert: no placeholders left; no θ1, θ2, θ̃ |
| T7 | Physical expressions substituted for f and g (sgn ω = 1) | Vin_simp = physical subs(Vin_abs) (difference 0) |
| **Closed loop** | V̇ computed with the true dynamics and the true θ | **V̇ − (−k1x1² − k2z2² − k3z3²) = 0**, both at the abstract level and at the physical level (with E15, E16, J, L) |

## 4. Final law
### 4.1 References
- W_ref = φ2 = (2Qvad + k1·DV + 2ΔP/Rbf)/(2α_ω)
- i_ref = φ3 = [2α_ω·DV − k2·(W − W_ref) + (2Q̇vad + k1(2Qvad − 2α_ω W + 2ΔP/Rbf) + 2ΔṖ/Rbf)/(2α_ω) + θ̂1(τ1 + α_P ΔP + τ2 W)] / (K·θ̂1)
- z2 = W_ref − W, z3 = i_ref − i, F = −τ1 − α_PΔP − τ2W + K·i (= J·ω̇)
- a32 = ∂i_ref/∂W = −(k1 + k2 − τ2·θ̂1)/(K·θ̂1)

### 4.2 Control and adaptation laws (short readable form; full form in the .m files)
- **Vin** = (φ̇3 + K·θ̂1·z2 + k3·z3)/θ̂2 + K·W + R_gp·i
  - φ̇3 = ∂φ3/∂DV·ẋ1 + a32·θ̂1·F + ∂φ3/∂θ̂1·θ̂̇1 + ∂φ3/∂(Qvad, ΔP, Q̇vad, ΔṖ)·(their derivatives)
  - This short form is E36 written with x2 = φ2 − z2 and x3 = φ3 − z3. `verify_adaptive.m` checks that its difference from the full expression is 0.
- **θ̂̇1** = γ1·[ −z2·(f2 + g2φ2 − g2z2 + g3φ3 − g3z3) + z3·a32·F ]. Physically: f2 = −τ1 − α_PΔP, g2 = −τ2, g3 = K. The last term is the tuning function.
- **θ̂̇2** = −γ2·z3·(−K·W − R_gp·i + Vin)
- Signals the laws need: DV, W, i, θ̂1, θ̂2, Qvad, ΔP, Q̇vad, ΔṖ, **Q̈vad, ΔP̈**. That is, the second derivatives of Qvad and ΔP are needed.
- The true θ1 = 1/J and θ2 = 1/L appear in none of the laws (assert).

### 4.3 V̇ residual of the document's law (S5)
Verified symbolically in `verify_adaptive.m` (difference 0):
- E36 + E38_corr + E40 (no tuning term):
  V̇ = −k1x1² − k2z2² − k3z3² **− z3·a32·F·θ̃1**
  = … + z3·(k1 + k2 − τ2θ̂1)/(Kθ̂1)·(K·i − τ1 − α_PΔP − τ2W)·θ̃1
- If E38 is used as written in the document, **−2K·z2·z3·θ̃1** is added to the residual.
- The sign of these terms is undetermined; V̇ ≤ 0 is not guaranteed.

### 4.4 Singularities and limits (`checks/analysis_adaptive.m`)
- Denominators: K³·Rbf²·α_ω²·θ̂1⁴·θ̂2 for Vin; K²·Rbf·α_ω·θ̂1² for θ̂̇1.
- θ̂1 = 0, θ̂2 = 0, K = 0 and α_ω = 0 are **true singularities**. Both the step-by-step and the simplified expression divide by zero there; the limit is ±∞. No removable 0/0 was found.
- K, α_ω and Rbf are positive physical constants and cause no problem in operation. The real risk is θ̂1 → 0 and θ̂2 → 0; hence projection is needed (§7).
- `simplify` did not shorten the expressions (Vin 1503 characters). Simplified and unsimplified expressions compared at 5 random points (`digits(50)`); relative difference 0.
- Validity condition: ω > 0 (sgn = 1). If the sign of ω changes in the model, the law must be derived again.

### 4.5 Simulation (`checks/sim_adaptive.m`, `checks/sim_adaptive.png`)
- Settings:
  - No projection. Solver ode15s: L/R = 3 ms while the mechanical and adaptation dynamics are much slower, so the system is stiff. Duration 5 s.
  - Gains: k = (5, 20, 200), γ = (10⁴, 10³).
  - Initial state: DV = 2 mL, W = 60 rad/s, i = 0.6 A.
  - Signals: Qvad = 83 + 20·sin(2πt) mL/s and ΔP = 10.7 + 2·sin(2πt) kPa. These signals are not in the document; they were chosen for the test.
- The first attempt used k = (10, 50, 500), γ = (10⁶, 10⁵), W(0) = 50 rad/s. At the start z3 ≈ 8 A and Vin ≈ 10³ V; θ̂2 fell to zero in under a millisecond and the solver stopped. Both laws behaved the same. This output is kept in `analysis_results.md`. Conclusion: without projection, the law reaches the singularity with high γ and a large initial error.

| θ̂(0) | law | max\|DV\| (t>1 s) | max\|z2\| | max\|z3\| | max\|Vin\| | θ̂1/θ1 at end | share of samples with V̇ > 0 |
|---|---|---|---|---|---|---|---|
| 0.5θ | tuning function | 1.70e-7 m³ | 0.44 rad/s | 0.24 A | 5.44 V | 0.562 | 0 (theory) |
| 0.5θ | document (E38_corr) | 1.68e-7 m³ | 0.44 rad/s | 0.24 A | 5.44 V | 0.568 | 0 (residual/target ≤ 0.23) |
| 1.5θ | tuning function | 3.37e-8 m³ | 0.066 rad/s | 0.107 A | 5.45 V | 1.488 | 0 (theory) |
| 1.5θ | document (E38_corr) | 3.37e-8 m³ | 0.066 rad/s | 0.107 A | 5.45 V | 1.487 | 0 (residual/target ≤ 0.16) |

- In this scenario the two laws behave practically the same. The residual of the document's law is at most 23 % of the target V̇, and V̇ is positive in no sample. The difference is theoretical: only the tuning-function law guarantees V̇ ≤ 0. The residual grows with (k1 + k2)/(Kθ̂1), z3 and θ̃1; it can matter at higher gains or larger θ̂ errors.
- θ̂ does not approach the true value within 5 s (θ̂2 almost constant). Without persistent excitation, V̇ ≤ 0 does not imply θ̂ → θ. DV, z2 and z3 also converge slowly: the remaining oscillation comes from the 1 Hz signal and is linked to θ̃.
- Vin stays below 5.5 V. No saturation risk in this scenario; with large initial errors Vin can reach the kilovolt range (first attempt).

## 5. Code choices
- `x2_new`, `x3_new`: separate names so that x2(t) and x3(t) keep their time dependence.
- Coefficients taken with `diff` (no division by z2, no 0/0). The rearrangement is checked with assert. The θ̃ coefficients are also taken with `diff`, and V̇ being linear in θ̃ is checked with assert.
- In `z3_dot`, the true φ̇3 is written as estimated φ̇3 + a32·(ẋ2 − ẋ2_h). a32 is a placeholder; the tuning-function term comes from this line (S5).
- `x2_dot_h`: φ̇3 is derived with the estimated dynamics (θ̂1) that the controller can compute.
- Before every `diff`, `subs` with explicit lists in a `for ii = 1:5` loop, followed by an assert.
- In φ̇3, the full θ̂̇1 law (including the tuning term) replaces diff(θ̂1(t)).
- Asserts: true θ and θ̃ absent from the laws; only allowed symbols in the final expressions; no unresolved `diff` in φ̇3.
- `th2h_dot_fun` is the short form (E40) that takes Vin as an input. Its difference from the full expression is checked to be 0 with assert.

## 6. Reference comparison
No reference solution was given.

## 7. Questions for the author
1. **Projection:** since the law divides by θ̂1 and θ̂2 (θ̂1⁻⁴ and θ̂2⁻¹ in Vin), the proposed rule is: θ̂̇i = 0 if θ̂i ≤ θi,min and τi < 0; otherwise τi (τi: the derived law). This rule keeps V̇ ≤ −Σk·(error)². Which lower/upper bounds should be used for J and L (θ1,min = 1/J_max, θ2,min = 1/L_max)?
2. Sign of f1 in E17a: if Qgp = α_ωω − ΔP/Rbf (E5) is correct, then f1 = 2Qvad + 2ΔP/Rbf. Is the sign in E5 or in E17a correct?
3. Is regulation x1 = ΔVh → 0 physically what is wanted, or should a ΔVh,ref be tracked? With tracking, derivatives of ΔVh,ref up to the 3rd enter the law.
4. Will Q̈vad and ΔP̈ be measured, or obtained with an estimator/filter? This matters for noise sensitivity.
5. What are the target values for the gains and γ? The simulation values are for testing only.
6. Units of τ1 and τ2 (E12): should they be N·m and N·m·s/rad?

## 8. Files
| File | Content |
|---|---|
| README.md | file guide |
| REPORT.md | this report |
| deriv_adaptive.m | derivation (author's code style) |
| Vin_fun.m | Vin for Simulink |
| th1h_dot_fun.m | θ̂̇1 for Simulink (with tuning function) |
| th2h_dot_fun.m | θ̂̇2 for Simulink (takes Vin as input) |
| results.mat | all derived quantities: abstract and physical, simplified and unsimplified |
| checks/source/equations.md | pandoc output of the input document |
| checks/inventory.md | sections, E/T numbers, symbol table, S decisions |
| checks/side_by_side.md | document and MATLAB check side by side |
| checks/chk_document.m | checks of the hand-solved part |
| checks/verify_adaptive.m | closed-loop checks, residual of the document's law; writes doc_law.mat |
| checks/analysis_adaptive.m | simplification, denominators, singularities |
| checks/sim_adaptive.m | simulation; writes sim_adaptive.png and sim_results.mat |
| checks/log_run.m | helper that appends script output to analysis_results.md |
| checks/analysis_results.md | all check outputs (timestamped, never deleted) |
