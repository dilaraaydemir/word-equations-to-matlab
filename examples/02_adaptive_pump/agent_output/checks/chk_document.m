cd(fileparts(mfilename('fullpath')));
% Checks of the hand-solved part of D12_b_model.docx (E1-E40)

syms Qvad Qgp DP W i Vin real
syms a_w a_P Rbf Rgp K J L t1 t2 positive
syms x1 x2 x3 u f1 f2 g1 g2 g3 g4 g5 real
syms phi2 phi3 phi2d phi3d z2 z3 real
syms th1 th2 gam1 gam2 k1 k2 k3 positive
syms th1h th2h th1t th2t th1hd th2hd real
sgnW = 1;                                                % S6: omega > 0

%% Model (E3-E5, E14)
Vh1_dot = Qvad - Qgp;
Vh2_dot = Qgp - Qvad;
DVh_dot = Vh1_dot - Vh2_dot;                             % E2
Qgp_e   = a_w*W - DP/Rbf;                                % E5
DVh_dot_s = subs(DVh_dot, Qgp, Qgp_e);
E14 = 2*Qvad + 2/Rbf*DP - 2*a_w*W;
fprintf('E4 == 2(Qvad-Qgp): %d\n', isAlways(DVh_dot == 2*(Qvad - Qgp)));
fprintf('E14 from E4,E5: %d\n', isAlways(simplify(DVh_dot_s - E14) == 0));

%% f, g, theta against the model (E17-E21)
f1_doc  = 2*Qvad - 2/Rbf*DP;                             % E17a (Document)
f1_corr = 2*Qvad + 2/Rbf*DP;                             % E17a_corr (Proposed correction)
f2_doc  = -t1*sgnW - a_P*DP;                             % E17b
g_doc   = [-2*a_w, -t2, K, -K, -Rgp];                    % E18, E19
th_doc  = [1/J, 1/L];                                    % E20
x1dot_doc  = f1_doc  + g_doc(1)*W;
x1dot_corr = f1_corr + g_doc(1)*W;
fprintf('E21a with E17a   == E14: %d, difference = %s\n', isAlways(simplify(x1dot_doc - E14) == 0), char(simplify(x1dot_doc - E14)));
fprintf('E21a with E17a_corr == E14: %d\n', isAlways(simplify(x1dot_corr - E14) == 0));
E15 = -t1/J*sgnW - a_P/J*DP - t2/J*W + K/J*i;
E16 = -K/L*W - Rgp/L*i + Vin/L;
fprintf('E21b == E15: %d\n', isAlways(simplify(th_doc(1)*(f2_doc + g_doc(2)*W + g_doc(3)*i) - E15) == 0));
fprintf('E21c == E16: %d\n', isAlways(simplify(th_doc(2)*(g_doc(4)*W + g_doc(5)*i + Vin) - E16) == 0));
E6 = -(t1*sgnW + t2*W)/J + K/J*i - a_P/J*DP;             % E6 with E8, K_i = K
fprintf('E6 (with E8) == E15: %d\n', isAlways(simplify(E6 - E15) == 0));

%% Error dynamics (E22-E25)
x1_dot = f1 + g1*x2;
x2_dot = th1*(f2 + g2*x2 + g3*x3);
x3_dot = th2*(g4*x2 + g5*x3 + u);
z2_dot = phi2d - x2_dot;
z3_dot = phi3d - x3_dot;
E24b = phi2d - th1*f2 - th1*g2*x2 - th1*g3*x3;
E24c = phi3d - th2*g4*x2 - th2*g5*x3 - th2*u;
fprintf('E24b: %d, E24c: %d\n', isAlways(expand(z2_dot - E24b) == 0), isAlways(expand(z3_dot - E24c) == 0));
xs = [x2 x3];
xn = [phi2 - z2, phi3 - z3];                             % E23
E25a = f1 + g1*(phi2 - z2);
E25b = phi2d - th1*f2 - th1*g2*(phi2 - z2) - th1*g3*(phi3 - z3);
E25c = phi3d - th2*g4*(phi2 - z2) - th2*g5*(phi3 - z3) - th2*u;
fprintf('E25a-c: %d %d %d\n', isAlways(expand(subs(x1_dot, xs, xn) - E25a) == 0), ...
    isAlways(expand(subs(z2_dot, xs, xn) - E25b) == 0), isAlways(expand(subs(z3_dot, xs, xn) - E25c) == 0));

%% Lyapunov function (E27)
V_doc  = x1^2/2 + z2^2/2 + z3^3/2 + th1t^2/(2*gam1) + th2t^2/(2*gam2);
V_corr = x1^2/2 + z2^2/2 + z3^2/2 + th1t^2/(2*gam1) + th2t^2/(2*gam2);
fprintf('E27 V(z3 = -1, others 0) = %s  (negative -> not positive definite)\n', char(subs(V_doc, [x1 z2 z3 th1t th2t], [0 0 -1 0 0])));
fprintf('E27 dV/dz3 = %s, document uses z3*z3_dot (matches E27_corr)\n', char(diff(V_doc, z3)));

