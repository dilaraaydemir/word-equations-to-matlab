
## chk_document.m  (2026-11-12 23:37:54)

```
E3 -> E4 residual: 0
E4+E5 -> E10 residual: 0
E6+E8 -> E11 residual: 0
E7 vs E12 residual: 0
E17 vs E10 residual: 0
E18 vs E11 residual: 0
E19 vs E12 residual: 0
Strict-feedback structure checks: [true true true true true true]
Coupling gains g1, g3, g6 = -2*a_w, K/J, 1/L (nonzero for positive constants)

--- latex() of MATLAB forms ---
E10 DV_dot: 2\,\mathrm{Qvad}-2\,W\,a_{w}+\frac{2\,\mathrm{DP}}{\mathrm{Rbf}}
E11 W_dot: \frac{K\,i}{J}-\frac{\mathrm{DP}\,a_{P}}{J}-\frac{W\,t_{2}}{J}-\frac{\mathrm{sgnW}\,t_{1}}{J}
E12 i_dot: \frac{\mathrm{Vin}}{L}-\frac{K\,W}{L}-\frac{\mathrm{Rgp}\,i}{L}
E14a f1: 2\,\mathrm{Qvad}+\frac{2\,\mathrm{DP}}{\mathrm{Rbf}}
E14b f2: -\frac{\mathrm{DP}\,a_{P}}{J}-\frac{\mathrm{sgnW}\,t_{1}}{J}

All document consistency residuals zero: 1

```

## deriv_backstepping.m  (2026-11-12 23:39:36)

```
T3: V_dot - (x1*TERM1 + z2*TERM2 + z3*TERM3) = 0
T5: phi2 = -(f1(t) + k1*x1(t))/g1
T5: phi3 = -(f2(t) - phi2_dot - k2*z2 + g1*x1(t) + g2*x2(t))/g3
T5: u    = (phi3_dot + g3*z2 + k3*z3 - g4*x2(t) - g5*x3(t))/g6

Abstract level (f, g symbolic):
phi2 = -(F1 + X1*k1)/g1
phi3 = -(F2 + X1*g1 + X2*g2 + (F1dot + k1*(F1 + X2*g1))/g1 + k2*(X2 + (F1 + X1*k1)/g1))/g3
u    = -(X2*g4 + X3*g5 + (f2dot + (f1ddot + k1*(F1dot + g1*(F2 + X2*g2 + X3*g3)))/g1 + k2*(F2 + X2*g2 + X3*g3 + (F1dot + k1*(F1 + X2*g1))/g1) + g1*(F1 + X2*g1) + g2*(F2 + X2*g2 + X3*g3))/g3 + k3*(X3 + (F2 + X1*g1 + X2*g2 + (F1dot + k1*(F1 + X2*g1))/g1 + k2*(X2 + (F1 + X1*k1)/g1))/g3) + g3*(X2 + (F1 + X1*k1)/g1))/g6

Physical level:
W_ref = (Qvad + (DV*k1)/2 + DP/Rbf)/a_w

i_ref = (a_w*t1 + J*Qvad_dot + J*Qvad*k1 + J*Qvad*k2 + DP*a_P*a_w + W*a_w*t2 + 2*DV*J*a_w^2 + (DV*J*k1*k2)/2 - J*W*a_w*k1 - J*W*a_w*k2)/(K*a_w) + (DP_dot*J + DP*J*k1 + DP*J*k2)/(K*Rbf*a_w)

Vin   = (J^2*L*Qvad_ddot + K^2*L*Qvad + (DV*K^2*L*k1)/2 + J*K^2*W*a_w - K^2*L*W*a_w + J^2*L*Qvad_dot*k1 + J^2*L*Qvad_dot*k2 + J^2*L*Qvad_dot*k3 - L*W*a_w*t2^2 + 4*J^2*L*Qvad*a_w^2 - 4*J^2*L*W*a_w^3 - L*a_w*t1*t2 + J*K*Rgp*a_w*i - DP*L*a_P*a_w*t2 + K*L*a_w*i*t2 + J*L*a_w*k1*t1 + J*L*a_w*k2*t1 + J*L*a_w*k3*t1 + J^2*L*Qvad*k1*k2 + J^2*L*Qvad*k1*k3 + J^2*L*Qvad*k2*k3 + 2*DV*J^2*L*a_w^2*k3 + DP_dot*J*L*a_P*a_w + DP*J*L*a_P*a_w*k1 + DP*J*L*a_P*a_w*k2 + DP*J*L*a_P*a_w*k3 - J*K*L*a_w*i*k1 - J*K*L*a_w*i*k2 - J*K*L*a_w*i*k3 + J*L*W*a_w*k1*t2 + J*L*W*a_w*k2*t2 + J*L*W*a_w*k3*t2 + (DV*J^2*L*k1*k2*k3)/2 - J^2*L*W*a_w*k1*k2 - J^2*L*W*a_w*k1*k3 - J^2*L*W*a_w*k2*k3)/(J*K*a_w) + (DP_ddot*J^2*L + DP*K^2*L + DP_dot*J^2*L*k1 + DP_dot*J^2*L*k2 + DP_dot*J^2*L*k3 + 4*DP*J^2*L*a_w^2 + DP*J^2*L*k1*k2 + DP*J^2*L*k1*k3 + DP*J^2*L*k2*k3)/(J*K*Rbf*a_w)

Symbols in Vin: [DP, DP_ddot, DP_dot, DV, J, K, L, Qvad, Qvad_ddot, Qvad_dot, Rbf, Rgp, W, a_P, a_w, i, k1, k2, k3, t1, t2]
Saved results.mat

```

