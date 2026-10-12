# 🧭 UYAP Dilekçe Hazırlayıcı: Proje Durumu & Geliştirici Devir Kılavuzu (v1.5.0)

Bu kılavuz, geliştirme süreçlerini ve mimariyi özetlemektedir.

---

## 📦 1. GitHub Depoları & Çalışma Alanları

Proje 3 farklı amaca göre ayrıştırılmış ve GitHub ile tam senkronize edilmiştir:

| Repo Adı | Görünürlük | Açıklama & Yol |
| :--- | :--- | :--- |
| **`ssayoglu/uyap-dilekce-hazirlayici`** | **Public** | **Ana macOS Sürümü:** Açık kaynaklı, macOS yerel Swift sarmalayıcılı (`DilekceApp`), Menubar Hızlı Mazeret popover'lı ana repo. |
| **`ssayoglu/uyap-dilekce-windows`** | **Public** | **Windows Sürümü:** `os.startfile`, `win_app.py` (Edge/Chrome app mode), `Baslat.bat`, `AppIcon.ico` ve PowerShell installer (`install.ps1`) içeren Windows sürümü. |
| **`ssayoglu/uyap-dilekce-pro`** | **Private** | **Ticari / Lisanslı Sürüm:** Çevrimdışı donanım kilitli (`HWID / HMAC-SHA256`) lisans motoru, `keygen.py` ve `Landing_Page` web sitesi içeren gizli repo. |

---

## 🚀 2. v1.5.0 Sürümünde Tamamlanan Özellikler (Aktif Durum)

1. **🤖 Yapay Zekâ Destekli Dilekçe Oluşturucu (Gemini 3.6 Flash):**
   - Olay serbest doğal dille anlatıldığında Türk mevzuatını, Yargıtay/AYM içtihatlarını inceleyerek formu otomatik doldurur.
2. **⚠️ Otomatik Hukuki Risk & Kırmızı Uyarı Bildirimi:**
   - Zamanaşımı, hak düşürücü süreler, delil ve usul riskleri dilekçede ve UYAP'ta kırmızı renkle (`foreground="-65536"`) vurgulanır.
3. **🎨 UYAP Doküman Editörü Tam Renk & Format Uyumluluğu:**
   - UDF gövde metinleri saf siyah (`foreground="-16777216"`) olarak standardize edildi; editör içi tema/link lacivert sapmaları önlendi.
4. **🏛️ Evrensel Tutukluluk ve Tahliye İtiraz Şablonu:**
   - Emsal ceza itirazları taranarak 8 temel hukuki bent (İstikrarlı savunma, CMK 100 somut delil yokluğu, kaçma şüphesi yokluğu, delil karartma imkansızlığı, katalog suçlarda dahi somutlaştırma zorunluluğu, ölçülülük/ultima ratio, adli kontrol önceliği ve AİHS m. 5/AYM içtihatları) ile evrenselleştirildi.
5. **⚡ Hızlı Mazeret Modülü (`/mazeret`):**
   - 3 saniyede UYAP uyumlu mazeret dilekçesi üretme ve doğrudan editörde açma.
6. **🔢 Dinamik UYAP Sıralı Liste & İki Yana Yaslama:**
   - Açıklamalar maddeleri UYAP Doküman Editörü'nün yerel XML şeması (`Numbered="true"`, `NumberType="NUMBER_TYPE_NUMBER_DOT"`, `LeftIndent="25.0"`) ile üretilir.
7. **💰 Canlı Harç, Masraf & Kademeli AAÜT Vekâlet Ücreti Motoru:**
   - Dava Değeri (H.E.D.) girildiği anda Peşin Harç (1/4), Başvuru Harcı, %20 İcra İnkâr Tazminatı ve kademeli AAÜT vekâlet ücreti anlık hesaplanır.
8. **👥 Yerel Müvekkil Rehberi (Local CRM):**
   - `localStorage` tabanlı; müvekkillerin T.C., unvan ve adresleri hafızada tutulup tek tıkla forma aktarılır.
9. **🪟 Windows Özelleştirmeleri:**
   - `get_desktop_dir()` ile OneDrive/Masaüstü dinamik tespiti.
   - `open_in_uyap()` ile `os.startfile` ve Windows UYAP kayıt yolları.
   - `win_app.py` ile pywebview / Edge-Chrome WebApp modu.
   - `AppIcon.ico` ve PowerShell masaüstü kısayol entegrasyonu.

---

## 🛠️ 3. Dosya & Kod Yapısı Haritası (Windows)

```text
├── server.py             # HTTP Backend (Port: 5678) + build_udf (XML Motoru) + AI Gemini + HTML_PAGE + MAZERET_HTML
├── win_app.py            # Windows Edge/Chrome App Launcher & GUI Wrapper
├── Baslat.bat            # Windows tek tıkla başlatma betiği
├── install.ps1           # Windows PowerShell tek komutlu kurulum betiği
├── version.json          # Sürüm kontrol ve otomatik güncelleme bildirim dosyası (v1.5.0)
├── AppIcon.ico           # Windows masaüstü kısayol simgesi (256x256)
├── dilekce_gui.py        # Alternatif Tkinter masaüstü arayüzü
└── build_all_templates.py# Toplu UDF şablon üretici
```

---

## 🎯 4. Sırada Bekleyen Geliştirme Fikirleri (Roadmap)
* 📥 **Özel UDF Şablon İçe Aktarma:** Kullanıcının kendi hazırladığı bir `.udf` dosyasını sürükle-bırak yaparak sisteme yeni şablon olarak kaydetmesi.
* ⚖️ **İcra Kapak Hesabı & Kıdem Tazminatı:** İcra takip talepleri ve İş Mahkemesi dilekçeleri için ek hesaplama modülleri.
