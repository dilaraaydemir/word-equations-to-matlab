# REPORT - D13_b_model.docx

*Translated from the agent's Turkish report. The content is unchanged; only the file list in §8 reflects the copy in this repository.*

## 1. Document, scope, decisions
- Document: `D13_b_model.docx` (= `../input_document.docx`), one section: *Adaptive backstepping -- three unknown parameters*.
- Output folder: `D13_b_model_2026-11-13_003254/` (= `agent_output/` here). MATLAB R2025b, Symbolic Math Toolbox 25.2.
- Decisions (details in `inventory.md`):
  - S1 the whole document; S2 step interpretation T1–T6 accepted.
  - **S3 (a) tuning functions**; the residual left by the document's plain laws is shown separately (section 5).
  - S4 V = E6, z = φ − x; S5 −x1·z2 → TERM2, z2·z3 → TERM3.
  - S6 k1..3, γ1..3 > 0; θi constant, sign unknown; regulation x1 → 0; no projection needed.
  - S7 `u_fun.m`, `thetahat_dot_fun.m`, `phi2_fun.m`, `phi3_fun.m`; ode45 comparison; assert that the true θ is absent from the laws.

## 2. Errors found in the hand-solved part
No errors found (`chk_document.m`, `side_by_side.md`):
- System E1 is in parametric strict-feedback form (x2, x3 linear with coefficient 1; u only in the last equation).
- The inversions in E4 (x2 = φ2 − z2, x3 = φ3 − z3) are consistent; E5b is correct (θ constant).
- V in E6 is positive definite (Hessian diag(1,1,1,1/γ1,1/γ2,1/γ3)); target in E7 is V̇ ≤ 0.

**Method note (not an error):** because θ1 and θ2 appear before the last equation, φ2 = φ2(x1, θ̂1) and φ3 = φ3(x1, x2, θ̂1, θ̂2), so θ̂̇ enters φ̇2 and φ̇3. The law from TERM_θi = 0 depends on z3 (x3) and cannot be used directly in φ3 (circular). The document's "TERM_θ = 0" step is fully consistent only with tuning functions.

## 3. Steps
Notation: w1 = [x1², 0, 0]ᵀ, Γ = diag(γ1, γ2, γ3).

| Step | Done | Result | Verification |
|---|---|---|---|
| T1 | V = E6 | — | positive definite |
| T2 | V̇ along the true dynamics, θ = θ̂ + θ̃, x2 = φ2 − z2, x3 = φ3 − z3 | — | decomposition asserts (each step + total) = 0 |
| T3 | V̇ = x1·TERM1 + z2·TERM2 + z3·TERM3 + Σθ̃i·TERM_θi; coefficients with `jacobian`/`diff` (no division by an error variable) | TERM_θ = x1·w1 + z2·ω2 + z3·ω3 − Γ⁻¹θ̂̇ | `simplify(Vdot − Σ) == 0` |
| T4a | TERM1 = −k1x1 → φ2 | φ2 = −x1(k1 + θ̂1x1) | x1·TERM1 = −k1x1² ✔ |
| T4b | TERM2 = −k2z2, with τ2 = Γ(x1w1 + z2ω2) in place of θ̂̇, ω2 = [∂φ2/∂x1·x1², −x1x2, 0]ᵀ | φ3 = −x1 + ∂φ2/∂x1(x2 + θ̂1x1²) + ∂φ2/∂θ̂·τ2 − θ̂2x1x2 + k2z2 | z2·TERM2 = −k2z2² ✔ |
| T5 | TERM_θi = 0 → `isolate` | θ̂̇ = τ3 = τ2 + Γz3ω3, ω3 = [∂φ3/∂x1·x1², ∂φ3/∂x2·x1x2, −x3]ᵀ | = τ3 ✔ |
| T4c | TERM3 = −k3z3 (including the cross terms z2 and z2·∂φ2/∂θ̂·Γω3) | u (below) | full closed loop ✔ |
| T6 | φ̇2, φ̇3 by the chain rule; placeholders resolved before every `diff`; z2, z3, φ substituted | u, θ̂̇ in x1..3, θ̂1..3, k, γ only | φ̇2, φ̇3 match an independent chain rule ✔ |

**Full closed-loop check** (`verify_adaptive.m`): V = ½x1² + ½z2² + ½z3² + Σ(θi − θ̂i)²/(2γi), V̇ computed along the dynamics with the true θ:
`simplify(Vdot − (−k1x1² − k2z2² − k3z3²)) = 0` ✔. 10 checks passed in total.

## 4. Final control law
Structured (readable) form, z2 = φ2 − x2, z3 = φ3 − x3:

- φ2 = −x1·(k1 + θ̂1·x1)
- φ3 = −x1 + ∂φ2/∂x1·(x2 + θ̂1x1²) + ∂φ2/∂θ̂1·τ2,1 − θ̂2x1x2 + k2z2, ∂φ2/∂x1 = −k1 − 2θ̂1x1, ∂φ2/∂θ̂1 = −x1²
- Explicit polynomial: φ3 = −2θ̂1²γ1x1⁷ − 3θ̂1γ1k1x1⁶ − 2θ̂1γ1x1⁵x2 − γ1(k1² + 1)x1⁵ − γ1k1x1⁴x2 − 2θ̂1²x1³ − θ̂1(k1 + k2)x1² − (2θ̂1 + θ̂2)x1x2 − (k1k2 + 1)x1 − (k1 + k2)x2
- θ̂̇ = Γ·(x1·w1 + z2·ω2 + z3·ω3), explicitly:
  - θ̂̇1 = γ1·x1²·(x1 + z2·∂φ2/∂x1 + z3·∂φ3/∂x1)
  - θ̂̇2 = γ2·x1x2·(−z2 + z3·∂φ3/∂x2)
  - θ̂̇3 = −γ3·z3·x3
