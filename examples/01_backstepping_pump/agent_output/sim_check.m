%% sim_check.m  ode45 test of the law on the true model (true sgn(omega) in the plant)
% The law uses sgn(omega) = +1 (S7). It is valid only while omega > 0, i.e. while
% W_ref = (Qvad + DP/Rbf + k1*DV/2)/a_w > 0. Two cases test inside and outside that region.
% Test values only (signals and gains are not from the document).
cd(fileparts(mfilename('fullpath')));
clear; clc;

%% Physical values (E9)
P.J = 0.293e-3; P.L = 1.44e-3; P.K = 72.4e-3; P.Rbf = 2.399e9; P.Rgp = 0.48;
P.a_w = 1.59e-6; P.a_P = 3.625e-6; P.t1 = 44.9e-6; P.t2 = 0.3e-3;
P.k1 = 1; P.k2 = 20; P.k3 = 200;                       % test gains
% Test signals: LVAD flow 5 L/min with 1 Hz pulsation, pressure difference 1e4 Pa
Q0 = 5/60000; w0 = 2*pi;
sig = @(t) [Q0*(1 + 0.2*sin(w0*t)), 1e4*(1 + 0.1*sin(w0*t)), ...      % Qvad, DP
            Q0*0.2*w0*cos(w0*t),    1e4*0.1*w0*cos(w0*t), ...          % Qvad_dot, DP_dot
           -Q0*0.2*w0^2*sin(w0*t), -1e4*0.1*w0^2*sin(w0*t)];           % Qvad_ddot, DP_ddot
cases = {'inside  (DV0 = +1e-4 m^3)', [ 1e-4; 40; 0]; ...
         'outside (DV0 = -3e-4 m^3)', [-3e-4; 40; 0]};
opts = odeset('RelTol', 1e-8, 'AbsTol', [1e-10 1e-6 1e-6], 'MaxStep', 1e-3);
for n = 1:size(cases, 1)
    [tt, xx] = ode45(@(t, x) plant(t, x, sig, P), [0 5], cases{n, 2}, opts);
    Vin = zeros(size(tt)); Wr = Vin;
    for m = 1:numel(tt)
        s = sig(tt(m));
        Vin(m) = law(xx(m, :), s, P);
        Wr(m) = W_ref_fun(xx(m, 1), s(1), s(2), P.a_P, P.a_w, P.Rbf, P.Rgp, P.L, P.J, P.K, P.t1, P.t2, P.k1, P.k2, P.k3);
    end
    fprintf('%s\n', cases{n, 1});
    fprintf('  |DV(5 s)| = %.3e m^3, min omega = %.2f rad/s, min W_ref = %.2f rad/s\n', ...
        abs(xx(end, 1)), min(xx(:, 2)), min(Wr));
    fprintf('  max |Vin| = %.2f V (at t = %.3f s), max |i| = %.2f A\n', ...
        max(abs(Vin)), tt(find(abs(Vin) == max(abs(Vin)), 1)), max(abs(xx(:, 3))));
    if min(xx(:, 2)) <= 0
        fprintf('  omega <= 0 reached: sgn(omega) = +1 is wrong there, the Lyapunov proof does not hold.\n');
    end
end

function v = law(x, s, P)
v = Vin_fun(x(1), x(2), x(3), s(1), s(2), s(3), s(4), s(5), s(6), ...
    P.a_P, P.a_w, P.Rbf, P.Rgp, P.L, P.J, P.K, P.t1, P.t2, P.k1, P.k2, P.k3);
end

function dx = plant(t, x, sig, P)
s = sig(t);
v = law(x, s, P);
dx = [2*s(1) + 2/P.Rbf*s(2) - 2*P.a_w*x(2); ...                                        % E10
      -P.t1/P.J*sign(x(2)) - P.a_P/P.J*s(2) - P.t2/P.J*x(2) + P.K/P.J*x(3); ...        % E11, true sgn
      -P.K/P.L*x(2) - P.Rgp/P.L*x(3) + v/P.L];                                          % E12
end
