Adaptive backstepping -- üç bilinmeyen parametre

Sistem:

ẋ1 = x2 + θ1·x1²

ẋ2 = x3 + θ2·x1·x2

ẋ3 = θ3·x3 + u

θ1, θ2, θ3 bilinmeyen, sabit parametrelerdir. x1, x2, x3 ölçülüyor. u kontrol girişidir.

Amaç: x1 → 0 ve bütün sinyaller sınırlı kalsın.

Define

z2 = φ2 − x2, z3 = φ3 − x3 (φ2, φ3: sanal kontroller)

θ̂i: θi'nin tahmini, θ̃i = θi − θ̂i, dθ̃i/dt = −dθ̂i/dt (i = 1, 2, 3)

Choose V = ½x1² + ½z2² + ½z3² + (1/(2γ1))·θ̃1² + (1/(2γ2))·θ̃2² + (1/(2γ3))·θ̃3²

Take derivative of V and subs x2 = φ2 − z2, x3 = φ3 − z3

Rearrange: V̇ = x1·TERM1 + z2·TERM2 + z3·TERM3 + θ̃1·TERM_θ1 + θ̃2·TERM_θ2 + θ̃3·TERM_θ3

Solve for φ2, φ3 and u such that x1·TERM1 = −k1x1², z2·TERM2 = −k2z2², z3·TERM3 = −k3z3² (θi yerine θ̂i kullanılır)

Choose the adaptation laws dθ̂1/dt, dθ̂2/dt, dθ̂3/dt such that TERM_θ1 = TERM_θ2 = TERM_θ3 = 0

Then V̇ = −k1x1² − k2z2² − k3z3² ≤ 0

Take derivative of φ2 and φ3 and obtain u and the adaptation laws in terms of x1, x2, x3 and θ̂1, θ̂2, θ̂3
