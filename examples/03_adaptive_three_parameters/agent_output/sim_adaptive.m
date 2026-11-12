%% sim_adaptive.m - ode45 comparison: tuning functions vs plain laws (test values from the user, S7)
cd(fileparts(mfilename('fullpath')));
clear; clc;

th   = [1 -0.5 2];          % true parameters (used ONLY in the plant)
k    = [1 1 1];
gam  = [1 1 1];
x0   = [1 0.5 -0.5];
thh0 = [0 0 0];
Tend = 20;
p    = num2cell([k gam]);

designs = {'tuning', @u_fun, @thetahat_dot_fun; 'plain', @u_plain_fun, @thetahat_dot_plain_fun};
opts = odeset('RelTol', 1e-9, 'AbsTol', 1e-11, 'Events', @blowup);
fig = figure('Visible', 'off', 'Position', [100 100 1100 800]);
for d = 1:2
    ufun = designs{d, 2}; tfun = designs{d, 3};
    rhs  = @(t, s) plant(s, th, ufun, tfun, p);
    [t, s, te] = ode45(rhs, [0 Tend], [x0 thh0], opts);
    n  = numel(t);
    u  = zeros(n, 1); V = zeros(n, 1);
    for j = 1:n
        sj = num2cell(s(j, :));
        u(j) = ufun(sj{:}, p{:});
        ph2 = phi2_fun(sj{:}, p{:});
        ph3 = phi3_fun(sj{:}, p{:});
        if d == 2, ph3 = phi3_plain(s(j, :), p); end
        V(j) = s(j,1)^2/2 + (ph2 - s(j,2))^2/2 + (ph3 - s(j,3))^2/2 + sum((th - s(j, 4:6)).^2./(2*gam));
    end
    dV = diff(V);
    fprintf('--- %s laws ---\n', designs{d, 1});
    if ~isempty(te), fprintf('  stopped at t = %.4g s (|state| > 1e6)\n', te(1)); end
    fprintf('  t_end = %.4g s, x(t_end) = [%.3g %.3g %.3g], theta_hat(t_end) = [%.4g %.4g %.4g]\n', t(end), s(end, 1:6));
    fprintf('  max|x1| = %.4g, max|x2| = %.4g, max|x3| = %.4g, max|u| = %.4g\n', max(abs(s(:, 1:3))), max(abs(u)));
    fprintf('  V(0) = %.4g, V(t_end) = %.4g, largest increase of V between steps = %.3g\n', V(1), V(end), max([dV; 0]));
    fprintf('  |theta - theta_hat(t_end)| = [%.3g %.3g %.3g]\n', abs(th - s(end, 4:6)));
    subplot(3, 2, d);   plot(t, s(:, 1:3)); grid on; title([designs{d, 1} ': states']); legend('x1', 'x2', 'x3');
    subplot(3, 2, 2+d); plot(t, s(:, 4:6), t, th.*ones(n, 1), ':'); grid on; title([designs{d, 1} ': \theta-hat (dotted: \theta)']);
    subplot(3, 2, 4+d); plot(t, V, t, u/max(abs(u))*max(V), '--'); grid on; title([designs{d, 1} ': V and u (scaled)']); legend('V', 'u scaled');
end
exportgraphics(fig, 'sim_adaptive.png');
fprintf('Figure: sim_adaptive.png\n');

function ds = plant(s, th, ufun, tfun, p)
sc = num2cell(s(:).');
u  = ufun(sc{:}, p{:});
ds = [s(2) + th(1)*s(1)^2; s(3) + th(2)*s(1)*s(2); th(3)*s(3) + u; tfun(sc{:}, p{:})];
end

function ph3 = phi3_plain(s, p)
persistent f
if isempty(f)
    R = load('results.mat', 'phi3_p_simp');
    syms X1 X2 X3 TH1h TH2h TH3h k1 k2 k3 g1 g2 g3 real
    f = matlabFunction(R.phi3_p_simp, 'Vars', {X1, X2, X3, TH1h, TH2h, TH3h, k1, k2, k3, g1, g2, g3});
end
sc  = num2cell(s);
ph3 = f(sc{:}, p{:});
end

function [val, term, dir] = blowup(~, s)
val = 1e6 - max(abs(s)); term = 1; dir = -1;
end
