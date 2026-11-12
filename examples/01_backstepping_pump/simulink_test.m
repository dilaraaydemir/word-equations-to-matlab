%% simulink_test.m
% Builds a Simulink model around the agent's control law (agent_output/Vin_fun.m),
% runs it on the full pump model (including the sgn(omega) friction term) and plots the result.
%
% Usage: cd to this folder in MATLAB and type  simulink_test
% Expected (R2025b): DeltaV goes from 2 mL to ~1e-11 mL, omega stays > 43 rad/s, v_in stays in 0-11 V.

clear; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'agent_output'));
mdl = 'pump_backstepping_sim';
if bdIsLoaded(mdl), close_system(mdl, 0); end
if exist([mdl '.slx'], 'file'), delete([mdl '.slx']); end
assert(exist('Vin_fun', 'file') == 2, 'agent_output/Vin_fun.m not found.');

%% 1) Parameters from Equations_v2 and controller gains
p.J   = 0.293e-3;   % kg.m^2
p.L   = 1.44e-3;    % H
p.K   = 72.4e-3;    % V.s/rad
p.Rbf = 2.399e9;    % Pa.s/m^3
p.Rgp = 0.48;       % ohm
p.a_w = 1.59e-6;    % m^3/rad
p.a_P = 3.625e-6;   % m^3
p.t1  = 44.9e-6;    % N.m
p.t2  = 0.3e-3;     % N.m.s/rad
k     = [20 20 20]; % k1 k2 k3 (chosen gains, not in the document)

%% 2) Test signals: Q_vad and DeltaP oscillating at heart rate (72 bpm)
sg.Q0 = 8.3e-5;  sg.Qa = 0.2*8.3e-5;   % 5 L/min mean, 20% oscillation
sg.P0 = 8000;    sg.Pa = 1300;         % Pa
sg.w  = 2*pi*1.2;                      % rad/s

%% 3) Initial state [DeltaV; omega; i_gp]
w0 = (sg.Q0 + sg.P0/p.Rbf)/p.a_w;                    % speed that keeps DeltaV constant
i0 = (p.t1 + p.a_P*sg.P0 + p.t2*w0)/p.K;             % current that holds this speed
x0 = [2e-6; w0; 0.9*i0];                             % DeltaV(0) = 2 mL, current 10% low

%% 4) Code of the MATLAB Function blocks
sigCode = sprintf([ ...
 'function s = signals(t)\n' ...
 'Q0=%.10g; Qa=%.10g; P0=%.10g; Pa=%.10g; w=%.10g;\n' ...
 's = [Q0+Qa*sin(w*t); P0+Pa*sin(w*t); Qa*w*cos(w*t); Pa*w*cos(w*t); -Qa*w^2*sin(w*t); -Pa*w^2*sin(w*t)];\n'], ...
 sg.Q0, sg.Qa, sg.P0, sg.Pa, sg.w);

ctrlCode = sprintf([ ...
 'function Vin = controller(x, s)\n' ...
 '%% s = [Qvad; DP; Qvad_dot; DP_dot; Qvad_ddot; DP_ddot]\n' ...
 'Vin = Vin_fun(x(1),x(2),x(3),s(1),s(2),s(3),s(4),s(5),s(6), ...\n' ...
 '      %.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g);\n'], ...
 p.a_P, p.a_w, p.Rbf, p.Rgp, p.L, p.J, p.K, p.t1, p.t2, k(1), k(2), k(3));

plantCode = sprintf([ ...
 'function dx = plant(x, Vin, s)\n' ...
 '%% True plant (document E14-E16): DeltaV, omega, i_gp\n' ...
 'J=%.10g; L=%.10g; K=%.10g; Rbf=%.10g; Rgp=%.10g; a_w=%.10g; a_P=%.10g; t1=%.10g; t2=%.10g;\n' ...
 'DV=x(1); W=x(2); i=x(3); Qvad=s(1); DP=s(2);\n' ...
 'dx = zeros(3,1);\n' ...
 'dx(1) = 2*Qvad + 2*DP/Rbf - 2*a_w*W;\n' ...
 'dx(2) = (-t1*sign(W) - a_P*DP - t2*W + K*i)/J;\n' ...
 'dx(3) = (-K*W - Rgp*i + Vin)/L;\n'], ...
 p.J, p.L, p.K, p.Rbf, p.Rgp, p.a_w, p.a_P, p.t1, p.t2);

