%% chk_document.m - checks of the hand-solved part of D13_b_model.docx
cd(fileparts(mfilename('fullpath')));
clear; clc;

syms X1 X2 X3 u real
syms th1 th2 th3 TH1h TH2h TH3h real
syms g1 g2 g3 positive
syms phi2 phi3 z2 z3 real

%% E1 - system
f = [X2 + th1*X1^2; X3 + th2*X1*X2; th3*X3 + u];
fprintf('E1a: x1_dot = %s\n', char(f(1)));
fprintf('E1b: x2_dot = %s\n', char(f(2)));
fprintf('E1c: x3_dot = %s\n', char(f(3)));

%% Strict-feedback form check
% equation i may depend on x1..x(i+1) only, x(i+1) linearly with a nonzero coefficient, u only in the last one
X = [X1 X2 X3];
for k = 1:2
    nxt = X(k+1);
    c = diff(f(k), nxt);
    assert(isempty(intersect(symvar(c), X)) && ~isequal(c, sym(0)), 'next state not linear in eq %d', k);
    assert(~has(f(k), u), 'u appears in eq %d', k);
    later = X(k+2:end);
    assert(isempty(later) || ~any(has(f(k), later)), 'later state in eq %d', k);
    fprintf('Eq %d: d/dx%d = %s (constant, nonzero) -> strict feedback OK\n', k, k+1, char(c));
end
assert(isequal(diff(f(3), u), sym(1)), 'u coefficient');
fprintf('Eq 3: u enters linearly with coefficient 1 -> OK\n');
fprintf('Parametric strict-feedback: theta1 in eq1, theta2 in eq2 (before the last eq) -> tuning functions needed (S3)\n');

%% E4 - error definitions, inverse used in T2
assert(isequal(simplify(subs(phi2 - z2, z2, phi2 - X2) - X2), sym(0)));
assert(isequal(simplify(subs(phi3 - z3, z3, phi3 - X3) - X3), sym(0)));
fprintf('E4: x2 = phi2 - z2, x3 = phi3 - z3 consistent with z = phi - x\n');

%% E5 - theta_tilde = theta - theta_hat, d/dt theta_tilde = -d/dt theta_hat (theta constant)
syms a1(t)
syms c1 real
tht = c1 - a1(t);
d = diff(tht, t) + diff(a1(t), t);
assert(isequal(simplify(d), sym(0)));
fprintf('E5b: d(theta - theta_hat)/dt = -d theta_hat/dt  -> OK (theta constant)\n');

%% E6 - V positive definite
syms tht1 tht2 tht3 real
V = X1^2/2 + z2^2/2 + z3^2/2 + tht1^2/(2*g1) + tht2^2/(2*g2) + tht3^2/(2*g3);
vars = [X1 z2 z3 tht1 tht2 tht3];
H = hessian(V, vars);
fprintf('E6: Hessian of V = %s\n', char(H));
assert(isequal(simplify(H - diag(diag(H))), sym(zeros(6))), 'V not diagonal quadratic');
assert(all(isAlways(diag(H) > 0)), 'V not positive definite');
assert(isequal(subs(V, vars, zeros(1,6)), sym(0)));
fprintf('E6: V quadratic, diagonal Hessian with positive entries (gamma_i > 0) -> positive definite\n');

%% E7 - target is negative semidefinite in (x1,z2,z3,tht) and negative definite in (x1,z2,z3)
syms k1 k2 k3 positive
Vd_target = -k1*X1^2 - k2*z2^2 - k3*z3^2;
assert(all(isAlways(diag(hessian(Vd_target, [X1 z2 z3])) < 0)));
fprintf('E7: target Vdot <= 0 (negative semidefinite, theta_tilde absent) -> LaSalle/Barbalat gives x1,z2,z3 -> 0\n');

fprintf('\nAll document checks passed.\n');
