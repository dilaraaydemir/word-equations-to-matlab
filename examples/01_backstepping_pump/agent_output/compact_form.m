%% compact_form.m  Readable form of the final law, checked against Vin_simp (B3: every short form is asserted)
% Qe = Qvad + DP/Rbf (= f1/2), S = k1+k2+k3, P = k1*k2+k1*k3+k2*k3
cd(fileparts(mfilename('fullpath')));
clear; clc;
load('results.mat');
syms DV W i real
syms Qvad DP Qvad_dot DP_dot Qvad_ddot DP_ddot real
syms a_P a_w Rbf Rgp L J K t1 t2 positive
syms k1 k2 k3 positive
Qe = Qvad + DP/Rbf; Qe_dot = Qvad_dot + DP_dot/Rbf; Qe_ddot = Qvad_ddot + DP_ddot/Rbf;
S = k1 + k2 + k3; P = k1*k2 + k1*k3 + k2*k3;

W_ref_c = (Qe + k1*DV/2)/a_w;
i_ref_c = (J*Qe_dot + J*(k1 + k2)*Qe + a_P*a_w*DP + a_w*t1 + a_w*t2*W ...
          + (2*J*a_w^2 + J*k1*k2/2)*DV - J*a_w*(k1 + k2)*W)/(K*a_w);
N = J^2*Qe_ddot + J^2*S*Qe_dot + (K^2 + 4*J^2*a_w^2 + J^2*P)*Qe ...
    + (K^2*k1/2 + 2*J^2*a_w^2*k3 + J^2*k1*k2*k3/2)*DV ...
    - a_w*(K^2 + t2^2 + 4*J^2*a_w^2 + J^2*P - J*t2*S)*W ...
    + a_w*t1*(J*S - t2) + a_P*a_w*(J*DP_dot + (J*S - t2)*DP) ...
    + K*a_w*(t2 - J*S)*i;
Vin_c = K*W + Rgp*i + L/(J*K*a_w)*N;

r1 = simplify(W_ref_c - W_ref_simp);
r2 = simplify(i_ref_c - i_ref_simp);
r3 = simplify(Vin_c - Vin_simp);
fprintf('compact - full: W_ref %s, i_ref %s, Vin %s\n', char(r1), char(r2), char(r3));
assert(isequal([r1 r2 r3], sym([0 0 0])), 'compact form differs');
fprintf('Compact forms equal the full expressions.\n');
