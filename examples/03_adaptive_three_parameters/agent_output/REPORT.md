# REPORT - D13_b_model.docx

## 1. Belge, kapsam, kararlar
- Belge: `D13_b_model.docx` (kopyası `source/`), tek bölüm: *Adaptive backstepping -- üç bilinmeyen parametre*.
- Çıktı klasörü: `D13_b_model_2026-11-13_003254/`. MATLAB R2025b, Symbolic Math Toolbox 25.2.
- Kararlar (ayrıntı `inventory.md`):
  - S1 belgenin tamamı; S2 adım yorumu T1–T6 kabul.
  - **S3 (a) tuning functions**; belgedeki saf yasalarla kalan fark ayrıca gösterildi (bölüm 5).
  - S4 V = E6, z = φ − x; S5 −x1·z2 → TERM2, z2·z3 → TERM3.
  - S6 k1..3, γ1..3 > 0; θi sabit, işareti bilinmiyor; regülasyon x1 → 0; projeksiyon gerekmez.
  - S7 `u_fun.m`, `thetahat_dot_fun.m`, `phi2_fun.m`, `phi3_fun.m`; ode45 karşılaştırması; gerçek θ'nın yasalarda olmadığına dair assert.

## 2. Elle çözülmüş kısımda bulunan hatalar
Hata bulunmadı (`chk_document.m`, `side_by_side.md`):
- E1 sistemi parametrik strict-feedback formunda (x2, x3 doğrusal, katsayı 1; u yalnızca son denklemde).
- E4 tersleri (x2 = φ2 − z2, x3 = φ3 − z3) tutarlı; E5b doğru (θ sabit).
- E6 V pozitif tanımlı (Hessian diag(1,1,1,1/γ1,1/γ2,1/γ3)); E7 hedef V̇ ≤ 0.

