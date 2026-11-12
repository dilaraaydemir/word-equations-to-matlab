# Rapor: D12_b_model.docx – Adaptive Backstepping

## 1. Belge, kapsam, kararlar
- Belge: `D12_b_model.docx` (kopyası `checks/source/`, pandoc çıktısı `checks/source/equations.md`).
- Kapsam: "Adaptive Backstepping" bölümü (E17–E40), adımlar T1–T7 (`checks/inventory.md`).
- Çıktı klasörü: `D12_b_model_2026-11-13_005946/`.
- Kararlar:

| No | Karar |
|---|---|
| S1 | Kapsam ve T1–T7 adımları onaylandı |
| S2 | f1 = 2Qvad **+** (2/Rbf)ΔP kullanıldı (E17a_corr) |
| S3 | V'de ½z3² kullanıldı (E27_corr) |
| S4 | z2·z3 çapraz terimlerinde düzeltilmiş işaretler kullanıldı (E29_corr, E38_corr) |
| S5 | Ana sonuç tuning-function yasası. Belgedeki yasanın V̇ artığı aşağıda veriliyor |
| S6 | ω > 0, sgn(ω) = +1 alındı (dirac terimi oluşmuyor) |
| S7 | Qvad ve ΔP ölçülen sinyaller, 2. türeve kadar biliniyor. f_i yalnızca zamana bağlı. Hedef regülasyon: x1 = ΔVh → 0 |
| S8 | k1..k3, γ1, γ2, θ1, θ2 > 0; α_ω ≠ 0, K ≠ 0 |
| S9 | Türetme ve simülasyon projeksiyonsuz yapıldı. Projeksiyon önerisi §7'de |
| S10 | Çıktılar: `Vin_fun.m`, `th1h_dot_fun.m`, `th2h_dot_fun.m`. Sayısal değer yerine konmadı. Referans çözüm yok |
| ek | Gerçek θ1, θ2 (J, L) son yasalarda yer almıyor; assert ile doğrulandı |
| ek | Simülasyonda θ̂(0) = 0.5θ ve 1.5θ; belgedeki yasa ile tuning-function yasası karşılaştırıldı |

## 2. Belgenin çözülmüş kısmındaki hatalar
Kontrol betiği `checks/chk_document.m`, sonuçlar `checks/analysis_results.md` içinde. Belge ile karşılaştırma `checks/side_by_side.md`'de.

| Denklem | Sorun | Düzeltilmiş hali | Sonucu |
|---|---|---|---|
| E17a | f1 = 2Qvad − (2/Rbf)ΔP. E4 ve E5'ten türetilen E14 ise **+** veriyor: f1 + g1ω − E14 = −4ΔP/Rbf | f1 = 2Qvad + (2/Rbf)ΔP | Son Vin'de ΔP, ΔṖ ve ΔP̈ terimlerinin işaretini değiştirir. Belgedeki f1 ile model ẋ1'i yanlış verir; ΔP ≈ 10⁴ Pa'da ẋ1 hatası 4ΔP/Rbf ≈ 1.8·10⁻⁵ m³/s (Qvad'ın ~%20'si) |
| E27 | V'de ½z3³ var. V(z3 = −1) = −½ olduğu için V pozitif tanımlı değil | ½z3² | Belgenin kendi V̇ ifadesi (z3·ż3) zaten ½z3²'ye karşılık geliyor; bu yazım hatası |
| E29 | z3 parantezinde −θ̂1g3z2, θ̃1 parantezinde +g3z2z3 var. Hesap: E28 − E29 = 2·g3·z2·z3·(θ̂1 − θ̃1) | z3[… **+**θ̂1g3z2 …], θ̃1(… **−**g3z2z3) | — |
| E36 | Belgedeki z3 parantezini (E35) çözmüyor, artık −2g3θ̂1z2. Ancak düzeltilmiş parantezi çözüyor | değişiklik yok | E36 doğru; hata sadece E35'in yazımında |
| E38 | θ̂̇1 = γ1(… **−** g3z2z3). Düzeltilmiş θ̃1 parantezine göre artık −2g3z2z3 | θ̂̇1 = γ1(… **+** g3z2z3) | V̇'ye ek artık −2K·z2·z3·θ̃1 ekler |
| E38/E40 (S5) | φ̇3, ẋ2 = θ1(…) üzerinden bilinmeyen θ1'i içeriyor. Belge bu terimi hesaba katmıyor | Tuning function: θ̂̇1'e γ1·z3·(∂φ3/∂x2)·(f2 + g2x2 + g3x3) terimi eklenir | Belgedeki yasayla V̇ ≠ −Σk·(hata)²; artık terim §4.3'te |
| E7 | Türev "i̇̇" olarak yazılmış | di/dt | sadece yazım |
| E6, E7 / E15, E16 | E6 ve E7'de K_i, K_emf, J, L; E15 ve E16'da K, J_gp, L_gp kullanılmış | aynı K | sadece gösterim |
| E30 | −k1x² | −k1x1² | sadece yazım |
| E12 | τ1 birimi N, τ2 birimi N·s·m⁻¹ | N·m ve N·m·s/rad olmalı | türetmeyi etkilemez |

