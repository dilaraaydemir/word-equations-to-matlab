%% deriv_backstepping.m  Backstepping law for the gear pump (Deneme_14_model.docx)
% Steps T1-T8 as decided in inventory.md (S1-S10).
% Regulation DV -> 0, z1 = x1, z2 = phi2 - x2, z3 = phi3 - x3, V = x1^2/2 + z2^2/2 + z3^2/2.
cd(fileparts(mfilename('fullpath')));
clear; clc;

%% Assignment (T1)
syms x1(t)
assume(x1(t),'real')
syms x2(t)
assume(x2(t),'real')
syms x3(t)
assume(x3(t),'real')
syms f1(t)
assume(f1(t),'real')
syms f1dot(t)
assume(f1dot(t),'real')
syms f2(t)
assume(f2(t),'real')
syms f1ddot f2dot real                         % highest derivatives needed (plain symbols)
syms g1 g2 g3 g4 g5 g6 real
syms k1 k2 k3 positive
syms z2 z3 phi2 phi3 phi2_dot phi3_dot u real  % errors and placeholders

%% Define system (E17-E19)
x1_dot = f1 + g1*x2;
x2_dot = f2 + g2*x2 + g3*x3;
x3_dot = g4*x2 + g5*x3 + g6*u;

%% Define new system dynamics (T1)
x2_new = phi2 - z2;
x3_new = phi3 - z3;
z2_dot = phi2_dot - x2_dot;
z3_dot = phi3_dot - x3_dot;

%% Solve for V_dot (T2)
V_dot = x1*x1_dot + z2*z2_dot + z3*z3_dot;

%% Subs (T3): x2 = phi2 - z2 in TERM1, x3 = phi3 - z3 in TERM2
V_dot_s = subs(V_dot, [x2(t) x3(t)], [x2_new x3_new]);

%% Define and rearrange terms (T3)
% TERM1: only x1 and phi2.  The cross term -g1*x1*z2 goes to TERM2.
% TERM2: the cross term +g3*z2*z3 goes to TERM3.
term1 = f1 + g1*phi2;
term2 = phi2_dot - f2 - g2*x2 - g3*phi3 - g1*x1;
term3 = phi3_dot - g4*x2 - g5*x3 - g6*u + g3*z2;
chk_split = formula(simplify(V_dot_s - subs(x1*term1 + z2*term2 + z3*term3, [x2(t) x3(t)], [x2_new x3_new])));
assert(isequal(chk_split, sym(0)), 'TERM split does not reproduce V_dot');
fprintf('T3: V_dot - (x1*TERM1 + z2*TERM2 + z3*TERM3) = %s\n', char(chk_split));

%% Solve for xr and u (T4, T5): z_i*TERM_i = -k_i*z_i^2
phi2_e = rhs(isolate(term1 == -k1*x1, phi2));
phi3_e = rhs(isolate(term2 == -k2*z2, phi3));
u_e    = rhs(isolate(term3 == -k3*z3, u));
fprintf('T5: phi2 = %s\n', char(phi2_e));
fprintf('T5: phi3 = %s\n', char(phi3_e));
fprintf('T5: u    = %s\n', char(u_e));

%% Solve for xr dot (T6)
% Time derivative along the dynamics: states, f1 -> f1dot -> f1ddot, f2 -> f2dot.
dold = [diff(x1(t),t), diff(x2(t),t), diff(x3(t),t), diff(f1(t),t), diff(f1dot(t),t), diff(f2(t),t)];
dnew = [x1_dot,        x2_dot,        x3_dot,        f1dot,          f1ddot,             f2dot];
ddt  = @(e) subs(diff(e, t), dold, dnew);
plh  = [phi2 phi2_dot phi3 phi3_dot z2 z3];

% phi2_dot: phi2_e has no placeholder
assert(~any(ismember(symvar(phi2_e), plh)), 'placeholder left before diff (phi2)');
phi2_dot_e = ddt(phi2_e);
assert(~any(ismember(symvar(phi2_dot_e), [plh u])), 'u or placeholder in phi2_dot');

% phi3_dot: resolve z2 = phi2 - x2, phi2, phi2_dot repeatedly, then differentiate
e = phi3_e; prev = sym(0);
while ~isequal(e, prev)
    prev = e;
    e = subs(e, [z2 phi2 phi2_dot], [phi2 - x2, phi2_e, phi2_dot_e]);
end
assert(~any(ismember(symvar(e), plh)), 'placeholder left before diff (phi3)');
phi3_full  = e;
phi3_dot_e = ddt(phi3_full);
assert(~any(ismember(symvar(phi3_dot_e), [plh u])), 'u or placeholder in phi3_dot');

