cd(fileparts(mfilename('fullpath')));

%% Assignment
syms t real
syms x1(t) x2(t) x3(t) f1(t) f1dot(t) f2(t) f2dot(t) th1h(t) th2h(t)
syms f1ddot g1 g2 g3 g4 g5 real
syms k1 k2 k3 gam1 gam2 th1 th2 positive
syms th1t th2t real                                      % parameter errors: th_t = th_h - th (E26)
syms z2 z3 phi2 phi3 phi2_dot phi3_dot_h a32 u th1h_dot th2h_dot real   % placeholder symbols, resolved before every diff
placeholders = [phi2 phi2_dot phi3 phi3_dot_h a32 z2 z3 u th1h_dot th2h_dot];

%% Define system (E21a-c)
x1_dot = f1(t) + g1*x2(t);
x2_dot = th1*(f2(t) + g2*x2(t) + g3*x3(t));
x3_dot = th2*(g4*x2(t) + g5*x3(t) + u);
x2_dot_h = th1h(t)*(f2(t) + g2*x2(t) + g3*x3(t));        % estimated dynamics: the controller can compute only this

%% Define new system dynamics (E22, E23, S5)
x2_new = phi2 - z2;                                      % separate name, so x2(t) keeps its time dependence
x3_new = phi3 - z3;
z2_dot = phi2_dot - x2_dot;
z3_dot = phi3_dot_h + a32*(x2_dot - x2_dot_h) - x3_dot;  % true phi3_dot = estimated phi3_dot + dphi3/dx2*(x2_dot - x2_dot_h), a32 = dphi3/dx2

%% Subs (E25a-c, E26)
th_true = [th1 th2];
th_e    = [th1h(t) - th1t, th2h(t) - th2t];
x1_dot_s = subs(x1_dot, [x2(t) x3(t)], [x2_new x3_new]);
z2_dot_s = subs(z2_dot, [x2(t) x3(t) th_true], [x2_new x3_new th_e]);
z3_dot_s = subs(z3_dot, [x2(t) x3(t) th_true], [x2_new x3_new th_e]);

%% Lyapunov function and its derivative (E27_corr, E28)
V    = x1(t)^2/2 + z2^2/2 + z3^2/2 + th1t^2/(2*gam1) + th2t^2/(2*gam2);
Vdot = x1(t)*x1_dot_s + z2*z2_dot_s + z3*z3_dot_s + th1t*th1h_dot/gam1 + th2t*th2h_dot/gam2;

%% Define and rearrange terms (E29_corr)
assert(isequal(diff(Vdot, th1t, 2), sym(0)) && isequal(diff(Vdot, th2t, 2), sym(0)), 'Vdot is not linear in th1t, th2t');
term_th1 = diff(Vdot, th1t);                             % coefficient by diff: Vdot is linear in th1t
term_th2 = diff(Vdot, th2t);
z2_dot_0 = subs(z2_dot_s, [th1t th2t], [0 0]);
z3_dot_0 = subs(z3_dot_s, [th1t th2t], [0 0]);
term1     = subs(x1_dot_s, [z2 z3], [0 0]);
x1_z2_coe = diff(x1_dot_s, z2)*x1(t);                    % coefficient by diff: no division by z2, no 0/0
x1_z3_coe = diff(x1_dot_s, z3)*x1(t);
term2     = subs(z2_dot_0, z3, 0) + x1_z2_coe;
z2_z3_coe = diff(z2_dot_0, z3)*z2;
term3     = z3_dot_0 + x1_z3_coe + z2_z3_coe;
assert(isequal(simplify(Vdot - (x1(t)*term1 + z2*term2 + z3*term3 + th1t*term_th1 + th2t*term_th2)), sym(0)), 'Vdot rearrangement is wrong');

%% Solve for xr, u and adaptation laws (E31-E40, S5)
phi2_e     = rhs(isolate(term1 == -k1*x1(t), phi2));
phi3_e     = rhs(isolate(term2 == -k2*z2, phi3));
u_e        = rhs(isolate(term3 == -k3*z3, u));
th1h_dot_e = rhs(isolate(term_th1 == 0, th1h_dot));      % contains the tuning-function term with a32
th2h_dot_e = rhs(isolate(term_th2 == 0, th2h_dot));

%% Solve for xr dot (T5)
d_syms = [diff(x1(t),t) diff(x2(t),t) diff(f1(t),t) diff(f1dot(t),t) diff(f2(t),t)];
d_vals = [x1_dot x2_dot_h f1dot(t) f1ddot f2dot(t)];
phi2_dot_e = subs(diff(phi2_e, t), d_syms, d_vals);

phi3_r = phi3_e;
for ii = 1:5                                             % repeated subs: one pass may leave placeholders
    phi3_r = subs(phi3_r, [phi2 phi2_dot z2], [phi2_e phi2_dot_e phi2 - x2(t)]);
end
assert(~any(ismember(symvar(phi3_r), placeholders)), 'placeholder left before diff of phi3');
a32_e = diff(phi3_r, x2(t));

th1h_dot_r = th1h_dot_e;
for ii = 1:5
    th1h_dot_r = subs(th1h_dot_r, [phi2 phi2_dot phi3 z2 z3 a32], [phi2_e phi2_dot_e phi3_r phi2 - x2(t) phi3 - x3(t) a32_e]);
end
assert(~any(ismember(symvar(th1h_dot_r), placeholders)), 'placeholder left in th1h_dot');

