%% chk_document.m  Checks of the hand-solved part of Deneme_14_model.docx (E1-E19)
cd(fileparts(mfilename('fullpath')));
clear; clc;

%% Assignment
syms Qvad Qgp DP W i Vin real
syms J L K Rbf Rgp a_w a_P t1 t2 positive
syms sgnW real

%% E3 -> E4: dVh1 - dVh2
Vh1_dot = Qvad - Qgp;                    % E3a
Vh2_dot = Qgp - Qvad;                    % E3b
DV_dot_E4 = 2*(Qvad - Qgp);              % E4 (document)
chk.E4 = simplify((Vh1_dot - Vh2_dot) - DV_dot_E4);
fprintf('E3 -> E4 residual: %s\n', char(chk.E4));

%% E5 into E4 -> E10
Qgp_E5 = a_w*W - DP/Rbf;                                 % E5
DV_dot_E10 = 2*Qvad + 2/Rbf*DP - 2*a_w*W;                % E10 (document)
chk.E10 = simplify(subs(DV_dot_E4, Qgp, Qgp_E5) - DV_dot_E10);
fprintf('E4+E5 -> E10 residual: %s\n', char(chk.E10));

%% E8 into E6 -> E11 (K_i = K, J = J_gp)
tau = t1*sgnW + t2*W;                                    % E8
W_dot_E6  = -tau/J + K/J*i - a_P/J*DP;                   % E6
W_dot_E11 = -t1/J*sgnW - a_P/J*DP - t2/J*W + K/J*i;      % E11 (document)
chk.E11 = simplify(W_dot_E6 - W_dot_E11);
fprintf('E6+E8 -> E11 residual: %s\n', char(chk.E11));

%% E7 vs E12 (K_emf = K, L = L_gp, V_in = v_in)
i_dot_E7  = -K/L*W - Rgp/L*i + Vin/L;
i_dot_E12 = -K/L*W - Rgp/L*i + 1/L*Vin;
chk.E12 = simplify(i_dot_E7 - i_dot_E12);
fprintf('E7 vs E12 residual: %s\n', char(chk.E12));

%% f, g definitions (E14-E16) reproduce E10-E12 in strict-feedback form (E17-E19)
syms x1 x2 x3 u real
f1 = 2*Qvad + 2/Rbf*DP;                 % E14a
f2 = -t1*sgnW/J - a_P/J*DP;             % E14b
g1 = -2*a_w; g2 = -t2/J; g3 = K/J;      % E15
g4 = -K/L;   g5 = -Rgp/L; g6 = 1/L;     % E16
x1_dot = f1 + g1*x2;                    % E17
x2_dot = f2 + g2*x2 + g3*x3;            % E18
x3_dot = g4*x2 + g5*x3 + g6*u;          % E19
phys = [x2 x3 u];
val  = [W  i  Vin];
chk.E17 = simplify(subs(x1_dot, phys, val) - DV_dot_E10);
chk.E18 = simplify(subs(x2_dot, phys, val) - W_dot_E11);
chk.E19 = simplify(subs(x3_dot, phys, val) - i_dot_E12);
fprintf('E17 vs E10 residual: %s\n', char(chk.E17));
fprintf('E18 vs E11 residual: %s\n', char(chk.E18));
fprintf('E19 vs E12 residual: %s\n', char(chk.E19));

%% Strict-feedback form
% x1_dot affine in x2 only, x2_dot affine in x3, u only in x3_dot, nonzero gains
sf = [ isequal(diff(x1_dot, x3), sym(0)), isequal(diff(x1_dot, u), sym(0)), ...
       isequal(diff(x2_dot, u), sym(0)), ...
       isequal(diff(x1_dot, x2, 2), sym(0)), isequal(diff(x2_dot, x3, 2), sym(0)), ...
       isequal(diff(x3_dot, u, 2), sym(0)) ];
fprintf('Strict-feedback structure checks: %s\n', mat2str(sf));
fprintf('Coupling gains g1, g3, g6 = %s, %s, %s (nonzero for positive constants)\n', ...
    char(g1), char(g3), char(g6));

%% LaTeX for side_by_side.md
fprintf('\n--- latex() of MATLAB forms ---\n');
names = {'E10 DV_dot','E11 W_dot','E12 i_dot','E14a f1','E14b f2'};
exprs = {DV_dot_E10, W_dot_E11, i_dot_E12, f1, f2};
for n = 1:numel(names)
    fprintf('%s: %s\n', names{n}, latex(exprs{n}));
end

allZero = all(cellfun(@(c) isequal(c, sym(0)), struct2cell(chk)));
fprintf('\nAll document consistency residuals zero: %d\n', allZero);
assert(allZero && all(sf), 'document check failed');