%% 5) Build the model
new_system(mdl); open_system(mdl);
add_block('simulink/Sources/Clock',                     [mdl '/Clock'],      'Position', [30 100 60 130]);
add_block('simulink/User-Defined Functions/MATLAB Function', [mdl '/Signals'],    'Position', [110 85 210 145]);
add_block('simulink/User-Defined Functions/MATLAB Function', [mdl '/Controller'], 'Position', [300 160 420 220]);
add_block('simulink/User-Defined Functions/MATLAB Function', [mdl '/Plant'],      'Position', [480 60 600 150]);
add_block('simulink/Continuous/Integrator',             [mdl '/Integrator'], 'Position', [660 90 700 130], ...
          'InitialCondition', mat2str(x0, 12));
add_block('simulink/Sinks/Scope',                       [mdl '/Scope'],      'Position', [800 60 840 140], 'NumInputPorts', '2');
add_block('simulink/Sinks/To Workspace',                [mdl '/x_out'],      'Position', [800 170 860 200], ...
          'VariableName', 'x_log', 'SaveFormat', 'Timeseries');
add_block('simulink/Sinks/To Workspace',                [mdl '/vin_out'],    'Position', [800 230 860 260], ...
          'VariableName', 'vin_log', 'SaveFormat', 'Timeseries');

setCode([mdl '/Signals'],    sigCode);
setCode([mdl '/Controller'], ctrlCode);
setCode([mdl '/Plant'],      plantCode);

add_line(mdl, 'Clock/1',      'Signals/1',    'autorouting', 'on');
add_line(mdl, 'Signals/1',    'Controller/2', 'autorouting', 'on');
add_line(mdl, 'Signals/1',    'Plant/3',      'autorouting', 'on');
add_line(mdl, 'Integrator/1', 'Controller/1', 'autorouting', 'on');
add_line(mdl, 'Integrator/1', 'Plant/1',      'autorouting', 'on');
add_line(mdl, 'Integrator/1', 'Scope/1',      'autorouting', 'on');
add_line(mdl, 'Integrator/1', 'x_out/1',      'autorouting', 'on');
add_line(mdl, 'Controller/1', 'Plant/2',      'autorouting', 'on');
add_line(mdl, 'Controller/1', 'Scope/2',      'autorouting', 'on');
add_line(mdl, 'Controller/1', 'vin_out/1',    'autorouting', 'on');
add_line(mdl, 'Plant/1',      'Integrator/1', 'autorouting', 'on');

set_param(mdl, 'StopTime', '3', 'Solver', 'ode45', 'RelTol', '1e-6', 'MaxStep', '1e-3');
save_system(mdl);

%% 6) Run
out = sim(mdl);
t   = out.x_log.Time;
x   = squeeze(out.x_log.Data);  if size(x,1) == 3, x = x.'; end
vin = squeeze(out.vin_log.Data);

%% 7) Results
figure('Name', 'Backstepping pump - Simulink');
subplot(4,1,1); plot(t, x(:,1)*1e6);      ylabel('\DeltaV [mL]'); grid on; title('Simulink: closed loop with Vin\_fun');
subplot(4,1,2); plot(t, x(:,2));          ylabel('\omega [rad/s]'); grid on;
subplot(4,1,3); plot(t, x(:,3));          ylabel('i_{gp} [A]'); grid on;
subplot(4,1,4); plot(t, vin);             ylabel('v_{in} [V]'); xlabel('t [s]'); grid on;

fprintf('\n--- Simulink test ---\n');
fprintf('DeltaV(0)      = %.4f mL\n', x(1,1)*1e6);
fprintf('DeltaV(son)    = %.2e mL\n', x(end,1)*1e6);
fprintf('max |DeltaV|, t > 1 s = %.2e mL\n', max(abs(x(t > 1, 1)))*1e6);
fprintf('min omega      = %.2f rad/s (must stay positive)\n', min(x(:,2)));
fprintf('v_in range      = [%.2f, %.2f] V\n', min(vin), max(vin));
if abs(x(end,1)) < 1e-3*abs(x(1,1)) && min(x(:,2)) > 0
    fprintf('RESULT: DeltaV went to zero and omega stayed positive. The control law works in Simulink.\n');
else
    fprintf('RESULT: unexpected behaviour, check the plots.\n');
end

%% Helper: writes the code of a MATLAB Function block
function setCode(blk, code)
    try
        cfg = get_param(blk, 'MATLABFunctionConfiguration');
        cfg.FunctionScript = code;
    catch
        rt = sfroot;
        ch = rt.find('-isa', 'Stateflow.EMChart', 'Path', blk);
        ch.Script = code;
    end
end
