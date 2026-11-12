cd(fileparts(mfilename('fullpath')));
% Closed-loop Lyapunov checks of deriv_adaptive.m, independent chain rule on plain symbols.
% Also builds the document law (E36, E38_corr, E40 without tuning term) and its Vdot residual.
S = load(fullfile('..', 'results.mat'));

syms DV W i th1_hat th2_hat F1 F1dot F1ddot F2 F2dot real
syms g1 g2 g3 g4 g5 real
syms k1 k2 k3 gam1 gam2 th1 th2 positive
X   = [DV W i th1_hat th2_hat F1 F1dot F2];              % everything V and the laws depend on
chk = @(e) isequal(simplify(e), sym(0));

phi2 = S.W_ref_abs;
phi3 = S.i_ref_abs;
z2 = phi2 - W;
z3 = phi3 - i;
F  = F2 + g2*W + g3*i;
a32 = diff(phi3, W);

% time derivative along given state derivatives (columns match X)
ddt = @(e, Xd) gradient(e, X).' * Xd(:);

%% phi2 (step 1)
fprintf('step 1: DV*(F1 + g1*phi2) == -k1*DV^2: %d\n', chk(DV*(F1 + g1*phi2) + k1*DV^2));

%% phi2_dot: derivation vs chain rule (phi2 has no parameter)
Xd_h = @(th1hd, u) [F1 + g1*W, th1_hat*F, th2_hat*(g4*W + g5*i + u), th1hd, 0, F1dot, F1ddot, F2dot];
phi2_dot = ddt(phi2, Xd_h(0, 0));
syms x1(t) x2(t) x3(t) f1(t) f1dot(t) f2(t) f2dot(t) th1h(t) th2h(t)
syms f1ddot real
t_funs = [x1(t) x2(t) x3(t) th1h(t) th2h(t) f1(t) f1dot(t) f2(t) f2dot(t) f1ddot];
s_vars = [DV W i th1_hat th2_hat F1 F1dot F2 F2dot F1ddot];
fprintf('phi2_dot (derivation) == chain rule: %d\n', chk(subs(S.phi2_dot_e, t_funs, s_vars) - phi2_dot));

%% phi3 (step 2 bracket)
br2 = phi2_dot - th1_hat*F2 - th1_hat*g2*phi2 + th1_hat*g2*z2 - th1_hat*g3*phi3 - g1*DV;
fprintf('step 2: bracket == -k2*z2: %d\n', chk(br2 + k2*z2));

%% Tuning-function law: th1h_dot, phi3_dot, u
th1hd_corr = gam1*(-F2*z2 - g2*phi2*z2 + g2*z2^2 - g3*phi3*z2 + g3*z2*z3);   % E38_corr
th1hd_tf   = th1hd_corr + gam1*z3*a32*F;                                       % tuning-function term
fprintf('th1h_dot (derivation) == E38_corr + gam1*z3*dphi3/dW*F: %d\n', chk(S.th1h_dot_abs - th1hd_tf));
phi3_dot_tf = ddt(phi3, Xd_h(th1hd_tf, 0));
fprintf('phi3_dot (derivation) == chain rule along estimated dynamics: %d\n', chk(subs(S.phi3_dot_e, t_funs, s_vars) - phi3_dot_tf));
u_E36 = @(p3d) p3d/th2_hat - g4*phi2 + g4*z2 - g5*phi3 + g5*z3 + th1_hat/th2_hat*g3*z2 + k3*z3/th2_hat;
fprintf('u (derivation) == E36 with tuning phi3_dot: %d\n', chk(S.Vin_abs - u_E36(phi3_dot_tf)));
u_tf = S.Vin_abs;
th2hd_tf = -gam2*z3*(g4*W + g5*i + u_tf);
fprintf('th2h_dot (derivation) == E40: %d\n', chk(S.th2h_dot_abs - th2hd_tf));

%% Full closed-loop check, tuning-function law
V = DV^2/2 + z2^2/2 + z3^2/2 + (th1_hat - th1)^2/(2*gam1) + (th2_hat - th2)^2/(2*gam2);
Xd_true = @(th1hd, th2hd, u) [F1 + g1*W, th1*F, th2*(g4*W + g5*i + u), th1hd, th2hd, F1dot, F1ddot, F2dot];
target = -k1*DV^2 - k2*z2^2 - k3*z3^2;
Vdot_tf = ddt(V, Xd_true(th1hd_tf, th2hd_tf, u_tf));
fprintf('CLOSED LOOP (tuning function): Vdot - (-k1 DV^2 - k2 z2^2 - k3 z3^2) == 0: %d\n', chk(Vdot_tf - target));

