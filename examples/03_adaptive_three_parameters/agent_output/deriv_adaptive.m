%% deriv_adaptive.m - D13_b_model.docx: adaptive backstepping, three unknown parameters
% Tuning-function design (decision S3 (a)); plain laws of the document at the end (comparison).
cd(fileparts(mfilename('fullpath')));
clear; clc;

%% Assignment
syms x1(t)
assume(x1(t),'real')
syms x2(t)
assume(x2(t),'real')
syms x3(t)
assume(x3(t),'real')
syms th1h(t)
assume(th1h(t),'real')
syms th2h(t)
assume(th2h(t),'real')
syms th3h(t)
assume(th3h(t),'real')
syms th1 th2 th3 tht1 tht2 tht3 u real
syms k1 k2 k3 g1 g2 g3 positive
syms phi2 phi3 z2 z3 real                  % placeholders: virtual controls, errors
syms th1h_dot th2h_dot th3h_dot real       % placeholders: adaptation laws
thh     = [th1h(t) th2h(t) th3h(t)];
tht     = [tht1 tht2 tht3];
thh_dot = [th1h_dot th2h_dot th3h_dot];
gam     = [g1 g2 g3];
Gam     = diag(gam);
ph      = [phi2 phi3 z2 z3 thh_dot];       % every placeholder
dx      = [diff(x1(t),t) diff(x2(t),t) diff(x3(t),t) diff(th1h(t),t) diff(th2h(t),t) diff(th3h(t),t)];

%% Define system (E1), theta = theta_hat + theta_tilde (E5a)
x1_dot = x2(t) + (th1h(t) + tht1)*x1(t)^2;
x2_dot = x3(t) + (th2h(t) + tht2)*x1(t)*x2(t);
x3_dot = (th3h(t) + tht3)*x3(t) + u;
xth_dot = [x1_dot x2_dot x3_dot thh_dot];  % right-hand side for diff(.,t)

