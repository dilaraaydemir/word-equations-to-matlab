# Side by side: document vs MATLAB check (chk_document.m)

Results of `chk_document.m` are in `analysis_results.md`. "Proposed correction" lines are not in the document.

| No | Document | MATLAB check | Status |
|---|---|---|---|
| E4 | ΔV̇h = 2(Qvad − Qgp) | `Vh1_dot - Vh2_dot` | OK |
| E14 | ΔV̇h = 2Qvad + (2/Rbf)ΔP − 2α_ω ω | from E4, E5 | OK |
| E17a | f1 = 2Qvad − (2/Rbf)ΔP | f1 + g1·ω − E14 = −4ΔP/Rbf | **Error** |
| E17a_corr | Proposed correction: f1 = 2Qvad + (2/Rbf)ΔP | f1 + g1·ω − E14 = 0 | used |
| E15, E16, E21b,c | θ1(f2+g2x2+g3x3), θ2(g4x2+g5x3+u) | equal to E15, E16 (sgn ω = 1) | OK |
| E6 | K_i, J; E7 K_emf, L | E15/E16 use K, J_gp, L_gp | notation only |
| E7 | \dot{\dot{i}}_{gp} | first derivative of i meant | typo |
| E24, E25 | error dynamics | `expand(.. - ..) == 0` | OK |
| E27 | V = … + ½z3³ + … | V(z3 = −1) = −½ | **Error** (not positive definite) |
| E27_corr | Proposed correction: ½z3² | dV/dz3 = z3, matches the document's V̇ | used |
| E29 | z3[… − θ̂1 g3 z2 …], θ̃1(… + g3 z2 z3) | E28 − E29 = 2·g3·z2·z3·(θ̂1 − θ̃1) | **Error** (two signs) |
| E29_corr | Proposed correction: z3[… **+** θ̂1 g3 z2 …], θ̃1(… **−** g3 z2 z3) | E28 − E29_corr = 0 | used |
| E30 | −k1 x² | −k1 x1² | typo |
| E32 | φ2 = (−k1x1 − f1)/g1 | solves E31 | OK |
| E34 | φ3 = … | solves E33 | OK |
| E36 | u = … + (θ̂1/θ̂2) g3 z2 + … | solves E35_corr, not E35 (residual −2g3θ̂1z2) | OK (fits the corrected bracket) |
| E38 | θ̂̇1 = γ1(… − g3 z2 z3) | against E37_corr: residual −2g3z2z3 | **Error** |
| E38_corr | Proposed correction: θ̂̇1 = γ1(… **+** g3 z2 z3) | solves E37_corr | basis of the "document law" |
| E40 | θ̂̇2 = γ2(…) | solves E39; = −γ2 z3 (g4x2 + g5x3 + u) | OK |
| (S5) | φ̇3 contains θ1 through ẋ2 | not in the document | missing tuning-function term |

Strict-feedback form: OK (x2 linear in ẋ1, x3 linear in ẋ2, u only in ẋ3).
