%% compare_reference.m  Run a copy of the author's ref.m and compare with this derivation (B6)
cd(fileparts(mfilename('fullpath')));
run('ref_copy.m');                    % the copy starts with clear
R.W_ref = W_ref_simp; R.i_ref = i_ref_simp; R.Vin = Vin_simp;
R.W_ref_raw = W_ref; R.i_ref_raw = i_ref; R.Vin_raw = Vin;
save('ref_results.mat', '-struct', 'R');
clearvars -except R
cd(fileparts(mfilename('fullpath')));
A = load('results.mat');
syms DV W i real
syms Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot real
syms a_P a_w Rbf Rgp L J K t1 t2 positive
syms k1 k2 k3 positive
fprintf('Symbols in ref Vin: %s\n', char(symvar(R.Vin)));
fprintf('ref keeps sign(W): %d\n', has(R.Vin, sign(W)));
% Compare with sign(W) = 1 (S7: omega > 0)
sw = @(e) subs(e, sign(W), sym(1));
d.W_ref = simplify(sw(R.W_ref) - A.W_ref_simp);
d.i_ref = simplify(sw(R.i_ref) - A.i_ref_simp);
d.Vin   = simplify(sw(R.Vin)   - A.Vin_simp);
fn = fieldnames(d);
for n = 1:numel(fn), fprintf('ref - agent, %-6s: %s\n', fn{n}, char(d.(fn{n}))); end
% Closed-loop check of the reference law on the true model (sgn = +1)
pv  = [DV W i Qvad DP Qvad_dot DP_dot];
pvd = [2*Qvad + 2/Rbf*DP - 2*a_w*W, -t1/J - a_P/J*DP - t2/J*W + K/J*i, ...
       -K/L*W - Rgp/L*i + sw(R.Vin)/L, Qvad_dot, DP_dot, Qvad_ddot, DP_ddot];
Dp = @(e) jacobian(e, pv) * pvd.';
z2 = sw(R.W_ref) - W; z3 = sw(R.i_ref) - i;
res = simplify(Dp(DV^2/2 + z2^2/2 + z3^2/2) + k1*DV^2 + k2*z2^2 + k3*z3^2);
fprintf('Closed-loop check of ref law (sgn = +1): %s\n', char(res));
% Numeric spot check at 5 random points (sgn(W) = +1 region, W > 0)
allv = [DV W i Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot a_P a_w Rbf Rgp L J K t1 t2 k1 k2 k3];
rng(42); digits(50); mx = 0;
for n = 1:5
    v = sym(0.5 + 1.5*rand(1, numel(allv)));
    a = vpa(subs(R.Vin, allv, v)); b = vpa(subs(A.Vin_simp, allv, v));
    mx = max(mx, double(abs(a - b)/abs(b)));
end
fprintf('Max relative difference Vin (ref vs agent), 5 points with W > 0: %.3g\n', mx);