%% Step 1 - T1/T2/T3: x1*x1_dot with x2 = phi2 - z2 (E4a)
Vdot1    = expand(x1(t)*subs(x1_dot, x2(t), phi2 - z2));
term_th1 = jacobian(Vdot1, tht);                         % theta_tilde coefficients of step 1
term1    = subs(x1_dot, [x2(t) tht], [phi2 0 0 0]);      % TERM1 (theta_hat in place of theta)
c12      = diff(Vdot1, z2);                              % cross term x1*(-z2) -> TERM2 (S5)
assert(isequal(simplify(Vdot1 - (x1(t)*term1 + c12*z2 + term_th1*tht.')), sym(0)), 'T3 split, step 1');

%% Step 1 - T4: solve phi2 from x1*TERM1 = -k1*x1^2
phi2_e = rhs(isolate(term1 == -k1*x1(t), phi2));
assert(isequal(simplify(x1(t)*subs(term1, phi2, phi2_e) + k1*x1(t)^2), sym(0)), 'phi2 bracket');
tau1 = Gam*term_th1.';                                   % tuning function 1

%% Step 2 - T6: phi2_dot (placeholders resolved before diff)
assertNoPh(phi2_e, ph, 'phi2_e');
phi2_dot   = expand(subs(diff(phi2_e, t), dx, xth_dot));
dphi2_dthh = jacobian(phi2_dot, thh_dot);                % d phi2 / d theta_hat

%% Step 2 - T2/T3: z2*z2_dot with x3 = phi3 - z3 (E4b)
z2_dot   = phi2_dot - subs(x2_dot, x3(t), phi3 - z3);
Vdot2    = expand(c12*z2 + z2*z2_dot);
term_th2 = jacobian(Vdot2, tht);
tau2     = tau1 + Gam*term_th2.';                        % tuning function 2
c23      = diff(Vdot2, z3);                              % cross term z2*z3 -> TERM3 (S5)
term2    = c12 + subs(phi2_dot - subs(x2_dot, x3(t), phi3), [tht thh_dot], [0 0 0 tau2.']);
% split: theta_hat_dot - tau2 is left for step 3
assert(isequal(simplify(Vdot2 - (z2*term2 + c23*z3 + term_th2*tht.' + z2*dphi2_dthh*(thh_dot.' - tau2))), sym(0)), 'T3 split, step 2');

%% Step 2 - T4: solve phi3 from z2*TERM2 = -k2*z2^2
phi3_e = rhs(isolate(term2 == -k2*z2, phi3));
phi3_x = resolve(phi3_e, [z2 phi2], [phi2_e - x2(t), phi2_e]);
assertNoPh(phi3_x, ph, 'phi3_x');

%% Step 3 - T6: phi3_dot
phi3_dot   = expand(subs(diff(phi3_x, t), dx, xth_dot));
dphi3_dthh = jacobian(phi3_dot, thh_dot);
z3_dot     = phi3_dot - x3_dot;
omega3     = jacobian(z3_dot, tht);                      % regressor of step 3 (no division by z3)
term_th3   = z3*omega3;

%% T5: adaptation laws from TERM_theta_i = 0
TERM_th   = term_th1 + term_th2 + term_th3 - thh_dot./gam;
thh_dot_e = sym(zeros(1,3));
for k = 1:3
    thh_dot_e(k) = rhs(isolate(TERM_th(k) == 0, thh_dot(k)));
end
tau3 = tau2 + Gam*term_th3.';
assert(isequal(simplify(thh_dot_e.' - tau3), sym(zeros(3,1))), 'adaptation law = tau3');

%% Step 3 - T3/T4: TERM3 (cross terms z2*z3 and z2*dphi2/dthh*(tau3 - tau2)), solve u
term3 = c23 + z2*dphi2_dthh*Gam*omega3.' + subs(z3_dot, [tht thh_dot], [0 0 0 thh_dot_e]);
Vdot_tot = Vdot1 + z2*z2_dot + z3*z3_dot - tht*(thh_dot./gam).';   % Vdot of E6 (cross term c12*z2 is inside Vdot1)
Vdot_tot = subs(Vdot_tot, thh_dot, thh_dot_e);
assert(isequal(simplify(expand(Vdot_tot - (x1(t)*term1 + z2*term2 + z3*term3))), sym(0)), 'T3 split, total');
u_e = rhs(isolate(term3 == -k3*z3, u));

%% Subs: resolve z2, z3, phi2, phi3 in u and adaptation laws
z_ph   = [z3 z2 phi3 phi2];
z_val  = [phi3_x - x3(t), phi2_e - x2(t), phi3_x, phi2_e];
u_x    = resolve(u_e, z_ph, z_val);
thd_x  = resolve(thh_dot_e, z_ph, z_val);
assertNoPh(u_x, ph, 'u_x');
assertNoPh(thd_x, ph, 'thd_x');
% derivatives of virtual controls along the dynamics with the final adaptation law
phi2_dot_x = resolve(subs(phi2_dot, thh_dot, thd_x), z_ph, z_val);
phi3_dot_x = resolve(subs(phi3_dot, thh_dot, thd_x), z_ph, z_val);

%% symfun to sym
syms X1 X2 X3 TH1h TH2h TH3h real
fx = [x1(t) x2(t) x3(t) th1h(t) th2h(t) th3h(t)];
Xs = [X1 X2 X3 TH1h TH2h TH3h];
phi2_s     = subs(phi2_e, fx, Xs);
phi3_s     = subs(phi3_x, fx, Xs);
u_s        = subs(u_x, fx, Xs);
thd_s      = subs(thd_x, fx, Xs);
phi2_dot_s = subs(phi2_dot_x, fx, Xs);                   % contains tht (true dynamics)
phi3_dot_s = subs(phi3_dot_x, fx, Xs);

%% Check: true parameters are not in u, adaptation laws, phi2, phi3
allowed = [X1 X2 X3 TH1h TH2h TH3h k1 k2 k3 g1 g2 g3];
for q = {phi2_s, phi3_s, u_s, thd_s}
    assert(all(ismember(symvar(q{1}), allowed)), 'unresolved symbol');
    assert(~any(has(q{1}, [th1 th2 th3 tht])), 'true parameter in law');
end
fprintf('Assert passed: phi2, phi3, u, theta_hat_dot contain only x, theta_hat, k, gamma.\n');

%% Simplification
tic; phi2_simp = simplify(phi2_s);                          fprintf('phi2 simplified (%.1f s)\n', toc);
tic; phi3_simp = simplify(collect(expand(phi3_s), [X1 X2]));  fprintf('phi3 simplified (%.1f s)\n', toc);
tic; thd_simp  = simplify(expand(thd_s));                   fprintf('theta_hat_dot simplified (%.1f s)\n', toc);
tic; u_simp    = simplify(expand(u_s), 'Steps', 30);        fprintf('u simplified (%.1f s)\n', toc);
for q = {{'phi2', phi2_s, phi2_simp}, {'phi3', phi3_s, phi3_simp}, {'thd', thd_s, thd_simp}, {'u', u_s, u_simp}}
    c = q{1};
    assert(isequal(simplify(expand(c{2} - c{3})), sym(zeros(size(c{2})))), 'simplified %s differs', c{1});
    [~, d] = numden(c{3});
    fprintf('%s: denominators = %s, length unsimp/simp = %d/%d chars\n', c{1}, char(d), length(char(c{2})), length(char(c{3})));
end

% compact (nested) forms for Simulink: shorter than the expanded polynomials
u_compact   = u_s;
thd_compact = simplify(thd_s, 'Steps', 50);
assert(isequal(simplify(expand(u_compact - u_simp)), sym(0)), 'u compact differs');
assert(isequal(simplify(expand(thd_compact - thd_simp)), sym(zeros(1,3))), 'thd compact differs');
fprintf('compact forms: u %d chars, theta_hat_dot %d chars (equal to expanded forms: assert passed)\n', ...
    length(char(u_compact)), length(char(thd_compact)));

fprintf('\nphi2 = %s\n', char(phi2_simp));
fprintf('\nphi3 = %s\n', char(phi3_simp));
fprintf('\ntheta1_hat_dot = %s\n', char(thd_simp(1)));
fprintf('\ntheta2_hat_dot = %s\n', char(thd_simp(2)));
fprintf('\ntheta3_hat_dot = %s\n', char(thd_simp(3)));
fprintf('\nu = %s\n', char(u_simp));

%% Plain laws (document reading, comparison): each theta_tilde cancelled only in its own step
thh_dot_p = [g1*x1(t)^3, -g2*z2*x1(t)*x2(t), -g3*z3*x3(t)];
term2_p   = c12 + subs(phi2_dot - subs(x2_dot, x3(t), phi3), [tht thh_dot], [0 0 0 thh_dot_p]);
phi3_pe   = rhs(isolate(term2_p == -k2*z2, phi3));
phi3_px   = resolve(phi3_pe, [z2 phi2], [phi2_e - x2(t), phi2_e]);
assertNoPh(phi3_px, ph, 'phi3_px');
phi3_dot_p = expand(subs(diff(phi3_px, t), dx, xth_dot));
z3_dot_p   = phi3_dot_p - x3_dot;
term3_p    = c23 + subs(z3_dot_p, [tht thh_dot], [0 0 0 thh_dot_p]);
u_pe       = rhs(isolate(term3_p == -k3*z3, u));
zp_ph      = [z3 z2 phi3 phi2];
zp_val     = [phi3_px - x3(t), phi2_e - x2(t), phi3_px, phi2_e];
u_p_s      = subs(resolve(u_pe, zp_ph, zp_val), fx, Xs);
thd_p_s    = subs(resolve(thh_dot_p, zp_ph, zp_val), fx, Xs);
phi3_p_s   = subs(phi3_px, fx, Xs);
for q = {phi3_p_s, u_p_s, thd_p_s}
    assert(all(ismember(symvar(q{1}), allowed)), 'unresolved symbol (plain)');
end
u_p_simp   = simplify(expand(u_p_s), 'Steps', 30);
thd_p_simp = simplify(expand(thd_p_s));
phi3_p_simp = simplify(collect(expand(phi3_p_s), [X1 X2]));
fprintf('\nPlain laws: theta_hat_dot = %s\n', char(thd_p_simp));
fprintf('Plain laws: phi3 - phi3_tuning = %s\n', char(simplify(expand(phi3_p_s - phi3_s))));

%% Save results
save('results.mat', 'phi2_e', 'phi3_x', 'u_x', 'thd_x', 'phi2_dot_x', 'phi3_dot_x', ...
    'phi2_s', 'phi3_s', 'u_s', 'thd_s', 'phi2_dot_s', 'phi3_dot_s', ...
    'phi2_simp', 'phi3_simp', 'u_simp', 'thd_simp', 'u_compact', 'thd_compact', 'tau1', 'tau2', 'tau3', 'omega3', ...
    'phi3_p_s', 'u_p_s', 'thd_p_s', 'phi3_p_simp', 'u_p_simp', 'thd_p_simp');

%% Simulink-ready functions
vars = {X1, X2, X3, TH1h, TH2h, TH3h, k1, k2, k3, g1, g2, g3};
matlabFunction(u_compact,    'File', 'u_fun',            'Vars', vars, 'Outputs', {'u'});
matlabFunction(thd_compact.', 'File', 'thetahat_dot_fun', 'Vars', vars, 'Outputs', {'thetahat_dot'});
matlabFunction(phi2_simp, 'File', 'phi2_fun',         'Vars', vars, 'Outputs', {'phi2'});
matlabFunction(phi3_simp, 'File', 'phi3_fun',         'Vars', vars, 'Outputs', {'phi3'});
matlabFunction(u_p_simp,  'File', 'u_plain_fun',      'Vars', vars, 'Outputs', {'u'});
matlabFunction(thd_p_simp.', 'File', 'thetahat_dot_plain_fun', 'Vars', vars, 'Outputs', {'thetahat_dot'});
fprintf('\nWritten: u_fun.m, thetahat_dot_fun.m, phi2_fun.m, phi3_fun.m, u_plain_fun.m, thetahat_dot_plain_fun.m\n');

%% Local functions
function e = resolve(e, phs, vals)
% substitute repeatedly until nothing changes (subs does one pass only)
prev = sym(NaN);
while ~isequal(e, prev)
    prev = e;
    e = subs(e, phs, vals);
end
end

function assertNoPh(e, phs, name)
assert(~any(ismember(symvar(e), phs)), 'placeholder left in %s', name);
end