Doğru bulunanlar: E4, E14, E21b,c = E15, E16; E24, E25; E32; E34; E40 (E40 = −γ2·z3·(g4x2 + g5x3 + u)). Sistem strict-feedback formunda.

## 3. Adımlar ve doğrulama
Türetme `deriv_adaptive.m`'de, doğrulamalar `checks/verify_adaptive.m`'de. Doğrulama, türetmeden bağımsız olarak düz semboller üzerinde zincir kuralıyla yapıldı.

| Adım | Yapılan | Doğrulama |
|---|---|---|
| T1 | V = ½x1² + ½z2² + ½z3² + θ̃1²/(2γ1) + θ̃2²/(2γ2) ve V̇ hesaplandı; θ = θ̂ − θ̃ | — |
| T2 | V̇ = x1·TERM1 + z2·TERM2 + z3·TERM3 + θ̃1·TERM_θ1 + θ̃2·TERM_θ2. Katsayılar `diff` ile alındı | assert: yeniden düzenleme doğru; V̇, θ̃'ya göre lineer |
| T3 | φ2, φ3 ve u, `isolate` ile bulundu | 1. ve 2. parantez koşulları = 0. u, E36'ya eşit |
| T4 | TERM_θ1 = 0 ve TERM_θ2 = 0'dan θ̂̇1 ve θ̂̇2 bulundu. TERM_θ1, a32 = ∂φ3/∂x2 terimini içeriyor | θ̂̇1 = E38_corr + γ1·z3·a32·F (fark 0); θ̂̇2 = E40 (fark 0) |
| T5 | φ̇2 hesaplandı (parametre içermiyor). φ̇3 kestirilmiş dinamik (θ̂1) ve tam θ̂̇1 yasasıyla hesaplandı | ikisi de zincir kuralıyla aynı sonucu veriyor (fark 0) |
| T6 | u, θ̂̇1 ve θ̂̇2 yalnızca x1, x2, x3, θ̂1, θ̂2 cinsinden yazıldı. Her `diff`'ten önce yer tutucular çözüldü | assert: yer tutucu kalmadı; θ1, θ2, θ̃ yok |
| T7 | f ve g yerine fiziksel ifadeler kondu (sgn ω = 1) | Vin_simp = fiziksel subs(Vin_abs) (fark 0) |
| **Kapalı çevrim** | Gerçek dinamik ve gerçek θ ile V̇ hesaplandı | **V̇ − (−k1x1² − k2z2² − k3z3²) = 0**: soyut seviyede ve fiziksel seviyede (E15, E16, J, L ile) |

