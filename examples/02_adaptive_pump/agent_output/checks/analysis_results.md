
## chk_document  (2026-11-13 01:04:24)

```
E4 == 2(Qvad-Qgp): 1
E14 from E4,E5: 1
[Warning: Unable to prove '-(4*DP)/Rbf == 0'.] 
[> In mupadengine/evalin2logical
In mupadengine/feval2logical
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('sym/isAlways', 'C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\@sym\isAlways.m', 39)" style="font-weight:bold">sym/isAlways</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\@sym\isAlways.m',39,0)">line 39</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('chk_document', 'C:\Users\Dilara\Desktop\agentword\Tekrar\D12_b\D12_b_model_2026-11-13_005946\checks\chk_document.m', 30)" style="font-weight:bold">chk_document</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Tekrar\D12_b\D12_b_model_2026-11-13_005946\checks\chk_document.m',30,0)">line 30</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('log_run', 'C:\Users\Dilara\Desktop\agentword\Tekrar\D12_b\D12_b_model_2026-11-13_005946\checks\log_run.m', 5)" style="font-weight:bold">log_run</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Tekrar\D12_b\D12_b_model_2026-11-13_005946\checks\log_run.m',5,0)">line 5</a>)
] 
E21a with E17a   == E14: 0, difference = -(4*DP)/Rbf
E21a with E17a_corr == E14: 1
E21b == E15: 1
E21c == E16: 1
E6 (with E8) == E15: 1
E24b: 1, E24c: 1
E25a-c: 1 1 1
E27 V(z3 = -1, others 0) = -1/2  (negative -> not positive definite)
E27 dV/dz3 = (3*z3^2)/2, document uses z3*z3_dot (matches E27_corr)
E28 - E29 (document)  = [2, g3, z2, z3, th1h - th1t]
E28 - E29_corr        = 0
E32 solves E31: 1
E34 solves E33: 1
[Warning: Unable to prove '-2*g3*th1h*z2 == 0'.] 
[> In mupadengine/evalin2logical
In mupadengine/feval2logical
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('sym/isAlways', 'C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\@sym\isAlways.m', 39)" style="font-weight:bold">sym/isAlways</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\symbolic\symbolic\@sym\isAlways.m',39,0)">line 39</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('chk_document', 'C:\Users\Dilara\Desktop\agentword\Tekrar\D12_b\D12_b_model_2026-11-13_005946\checks\chk_document.m', 86)" style="font-weight:bold">chk_document</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Tekrar\D12_b\D12_b_model_2026-11-13_005946\checks\chk_document.m',86,0)">line 86</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('run', 'C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m', 112)" style="font-weight:bold">run</a> (<a href="matlab: opentoline('C:\Program Files\MATLAB\R2025b\toolbox\matlab\lang\run.m',112,0)">line 112</a>)
In <a href="matlab:matlab.lang.internal.introspective.errorDocCallback('log_run', 'C:\Users\Dilara\Desktop\agentword\Tekrar\D12_b\D12_b_model_2026-11-13_005946\checks\log_run.m', 5)" style="font-weight:bold">log_run</a> (<a href="matlab: opentoline('C:\Users\Dilara\Desktop\agentword\Tekrar\D12_b\D12_b_model_2026-11-13_005946\checks\log_run.m',5,0)">line 5</a>)
] 
E36 solves E35 (document bracket): 0, residual = -2*g3*th1h*z2
E36 solves E35_corr bracket:       1
E38 solves E37 (document bracket): 1
E38 against E37_corr bracket: residual = -2*g3*z2*z3
E38_corr solves E37_corr: 1
E40 solves E39: 1
E40 compact: th2h_dot = -gam2*z3*(g4*x2 + g5*x3 + u): 1
Strict feedback: x2 linear in x1_dot: 1, x3 linear in x2_dot: 1, u only in x3_dot: 1

```

## verify_adaptive  (2026-11-13 01:06:48)

```
step 1: DV*(F1 + g1*phi2) == -k1*DV^2: 1
phi2_dot (derivation) == chain rule: 1
step 2: bracket == -k2*z2: 1
th1h_dot (derivation) == E38_corr + gam1*z3*dphi3/dW*F: 1
phi3_dot (derivation) == chain rule along estimated dynamics: 1
u (derivation) == E36 with tuning phi3_dot: 1
th2h_dot (derivation) == E40: 1
CLOSED LOOP (tuning function): Vdot - (-k1 DV^2 - k2 z2^2 - k3 z3^2) == 0: 1
Document law (E38_corr): residual == -z3*(dphi3/dW)*(F2+g2 W+g3 i)*th1_tilde: 1
  dphi3/dW = -(k1 + k2 + g2*th1_hat)/(g3*th1_hat)
Document law (E38 as written): residual == previous - 2*g3*z2*z3*th1_tilde: 1
J, L, th1, th2 absent from Vin_simp, th1h_dot_simp, th2h_dot_cmp: 1
Vin_simp == physical subs of Vin_abs: 1
th1h_dot_simp == physical subs of th1h_dot_abs: 1
CLOSED LOOP physical (E15, E16, J, L): Vdot - target == 0: 1

```

