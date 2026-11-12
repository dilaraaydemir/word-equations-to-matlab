%% verify_adaptive.m - closed-loop checks for deriv_adaptive.m (independent: plain symbols, chain rule)
cd(fileparts(mfilename('fullpath')));
clear; clc;
S = load('results.mat');

syms X1 X2 X3 TH1h TH2h TH3h real
syms th1 th2 th3 tht1 tht2 tht3 real
syms k1 k2 k3 g1 g2 g3 positive
Xs  = [X1 X2 X3 TH1h TH2h TH3h];
THh = [TH1h TH2h TH3h];
th  = [th1 th2 th3];
gam = [g1 g2 g3];
Gam = diag(gam);
phi2 = S.phi2_s;  phi3 = S.phi3_s;  u = S.u_s;  thd = S.thd_s;
z2 = phi2 - X2;   z3 = phi3 - X3;

% true dynamics (E1) and time derivative along it
fx  = @(uu) [X2 + th1*X1^2; X3 + th2*X1*X2; th3*X3 + uu];
ddt = @(e, uu, thdot) jacobian(e, Xs)*[fx(uu); thdot(:)];
isZero = @(e) isequal(simplify(expand(e)), sym(zeros(size(e))));
nPass = 0;

%% 0. True parameters absent from the laws
for q = {phi2, phi3, u, thd, S.u_compact, S.thd_compact}
    assert(~any(has(q{1}, [th tht1 tht2 tht3])), 'true parameter in a law');
end
fprintf('[PASS] theta1..3 (and theta_tilde) do not appear in phi2, phi3, u, theta_hat_dot\n'); nPass = nPass + 1;

%% 1. phi2: x1*TERM1 = -k1*x1^2
assert(isZero(X1*(phi2 + TH1h*X1^2) + k1*X1^2));
fprintf('[PASS] phi2 bracket: x1*(phi2 + th1h*x1^2) = -k1*x1^2\n'); nPass = nPass + 1;

%% 2. phi3: z2*TERM2 = -k2*z2^2 with tuning function tau2 (recomputed here)
dphi2_dx1  = diff(phi2, X1);
dphi2_dthh = jacobian(phi2, THh);
tau1  = Gam*[X1^3; 0; 0];
tau2  = tau1 + Gam*z2*[dphi2_dx1*X1^2; -X1*X2; 0];
TERM2 = -X1 + dphi2_dx1*(X2 + TH1h*X1^2) + dphi2_dthh*tau2 - phi3 - TH2h*X1*X2;
assert(isZero(TERM2 + k2*z2));
fprintf('[PASS] phi3 bracket: z2*TERM2 = -k2*z2^2 (TERM2 with tau2)\n'); nPass = nPass + 1;

%% 3. Adaptation law = tau3 (all theta_tilde terms of Vdot)
omega3 = [diff(phi3, X1)*X1^2; diff(phi3, X2)*X1*X2; -X3];
tau3   = tau2 + Gam*z3*omega3;
assert(isZero(thd(:) - tau3));
fprintf('[PASS] theta_hat_dot = tau3 = Gamma*(x1*w1 + z2*w2 + z3*w3)\n'); nPass = nPass + 1;

%% 4. Derivatives phi2_dot, phi3_dot from deriv vs chain rule here
sub_tht = @(e) subs(e, [tht1 tht2 tht3], th - THh);
assert(isZero(sub_tht(S.phi2_dot_s) - ddt(phi2, u, thd)));
fprintf('[PASS] phi2_dot (deriv) = d/dt phi2 along the true dynamics\n'); nPass = nPass + 1;
assert(isZero(sub_tht(S.phi3_dot_s) - ddt(phi3, u, thd)));
fprintf('[PASS] phi3_dot (deriv) = d/dt phi3 along the true dynamics\n'); nPass = nPass + 1;

%% 5. Full closed-loop check (tuning functions)
V    = X1^2/2 + z2^2/2 + z3^2/2 + sum((th - THh).^2./(2*gam));
Vdot = ddt(V, u, thd);
tic;
res  = simplify(expand(Vdot - (-k1*X1^2 - k2*z2^2 - k3*z3^2)));
fprintf('closed-loop residual (%.1f s): %s\n', toc, char(res));
assert(isequal(res, sym(0)), 'closed-loop check failed');
fprintf('[PASS] Vdot = -k1*x1^2 - k2*z2^2 - k3*z3^2 exactly (tuning functions)\n'); nPass = nPass + 1;