%% Document law: E38_corr without tuning term, phi3_dot with the implemented law, E36, E40
phi3_dot_doc = ddt(phi3, Xd_h(th1hd_corr, 0));
u_doc  = u_E36(phi3_dot_doc);
th2hd_doc = -gam2*z3*(g4*W + g5*i + u_doc);
Vdot_doc = ddt(V, Xd_true(th1hd_corr, th2hd_doc, u_doc));
res_doc = simplify(Vdot_doc - target);
res_exp = -z3*a32*F*(th1_hat - th1);
fprintf('Document law (E38_corr): residual == -z3*(dphi3/dW)*(F2+g2 W+g3 i)*th1_tilde: %d\n', chk(res_doc - res_exp));
fprintf('  dphi3/dW = %s\n', char(simplify(a32)));

%% Document law as written: E38 with -g3*z2*z3
th1hd_lit = gam1*(-F2*z2 - g2*phi2*z2 + g2*z2^2 - g3*phi3*z2 - g3*z2*z3);
phi3_dot_lit = ddt(phi3, Xd_h(th1hd_lit, 0));
u_lit  = u_E36(phi3_dot_lit);
th2hd_lit = -gam2*z3*(g4*W + g5*i + u_lit);
Vdot_lit = ddt(V, Xd_true(th1hd_lit, th2hd_lit, u_lit));
res_lit = simplify(Vdot_lit - target);
res_lit_exp = res_exp - 2*g3*z2*z3*(th1_hat - th1);
fprintf('Document law (E38 as written): residual == previous - 2*g3*z2*z3*th1_tilde: %d\n', chk(res_lit - res_lit_exp));

%% Physical level: true parameters absent, final law against abstract law
syms Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot real
syms a_P a_w Rbf Rgp K t1 t2 J L positive
fprintf('J, L, th1, th2 absent from Vin_simp, th1h_dot_simp, th2h_dot_cmp: %d\n', ...
    ~any(ismember([J L th1 th2], symvar([S.Vin_simp S.th1h_dot_simp S.th2h_dot_cmp]))));
abs_syms  = [F1 F1dot F1ddot F2 F2dot g1 g2 g3 g4 g5];
phys_vals = [2*Qvad + 2*DP/Rbf, 2*Qvad_dot + 2*DP_dot/Rbf, 2*Qvad_ddot + 2*DP_ddot/Rbf, -t1 - a_P*DP, -a_P*DP_dot, -2*a_w, -t2, K, -K, -Rgp];
fprintf('Vin_simp == physical subs of Vin_abs: %d\n', chk(S.Vin_simp - subs(S.Vin_abs, abs_syms, phys_vals)));
fprintf('th1h_dot_simp == physical subs of th1h_dot_abs: %d\n', chk(S.th1h_dot_simp - subs(S.th1h_dot_abs, abs_syms, phys_vals)));

%% Physical closed-loop check (J, L as true parameters)
syms Vin real
Xp  = [DV W i th1_hat th2_hat Qvad DP Qvad_dot DP_dot];
Xpd = [2*Qvad + 2*DP/Rbf - 2*a_w*W, (-t1 - a_P*DP - t2*W + K*i)/J, (-K*W - Rgp*i + S.Vin_simp)/L, S.th1h_dot_simp, ...
       subs(S.th2h_dot_cmp, Vin, S.Vin_simp), Qvad_dot, DP_dot, Qvad_ddot, DP_ddot];
z2p = S.W_ref_simp - W;
z3p = S.i_ref_simp - i;
Vp  = DV^2/2 + z2p^2/2 + z3p^2/2 + (th1_hat - 1/J)^2/(2*gam1) + (th2_hat - 1/L)^2/(2*gam2);
Vpdot = gradient(Vp, Xp).' * Xpd(:);
fprintf('CLOSED LOOP physical (E15, E16, J, L): Vdot - target == 0: %d\n', chk(Vpdot - (-k1*DV^2 - k2*z2p^2 - k3*z3p^2)));

%% Save document laws (abstract) for the simulation
Vin_doc_abs = u_doc;
th1h_dot_doc_abs = th1hd_corr;
save('doc_law.mat', 'Vin_doc_abs', 'th1h_dot_doc_abs', 'res_doc', 'res_lit');
