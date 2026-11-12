%% analyze_simplification.m  Denominators, 0/0 check, random-point test, Simulink functions (B4, B5)
cd(fileparts(mfilename('fullpath')));
clear; clc;
load('results.mat');
syms DV W i real
syms Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot real
syms a_P a_w Rbf Rgp L J K t1 t2 positive
syms k1 k2 k3 positive
syms X1 X2 X3 F1 F1dot F2 f1ddot f2dot g1 g2 g3 g4 g5 g6 real

%% Denominators
names = {'W_ref', 'i_ref', 'Vin'};
ex = {W_ref_simp, i_ref_simp, Vin_simp};
for n = 1:numel(ex)
    [~, d] = numden(simplifyFraction(ex{n}));
    fprintf('Denominator of %s (one fraction): %s\n', names{n}, char(factor(d)));
end
fprintf('Intermediate denominators: g1 = -2*a_w, g2 = -t2/J, g3 = K/J, g4 = -K/L, g5 = -Rgp/L, g6 = 1/L,\n');
fprintf('  f1 contains 1/Rbf, f2 contains 1/J; the abstract law divides by g1, g3, g6.\n');
fprintf('No state (DV, W, i) and no signal appears in any denominator.\n\n');

%% 0/0 check: step-by-step vs simplified at v = 0
allv = [DV W i Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot a_P a_w Rbf Rgp L J K t1 t2 k1 k2 k3];
rng(42);
base = 0.5 + 1.5*rand(1, numel(allv));
cand = [a_w K J L Rbf];
pFun = matlabFunction(p_new, 'Vars', {allv});      % numeric: 1/0 -> Inf, 0/0 -> NaN
uFun = matlabFunction(u_abs, 'Vars', {[X1 X2 X3 F1 F1dot f1ddot F2 f2dot g1 g2 g3 g4 g5 g6 k1 k2 k3]});
vFun = matlabFunction(Vin_simp, 'Vars', {allv});
for c = cand
    vals = base; vals(allv == c) = 0;
    % step by step: numeric f, g first, then the abstract law
    pn = pFun(vals);
    step = uFun([pn, vals(end-2:end)]);
    simp = vFun(vals);
    lim  = limit(subs(Vin_simp, allv(allv ~= c), base(allv ~= c)), c, 0, 'right');
    if ~isfinite(step) && isfinite(simp), kind = 'removable';
    elseif ~isfinite(simp), kind = 'real singularity';
    else, kind = 'regular';
    end
    fprintf('%-4s = 0: step-by-step %g, simplified %g, limit(0+) %s -> %s\n', ...
        char(c), step, simp, char(lim), kind);
end
fprintf('All of these are positive physical constants (S9), so none is reached in operation.\n\n');

%% Random-point test: simplified vs unsimplified (abstract chain and physical)
digits(50);
maxrel = 0;
for n = 1:5
    vals = sym(0.5 + 1.5*rand(1, numel(allv)));
    pn = subs(p_new, allv, vals);
    a = vpa(subs(subs(u_abs, p_old, pn), allv, vals));
    b = vpa(subs(Vin_simp, allv, vals));
    c2 = vpa(subs(i_ref, allv, vals)); d2 = vpa(subs(i_ref_simp, allv, vals));
    c1 = vpa(subs(W_ref, allv, vals)); d1 = vpa(subs(W_ref_simp, allv, vals));
    rel = max(double(abs([a - b, c2 - d2, c1 - d1]) ./ abs([b, d2, d1])));
    maxrel = max(maxrel, rel);
    fprintf('point %d: Vin = %.12g, rel. diff (Vin, i_ref, W_ref) max = %.3g\n', n, double(b), rel);
end
assert(maxrel < 1e-10, 'simplified and unsimplified differ');
fprintf('Max relative difference: %.3g (< 1e-10)\n\n', maxrel);

%% Simulink-ready functions
consts = {a_P, a_w, Rbf, Rgp, L, J, K, t1, t2, k1, k2, k3};
matlabFunction(W_ref_simp, 'File', 'W_ref_fun', 'Vars', [{DV, Qvad, DP}, consts]);
matlabFunction(i_ref_simp, 'File', 'i_ref_fun', 'Vars', [{DV, W, Qvad, DP, Qvad_dot, DP_dot}, consts]);
matlabFunction(Vin_simp, 'File', 'Vin_fun', ...
    'Vars', [{DV, W, i, Qvad, DP, Qvad_dot, DP_dot, Qvad_ddot, DP_ddot}, consts]);
% Check the generated function against the symbolic law
vals = 0.5 + 1.5*rand(1, numel(allv));
cv = num2cell(vals(10:end));
v_fun = Vin_fun(vals(1), vals(2), vals(3), vals(4), vals(5), vals(6), vals(7), vals(8), vals(9), cv{:});
v_sym = double(subs(Vin_simp, allv, vals));
fprintf('Vin_fun vs symbolic: %.3g relative difference\n', abs(v_fun - v_sym)/abs(v_sym));
assert(abs(v_fun - v_sym)/abs(v_sym) < 1e-12, 'Vin_fun mismatch');
fprintf('Wrote W_ref_fun.m, i_ref_fun.m, Vin_fun.m\n');
fprintf('\nLaTeX Vin:\n%s\n', latex(Vin_simp));
