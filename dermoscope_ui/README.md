# DermaScope UI

Bu proje, DermaScope mobil uygulamasının Flutter ile geliştirilen kullanıcı arayüzü (UI) kısmını içerir. Proje, modüler ve ölçeklenebilir bir mimariyle tasarlanmıştır. Aşağıda, dosya ve klasör yapısının açıklaması ile birlikte bu şablonun amacı detaylandırılmıştır.

## Proje Mimarisi ve Klasör Yapısı

```
lib/
  core/
    constants/         # Sabitler ve genel tanımlar
    utils/             # Yardımcı fonksiyonlar
    theme/             # Tema ve stil dosyaları
    app_export.dart    # Her sayfada kullanılması gereken importların birleştirildiği dosya
  models/              # Veri modelleri (ör. kullanıcı, analiz sonucu)
  services/            # Servisler (ör. yapay zekâ, kullanıcı işlemleri)
  screens/
    splash/            # Splash ekranı
    auth/              # Giriş/kayıt ekranları
    home/              # Ana ekran
    chat_consultation/ # Cilt, saç ve genel chat ekranları
    profile/           # Kişisel bilgiler ekranı
    analysis_result/   # Analiz ve grafik ekranları
    camera_capture/    # Geliştirilmiş kamera ekranı
    skin_analysis_history/ # Yapılan sorgulama geçmişleri
    widgets/           # Ortak, tekrar kullanılabilir widgetlar
  providers/           # State management dosyaları
  routes/              # Sayfa yönlendirme ve route yönetimi
  l10n/                # Çoklu dil desteği dosyaları (opsiyonel)
  main.dart            # Uygulamanın başlangıç noktası
```

## Şablonun Amacı
- **Modülerlik:** Her ekran ve ana fonksiyon için ayrı klasörler ile kodun okunabilirliği ve yönetimi kolaylaştırılır.
- **Genişletilebilirlik:** Yeni ekranlar, servisler veya modeller eklemek kolaydır.
- **Yeniden Kullanılabilirlik:** Ortak widgetlar ve yardımcı fonksiyonlar merkezi olarak tutulur.
- **State Management:** Uygulamanın veri yönetimi için ayrı bir alan ayrılmıştır.
- **Backend Entegrasyonu:** İleride API bağlantısı veya veri tabanı eklemek için uygun altyapı hazırdır.
- **Çoklu Dil Desteği:** Uygulamanın farklı dillerde kullanılabilmesi için altyapı düşünülmüştür.

## Ekranlar ve Bileşenler
- **Splash Screen:** Açılış ekranı
- **Login Screen:** Giriş ekranı
- **Home Screen:** Ana ekran
- **Chat Ekranları:** Cilt, saç ve genel chat için üç ayrı ekran
- **Profil Ekranı:** Kullanıcıya ait kişisel bilgiler
- **Cilt Durumu Grafik Ekranı:** Analiz sonuçlarının grafiksel gösterimi
- **Bugünün Bilgisi Widget'ı:** Günlük bilgilendirici içerik

---

Bu yapı, projenin sürdürülebilirliğini ve büyümesini kolaylaştırmak için önerilmiştir. Yeni özellikler eklemek veya mevcutları geliştirmek için klasörler arası net bir ayrım ve esneklik sağlar.