- **u = k3z3 + z2 + z2·(∂φ2/∂θ̂)·Γ·ω3 + ∂φ3/∂x1·(x2 + θ̂1x1²) + ∂φ3/∂x2·(x3 + θ̂2x1x2) + (∂φ3/∂θ̂)·θ̂̇ − θ̂3x3**

The fully expanded polynomial forms (u: 10521 characters, θ̂̇: 3502 characters) are in `analysis_results.md` and `results.mat` (`u_simp`, `thd_simp`). The Simulink files were generated from a shorter nested form (`u_compact`, `thd_compact`). Their difference from the expanded form is 0 symbolically; maximum relative difference at 5 random points 4.6e−16.

- **Signals needed:** only x1, x2, x3 and θ̂1, θ̂2, θ̂3 (integrals of the adaptation law). No signal derivatives needed.
- **Simulink input order (same in all 4 files):** `(x1, x2, x3, th1h, th2h, th3h, k1, k2, k3, g1, g2, g3)`. `thetahat_dot_fun` returns a 3×1 vector; three integrators give θ̂ (θ̂(0) free).
- **Singularity / 0/0:** no denominator in any expression (pure polynomials). No singularity or 0/0; `limit` not needed. No division by θ̂, so no projection needed.
- **True parameters:** asserts in deriv and verify check that θ1..3 and θ̃ do not appear in φ2, φ3, u and θ̂̇ ✔.
- **Stability claim:** V̇ = −k1x1² − k2z2² − k3z3² ≤ 0, so x and θ̂ are bounded; by Barbalat x1, z2, z3 → 0 and therefore x2, x3 → 0. **V̇ ≤ 0 does not imply θ̂ → θ without persistent excitation** (in simulation θ̂ stopped at θ̂ ≠ θ).

## 5. Difference from the plain laws (the document read "without tuning functions")
Plain laws: each θ̃i is cancelled only in its own step.
- θ̂̇1 = γ1x1³, θ̂̇2 = −γ2z2x1x2, θ̂̇3 = −γ3z3x3; φ3 and u use these laws (certainty equivalence).
- Difference from the tuning law: φ3,plain − φ3,tuning = γ1·x1⁴·(k1 + 2θ̂1x1)·(x2 + k1x1 + θ̂1x1²).
- In closed loop: V̇ = −k1x1² − k2z2² − k3z3² + **R**, where
  **R = θ̃1·x1²·(z2·∂φ2/∂x1 + z3·∂φ3/∂x1) + θ̃2·z3·∂φ3/∂x2·x1x2** (the θ̃3 term cancels exactly).
- The sign of R is undetermined. With the user's test values, at t = 0 R = 24.25 and the target part = −15.5, so **V̇(0) = +8.75 > 0**. With the plain laws there is no Lyapunov proof.

**ode45 comparison** (`sim_adaptive.m`, `sim_adaptive.png`). Test values: θ = (1, −0.5, 2), k = γ = 1, θ̂(0) = 0, x(0) = (1, 0.5, −0.5), 20 s, RelTol 1e−9.

| | tuning functions | plain laws |
|---|---|---|
| x(20) | (1.4e−4, 3.7e−4, −3.8e−4) | (1.0e−2, −6.1e−3, −3.3e−4) |
| θ̂(20) | (2.06, 0.96, 5.36) | (0.65, −3.87, 8.67) |
| max\|x3\| | 91.4 | 25.3 |
| max\|u\| | **4.67e4** (t < 0.5 s) | 228 |
| V(0) → V(20) | 16.75 → 7.27, **never increases** | 10.38 → 28.01, **increases** (largest step increase 0.215; peak ≈ 65) |

Comments:
- With tuning functions V decreases monotonically (consistent with the theory).
- With the plain laws V increases. From this initial condition the states still approached zero, but there is no guarantee.
- **Warning:** in the tuning design |u| ≈ 4.7e4 in the first 0.5 s. This peak comes from high powers of x1 (x1²² terms in u, multiplied by γ1). Saturation is expected on a real actuator.
- Smaller γ1 or k lower this peak. Stability under saturation is outside the scope of this analysis.
- θ̂ converged to θ in neither design (no persistent excitation in regulation).

## 6. Reference comparison
No reference code was given (S7).

## 7. Questions for the author
1. Was the document's "TERM_θ = 0" step meant as tuning functions? The plain laws do not give V̇ ≤ 0 (section 5).
2. Is the peak value of u acceptable, or is further work needed on actuator limits and γ/k tuning?
3. Is parameter convergence (θ̂ → θ) also a goal? Then a reference/excitation signal is needed.

## 8. Files in the folder
- `source/equations.md`: pandoc output of the input document.
- `inventory.md`: sections, E/T lists, symbol table, S decisions.
- `side_by_side.md`: document equations next to MATLAB `latex()`.
- `chk_document.m`: checks of the hand-solved part.
- `deriv_adaptive.m`: derivation (tuning functions and plain laws), simplification, function generation.
- `verify_adaptive.m`: 10 checks (brackets, τ3, φ̇, full closed loop, plain-law residual R, random-point test, denominators).
- `sim_adaptive.m`, `sim_adaptive.png`: ode45 comparison.
- `analysis_results.md`: all script outputs (timestamped, appended).
- `results.mat`: all symbolic results (abstract/simplified/compact; tuning and plain).
- `u_fun.m`, `thetahat_dot_fun.m`, `phi2_fun.m`, `phi3_fun.m`: Simulink functions (tuning functions).
- `u_plain_fun.m`, `thetahat_dot_plain_fun.m`: plain laws (for comparison only).
- `run_and_log.m`: helper that runs scripts and appends the output to `analysis_results.md`.
