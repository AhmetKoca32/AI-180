# Dermoscope Backend

Bu proje, cilt hastalıklarının otomatik teşhisi ve kullanıcıya öneriler sunmak için geliştirilen Dermoscope uygulamasının backend (sunucu tarafı) kodlarını içerir.

## Özellikler
- **Kullanıcı Yönetimi:** Kayıt, giriş, JWT tabanlı kimlik doğrulama
- **Görsel Yükleme & AI Tanısı:** Kullanıcıdan alınan cilt görsellerinin PyTorch modelleriyle analizi
- **Yaşam Tarzı Önerileri:** GEMINI tabanlı öneri üretimi
- **Veritabanı Yönetimi:** SQLAlchemy ile kullanıcı, tanı ve öneri kayıtları
- **Cloudinary Desteği:** Görselleri bulutta saklama (isteğe bağlı)

---

## Klasör Yapısı

```
dermoscope_backend/
│
├── app/
│   ├── main.py                  # Uvicorn ile uygulamayı başlatan ana dosya
│   ├── core/                    # Ortam ayarları ve güvenlik
│   ├── routers/                 # API endpoint'leri
│   ├── schemas/                 # Pydantic modelleri
│   ├── models/                  # SQLAlchemy ORM modelleri
│   ├── services/                # İş mantığı katmanı
│   ├── database/                # Veritabanı bağlantısı
│   ├── utils/                   # Yardımcı fonksiyonlar
│   └── tasks/                   # Asenkron görevler
│
├── model_api/                   # PyTorch modelleri ve tahmin wrapper'ı
├── static/uploads/              # (Opsiyonel) Lokal görsel yükleme klasörü
├── .env                         # Ortam değişkenleri
├── requirements.txt             # Bağımlılıklar
├── Dockerfile                   # Docker için
└── README.md                    # Bu dosya
```

---   

## Kurulum

1. **Gereksinimler:**
   - Python 3.9+
   - (Opsiyonel) Docker
2. **Bağımlılıkları yükle:**
   ```bash
   pip install -r requirements.txt
   ```
3. **.env dosyasını oluşturun:**
   - Örnek içerik:
     ```env
     DB_URL=sqlite:///./test.db
     SECRET_KEY=supersecret
     ALGORITHM=HS256
     ACCESS_TOKEN_EXPIRE_MINUTES=30
     CLOUDINARY_URL=cloudinary://... (opsiyonel)
     GEMINI_API_KEY=... (opsiyonel)
     ```
4. **Veritabanı tablolarını oluşturun:**
   - SQLAlchemy Base ile otomatik migrate veya elle oluşturabilirsiniz.
5. **Uygulamayı başlatın:**
   ```bash
   uvicorn app.main:app --reload
   ```
   veya Docker ile:
   ```bash
   docker build -t dermoscope-backend .
   docker run -p 8000:8000 dermoscope-backend
   ```

---

## API Kısa Açıklama
- `/auth/` : Kullanıcı kayıt/giriş
- `/diagnosis/` : Görsel yükle, AI tanısı al
- `/advice/` : LLM tabanlı öneri al
- `/user/` : Kullanıcı bilgileri

---

## Geliştirici Notları
- **AI Modelleri:** `model_api/acne_model.pt` ve `eczema_model.pt` dosyaları PyTorch ile eğitilmiş modellerdir.
- **Cloudinary:** Cloudinary entegrasyonu opsiyoneldir, local upload için `static/uploads` kullanılabilir.
- **Asenkron Görevler:** Celery gibi bir sistem entegre edilebilir.

---

## Katkı ve Lisans
Katkıda bulunmak için PR açabilirsiniz. Lisans bilgisi için proje sahibine danışınız.