## analysis_adaptive  (2026-11-13 01:07:28)

```
W_ref     length full    37, simplified    37, denominator factors: [2, Rbf, a_w]
i_ref     length full   179, simplified   179, denominator factors: [2, K, Rbf, a_w, th1_hat]
Vin       length full  1503, simplified  1503, denominator factors: [4, K, K, K, Rbf, Rbf, a_w, a_w, th1_hat, th1_hat, th1_hat, th1_hat, th2_hat]
th1h_dot  length full   330, simplified   330, denominator factors: [2, K, K, Rbf, a_w, th1_hat, th1_hat]
Intermediate denominators: g1 = -2*a_w (phi2), g3 = K and th1_hat (phi3), th2_hat (u), Rbf (f1)
point 1: max relative difference = 0.0
point 2: max relative difference = 0.0
point 3: max relative difference = 0.0
point 4: max relative difference = 0.0
point 5: max relative difference = 0.0
Vin at th1_hat  = 0: step-by-step DivByZero, simplified DivByZero, right limit -Inf
Vin at th2_hat  = 0: step-by-step DivByZero, simplified DivByZero, right limit -Inf
Vin at K        = 0: step-by-step DivByZero, simplified DivByZero, right limit -Inf
Vin at a_w      = 0: step-by-step DivByZero, simplified DivByZero, right limit -Inf
Rbf appears only as 1/Rbf (Rbf > 0, 2.4e9): no singularity in operation
Vin: pole order in th1_hat = 4, in th2_hat = 1
th1h_dot: pole order in th1_hat = 2

```

## sim_adaptive  (2026-11-13 01:08:35)

```
Solver ode15s (L/R = 3.0 ms next to mechanical/adaptive dynamics: stiff), horizon 5 s
Gains k1 k2 k3 = 10 50 500, gam1 gam2 = 1e+06 100000, no projection

[tuning function, th_hat(0) = 0.5*th]  cpu 0.2 s, steps 131, STOPPED at t = 0.0000 s (th_hat <= 1% of th)
  max|DV| t>1 s =  m^3, max|z2| t>1 s =  rad/s, max|z3| t>1 s =  A
  max|Vin| = 1066.932 V (t>0.05 s:  V), min th1_hat/th1 = 0.500, min th2_hat/th2 = 0.010
  final th1_hat/th1 = 0.501, th2_hat/th2 = 0.010, V(0) = 2.640e+02, V(end) = 2.633e+02, max increase of V per step = 0.000e+00

[document (E38_corr), th_hat(0) = 0.5*th]  cpu 0.1 s, steps 130, STOPPED at t = 0.0000 s (th_hat <= 1% of th)
  max|DV| t>1 s =  m^3, max|z2| t>1 s =  rad/s, max|z3| t>1 s =  A
  max|Vin| = 1066.080 V (t>0.05 s:  V), min th1_hat/th1 = 0.500, min th2_hat/th2 = 0.010
  final th1_hat/th1 = 0.501, th2_hat/th2 = 0.010, V(0) = 2.640e+02, V(end) = 2.633e+02, max increase of V per step = 0.000e+00

[tuning function, th_hat(0) = 1.5*th]  cpu 0.1 s, steps 390, STOPPED at t = 0.0006 s (th_hat <= 1% of th)
  max|DV| t>1 s =  m^3, max|z2| t>1 s =  rad/s, max|z3| t>1 s =  A
  max|Vin| = 67297.840 V (t>0.05 s:  V), min th1_hat/th1 = 0.265, min th2_hat/th2 = 0.010
  final th1_hat/th1 = 0.265, th2_hat/th2 = 0.010, V(0) = 2.227e+02, V(end) = 2.086e+02, max increase of V per step = 0.000e+00

[document (E38_corr), th_hat(0) = 1.5*th]  cpu 0.1 s, steps 389, STOPPED at t = 0.0006 s (th_hat <= 1% of th)
  max|DV| t>1 s =  m^3, max|z2| t>1 s =  rad/s, max|z3| t>1 s =  A
  max|Vin| = 63081.797 V (t>0.05 s:  V), min th1_hat/th1 = 0.266, min th2_hat/th2 = 0.010
  final th1_hat/th1 = 0.266, th2_hat/th2 = 0.010, V(0) = 2.227e+02, V(end) = 2.086e+02, max increase of V per step = 0.000e+00

```

