# Example 01 – Backstepping control of a gear pump (3 states)

## Input
`input_document.docx`: model of a mock circulatory loop (LVAD, gear pump, two tanks). The pump voltage v_in should regulate the volume difference ΔV between the tanks to zero. The document contains:

- the physical model and parameter values,
- the strict-feedback form, with x1 = ΔV, x2 = ω, x3 = i_gp:

  ẋ1 = f1 + g1·x2
  ẋ2 = f2 + g2·x2 + g3·x3
  ẋ3 = g4·x2 + g5·x3 + g6·u

There is **no step list and no Lyapunov function** in the document; only the state equations are given. The agent proposed the standard backstepping steps and the user confirmed them.

## What was asked and answered
All questions came on one screen, each with a recommended answer. The user accepted all recommendations.

| Question | Answer |
|---|---|
| Step list (none in the document) | Standard steps: choose V, compute V̇, split it into TERM brackets, set each to −kᵢzᵢ², solve for ω_ref, i_ref and u, differentiate, substitute |
| Control goal | Regulation ΔV → 0 |
| Error sign | z2 = φ2 − x2, z3 = φ3 − x3 |
| Lyapunov function | V = ½x1² + ½z2² + ½z3² (alternatives offered: weighted, with integral action) |
| Target V̇ | −k1x1² − k2z2² − k3z3² |
| sgn(ω) in the friction term | The pump turns one way: ω > 0, so sgn(ω) = +1 |
| Q_vad, ΔP | External measured signals, needed up to their 2nd derivatives |
| Parameter names | K_i = K_emf = K, all constants positive |
| Output | Simplified law and `Vin_fun.m`, no numbers substituted |

The full list is in `agent_output/inventory.md` (section "Questions and decisions").

## Result
- The law matches the author's own MATLAB solution (`author_reference_solution.m`) exactly: the differences in ω_ref, i_ref and v_in are 0.
- The closed-loop check gives V̇ + k1x1² + k2z2² + k3z3² = 0.
- Only notation issues were found in the document (a double dot on di/dt, units of τ1 and τ2, valve labels that reuse the names g1..g6).
- `simulink_test.m` builds a Simulink model and runs the law on the full pump model, including the sgn(ω) friction term. ΔV goes from 2 mL to ~1e-11 mL, ω stays above 43 rad/s and v_in stays within 0–11 V.

## Where to look
1. `agent_output/REPORT.md`: decisions, document check, steps, final law.
2. `agent_output/Vin_fun.m`: the control law for Simulink. Input order: `(DV, W, i, Qvad, DP, Qvad_dot, DP_dot, Qvad_ddot, DP_ddot, a_P, a_w, Rbf, Rgp, L, J, K, t1, t2, k1, k2, k3)`, where `t1`, `t2` are τ1, τ2.
3. `simulink_test.m`: run it from this folder in MATLAB.

Internal names: `Deneme_14_model.docx` in the agent's files is `input_document.docx` here ("Deneme" means "trial" in Turkish), and `ref.m` / `ref_copy.m` is `author_reference_solution.m`.