**Yöntem notu (hata değil):** θ1 ve θ2 son denklemden önce göründüğü için φ2 = φ2(x1, θ̂1), φ3 = φ3(x1, x2, θ̂1, θ̂2) olur ve φ̇2, φ̇3 içine θ̂̇ girer. TERM_θi = 0'dan gelen yasa z3'e (x3'e) bağlıdır; φ3'te doğrudan kullanılamaz (döngüsel). Belgedeki "TERM_θ = 0" adımı ancak tuning functions ile tam tutarlıdır.

## 3. Adımlar
Notasyon: w1 = [x1², 0, 0]ᵀ, Γ = diag(γ1, γ2, γ3).

| Adım | Ne yapıldı | Sonuç | Doğrulama |
|---|---|---|---|
| T1 | V = E6 | — | pozitif tanımlı |
| T2 | V̇ gerçek dinamik boyunca, θ = θ̂ + θ̃, x2 = φ2 − z2, x3 = φ3 − z3 | — | ayrışma assert'leri (her adım + toplam) = 0 |
| T3 | V̇ = x1·TERM1 + z2·TERM2 + z3·TERM3 + Σθ̃i·TERM_θi; katsayılar `jacobian`/`diff` ile (hata değişkenine bölme yok) | TERM_θ = x1·w1 + z2·ω2 + z3·ω3 − Γ⁻¹θ̂̇ | `simplify(Vdot − Σ) == 0` |
| T4a | TERM1 = −k1x1 → φ2 | φ2 = −x1(k1 + θ̂1x1) | x1·TERM1 = −k1x1² ✔ |
| T4b | TERM2 = −k2z2, θ̂̇ yerine τ2 = Γ(x1w1 + z2ω2), ω2 = [∂φ2/∂x1·x1², −x1x2, 0]ᵀ | φ3 = −x1 + ∂φ2/∂x1(x2 + θ̂1x1²) + ∂φ2/∂θ̂·τ2 − θ̂2x1x2 + k2z2 | z2·TERM2 = −k2z2² ✔ |
| T5 | TERM_θi = 0 → `isolate` | θ̂̇ = τ3 = τ2 + Γz3ω3, ω3 = [∂φ3/∂x1·x1², ∂φ3/∂x2·x1x2, −x3]ᵀ | = τ3 ✔ |
| T4c | TERM3 = −k3z3 (çapraz terimler z2 ve z2·∂φ2/∂θ̂·Γω3 dahil) | u (aşağıda) | tam kapalı çevrim ✔ |
| T6 | φ̇2, φ̇3 zincir kuralıyla; placeholder'lar her `diff` öncesi çözüldü; z2, z3, φ yerine kondu | u, θ̂̇ yalnızca x1..3, θ̂1..3, k, γ cinsinden | φ̇2, φ̇3 bağımsız zincir kuralı ile aynı ✔ |

**Tam kapalı çevrim kontrolü** (`verify_adaptive.m`): V = ½x1² + ½z2² + ½z3² + Σ(θi − θ̂i)²/(2γi), gerçek θ ile dinamik boyunca V̇ hesaplandı:
`simplify(Vdot − (−k1x1² − k2z2² − k3z3²)) = 0` ✔. Toplam 10 kontrol geçti.

## 4. Nihai kontrol yasası
Yapısal (okunabilir) form, z2 = φ2 − x2, z3 = φ3 − x3:

- φ2 = −x1·(k1 + θ̂1·x1)
- φ3 = −x1 + ∂φ2/∂x1·(x2 + θ̂1x1²) + ∂φ2/∂θ̂1·τ2,1 − θ̂2x1x2 + k2z2, ∂φ2/∂x1 = −k1 − 2θ̂1x1, ∂φ2/∂θ̂1 = −x1²
- Açık polinom: φ3 = −2θ̂1²γ1x1⁷ − 3θ̂1γ1k1x1⁶ − 2θ̂1γ1x1⁵x2 − γ1(k1² + 1)x1⁵ − γ1k1x1⁴x2 − 2θ̂1²x1³ − θ̂1(k1 + k2)x1² − (2θ̂1 + θ̂2)x1x2 − (k1k2 + 1)x1 − (k1 + k2)x2
- θ̂̇ = Γ·(x1·w1 + z2·ω2 + z3·ω3), açık hali:
  - θ̂̇1 = γ1·x1²·(x1 + z2·∂φ2/∂x1 + z3·∂φ3/∂x1)
  - θ̂̇2 = γ2·x1x2·(−z2 + z3·∂φ3/∂x2)
  - θ̂̇3 = −γ3·z3·x3
- **u = k3z3 + z2 + z2·(∂φ2/∂θ̂)·Γ·ω3 + ∂φ3/∂x1·(x2 + θ̂1x1²) + ∂φ3/∂x2·(x3 + θ̂2x1x2) + (∂φ3/∂θ̂)·θ̂̇ − θ̂3x3**

Tamamen açılmış polinom formları (u: 10521 karakter, θ̂̇: 3502 karakter) `analysis_results.md` ve `results.mat` (`u_simp`, `thd_simp`) içinde. Simulink dosyaları daha kısa iç içe formdan üretildi (`u_compact`, `thd_compact`). Açık formla farkları sembolik olarak 0, 5 rastgele noktada maks. bağıl fark 4.6e−16.

- **Gerekli sinyaller:** yalnızca x1, x2, x3 ve θ̂1, θ̂2, θ̂3 (adaptasyon yasasının integralinden). Türev sinyali gerekmez.
- **Simulink giriş sırası (4 dosyada aynı):** `(x1, x2, x3, th1h, th2h, th3h, k1, k2, k3, g1, g2, g3)`. `thetahat_dot_fun` 3×1 vektör döndürür; üç integratörle θ̂ elde edilir (θ̂(0) serbest).
- **Tekillik / 0/0:** hiçbir ifadede payda yok (saf polinom). Tekillik ve 0/0 yok, `limit` gerekmedi. θ̂'ye bölme olmadığından projeksiyon gerekmiyor.
- **Gerçek parametreler:** θ1..3 ve θ̃ ifadesinin φ2, φ3, u ve θ̂̇ içinde olmadığı deriv ve verify'de assert ile kontrol edildi ✔.
- **Kararlılık iddiası:** V̇ = −k1x1² − k2z2² − k3z3² ≤ 0, bu yüzden x, θ̂ sınırlıdır; Barbalat ile x1, z2, z3 → 0 ve dolayısıyla x2, x3 → 0. **V̇ ≤ 0, kalıcı uyarım olmadan θ̂ → θ anlamına gelmez** (simülasyonda θ̂ ≠ θ ile durdu).

## 5. Saf yasalarla fark (belgenin "tuning functions'sız" okunuşu)
Saf yasalar: her θ̃i yalnız kendi adımında sıfırlanır.
- θ̂̇1 = γ1x1³, θ̂̇2 = −γ2z2x1x2, θ̂̇3 = −γ3z3x3; φ3 ve u bu yasalarla (certainty equivalence).
- Tuning yasasından fark: φ3,plain − φ3,tuning = γ1·x1⁴·(k1 + 2θ̂1x1)·(x2 + k1x1 + θ̂1x1²).
- Kapalı çevrimde: V̇ = −k1x1² − k2z2² − k3z3² + **R**, burada
  **R = θ̃1·x1²·(z2·∂φ2/∂x1 + z3·∂φ3/∂x1) + θ̃2·z3·∂φ3/∂x2·x1x2** (θ̃3 terimi tam sıfırlanır).
- R işareti belirsizdir. Kullanıcının test değerleriyle t = 0'da R = 24.25 ve hedef kısım = −15.5 olduğundan **V̇(0) = +8.75 > 0**. Saf yasalarla Lyapunov ispatı yok.

**ode45 karşılaştırması** (`sim_adaptive.m`, `sim_adaptive.png`). Test değerleri: θ = (1, −0.5, 2), k = γ = 1, θ̂(0) = 0, x(0) = (1, 0.5, −0.5), 20 s, RelTol 1e−9.

| | tuning functions | saf yasalar |
|---|---|---|
| x(20) | (1.4e−4, 3.7e−4, −3.8e−4) | (1.0e−2, −6.1e−3, −3.3e−4) |
| θ̂(20) | (2.06, 0.96, 5.36) | (0.65, −3.87, 8.67) |
| max\|x3\| | 91.4 | 25.3 |
| max\|u\| | **4.67e4** (t < 0.5 s) | 228 |
| V(0) → V(20) | 16.75 → 7.27, **hiç artmıyor** | 10.38 → 28.01, **artıyor** (en büyük adım artışı 0.215; tepe ≈ 65) |

Yorum:
- Tuning functions'ta V monoton azalıyor (teoriyle uyumlu).
- Saf yasalarla V artıyor. Bu başlangıç koşulunda durumlar yine de sıfıra yaklaştı, ama garanti yok.
- **Uyarı:** tuning tasarımında ilk 0.5 s'de |u| ≈ 4.7e4. Bu tepe, x1'in yüksek kuvvetlerinden (u'da x1²² terimleri, γ1 çarpanlı) geliyor. Gerçek aktüatörde satürasyon beklenir.
- Daha küçük γ1 ya da k değerleri bu tepeyi düşürür. Satürasyon altındaki kararlılık bu analizin kapsamı dışında.
- θ̂ hiçbir tasarımda θ'ya yakınsamadı (regülasyonda kalıcı uyarım yok).

## 6. Referans karşılaştırması
Referans kod verilmedi (S7).

## 7. Dış sorular (yazar için)
1. Belgedeki "TERM_θ = 0" adımı tuning functions olarak mı kastedildi? Saf yasalar V̇ ≤ 0 vermez (bölüm 5).
2. u'daki tepe değer kabul edilebilir mi, yoksa aktüatör sınırı ve γ/k ayarı için ek bir çalışma mı yapılacak?
3. Parametre yakınsaması (θ̂ → θ) da bir amaç mı? O durumda referans/uyarım sinyali gerekir.

## 8. Klasördeki dosyalar
- `source/D13_b_model.docx`, `source/equations.md`: belgenin kopyası, pandoc çıktısı.
- `inventory.md`: bölümler, E/T listeleri, sembol tablosu, S-kararları.
- `side_by_side.md`: belge denklemleri ile MATLAB `latex()` yan yana.
- `chk_document.m`: elle çözülmüş kısmın kontrolleri.
- `deriv_adaptive.m`: türetme (tuning functions ve saf yasalar), sadeleştirme, fonksiyon üretimi.
- `verify_adaptive.m`: 10 kontrol (bracket'ler, τ3, φ̇, tam kapalı çevrim, saf yasa artığı R, rastgele nokta testi, paydalar).
- `sim_adaptive.m`, `sim_adaptive.png`: ode45 karşılaştırması.
- `analysis_results.md`: tüm script çıktıları (zaman damgalı, ekleme ile).
- `results.mat`: tüm sembolik sonuçlar (soyut/sadeleştirilmiş/kompakt; tuning ve saf).
- `u_fun.m`, `thetahat_dot_fun.m`, `phi2_fun.m`, `phi3_fun.m`: Simulink fonksiyonları (tuning functions).
- `u_plain_fun.m`, `thetahat_dot_plain_fun.m`: saf yasalar (yalnızca karşılaştırma için).
- `run_and_log.m`: script'leri çalıştırıp çıktıyı `analysis_results.md`'ye ekleyen yardımcı.