## sim_adaptive  (2026-11-13 01:09:01)

```
Solver ode15s (L/R = 3.0 ms next to mechanical/adaptive dynamics: stiff), horizon 5 s
Gains k1 k2 k3 = 5 20 200, gam1 gam2 = 10000 1000, no projection

[tuning function, th_hat(0) = 0.5*th]  cpu 0.2 s, steps 958
  max|DV| t>1 s = 1.701e-07 m^3, max|z2| t>1 s = 4.441e-01 rad/s, max|z3| t>1 s = 2.412e-01 A
  max|Vin| = 5.437 V (t>0.05 s: 5.437 V), min th1_hat/th1 = 0.499, min th2_hat/th2 = 0.499
  final th1_hat/th1 = 0.562, th2_hat/th2 = 0.499, V(0) = 2.077e+02, V(end) = 1.727e+02, max increase of V per step = 0.000e+00

[document (E38_corr), th_hat(0) = 0.5*th]  cpu 0.1 s, steps 1052
  max|DV| t>1 s = 1.682e-07 m^3, max|z2| t>1 s = 4.414e-01 rad/s, max|z3| t>1 s = 2.402e-01 A
  max|Vin| = 5.437 V (t>0.05 s: 5.437 V), min th1_hat/th1 = 0.499, min th2_hat/th2 = 0.499
  final th1_hat/th1 = 0.568, th2_hat/th2 = 0.499, V(0) = 2.077e+02, V(end) = 1.696e+02, max increase of V per step = 0.000e+00

[tuning function, th_hat(0) = 1.5*th]  cpu 0.2 s, steps 1443
  max|DV| t>1 s = 3.366e-08 m^3, max|z2| t>1 s = 6.649e-02 rad/s, max|z3| t>1 s = 1.072e-01 A
  max|Vin| = 5.451 V (t>0.05 s: 5.451 V), min th1_hat/th1 = 1.488, min th2_hat/th2 = 1.500
  final th1_hat/th1 = 1.488, th2_hat/th2 = 1.500, V(0) = 2.076e+02, V(end) = 1.992e+02, max increase of V per step = 0.000e+00

[document (E38_corr), th_hat(0) = 1.5*th]  cpu 0.1 s, steps 1400
  max|DV| t>1 s = 3.365e-08 m^3, max|z2| t>1 s = 6.647e-02 rad/s, max|z3| t>1 s = 1.071e-01 A
  max|Vin| = 5.451 V (t>0.05 s: 5.451 V), min th1_hat/th1 = 1.487, min th2_hat/th2 = 1.500
  final th1_hat/th1 = 1.487, th2_hat/th2 = 1.500, V(0) = 2.076e+02, V(end) = 1.984e+02, max increase of V per step = 0.000e+00

```

## sim_adaptive  (2026-11-13 01:09:37)

