# Side by side: document vs MATLAB (`chk_document.m`)

All residuals are 0 (see `analysis_results.md`).

| No. | Document (LaTeX from pandoc) | MATLAB `latex()` | Check |
|---|---|---|---|
| E4 | `\Delta\dot V_h = 2(Q_{vad}-Q_{gp})` | from E3a − E3b | residual 0 |
| E10 | `\Delta\dot V_h = 2Q_{vad} + \frac{2}{R_{bf}}\Delta P - 2\alpha_\omega\omega` | `2\,\mathrm{Qvad}-2\,W\,a_{w}+\frac{2\,\mathrm{DP}}{\mathrm{Rbf}}` | E4 + E5, residual 0 |
| E11 | `\dot\omega = -\frac{\tau_1}{J_{gp}}sgn(\omega) - \frac{\alpha_P}{J_{gp}}\Delta P - \frac{\tau_2}{J_{gp}}\omega + \frac{K}{J_{gp}}i_{gp}` | `\frac{K\,i}{J}-\frac{\mathrm{DP}\,a_{P}}{J}-\frac{W\,t_{2}}{J}-\frac{\mathrm{sgnW}\,t_{1}}{J}` | E6 + E8, residual 0 |
| E12 | `\dot i_{gp} = -\frac{K}{L_{gp}}\omega - \frac{R_{gp}}{L_{gp}}i_{gp} + \frac{1}{L_{gp}}v_{in}` | `\frac{\mathrm{Vin}}{L}-\frac{K\,W}{L}-\frac{\mathrm{Rgp}\,i}{L}` | = E7, residual 0 |
| E14a | `f_1 = 2Q_{vad} + \frac{2}{R_{bf}}\Delta P` | `2\,\mathrm{Qvad}+\frac{2\,\mathrm{DP}}{\mathrm{Rbf}}` | E17 = E10 |
| E14b | `f_2 = -\frac{\tau_1 sgn(\omega)}{J_{gp}} - \frac{\alpha_P}{J_{gp}}\Delta P` | `-\frac{\mathrm{DP}\,a_{P}}{J}-\frac{\mathrm{sgnW}\,t_{1}}{J}` | E18 = E11 |
| E15–E16 | `g_1=-2\alpha_\omega, g_2=-\tau_2/J, g_3=K/J, g_4=-K/L, g_5=-R_{gp}/L, g_6=1/L` | same | E17–E19 = E10–E12 |
| E17–E19 | strict-feedback form | affine in x2, x3, u; g1, g3, g6 ≠ 0 | strict-feedback: yes |

## Findings (none change the derivation)
| No. | Finding | Proposed correction |
|---|---|---|
| E6, E7 vs E11, E12 | Motor constant written K_i, K_emf and K; J vs J_gp; L vs L_gp | Use one name (K, J_gp, L_gp) — decided S9 |
| E2 vs E13 | ΔV_h vs ΔV | Use one name — decided S9 |
| E7, E12 | `\dot{\dot{i}}_{gp}` in the Word equation (dot on a dotted i) | `\dot{i}_{gp}` |
| E9 | τ1 in N, τ2 in N·s·m⁻¹; they are torque terms | τ1 in N·m, τ2 in N·m·s·rad⁻¹ |
| Figure | Valves labelled g1..g6, same names as the model coefficients g1..g6 | Rename valves (e.g. v1..v6) |
