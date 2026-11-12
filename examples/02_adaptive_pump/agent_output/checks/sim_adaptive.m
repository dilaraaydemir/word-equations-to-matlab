cd(fileparts(mfilename('fullpath')));
% Closed-loop simulation without projection: tuning-function law (Vin_fun, th1h_dot_fun, th2h_dot_fun)
% against the document law (E36, E38_corr, E40, no tuning term). th_hat(0) = 0.5*th and 1.5*th.
addpath('..');
D = load('doc_law.mat');

%% Physical values (E9-E12)
P.J = 0.293e-3; P.L = 1.44e-3; P.K = 72.4e-3; P.Rbf = 2.399e9; P.Rgp = 0.48;
P.a_w = 1.59e-6; P.a_P = 3.625e-6; P.t1 = 44.9e-6; P.t2 = 0.3e-3;
P.k1 = 5; P.k2 = 20; P.k3 = 200; P.gam1 = 1e4; P.gam2 = 1e3;
th_true = [1/P.J, 1/P.L];

%% Signals: VAD flow and pressure difference (1 Hz pulsation)
wf = 2*pi;
sig = @(t) [8.3e-5 + 2e-5*sin(wf*t), 1.07e4 + 2e3*sin(wf*t), ...
            2e-5*wf*cos(wf*t), 2e3*wf*cos(wf*t), -2e-5*wf^2*sin(wf*t), -2e3*wf^2*sin(wf*t)];  % Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot

%% Document law as numeric functions
syms DV W i th1_hat th2_hat F1 F1dot F1ddot F2 F2dot g1 g2 g3 g4 g5 real
syms Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot real
syms a_P a_w Rbf Rgp K t1 t2 k1 k2 k3 gam1 positive
abs_syms  = [F1 F1dot F1ddot F2 F2dot g1 g2 g3 g4 g5];
phys_vals = [2*Qvad + 2*DP/Rbf, 2*Qvad_dot + 2*DP_dot/Rbf, 2*Qvad_ddot + 2*DP_ddot/Rbf, -t1 - a_P*DP, -a_P*DP_dot, -2*a_w, -t2, K, -K, -Rgp];
in_vars = {DV, W, i, th1_hat, th2_hat, Qvad, DP, Qvad_dot, DP_dot, Qvad_ddot, DP_ddot, a_w, a_P, Rbf, Rgp, K, t1, t2, k1, k2, k3, gam1};
Vin_doc_fun      = matlabFunction(subs(D.Vin_doc_abs, abs_syms, phys_vals), 'Vars', in_vars);
th1h_dot_doc_fun = matlabFunction(subs(D.th1h_dot_doc_abs, abs_syms, phys_vals), 'Vars', in_vars);
syms th1 positive
res_doc_fun = matlabFunction(subs(D.res_doc, abs_syms, phys_vals), 'Vars', [in_vars, {th1}]);   % Vdot residual of the document law

R = load(fullfile('..', 'results.mat'));
P.i_ref = matlabFunction(R.i_ref_simp, 'Vars', in_vars);   % same expression as in deriv_adaptive.m
laws.tf  = struct('Vin', @Vin_fun, 'th1d', @th1h_dot_fun, 'name', 'tuning function');
laws.doc = struct('Vin', Vin_doc_fun, 'th1d', th1h_dot_doc_fun, 'name', 'document (E38_corr)');

