# D12_b_model – Adaptive Backstepping

*Translated from the agent's Turkish file guide.*

Open REPORT.md first. Formulas for Simulink: Vin_fun.m (plus th1h_dot_fun.m and th2h_dot_fun.m). Derivation: deriv_adaptive.m.

| File | What it is | When to open it |
|---|---|---|
| REPORT.md | Errors found, decisions, final law, verification, simulation, questions for the author | first |
| deriv_adaptive.m | Derivation (sections numbered by E/T) | to read or rerun the derivation (~6 s) |
| Vin_fun.m | Vin(DV, W, i, th1_hat, th2_hat, Qvad, DP, Qvad_dot, DP_dot, Qvad_ddot, DP_ddot, a_w, a_P, Rbf, Rgp, K, t1, t2, k1, k2, k3, gam1) | Simulink MATLAB Function block |
| th1h_dot_fun.m | θ̂̇1, same inputs as Vin_fun (tuning function included) | Simulink: input of the θ̂1 integrator |
| th2h_dot_fun.m | θ̂̇2(DV, W, i, th1_hat, Vin, Qvad, DP, Qvad_dot, DP_dot, a_w, a_P, Rbf, Rgp, K, t1, t2, k1, k2, gam2) | Simulink: input of the θ̂2 integrator |
| results.mat | All derived quantities (W_ref_simp, i_ref_simp, Vin_simp, th1h_dot_simp, th2h_dot_cmp, …) | to use in MATLAB |
| checks/ | Checks, verification, analysis, simulation, raw outputs | to verify the result |

Notes:
- Names such as `t4`, `t5`, `et1` in the generated `*_fun.m` files are intermediate variables of matlabFunction. They are not time and have nothing to do with `t1`, `t2` (τ1, τ2).
- No projection is included. If θ̂1 or θ̂2 approaches zero the law becomes singular. In Simulink, add a lower bound or projection to the integrator (REPORT §7).
- Validity condition: ω > 0.