## verify_backstepping.m  (2026-11-12 23:39:58)

```
Abstract level residuals:
  term1      0
  phi2_dot   0
  term2      0
  phi3_dot   0
  term3      0
  Vdot       0
  u_simp     0
  phi3_simp  0

Physical level residuals:
  W_ref_dot  0
  i_ref_dot  0
  Vdot       0
  W_simp     0
  i_simp     0
  Vin_simp   0

All closed-loop checks are 0.

```

## analyze_simplification.m  (2026-11-12 23:40:38)

```
Denominator of W_ref (one fraction): [2, Rbf, a_w]
Denominator of i_ref (one fraction): [2, K, Rbf, a_w]
Denominator of Vin (one fraction): [2, J, K, Rbf, a_w]
Intermediate denominators: g1 = -2*a_w, g2 = -t2/J, g3 = K/J, g4 = -K/L, g5 = -Rgp/L, g6 = 1/L,
  f1 contains 1/Rbf, f2 contains 1/J; the abstract law divides by g1, g3, g6.
No state (DV, W, i) and no signal appears in any denominator.

a_w  = 0: step-by-step Inf, simplified Inf, limit(0+) Inf -> real singularity
K    = 0: step-by-step Inf, simplified Inf, limit(0+) Inf -> real singularity
J    = 0: step-by-step NaN, simplified NaN, limit(0+) -Inf -> real singularity
L    = 0: step-by-step NaN, simplified 4.28726, limit(0+) 173911932359871171538992145444565/40564819207303340847894502572032 -> removable
Rbf  = 0: step-by-step Inf, simplified Inf, limit(0+) Inf -> real singularity
All of these are positive physical constants (S9), so none is reached in operation.

point 1: Vin = 167.317914318, rel. diff (Vin, i_ref, W_ref) max = 0
point 2: Vin = 13.602588777, rel. diff (Vin, i_ref, W_ref) max = 0
point 3: Vin = 15.0560273049, rel. diff (Vin, i_ref, W_ref) max = 0
point 4: Vin = 37.5750040102, rel. diff (Vin, i_ref, W_ref) max = 0
point 5: Vin = 6.42023195872, rel. diff (Vin, i_ref, W_ref) max = 0
Max relative difference: 0 (< 1e-10)

Vin_fun vs symbolic: 1.12e-16 relative difference
Wrote W_ref_fun.m, i_ref_fun.m, Vin_fun.m

LaTeX Vin:
\frac{J^2\,L\,\ddot{\mathrm{Qvad}}+K^2\,L\,\mathrm{Qvad}+\frac{\mathrm{DV}\,K^2\,L\,k_{1}}{2}+J\,K^2\,W\,a_{w}-K^2\,L\,W\,a_{w}+J^2\,L\,\dot{\mathrm{Qvad}}\,k_{1}+J^2\,L\,\dot{\mathrm{Qvad}}\,k_{2}+J^2\,L\,\dot{\mathrm{Qvad}}\,k_{3}-L\,W\,a_{w}\,{t_{2}}^2+4\,J^2\,L\,\mathrm{Qvad}\,{a_{w}}^2-4\,J^2\,L\,W\,{a_{w}}^3-L\,a_{w}\,t_{1}\,t_{2}+J\,K\,\mathrm{Rgp}\,a_{w}\,i-\mathrm{DP}\,L\,a_{P}\,a_{w}\,t_{2}+K\,L\,a_{w}\,i\,t_{2}+J\,L\,a_{w}\,k_{1}\,t_{1}+J\,L\,a_{w}\,k_{2}\,t_{1}+J\,L\,a_{w}\,k_{3}\,t_{1}+J^2\,L\,\mathrm{Qvad}\,k_{1}\,k_{2}+J^2\,L\,\mathrm{Qvad}\,k_{1}\,k_{3}+J^2\,L\,\mathrm{Qvad}\,k_{2}\,k_{3}+2\,\mathrm{DV}\,J^2\,L\,{a_{w}}^2\,k_{3}+\dot{\mathrm{DP}}\,J\,L\,a_{P}\,a_{w}+\mathrm{DP}\,J\,L\,a_{P}\,a_{w}\,k_{1}+\mathrm{DP}\,J\,L\,a_{P}\,a_{w}\,k_{2}+\mathrm{DP}\,J\,L\,a_{P}\,a_{w}\,k_{3}-J\,K\,L\,a_{w}\,i\,k_{1}-J\,K\,L\,a_{w}\,i\,k_{2}-J\,K\,L\,a_{w}\,i\,k_{3}+J\,L\,W\,a_{w}\,k_{1}\,t_{2}+J\,L\,W\,a_{w}\,k_{2}\,t_{2}+J\,L\,W\,a_{w}\,k_{3}\,t_{2}+\frac{\mathrm{DV}\,J^2\,L\,k_{1}\,k_{2}\,k_{3}}{2}-J^2\,L\,W\,a_{w}\,k_{1}\,k_{2}-J^2\,L\,W\,a_{w}\,k_{1}\,k_{3}-J^2\,L\,W\,a_{w}\,k_{2}\,k_{3}}{J\,K\,a_{w}}+\frac{\ddot{\mathrm{DP}}\,J^2\,L+\mathrm{DP}\,K^2\,L+\dot{\mathrm{DP}}\,J^2\,L\,k_{1}+\dot{\mathrm{DP}}\,J^2\,L\,k_{2}+\dot{\mathrm{DP}}\,J^2\,L\,k_{3}+4\,\mathrm{DP}\,J^2\,L\,{a_{w}}^2+\mathrm{DP}\,J^2\,L\,k_{1}\,k_{2}+\mathrm{DP}\,J^2\,L\,k_{1}\,k_{3}+\mathrm{DP}\,J^2\,L\,k_{2}\,k_{3}}{J\,K\,\mathrm{Rbf}\,a_{w}}

```

