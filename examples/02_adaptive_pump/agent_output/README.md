# D12_b_model – Adaptive Backstepping

Önce REPORT.md'yi açın. Simulink için formüller: Vin_fun.m (ayrıca th1h_dot_fun.m ve th2h_dot_fun.m). Türetme: deriv_adaptive.m.

| Dosya | Ne olduğu | Ne zaman açılır |
|---|---|---|
| REPORT.md | Bulunan hatalar, kararlar, son yasa, doğrulama, simülasyon, yazara sorular | ilk |
| deriv_adaptive.m | Türetme (E/T numaralı bölümler) | türetmeyi okumak veya yeniden çalıştırmak için (~6 s) |
| Vin_fun.m | Vin(DV, W, i, th1_hat, th2_hat, Qvad, DP, Qvad_dot, DP_dot, Qvad_ddot, DP_ddot, a_w, a_P, Rbf, Rgp, K, t1, t2, k1, k2, k3, gam1) | Simulink MATLAB Function bloğu |
| th1h_dot_fun.m | θ̂̇1, Vin_fun ile aynı girişler (tuning function dahil) | Simulink: θ̂1 integratörünün girişi |
| th2h_dot_fun.m | θ̂̇2(DV, W, i, th1_hat, Vin, Qvad, DP, Qvad_dot, DP_dot, a_w, a_P, Rbf, Rgp, K, t1, t2, k1, k2, gam2) | Simulink: θ̂2 integratörünün girişi |
| results.mat | Türetilen tüm büyüklükler (W_ref_simp, i_ref_simp, Vin_simp, th1h_dot_simp, th2h_dot_cmp, …) | MATLAB'da kullanmak için |
| checks/ | Kontroller, doğrulamalar, analiz, simülasyon, ham çıktılar | sonucu doğrulamak için |

Notlar:
- Üretilen `*_fun.m` dosyalarındaki `t4`, `t5`, `et1` gibi isimler matlabFunction'ın ara değişkenleridir. Bunlar zaman değildir ve `t1`, `t2` (τ1, τ2) ile ilgileri yoktur.
- Projeksiyon eklenmemiştir. θ̂1 ve θ̂2 sıfıra yaklaşırsa yasa tekil olur. Simulink'te integratöre alt sınır veya projeksiyon ekleyin (REPORT §7).
- Geçerlilik koşulu: ω > 0.