phi3_dot_e = subs(diff(phi3_r, t), [d_syms diff(th1h(t),t)], [d_vals th1h_dot_r]);  % uses the full adaptation law
assert(~contains(char(phi3_dot_e), 'diff'), 'unresolved derivative in phi3_dot');

%% Subs (T6): u and adaptation laws in x1, x2, x3, th1h, th2h only
u_r = u_e;
for ii = 1:5
    u_r = subs(u_r, [phi2 phi2_dot phi3 phi3_dot_h z2 z3], [phi2_e phi2_dot_e phi3_r phi3_dot_e phi2 - x2(t) phi3 - x3(t)]);
end
assert(~any(ismember(symvar(u_r), placeholders)), 'placeholder left in u');

th2h_dot_r = th2h_dot_e;
for ii = 1:5
    th2h_dot_r = subs(th2h_dot_r, [phi2 phi3 z2 z3 u], [phi2_e phi3_r phi2 - x2(t) phi3 - x3(t) u_r]);
end
assert(~any(ismember(symvar(th2h_dot_r), placeholders)), 'placeholder left in th2h_dot');
assert(~any(ismember([th1 th2 th1t th2t], symvar([u_r th1h_dot_r th2h_dot_r]))), 'true parameter in a law');

%% symfun to sym
syms DV W i th1_hat th2_hat F1 F1dot F1ddot F2 F2dot real
t_funs = [x1(t) x2(t) x3(t) th1h(t) th2h(t) f1(t) f1dot(t) f2(t) f2dot(t) f1ddot];
s_vars = [DV W i th1_hat th2_hat F1 F1dot F2 F2dot F1ddot];
W_ref_abs    = subs(phi2_e, t_funs, s_vars);
i_ref_abs    = subs(phi3_r, t_funs, s_vars);
Vin_abs      = subs(u_r, t_funs, s_vars);
th1h_dot_abs = subs(th1h_dot_r, t_funs, s_vars);
th2h_dot_abs = subs(th2h_dot_r, t_funs, s_vars);

%% Physical values (E17a_corr, E17b, E18, E19, S6: sgn(W) = 1)
syms Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot Vin real
syms a_P a_w Rbf Rgp K t1 t2 positive
abs_syms  = [F1 F1dot F1ddot F2 F2dot g1 g2 g3 g4 g5];
phys_vals = [2*Qvad + 2*DP/Rbf, 2*Qvad_dot + 2*DP_dot/Rbf, 2*Qvad_ddot + 2*DP_ddot/Rbf, -t1 - a_P*DP, -a_P*DP_dot, -2*a_w, -t2, K, -K, -Rgp];
W_ref    = subs(W_ref_abs, abs_syms, phys_vals);
i_ref    = subs(i_ref_abs, abs_syms, phys_vals);
Vin_e    = subs(Vin_abs, abs_syms, phys_vals);
th1h_dot = subs(th1h_dot_abs, abs_syms, phys_vals);
th2h_dot = subs(th2h_dot_abs, abs_syms, phys_vals);

W_ref_simp    = simplify(W_ref);
i_ref_simp    = simplify(i_ref);
Vin_simp      = simplify(Vin_e);
th1h_dot_simp = simplify(th1h_dot);
th2h_dot_cmp  = -gam2*(i_ref_simp - i)*(-K*W - Rgp*i + Vin);   % E40 compact form with Vin as input
assert(isequal(simplify(subs(th2h_dot_cmp, Vin, Vin_simp) - th2h_dot), sym(0)), 'compact th2h_dot differs from full form');

allowed = [DV W i th1_hat th2_hat Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot a_P a_w Rbf Rgp K t1 t2 k1 k2 k3 gam1 gam2 Vin];
assert(all(ismember(symvar([W_ref_simp i_ref_simp Vin_simp th1h_dot_simp th2h_dot_cmp]), allowed)), 'unresolved symbol in a final law');

%% Save and export
save('results.mat', 'phi2_e', 'phi3_e', 'u_e', 'th1h_dot_e', 'th2h_dot_e', 'phi2_dot_e', 'phi3_r', 'a32_e', 'th1h_dot_r', 'phi3_dot_e', 'u_r', 'th2h_dot_r', ...
    'W_ref_abs', 'i_ref_abs', 'Vin_abs', 'th1h_dot_abs', 'th2h_dot_abs', ...
    'W_ref', 'i_ref', 'Vin_e', 'th1h_dot', 'th2h_dot', 'W_ref_simp', 'i_ref_simp', 'Vin_simp', 'th1h_dot_simp', 'th2h_dot_cmp');
in_vars = {DV, W, i, th1_hat, th2_hat, Qvad, DP, Qvad_dot, DP_dot, Qvad_ddot, DP_ddot, a_w, a_P, Rbf, Rgp, K, t1, t2, k1, k2, k3, gam1};
matlabFunction(Vin_simp, 'File', 'Vin_fun', 'Vars', in_vars, 'Outputs', {'Vin'});
matlabFunction(th1h_dot_simp, 'File', 'th1h_dot_fun', 'Vars', in_vars, 'Outputs', {'th1h_dot'});   % same inputs as Vin_fun
matlabFunction(th2h_dot_cmp, 'File', 'th2h_dot_fun', 'Vars', {DV, W, i, th1_hat, Vin, Qvad, DP, Qvad_dot, DP_dot, a_w, a_P, Rbf, Rgp, K, t1, t2, k1, k2, gam2}, 'Outputs', {'th2h_dot'});