## 4. Son yasa
### 4.1 Referanslar
- W_ref = φ2 = (2Qvad + k1·DV + 2ΔP/Rbf)/(2α_ω)
- i_ref = φ3 = [2α_ω·DV − k2·(W − W_ref) + (2Q̇vad + k1(2Qvad − 2α_ω W + 2ΔP/Rbf) + 2ΔṖ/Rbf)/(2α_ω) + θ̂1(τ1 + α_P ΔP + τ2 W)] / (K·θ̂1)
- z2 = W_ref − W, z3 = i_ref − i, F = −τ1 − α_PΔP − τ2W + K·i (= J·ω̇)
- a32 = ∂i_ref/∂W = −(k1 + k2 − τ2·θ̂1)/(K·θ̂1)

### 4.2 Kontrol ve uyarlama yasaları (kısa okunur form; tam form .m dosyalarında)
- **Vin** = (φ̇3 + K·θ̂1·z2 + k3·z3)/θ̂2 + K·W + R_gp·i
  - φ̇3 = ∂φ3/∂DV·ẋ1 + a32·θ̂1·F + ∂φ3/∂θ̂1·θ̂̇1 + ∂φ3/∂(Qvad, ΔP, Q̇vad, ΔṖ)·(türevleri)
  - Bu kısa form, E36'nın x2 = φ2 − z2 ve x3 = φ3 − z3 ile yazılmış halidir. `verify_adaptive.m` içinde tam ifadeyle farkının 0 olduğu doğrulandı.
- **θ̂̇1** = γ1·[ −z2·(f2 + g2φ2 − g2z2 + g3φ3 − g3z3) + z3·a32·F ]. Fiziksel olarak: f2 = −τ1 − α_PΔP, g2 = −τ2, g3 = K. Son terim tuning function.
- **θ̂̇2** = −γ2·z3·(−K·W − R_gp·i + Vin)
- Yasalarda gerekli sinyaller: DV, W, i, θ̂1, θ̂2, Qvad, ΔP, Q̇vad, ΔṖ, **Q̈vad, ΔP̈**. Yani Qvad ve ΔP'nin ikinci türevleri gerekiyor.
- Gerçek θ1 = 1/J ve θ2 = 1/L hiçbir yasada yok (assert).

### 4.3 Belgedeki yasada V̇ artığı (S5)
`verify_adaptive.m` içinde sembolik olarak, fark 0 olacak şekilde doğrulandı:
- E36 + E38_corr + E40 (tuning terimi yok):
  V̇ = −k1x1² − k2z2² − k3z3² **− z3·a32·F·θ̃1**
  = … + z3·(k1 + k2 − τ2θ̂1)/(Kθ̂1)·(K·i − τ1 − α_PΔP − τ2W)·θ̃1
- E38 belgede yazıldığı gibi kullanılırsa artığa ayrıca **−2K·z2·z3·θ̃1** eklenir.
- Bu terimlerin işareti belirsiz; V̇ ≤ 0 garantisi yok.

### 4.4 Tekillikler ve limitler (`checks/analysis_adaptive.m`)
- Paydalar: Vin için K³·Rbf²·α_ω²·θ̂1⁴·θ̂2; θ̂̇1 için K²·Rbf·α_ω·θ̂1².
- θ̂1 = 0, θ̂2 = 0, K = 0 ve α_ω = 0 noktaları **gerçek tekillik**. Hem adım adım hem sadeleştirilmiş ifadede bölme sıfıra çıkıyor; limit ±∞. Kaldırılabilir 0/0 bulunmadı.
- K, α_ω ve Rbf fiziksel sabit ve pozitif olduğu için çalışmada sorun çıkarmazlar. Asıl risk θ̂1 → 0 ve θ̂2 → 0; bu yüzden projeksiyon gerekir (§7).
- `simplify` ifadeleri kısaltmadı (Vin 1503 karakter). Sadeleştirilmiş ve sadeleştirilmemiş ifade 5 rastgele noktada karşılaştırıldı (`digits(50)`); bağıl fark 0.
- Geçerlilik koşulları: ω > 0 (sgn = 1). Belgedeki modelde ω'nun işareti değişirse yasa yeniden türetilmeli.

