cd(fileparts(mfilename('fullpath')));
% Simplification, denominators, singularities and limits of W_ref, i_ref, Vin, th1h_dot
S = load(fullfile('..', 'results.mat'));
syms DV W i th1_hat th2_hat Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot real
syms a_P a_w Rbf Rgp K t1 t2 k1 k2 k3 gam1 gam2 positive

names = {'W_ref', 'i_ref', 'Vin', 'th1h_dot'};
full  = [S.W_ref, S.i_ref, S.Vin_e, S.th1h_dot];
simp  = [S.W_ref_simp, S.i_ref_simp, S.Vin_simp, S.th1h_dot_simp];

%% Size and denominators
for n = 1:numel(names)
    [~, den] = numden(simplifyFraction(simp(n)));
    fprintf('%-9s length full %5d, simplified %5d, denominator factors: %s\n', names{n}, ...
        length(char(full(n))), length(char(simp(n))), char(factor(den)));
end
fprintf('Intermediate denominators: g1 = -2*a_w (phi2), g3 = K and th1_hat (phi3), th2_hat (u), Rbf (f1)\n');

%% Simplified vs unsimplified at 5 random points
rng(42);
digits(50);
vars = symvar([full simp]);
for p = 1:5
    vals = vpa(0.5 + 1.5*rand(1, numel(vars)));
    a = vpa(subs(full, vars, vals));
    b = vpa(subs(simp, vars, vals));
    fprintf('point %d: max relative difference = %s\n', p, char(vpa(max(abs((a - b)./b)), 5)));
end

%% Singular candidates: step-by-step vs simplified at v = 0
base = num2cell(vpa(0.5 + 1.5*rand(1, numel(vars))));
cand = [th1_hat th2_hat K a_w];
for c = cand
    vals = base;
    vals{vars == c} = 0;
    try
        step = vpa(subs(S.Vin_e, vars, [vals{:}]));
    catch
        step = sym('DivByZero');                         % subs reports division by zero
    end
    try
        sv = vpa(subs(S.Vin_simp, vars, [vals{:}]));
    catch
        sv = sym('DivByZero');
    end
    lr = limit(subs(S.Vin_simp, setdiff(vars, c), [vals{vars ~= c}]), c, 0, 'right');
    fprintf('Vin at %-8s = 0: step-by-step %s, simplified %s, right limit %s\n', char(c), char(step), char(sv), char(lr));
end
fprintf('Rbf appears only as 1/Rbf (Rbf > 0, 2.4e9): no singularity in operation\n');

%% Pole order in th1_hat and th2_hat
[~, denV] = numden(simplifyFraction(S.Vin_simp));
[~, denT] = numden(simplifyFraction(S.th1h_dot_simp));
fprintf('Vin: pole order in th1_hat = %d, in th2_hat = %d\n', polynomialDegree(denV, th1_hat), polynomialDegree(denV, th2_hat));
fprintf('th1h_dot: pole order in th1_hat = %d\n', polynomialDegree(denT, th1_hat));