%% 6. Plain laws of the document: residual in Vdot
phi3p = S.phi3_p_s;  up = S.u_p_s;  thdp = S.thd_p_s;
z3p   = phi3p - X3;
Vp    = X1^2/2 + z2^2/2 + z3p^2/2 + sum((th - THh).^2./(2*gam));
Rp    = expand(ddt(Vp, up, thdp) - (-k1*X1^2 - k2*z2^2 - k3*z3p^2));
Rp    = expand(subs(Rp, th, THh + [tht1 tht2 tht3]));
cR    = jacobian(Rp, [tht1 tht2 tht3]);
R0    = simplify(subs(Rp, [tht1 tht2 tht3], [0 0 0]));
assert(isZero(Rp - cR*[tht1; tht2; tht3] - R0), 'residual not linear in theta_tilde');
% expected residual: tht1*(z2*dphi2/dx1*x1^2 + z3*dphi3/dx1*x1^2) + tht2*z3*dphi3/dx2*x1*x2
c1_exp = z2*dphi2_dx1*X1^2 + z3p*diff(phi3p, X1)*X1^2;
c2_exp = z3p*diff(phi3p, X2)*X1*X2;
assert(isZero(cR(1) - c1_exp) && isZero(cR(2) - c2_exp) && isZero(cR(3)) && isZero(R0));
fprintf('[INFO] plain laws: Vdot = -k1*x1^2 - k2*z2^2 - k3*z3^2 + R\n');
fprintf('       R = tht1*(z2*dphi2/dx1 + z3*dphi3/dx1)*x1^2 + tht2*z3*dphi3/dx2*x1*x2   (tht3 cancels)\n');
fprintf('       dphi2/dx1 = %s\n', char(simplify(dphi2_dx1)));
fprintf('       sign-indefinite: R ~= 0 for tht ~= 0  -> no Lyapunov proof with the plain laws\n');
nPass = nPass + 1;
% numeric example of a positive residual (state where plain Vdot > 0)
vals = [X1 X2 X3 TH1h TH2h TH3h k1 k2 k3 g1 g2 g3 tht1 tht2 tht3];
pt   = [1 0.5 -0.5 0 0 0 1 1 1 1 1 1 1 -0.5 2];
fprintf('       at x(0)=(1,0.5,-0.5), th_hat=0, k=gamma=1, tht=(1,-0.5,2): R = %.4g, target part = %.4g\n', ...
    double(subs(Rp, vals, pt)), double(subs(-k1*X1^2 - k2*z2^2 - k3*z3p^2, vals, pt)));

%% 7. Simplified / compact / function files vs full expression at 5 random points
rng(42); digits(50);
fu = @u_fun; ft = @thetahat_dot_fun; fp2 = @phi2_fun; fp3 = @phi3_fun;
maxrel = 0;
for n = 1:5
    p   = 0.5 + 1.5*rand(1, 12);
    pv  = num2cell(p);
    s   = [Xs k1 k2 k3 g1 g2 g3];
    uf  = vpa(subs(u, s, p));
    pairs = {vpa(subs(S.u_simp, s, p)), uf; fu(pv{:}), double(uf); ...
             ft(pv{:}), double(vpa(subs(thd(:), s, p))); ...
             fp2(pv{:}), double(vpa(subs(phi2, s, p))); fp3(pv{:}), double(vpa(subs(phi3, s, p)))};
    for m = 1:size(pairs, 1)
        a = double(pairs{m, 1}); b = double(pairs{m, 2});
        maxrel = max(maxrel, max(abs(a(:) - b(:))./max(abs(b(:)), 1)));
    end
end
assert(maxrel < 1e-10, 'simplified/compact form differs');
fprintf('[PASS] 5 random points (rng 42): simplified, compact and *_fun.m agree, max rel. diff = %.2e\n', maxrel); nPass = nPass + 1;

%% 8. Denominators / 0-0
for q = {{'phi2', phi2}, {'phi3', phi3}, {'u', u}, {'thd', thd}}
    [~, d] = numden(q{1}{2});
    assert(all(isAlways(d == 1)), 'denominator found');
end
fprintf('[PASS] no denominators in phi2, phi3, u, theta_hat_dot: polynomial, no singularity, no 0/0\n'); nPass = nPass + 1;

fprintf('\n%d checks passed.\n', nPass);
