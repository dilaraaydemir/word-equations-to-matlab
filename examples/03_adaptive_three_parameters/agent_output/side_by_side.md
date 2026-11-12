# Side by side - solved part of D13_b_model.docx

MATLAB names: `X1..X3` = x1..x3, `th_i` = θi, `tht_i` = θ̃i, `g_i` = γi. Checks in `chk_document.m`.

| No | Document | MATLAB `latex()` | Check |
|----|----------|------------------|-------|
| E1a | $\dot x_1 = x_2 + \theta_1 x_1^2$ | $\mathrm{th}_{1}\,{X_{1}}^2+X_{2}$ | equal; x2 linear, coeff. 1 |
| E1b | $\dot x_2 = x_3 + \theta_2 x_1 x_2$ | $X_{3}+X_{1}\,X_{2}\,\mathrm{th}_{2}$ | equal; x3 linear, coeff. 1 |
| E1c | $\dot x_3 = \theta_3 x_3 + u$ | $u+X_{3}\,\mathrm{th}_{3}$ | equal; u only here |
| E4a | $z_2 = \varphi_2 - x_2$ | `z2 = phi2 - X2` | inverse x2 = φ2 − z2 used in T2: OK |
| E4b | $z_3 = \varphi_3 - x_3$ | `z3 = phi3 - X3` | inverse x3 = φ3 − z3: OK |
| E5a | $\tilde\theta_i = \theta_i - \hat\theta_i$ | `th_i = TH_ih + tht_i` | OK |
| E5b | $\dot{\tilde\theta}_i = -\dot{\hat\theta}_i$ | `diff(c1 - a1(t),t) = -diff(a1(t),t)` | OK (θ constant) |
| E6 | $V = \tfrac12 x_1^2 + \tfrac12 z_2^2 + \tfrac12 z_3^2 + \sum \tfrac{1}{2\gamma_i}\tilde\theta_i^2$ | $\frac{{X_{1}}^2}{2}+\frac{{z_{2}}^2}{2}+\frac{{z_{3}}^2}{2}+\frac{{\mathrm{tht}_{1}}^2}{2\,g_{1}}+\frac{{\mathrm{tht}_{2}}^2}{2\,g_{2}}+\frac{{\mathrm{tht}_{3}}^2}{2\,g_{3}}$ | Hessian diag(1,1,1,1/γ1,1/γ2,1/γ3): positive definite |
| E7 | $\dot V = -k_1x_1^2 - k_2z_2^2 - k_3z_3^2$ | `-k1*X1^2 - k2*z2^2 - k3*z3^2` | ≤ 0 |

No `_corr` lines: no error found in the solved part.
Remark (not an error, but changes the method): θ1 and θ2 appear before the last equation, so θ̂̇1, θ̂̇2 enter φ̇2, φ̇3. The document's "TERM_θi = 0" is only exact with tuning functions (decision S3 (a)).
