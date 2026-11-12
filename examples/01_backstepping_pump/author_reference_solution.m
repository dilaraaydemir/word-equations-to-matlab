%
clear
clc

%% Assignment
syms t real
syms x1(t) x2(t) x3(t) real
syms f1(t) f2(t) g1 g2 g3 g4 g5 g6 u real
syms f1dot(t) f2dot(t) real
syms f1ddot f2ddot real
syms k1 k2 k3 real
syms z2(t) z3(t) real
syms phi2 phi3 real
syms phi2_dot phi3_dot  real


%% Define system
x1_dot=f1+g1*x2;
x2_dot=f2+g2*x2+g3*x3;
x3_dot=g4*x2+g5*x3+g6*u;

%% Define new system dynamics
x2 = phi2-z2;
x3 = phi3-z3;

z2_dot = phi2_dot - x2_dot;
z3_dot = phi3_dot - x3_dot;

%% Subs 
x1_dot=simplify(subs(x1_dot));   
z2_dot=simplify(subs(z2_dot));
z3_dot=simplify(subs(z3_dot)); 

%% Define and rearrange terms
term1 = subs(x1_dot,{z2 z3},{0 0}); 
x1_z2_coe=simplify(subs(x1_dot-term1,z3,0))*x1/z2;
x1_z3_coe=simplify(subs(x1_dot-term1,z2,0))*x1/z3;

term2_p = subs(z2_dot,z3,0); 
z2_z3_coe=simplify(z2_dot-term2_p)*z2/z3;
term2=term2_p + x1_z2_coe;

term3 = z3_dot + x1_z3_coe + z2_z3_coe;

%% Solve for xr and u
phi2=subs(rhs(isolate(term1==-k1*x1,phi2)));  
phi3=subs(rhs(isolate(term2==-k2*z2,phi3))); 
u  =subs(rhs(isolate(term3==-k3*z3,u)));  

%% Solve for xr dot
phi2_dot=diff(phi2,t);
phi2_dot = subs(phi2_dot,{diff(x1(t), t),diff(x2(t), t),diff(x3(t), t), diff(z2(t), t),diff(z3(t), t),diff(f1(t), t),diff(f2(t), t),diff(f1dot(t), t),diff(f2dot(t), t)},{x1_dot,x2_dot,x3_dot,z2_dot,z3_dot,f1dot,f2dot,f1ddot,f2ddot});
phi2_dot = subs(phi2_dot); 
phi3_dot=diff(subs(phi3),t);
phi3_dot = subs(phi3_dot,{diff(x1(t), t),diff(x2(t), t),diff(x3(t), t), diff(z2(t), t),diff(z3(t), t),diff(f1(t), t),diff(f2(t), t),diff(f1dot(t), t),diff(f2dot(t), t)},{x1_dot,x2_dot,x3_dot,z2_dot,z3_dot,f1dot,f2dot,f1ddot,f2ddot});
phi3_dot = subs(phi3_dot); 
%% symfun to sym
syms  X1 X2 X3  F1 F2 F1dot F2dot
x1(t)=X1; x2(t)=X2; x3(t)=X3;
f1(t)=F1; f2(t)=F2; 
f1dot(t)=F1dot; f2dot(t)=F2dot; 
z2(t)=phi2-X2; z3(t)=phi3-X3;

%% Subs
for ii=1:5
phi2=subs(phi2); %symvar(x2r)
phi3=subs(phi3); %symvar(x3r)

phi2_dot=subs(phi2_dot); %symvar(e2dot)
phi3_dot=subs(phi3_dot); %symvar(e3dot)
end

for ii=1:5
u = subs(u); %symvar(u)
end

%%
syms DV W i
syms Qvad DP a_P a_w Rbf Rgp 
syms L J K t1 t2
syms Qvad_dot DP_dot
syms Qvad_ddot DP_ddot



X1=DV; X2=W; X3=i;
F1=2*Qvad+(2/Rbf)*DP ; F2=-(t1/J)*sign(W)-(a_P/J)*DP;
F1dot=2*Qvad_dot+(2/Rbf)*DP_dot; F2dot=-(a_P/J)*DP_dot; 
f1ddot = 2*Qvad_ddot + (2/Rbf)*DP_ddot;   % isaret F1 ile ayni olmali
f2ddot = -(a_P/J)*DP_ddot;

g1=-2*a_w; g2=-(t2/J); g3=K/J; g4=-K/L; g5=-Rgp/L; g6=1/L;

W_ref=subs(phi2); % symvar(QVAD_ref)
i_ref=subs(phi3); % symvar(si_ref)
Vin=subs(u); 

W_ref_simp=simplify(W_ref);
i_ref_simp=simplify(i_ref);
Vin_simp=simplify(Vin);