```
Solver ode15s (L/R = 3.0 ms next to mechanical/adaptive dynamics: stiff), horizon 5 s
Gains k1 k2 k3 = 5 20 200, gam1 gam2 = 10000 1000, no projection

[tuning function, th_hat(0) = 0.5*th]  cpu 0.2 s, steps 958
  max|DV| t>1 s = 1.701e-07 m^3, max|z2| t>1 s = 4.441e-01 rad/s, max|z3| t>1 s = 2.412e-01 A
  max|Vin| = 5.437 V (t>0.05 s: 5.437 V), min th1_hat/th1 = 0.499, min th2_hat/th2 = 0.499
  final th1_hat/th1 = 0.562, th2_hat/th2 = 0.499, V(0) = 2.077e+02, V(end) = 1.727e+02, max increase of V per step = 0.000e+00
  document law: max |residual|/|target| = 2.311e-01, fraction of samples with Vdot > 0 = 0.000

[document (E38_corr), th_hat(0) = 0.5*th]  cpu 0.2 s, steps 1052
  max|DV| t>1 s = 1.682e-07 m^3, max|z2| t>1 s = 4.414e-01 rad/s, max|z3| t>1 s = 2.402e-01 A
  max|Vin| = 5.437 V (t>0.05 s: 5.437 V), min th1_hat/th1 = 0.499, min th2_hat/th2 = 0.499
  final th1_hat/th1 = 0.568, th2_hat/th2 = 0.499, V(0) = 2.077e+02, V(end) = 1.696e+02, max increase of V per step = 0.000e+00

[tuning function, th_hat(0) = 1.5*th]  cpu 0.2 s, steps 1443
  max|DV| t>1 s = 3.366e-08 m^3, max|z2| t>1 s = 6.649e-02 rad/s, max|z3| t>1 s = 1.072e-01 A
  max|Vin| = 5.451 V (t>0.05 s: 5.451 V), min th1_hat/th1 = 1.488, min th2_hat/th2 = 1.500
  final th1_hat/th1 = 1.488, th2_hat/th2 = 1.500, V(0) = 2.076e+02, V(end) = 1.992e+02, max increase of V per step = 0.000e+00
  document law: max |residual|/|target| = 1.559e-01, fraction of samples with Vdot > 0 = 0.000

[document (E38_corr), th_hat(0) = 1.5*th]  cpu 0.1 s, steps 1400
  max|DV| t>1 s = 3.365e-08 m^3, max|z2| t>1 s = 6.647e-02 rad/s, max|z3| t>1 s = 1.071e-01 A
  max|Vin| = 5.451 V (t>0.05 s: 5.451 V), min th1_hat/th1 = 1.487, min th2_hat/th2 = 1.500
  final th1_hat/th1 = 1.487, th2_hat/th2 = 1.500, V(0) = 2.076e+02, V(end) = 1.984e+02, max increase of V per step = 0.000e+00

```

## sim_adaptive  (2026-11-13 01:10:00)

```
Solver ode15s (L/R = 3.0 ms next to mechanical/adaptive dynamics: stiff), horizon 5 s
Gains k1 k2 k3 = 5 20 200, gam1 gam2 = 10000 1000, no projection

[tuning function, th_hat(0) = 0.5*th]  cpu 0.3 s, steps 958
  max|DV| t>1 s = 1.701e-07 m^3, max|z2| t>1 s = 4.441e-01 rad/s, max|z3| t>1 s = 2.412e-01 A
  max|Vin| = 5.437 V (t>0.05 s: 5.437 V), min th1_hat/th1 = 0.499, min th2_hat/th2 = 0.499
  final th1_hat/th1 = 0.562, th2_hat/th2 = 0.499, V(0) = 2.077e+02, V(end) = 1.727e+02, max increase of V per step = 0.000e+00

[document (E38_corr), th_hat(0) = 0.5*th]  cpu 0.1 s, steps 1052
  max|DV| t>1 s = 1.682e-07 m^3, max|z2| t>1 s = 4.414e-01 rad/s, max|z3| t>1 s = 2.402e-01 A
  max|Vin| = 5.437 V (t>0.05 s: 5.437 V), min th1_hat/th1 = 0.499, min th2_hat/th2 = 0.499
  final th1_hat/th1 = 0.568, th2_hat/th2 = 0.499, V(0) = 2.077e+02, V(end) = 1.696e+02, max increase of V per step = 0.000e+00
  document law: max |residual|/|target| = 2.311e-01, fraction of samples with Vdot > 0 = 0.000

[tuning function, th_hat(0) = 1.5*th]  cpu 0.2 s, steps 1443
  max|DV| t>1 s = 3.366e-08 m^3, max|z2| t>1 s = 6.649e-02 rad/s, max|z3| t>1 s = 1.072e-01 A
  max|Vin| = 5.451 V (t>0.05 s: 5.451 V), min th1_hat/th1 = 1.488, min th2_hat/th2 = 1.500
  final th1_hat/th1 = 1.488, th2_hat/th2 = 1.500, V(0) = 2.076e+02, V(end) = 1.992e+02, max increase of V per step = 0.000e+00

[document (E38_corr), th_hat(0) = 1.5*th]  cpu 0.1 s, steps 1400
  max|DV| t>1 s = 3.365e-08 m^3, max|z2| t>1 s = 6.647e-02 rad/s, max|z3| t>1 s = 1.071e-01 A
  max|Vin| = 5.451 V (t>0.05 s: 5.451 V), min th1_hat/th1 = 1.487, min th2_hat/th2 = 1.500
  final th1_hat/th1 = 1.487, th2_hat/th2 = 1.500, V(0) = 2.076e+02, V(end) = 1.984e+02, max increase of V per step = 0.000e+00
  document law: max |residual|/|target| = 1.559e-01, fraction of samples with Vdot > 0 = 0.000

```