## sim_check.m  (2026-11-12 23:41:05)

```
inside  (DV0 = +1e-4 m^3)
  |DV(5 s)| = 6.772e-07 m^3, min omega = 40.00 rad/s, min W_ref = 44.56 rad/s
  max |Vin| = 22.59 V (at t = 0.002 s), max |i| = 29.04 A
outside (DV0 = -3e-4 m^3)
  |DV(5 s)| = 2.027e-06 m^3, min omega = -55.11 rad/s, min W_ref = -39.31 rad/s
  max |Vin| = 29.37 V (at t = 0.002 s), max |i| = 46.82 A
  omega <= 0 reached: sgn(omega) = +1 is wrong there, the Lyapunov proof does not hold.

```

## compare_reference.m  (2026-11-12 23:41:42)

```
[Warning: Can only make assumptions on variable names, not 'x1(t)'.] 
[> In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('syms', 'C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m', 337)" style="font-weight:bold">syms</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m',337,0)">line 337</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('ref_copy', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m', 7)" style="font-weight:bold">ref_copy</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m',7,0)">line 7</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('compare_reference', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m', 3)" style="font-weight:bold">compare_reference</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m',3,0)">line 3</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run_and_log', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m', 7)" style="font-weight:bold">run_and_log</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m',7,0)">line 7</a>)] 
[Warning: Can only make assumptions on variable names, not 'x2(t)'.] 
[> In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('syms', 'C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m', 337)" style="font-weight:bold">syms</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m',337,0)">line 337</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('ref_copy', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m', 7)" style="font-weight:bold">ref_copy</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m',7,0)">line 7</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('compare_reference', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m', 3)" style="font-weight:bold">compare_reference</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m',3,0)">line 3</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run_and_log', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m', 7)" style="font-weight:bold">run_and_log</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m',7,0)">line 7</a>)] 
[Warning: Can only make assumptions on variable names, not 'x3(t)'.] 
[> In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('syms', 'C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m', 337)" style="font-weight:bold">syms</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m',337,0)">line 337</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('ref_copy', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m', 7)" style="font-weight:bold">ref_copy</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m',7,0)">line 7</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('compare_reference', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m', 3)" style="font-weight:bold">compare_reference</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m',3,0)">line 3</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run_and_log', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m', 7)" style="font-weight:bold">run_and_log</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m',7,0)">line 7</a>)] 
[Warning: Can only make assumptions on variable names, not 'f1(t)'.] 
[> In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('syms', 'C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m', 337)" style="font-weight:bold">syms</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m',337,0)">line 337</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('ref_copy', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m', 8)" style="font-weight:bold">ref_copy</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m',8,0)">line 8</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('compare_reference', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m', 3)" style="font-weight:bold">compare_reference</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m',3,0)">line 3</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run_and_log', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m', 7)" style="font-weight:bold">run_and_log</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m',7,0)">line 7</a>)] 
[Warning: Can only make assumptions on variable names, not 'f2(t)'.] 
[> In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('syms', 'C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m', 337)" style="font-weight:bold">syms</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m',337,0)">line 337</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('ref_copy', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m', 8)" style="font-weight:bold">ref_copy</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m',8,0)">line 8</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('compare_reference', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m', 3)" style="font-weight:bold">compare_reference</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m',3,0)">line 3</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run_and_log', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m', 7)" style="font-weight:bold">run_and_log</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m',7,0)">line 7</a>)] 
[Warning: Can only make assumptions on variable names, not 'f1dot(t)'.] 
[> In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('syms', 'C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m', 337)" style="font-weight:bold">syms</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m',337,0)">line 337</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('ref_copy', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m', 9)" style="font-weight:bold">ref_copy</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m',9,0)">line 9</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('compare_reference', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m', 3)" style="font-weight:bold">compare_reference</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m',3,0)">line 3</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run_and_log', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m', 7)" style="font-weight:bold">run_and_log</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m',7,0)">line 7</a>)] 
[Warning: Can only make assumptions on variable names, not 'f2dot(t)'.] 
[> In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('syms', 'C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m', 337)" style="font-weight:bold">syms</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m',337,0)">line 337</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('ref_copy', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m', 9)" style="font-weight:bold">ref_copy</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m',9,0)">line 9</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('compare_reference', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m', 3)" style="font-weight:bold">compare_reference</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m',3,0)">line 3</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run_and_log', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m', 7)" style="font-weight:bold">run_and_log</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m',7,0)">line 7</a>)] 
[Warning: Can only make assumptions on variable names, not 'z2(t)'.] 
[> In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('syms', 'C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m', 337)" style="font-weight:bold">syms</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m',337,0)">line 337</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('ref_copy', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m', 12)" style="font-weight:bold">ref_copy</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m',12,0)">line 12</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('compare_reference', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m', 3)" style="font-weight:bold">compare_reference</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m',3,0)">line 3</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run_and_log', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m', 7)" style="font-weight:bold">run_and_log</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m',7,0)">line 7</a>)] 
[Warning: Can only make assumptions on variable names, not 'z3(t)'.] 
[> In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('syms', 'C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m', 337)" style="font-weight:bold">syms</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\syms.m',337,0)">line 337</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('ref_copy', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m', 12)" style="font-weight:bold">ref_copy</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\ref_copy.m',12,0)">line 12</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('compare_reference', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m', 3)" style="font-weight:bold">compare_reference</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\compare_reference.m',3,0)">line 3</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run_and_log', 'C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m', 7)" style="font-weight:bold">run_and_log</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Deneme_14\Deneme_14_model_2026-11-12_233140\run_and_log.m',7,0)">line 7</a>)] 
Symbols in ref Vin: [DP, DP_ddot, DP_dot, DV, J, K, L, Qvad, Qvad_ddot, Qvad_dot, Rbf, Rgp, W, a_P, a_w, i, k1, k2, k3, t1, t2]
ref keeps sign(W): 1
ref - agent, W_ref : 0
ref - agent, i_ref : 0
ref - agent, Vin   : 0
Closed-loop check of ref law (sgn = +1): 0
Max relative difference Vin (ref vs agent), 5 points with W > 0: 0

```

## compact_form.m  (2026-11-12 23:42:03)

```
compact - full: W_ref 0, i_ref 0, Vin 0
Compact forms equal the full expressions.

```