%% Vdot expanded (E28) and rearranged (E29)
E28 = x1*E25a + z2*subs(E25b, th1, th1h - th1t) + z3*subs(E25c, th2, th2h - th2t) + th1t*th1hd/gam1 + th2t*th2hd/gam2;
E29_doc = x1*(f1 + g1*phi2) ...
    + z2*(phi2d - g1*x1 - th1h*f2 - th1h*g2*phi2 + th1h*g2*z2 - th1h*g3*phi3) ...
    + z3*(phi3d - th1h*g3*z2 - th2h*g4*phi2 + th2h*g4*z2 - th2h*g5*phi3 + th2h*g5*z3 - th2h*u) ...
    + th1t*(th1hd/gam1 + f2*z2 + g2*phi2*z2 - g2*z2^2 + g3*phi3*z2 + g3*z2*z3) ...
    + th2t*(th2hd/gam2 + g4*phi2*z3 - g4*z2*z3 + g5*phi3*z3 - g5*z3^2 + z3*u);
E29_corr = x1*(f1 + g1*phi2) ...
    + z2*(phi2d - g1*x1 - th1h*f2 - th1h*g2*phi2 + th1h*g2*z2 - th1h*g3*phi3) ...
    + z3*(phi3d + th1h*g3*z2 - th2h*g4*phi2 + th2h*g4*z2 - th2h*g5*phi3 + th2h*g5*z3 - th2h*u) ...
    + th1t*(th1hd/gam1 + f2*z2 + g2*phi2*z2 - g2*z2^2 + g3*phi3*z2 - g3*z2*z3) ...
    + th2t*(th2hd/gam2 + g4*phi2*z3 - g4*z2*z3 + g5*phi3*z3 - g5*z3^2 + z3*u);
fprintf('E28 - E29 (document)  = %s\n', char(factor(expand(E28 - E29_doc))));
fprintf('E28 - E29_corr        = %s\n', char(expand(E28 - E29_corr)));

%% Steps 1-3 (E31-E36)
phi2_doc = (-k1*x1 - f1)/g1;                             % E32
fprintf('E32 solves E31: %d\n', isAlways(simplify(subs(x1*(f1 + g1*phi2), phi2, phi2_doc) + k1*x1^2) == 0));
br2 = phi2d - th1h*f2 - th1h*g2*phi2 + th1h*g2*z2 - th1h*g3*phi3 - g1*x1;
phi3_doc = 1/g3*(phi2d/th1h - f2 - g2*phi2 + g2*z2 - g1*x1/th1h + k2*z2/th1h);  % E34
fprintf('E34 solves E33: %d\n', isAlways(simplify(subs(br2, phi3, phi3_doc) + k2*z2) == 0));
br3_doc  = phi3d - th1h*g3*z2 - th2h*g4*phi2 + th2h*g4*z2 - th2h*g5*phi3 + th2h*g5*z3 - th2h*u;
br3_corr = phi3d + th1h*g3*z2 - th2h*g4*phi2 + th2h*g4*z2 - th2h*g5*phi3 + th2h*g5*z3 - th2h*u;
u_doc = phi3d/th2h - g4*phi2 + g4*z2 - g5*phi3 + g5*z3 + th1h/th2h*g3*z2 + k3*z3/th2h;  % E36
fprintf('E36 solves E35 (document bracket): %d, residual = %s\n', isAlways(simplify(subs(br3_doc, u, u_doc) + k3*z3) == 0), char(simplify(subs(br3_doc, u, u_doc) + k3*z3)));
fprintf('E36 solves E35_corr bracket:       %d\n', isAlways(simplify(subs(br3_corr, u, u_doc) + k3*z3) == 0));

%% Adaptation laws (E37-E40)
th1hd_doc  = gam1*(-f2*z2 - g2*phi2*z2 + g2*z2^2 - g3*phi3*z2 - g3*z2*z3);  % E38
th1hd_corr = gam1*(-f2*z2 - g2*phi2*z2 + g2*z2^2 - g3*phi3*z2 + g3*z2*z3);  % E38_corr
br_th1_corr = th1hd/gam1 + f2*z2 + g2*phi2*z2 - g2*z2^2 + g3*phi3*z2 - g3*z2*z3;
fprintf('E38 solves E37 (document bracket): %d\n', isAlways(simplify(subs(th1hd/gam1 + f2*z2 + g2*phi2*z2 - g2*z2^2 + g3*phi3*z2 + g3*z2*z3, th1hd, th1hd_doc)) == 0));
fprintf('E38 against E37_corr bracket: residual = %s\n', char(simplify(subs(br_th1_corr, th1hd, th1hd_doc))));
fprintf('E38_corr solves E37_corr: %d\n', isAlways(simplify(subs(br_th1_corr, th1hd, th1hd_corr)) == 0));
th2hd_doc = gam2*(-g4*phi2*z3 + g4*z2*z3 - g5*phi3*z3 + g5*z3^2 - z3*u);    % E40
fprintf('E40 solves E39: %d\n', isAlways(simplify(subs(th2hd/gam2 + g4*phi2*z3 - g4*z2*z3 + g5*phi3*z3 - g5*z3^2 + z3*u, th2hd, th2hd_doc)) == 0));
fprintf('E40 compact: th2h_dot = -gam2*z3*(g4*x2 + g5*x3 + u): %d\n', isAlways(simplify(subs(th2hd_doc - (-gam2*z3*(g4*(phi2 - z2) + g5*(phi3 - z3) + u)))) == 0));

%% Strict-feedback form
fprintf('Strict feedback: x2 linear in x1_dot: %d, x3 linear in x2_dot: %d, u only in x3_dot: %d\n', ...
    isAlways(diff(x1_dot, x2, 2) == 0), isAlways(diff(x2_dot, x3, 2) == 0), ~has(x1_dot, u) && ~has(x2_dot, u));