### 4.5 Simülasyon (`checks/sim_adaptive.m`, `checks/sim_adaptive.png`)
- Ayarlar:
  - Projeksiyon yok. Çözücü ode15s: L/R = 3 ms, mekanik ve uyarlama dinamikleri çok daha yavaş, sistem sert. Süre 5 s.
  - Kazançlar: k = (5, 20, 200), γ = (10⁴, 10³).
  - Başlangıç: DV = 2 mL, W = 60 rad/s, i = 0.6 A.
  - Sinyaller: Qvad = 83 + 20·sin(2πt) mL/s ve ΔP = 10.7 + 2·sin(2πt) kPa. Bu sinyaller belgede yok, test için seçildi.
- İlk deneme k = (10, 50, 500), γ = (10⁶, 10⁵), W(0) = 50 rad/s ile yapıldı. Başlangıçta z3 ≈ 8 A ve Vin ≈ 10³ V oldu; θ̂2 bir milisaniyenin altında sıfıra indi ve çözüm durduruldu. Her iki yasada da aynı davranış görüldü. Bu çıktı `analysis_results.md`'de duruyor. Sonuç: projeksiyonsuz yasa, yüksek γ ve büyük başlangıç hatasıyla tekilliğe gidiyor.

| θ̂(0) | yasa | max\|DV\| (t>1 s) | max\|z2\| | max\|z3\| | max\|Vin\| | θ̂1/θ1 sonda | V̇ > 0 örnek oranı |
|---|---|---|---|---|---|---|---|
| 0.5θ | tuning function | 1.70e-7 m³ | 0.44 rad/s | 0.24 A | 5.44 V | 0.562 | 0 (teorik) |
| 0.5θ | belge (E38_corr) | 1.68e-7 m³ | 0.44 rad/s | 0.24 A | 5.44 V | 0.568 | 0 (artık/hedef ≤ 0.23) |
| 1.5θ | tuning function | 3.37e-8 m³ | 0.066 rad/s | 0.107 A | 5.45 V | 1.488 | 0 (teorik) |
| 1.5θ | belge (E38_corr) | 3.37e-8 m³ | 0.066 rad/s | 0.107 A | 5.45 V | 1.487 | 0 (artık/hedef ≤ 0.16) |

- Bu senaryoda iki yasa pratikte aynı davranıyor. Belgedeki yasanın artığı hedef V̇'nin en fazla %23'ü kadar ve V̇ hiçbir örnekte pozitif olmuyor. Fark teorik: V̇ ≤ 0 garantisi yalnızca tuning-function yasasında var. Artık, (k1 + k2)/(Kθ̂1), z3 ve θ̃1 ile büyür; daha yüksek kazançlarda veya daha büyük θ̂ hatasında önemli hale gelebilir.
- θ̂, 5 s içinde gerçek değere yaklaşmıyor (θ̂2 neredeyse sabit). Kalıcı uyarım (persistent excitation) olmadan V̇ ≤ 0, θ̂ → θ anlamına gelmez. DV, z2 ve z3'ün sıfıra yakınsaması da yavaş: kalan salınım 1 Hz'lik sinyalden geliyor ve θ̃ ile bağlantılı.
- Vin en fazla 5.5 V. Bu senaryoda doyma (saturation) riski görünmüyor; ancak büyük başlangıç hatalarında Vin kilovolt mertebesine çıkabiliyor (ilk deneme).