%% Subs z2 and z3 (T7): everything in x1, x2, x3 only
e = u_e; prev = sym(0);
while ~isequal(e, prev)
    prev = e;
    e = subs(e, [z3 z2 phi3_dot phi3 phi2_dot phi2], ...
        [phi3 - x3, phi2 - x2, phi3_dot_e, phi3_full, phi2_dot_e, phi2_e]);
end
assert(~any(ismember(symvar(e), plh)), 'placeholder left in u');
u_full = e;

%% symfun to sym
syms X1 X2 X3 F1 F1dot F2 real
s_old = [x1(t) x2(t) x3(t) f1dot(t) f1(t) f2(t)];
s_new = [X1    X2    X3    F1dot    F1    F2];
phi2_abs     = formula(subs(phi2_e,     s_old, s_new));
phi2_dot_abs = formula(subs(phi2_dot_e, s_old, s_new));
phi3_abs     = formula(subs(phi3_full,  s_old, s_new));
phi3_dot_abs = formula(subs(phi3_dot_e, s_old, s_new));
u_abs        = formula(subs(u_full,     s_old, s_new));
allowed_abs = [X1 X2 X3 F1 F1dot f1ddot F2 f2dot g1 g2 g3 g4 g5 g6 k1 k2 k3];
assert(all(ismember(symvar(u_abs), allowed_abs)), 'unresolved symbol in abstract u');

phi2_abs_simp = simplify(phi2_abs);
phi3_abs_simp = simplify(phi3_abs);
u_abs_simp    = simplify(u_abs);
fprintf('\nAbstract level (f, g symbolic):\n');
fprintf('phi2 = %s\n', char(phi2_abs_simp));
fprintf('phi3 = %s\n', char(phi3_abs_simp));
fprintf('u    = %s\n', char(u_abs_simp));

%% Physical values (T8)
syms DV W i real
syms Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot real
syms a_P a_w Rbf Rgp L J K t1 t2 positive
sgnW = sym(1);                                  % S7: omega > 0
p_old = [X1 X2 X3 F1 F1dot f1ddot F2 f2dot g1 g2 g3 g4 g5 g6];
p_new = [DV W i, ...
    2*Qvad + 2/Rbf*DP, ...                      % F1      (E14a)
    2*Qvad_dot + 2/Rbf*DP_dot, ...              % F1dot
    2*Qvad_ddot + 2/Rbf*DP_ddot, ...            % f1ddot
    -t1*sgnW/J - a_P/J*DP, ...                  % F2      (E14b)
    -a_P/J*DP_dot, ...                          % f2dot   (sgn constant)
    -2*a_w, -t2/J, K/J, -K/L, -Rgp/L, 1/L];     % g1..g6  (E15, E16)
W_ref     = subs(phi2_abs, p_old, p_new);
W_ref_dot = subs(phi2_dot_abs, p_old, p_new);
i_ref     = subs(phi3_abs, p_old, p_new);
i_ref_dot = subs(phi3_dot_abs, p_old, p_new);
Vin       = subs(u_abs,    p_old, p_new);

W_ref_simp = simplify(W_ref, 'Steps', 50);
i_ref_simp = simplify(i_ref, 'Steps', 50);
Vin_simp   = simplify(Vin,   'Steps', 100);

allowed = [DV W i Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot a_P a_w Rbf Rgp L J K t1 t2 k1 k2 k3];
assert(all(ismember(symvar(Vin_simp), allowed)), 'unresolved symbol in Vin');
assert(all(ismember(symvar(i_ref_simp), allowed)), 'unresolved symbol in i_ref');
assert(all(ismember(symvar(W_ref_simp), allowed)), 'unresolved symbol in W_ref');
assert(isequal(simplify(Vin_simp - Vin), sym(0)), 'Vin_simp differs from Vin');

fprintf('\nPhysical level:\n');
fprintf('W_ref = %s\n\n', char(W_ref_simp));
fprintf('i_ref = %s\n\n', char(i_ref_simp));
fprintf('Vin   = %s\n\n', char(Vin_simp));
fprintf('Symbols in Vin: %s\n', char(symvar(Vin_simp)));

%% Save
save('results.mat', 'phi2_e', 'phi3_e', 'u_e', 'phi2_dot_e', 'phi3_full', 'phi3_dot_e', 'u_full', ...
    'phi2_abs', 'phi2_dot_abs', 'phi3_abs', 'phi3_dot_abs', 'u_abs', ...
    'phi2_abs_simp', 'phi3_abs_simp', 'u_abs_simp', ...
    'W_ref', 'W_ref_dot', 'i_ref', 'i_ref_dot', 'Vin', 'W_ref_simp', 'i_ref_simp', 'Vin_simp', ...
    'p_old', 'p_new');
fprintf('Saved results.mat\n');
