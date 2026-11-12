%% verify_backstepping.m  Closed-loop checks of every step (B3)
% Independent chain-rule derivatives along the real dynamics, abstract and physical level.
cd(fileparts(mfilename('fullpath')));
clear; clc;
load('results.mat');

%% Abstract level
syms X1 X2 X3 F1 F1dot F2 f1ddot f2dot real
syms g1 g2 g3 g4 g5 g6 real
syms k1 k2 k3 positive
u = u_abs;
xv  = [X1 X2 X3 F1 F1dot F2];
xvd = [F1 + g1*X2, F2 + g2*X2 + g3*X3, g4*X2 + g5*X3 + g6*u, F1dot, f1ddot, f2dot];
D = @(e) jacobian(e, xv) * xvd.';          % d/dt along the closed loop

z2 = phi2_abs - X2;
z3 = phi3_abs - X3;
r = struct();
% After phi2: x1*TERM1 = -k1*x1^2
r.term1 = simplify(X1*(F1 + g1*phi2_abs) + k1*X1^2);
% phi2_dot from derivation vs chain rule
r.phi2_dot = simplify(phi2_dot_abs - D(phi2_abs));
% After phi3: z2*TERM2 = -k2*z2^2 (TERM2 with the chain-rule phi2_dot)
r.term2 = simplify(z2*(D(phi2_abs) - F2 - g2*X2 - g3*phi3_abs - g1*X1) + k2*z2^2);
% phi3_dot from derivation vs chain rule (does not depend on u)
r.phi3_dot = simplify(phi3_dot_abs - D(phi3_abs));
% After u: z3*TERM3 = -k3*z3^2
r.term3 = simplify(z3*(D(phi3_abs) - g4*X2 - g5*X3 - g6*u + g3*z2) + k3*z3^2);
% Full closed loop
V = X1^2/2 + z2^2/2 + z3^2/2;
r.Vdot = simplify(D(V) - (-k1*X1^2 - k2*z2^2 - k3*z3^2));
% Simplified abstract forms equal unsimplified
r.u_simp    = simplify(u_abs_simp - u_abs);
r.phi3_simp = simplify(phi3_abs_simp - phi3_abs);
fn = fieldnames(r);
fprintf('Abstract level residuals:\n');
for n = 1:numel(fn), fprintf('  %-10s %s\n', fn{n}, char(r.(fn{n}))); end
assert(all(cellfun(@(c) isequal(c, sym(0)), struct2cell(r))), 'abstract check failed');

%% Physical level (sgn(omega) = +1)
syms DV W i real
syms Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot real
syms a_P a_w Rbf Rgp L J K t1 t2 positive
pv  = [DV W i Qvad DP Qvad_dot DP_dot];
pvd = [2*Qvad + 2/Rbf*DP - 2*a_w*W, ...                         % E10
       -t1/J - a_P/J*DP - t2/J*W + K/J*i, ...                    % E11, sgn = +1
       -K/L*W - Rgp/L*i + Vin_simp/L, ...                        % E12 with the derived Vin
       Qvad_dot, DP_dot, Qvad_ddot, DP_ddot];
Dp = @(e) jacobian(e, pv) * pvd.';
z2p = W_ref_simp - W;
z3p = i_ref_simp - i;
q = struct();
q.W_ref_dot = simplify(W_ref_dot - Dp(W_ref_simp));
q.i_ref_dot = simplify(i_ref_dot - Dp(i_ref_simp));
Vp = DV^2/2 + z2p^2/2 + z3p^2/2;
q.Vdot = simplify(Dp(Vp) - (-k1*DV^2 - k2*z2p^2 - k3*z3p^2));
q.W_simp = simplify(W_ref_simp - W_ref);
q.i_simp = simplify(i_ref_simp - i_ref);
q.Vin_simp = simplify(Vin_simp - Vin);
fn = fieldnames(q);
fprintf('\nPhysical level residuals:\n');
for n = 1:numel(fn), fprintf('  %-10s %s\n', fn{n}, char(q.(fn{n}))); end
assert(all(cellfun(@(c) isequal(c, sym(0)), struct2cell(q))), 'physical check failed');
fprintf('\nAll closed-loop checks are 0.\n');