## 5. Kod seçimleri
- `x2_new`, `x3_new`: x2(t) ve x3(t) zamana bağlılığını korusun diye ayrı isimler kullanıldı.
- Katsayılar `diff` ile alındı (z2'ye bölme yok, 0/0 yok). Yeniden düzenleme assert ile doğrulandı. θ̃ katsayıları da `diff` ile alındı ve V̇'nin θ̃'ya göre lineer olduğu assert ile kontrol edildi.
- `z3_dot` içinde gerçek φ̇3 = kestirilmiş φ̇3 + a32·(ẋ2 − ẋ2_h) olarak yazıldı. a32 bir yer tutucu; tuning-function terimi bu satırdan doğuyor (S5).
- `x2_dot_h`: φ̇3, kontrolörün hesaplayabileceği kestirilmiş dinamikle (θ̂1) türetildi.
- Her `diff`'ten önce `for ii = 1:5` döngüsüyle açık listelerle `subs` yapıldı ve ardından assert kondu.
- φ̇3 hesabında diff(θ̂1(t)) yerine tam θ̂̇1 yasası (tuning terimi dahil) kondu.
- Assert'ler: gerçek θ ve θ̃ yasalarda yok; son ifadelerde yalnızca izin verilen semboller var; φ̇3'te çözülmemiş `diff` kalmadı.
- `th2h_dot_fun`, Vin'i giriş olarak alan kısa form (E40). Tam ifadeyle farkının 0 olduğu assert ile doğrulandı.

## 6. Referans karşılaştırması
Referans çözüm verilmedi.

## 7. Dış sorular (yazar için)
1. **Projeksiyon:** θ̂1 ve θ̂2'ye bölündüğü için (Vin'de θ̂1⁻⁴ ve θ̂2⁻¹) önerilen kural: θ̂̇i = 0, eğer θ̂i ≤ θi,min ve τi < 0 ise; değilse τi (τi: türetilen yasa). Bu kural V̇ ≤ −Σk·(hata)² özelliğini korur. J ve L için hangi alt/üst sınırlar kullanılacak (θ1,min = 1/J_max, θ2,min = 1/L_max)?
2. E17a'daki f1 işareti: Qgp = α_ωω − ΔP/Rbf (E5) doğruysa f1 = 2Qvad + 2ΔP/Rbf olur. E5'teki işaret mi yoksa E17a mı doğru?
3. Regülasyon hedefi x1 = ΔVh → 0 fiziksel olarak isteniyor mu, yoksa bir ΔVh,ref izlenmeli mi? İzleme istenirse ΔVh,ref'in 3. türevine kadar türevleri yasaya girer.
4. Q̈vad ve ΔP̈ ölçülerek mi, kestirici/filtre ile mi elde edilecek? Gürültüye duyarlılık açısından önemli.
5. Kazançlar ve γ için hedef değerler nedir? Simülasyondaki değerler yalnızca test amaçlı.
6. τ1 ve τ2 birimleri (E12): N·m ve N·m·s/rad mı olmalı?

## 8. Dosyalar
| Dosya | İçerik |
|---|---|
| README.md | dosya rehberi |
| REPORT.md | bu rapor |
| deriv_adaptive.m | türetme (yazarın kod stili) |
| Vin_fun.m | Simulink için Vin |
| th1h_dot_fun.m | Simulink için θ̂̇1 (tuning function dahil) |
| th2h_dot_fun.m | Simulink için θ̂̇2 (Vin girişli) |
| results.mat | soyut ve fiziksel, sadeleştirilmiş ve sadeleştirilmemiş tüm türetilen büyüklükler |
| checks/source/ | Word kopyası, equations.md |
| checks/inventory.md | bölümler, E/T numaraları, sembol tablosu, S kararları |
| checks/side_by_side.md | belge ve MATLAB kontrolü yan yana |
| checks/chk_document.m | çözülmüş kısmın kontrolleri |
| checks/verify_adaptive.m | kapalı çevrim kontrolleri, belge yasası artığı; doc_law.mat'ı yazar |
| checks/analysis_adaptive.m | sadeleştirme, paydalar, tekillikler |
| checks/sim_adaptive.m | simülasyon; sim_adaptive.png ve sim_results.mat'ı yazar |
| checks/log_run.m | betik çıktısını analysis_results.md'ye ekleyen yardımcı |
| checks/analysis_results.md | tüm kontrol çıktıları (zaman damgalı, silinmeden) |