%% Runs
x0_phys = [2e-6, 60, 0.6];                              % DV [m^3], W [rad/s], i [A]
opts = odeset('RelTol', 1e-8, 'AbsTol', [1e-13 1e-7 1e-8 1e-3 1e-3], 'Events', @(t, x) theta_event(x));
Tend = 5;
fprintf('Solver ode15s (L/R = %.1f ms next to mechanical/adaptive dynamics: stiff), horizon %g s\n', 1e3*P.L/P.Rgp, Tend);
fprintf('Gains k1 k2 k3 = %g %g %g, gam1 gam2 = %g %g, no projection\n', P.k1, P.k2, P.k3, P.gam1, P.gam2);
res = struct();
fig = figure('Visible', 'off', 'Position', [100 100 1100 800]);
cases = [0.5 1.5];
lawNames = {'tf', 'doc'};
for c = 1:numel(cases)
    for l = 1:2
        lw = laws.(lawNames{l});
        x0 = [x0_phys, cases(c)*th_true];
        tic;
        [tt, xx, te] = ode15s(@(t, x) plant(t, x, P, sig, lw), [0 Tend], x0, opts);
        cpu = toc;
        stopTxt = '';
        if ~isempty(te)
            stopTxt = sprintf(', STOPPED at t = %.4f s (th_hat <= 1%% of th)', te(1));
        end
        [Vin_t, V_t, z2_t, z3_t] = deal(zeros(size(tt)));
        for n = 1:numel(tt)
            [~, Vin_t(n), V_t(n), z2_t(n), z3_t(n)] = plant(tt(n), xx(n, :).', P, sig, lw);
        end
        late = tt > 1;
        docTxt = '';
        if strcmp(lawNames{l}, 'doc')
            [r, tg] = deal(zeros(size(tt)));
            for n = 1:numel(tt)
                sv = num2cell(sig(tt(n)));
                r(n)  = res_doc_fun(xx(n, 1), xx(n, 2), xx(n, 3), xx(n, 4), xx(n, 5), sv{:}, P.a_w, P.a_P, P.Rbf, P.Rgp, P.K, P.t1, P.t2, P.k1, P.k2, P.k3, P.gam1, th_true(1));
                tg(n) = -P.k1*xx(n, 1)^2 - P.k2*z2_t(n)^2 - P.k3*z3_t(n)^2;
            end
            docTxt = sprintf('  document law: max |residual|/|target| = %.3e, fraction of samples with Vdot > 0 = %.3f\n', max(abs(r)./max(abs(tg), realmin)), mean(tg + r > 0));
        end
        dV = diff(V_t);
        fprintf(['\n[%s, th_hat(0) = %.1f*th]  cpu %.1f s, steps %d%s\n' ...
                 '  max|DV| t>1 s = %.3e m^3, max|z2| t>1 s = %.3e rad/s, max|z3| t>1 s = %.3e A\n' ...
                 '  max|Vin| = %.3f V (t>0.05 s: %.3f V), min th1_hat/th1 = %.3f, min th2_hat/th2 = %.3f\n' ...
                 '  final th1_hat/th1 = %.3f, th2_hat/th2 = %.3f, V(0) = %.3e, V(end) = %.3e, max increase of V per step = %.3e\n'], ...
            lw.name, cases(c), cpu, numel(tt), stopTxt, ...
            max(abs(xx(late, 1))), max(abs(z2_t(late))), max(abs(z3_t(late))), ...
            max(abs(Vin_t)), max(abs(Vin_t(tt > 0.05))), min(xx(:, 4))/th_true(1), min(xx(:, 5))/th_true(2), ...
            xx(end, 4)/th_true(1), xx(end, 5)/th_true(2), V_t(1), V_t(end), max([dV; 0]));
        fprintf('%s', docTxt);
        res.(sprintf('c%d_%s', c, lawNames{l})) = struct('t', tt, 'x', xx, 'Vin', Vin_t, 'V', V_t);
        subplot(3, 2, c);       plot(tt, z2_t, 'DisplayName', lw.name); hold on; ylabel('z_2 [rad/s]'); title(sprintf('\\theta(0) = %.1f\\theta', cases(c)));
        subplot(3, 2, 2 + c);   semilogy(tt, max(V_t, 1e-16), 'DisplayName', lw.name); hold on; ylabel('V');
        subplot(3, 2, 4 + c);   plot(tt, xx(:, 4)/th_true(1), 'DisplayName', [lw.name ' \theta_1']); hold on;
        plot(tt, xx(:, 5)/th_true(2), '--', 'DisplayName', [lw.name ' \theta_2']); ylabel('\theta-hat / \theta'); xlabel('t [s]');
    end
end
for s = 1:6
    subplot(3, 2, s); legend('Location', 'best'); grid on;
end
exportgraphics(fig, 'sim_adaptive.png');
close(fig);
save('sim_results.mat', 'res', 'P');

%% Local functions
function [dx, Vin, V, z2, z3] = plant(t, x, P, sig, lw)
s = num2cell(sig(t));
[Qvad, DP] = s{1:2};
DVv = x(1); Wv = x(2); iv = x(3); th1h = x(4); th2h = x(5);
args = {DVv, Wv, iv, th1h, th2h, s{:}, P.a_w, P.a_P, P.Rbf, P.Rgp, P.K, P.t1, P.t2, P.k1, P.k2, P.k3, P.gam1};
Vin  = lw.Vin(args{:});
th1d = lw.th1d(args{:});
th2d = th2h_dot_fun(DVv, Wv, iv, th1h, Vin, s{1:4}, P.a_w, P.a_P, P.Rbf, P.Rgp, P.K, P.t1, P.t2, P.k1, P.k2, P.gam2);
dx = [2*Qvad + 2*DP/P.Rbf - 2*P.a_w*Wv;                   % E14
      (-P.t1 - P.a_P*DP - P.t2*Wv + P.K*iv)/P.J;           % E15, W > 0
      (-P.K*Wv - P.Rgp*iv + Vin)/P.L;                      % E16
      th1d;
      th2d];
W_ref = (2*Qvad + DVv*P.k1 + 2*DP/P.Rbf)/(2*P.a_w);   % W_ref_simp
z2 = W_ref - Wv;
i_ref = P.i_ref(args{:});
z3 = i_ref - iv;
V = DVv^2/2 + z2^2/2 + z3^2/2 + (th1h - 1/P.J)^2/(2*P.gam1) + (th2h - 1/P.L)^2/(2*P.gam2);
end

function [value, isterminal, direction] = theta_event(x)
value = [x(4) - 0.01/0.293e-3; x(5) - 0.01/1.44e-3];    % th_hat reaches 1 % of the true value
isterminal = [1; 1];
direction = [-1; -1];
end
