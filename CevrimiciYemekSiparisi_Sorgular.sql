-- ====================================================================
-- PROJE: Çevrimiçi Yemek Sipariş Platformu Veritabanı Tasarımı
-- VERİTABANI YÖNETİM SİSTEMİ: SQL Server (SSMS)
-- ====================================================================

-- 1. Veritabanı Oluşturma ve Kullanma
CREATE DATABASE YemekSiparisDB;
GO

USE YemekSiparisDB;
GO

-- ====================================================================
-- TABLOLARIN OLUŞTURULMASI (DDL SORGULARI)
-- ====================================================================

-- Müşteriler Tablosu
CREATE TABLE Musteriler (
    MusteriID INT IDENTITY(1,1) PRIMARY KEY,
    Ad NVARCHAR(50) NOT NULL,
    Soyad NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Telefon NVARCHAR(15),
    Adres NVARCHAR(255),
    KayitTarihi DATETIME DEFAULT GETDATE()
);
GO

-- Restoranlar Tablosu
CREATE TABLE Restoranlar (
    RestoranID INT IDENTITY(1,1) PRIMARY KEY,
    RestoranAdi NVARCHAR(100) NOT NULL,
    Kategori NVARCHAR(50),
    Telefon NVARCHAR(15),
    Adres NVARCHAR(255),
    Puan DECIMAL(3,2) CHECK (Puan >= 0 AND Puan <= 5),
    KayitTarihi DATETIME DEFAULT GETDATE()
);
GO

-- Menü Kategorileri Tablosu
CREATE TABLE Kategoriler (
    KategoriID INT IDENTITY(1,1) PRIMARY KEY,
    KategoriAdi NVARCHAR(50) NOT NULL,
    Aciklama NVARCHAR(255)
);
GO

-- Ürünler (Menü İçeriği) Tablosu
CREATE TABLE Urunler (
    UrunID INT IDENTITY(1,1) PRIMARY KEY,
    RestoranID INT NOT NULL,
    KategoriID INT NOT NULL,
    UrunAdi NVARCHAR(100) NOT NULL,
    Aciklama NVARCHAR(255),
    Fiyat DECIMAL(10,2) NOT NULL,
    HazirlanmaSuresiDk INT,
    FOREIGN KEY (RestoranID) REFERENCES Restoranlar(RestoranID) ON DELETE CASCADE,
    FOREIGN KEY (KategoriID) REFERENCES Kategoriler(KategoriID) ON DELETE CASCADE
);
GO

-- Siparişler Tablosu
CREATE TABLE Siparisler (
    SiparisID INT IDENTITY(1,1) PRIMARY KEY,
    MusteriID INT NOT NULL,
    RestoranID INT NOT NULL,
    SiparisTarihi DATETIME DEFAULT GETDATE(),
    ToplamTutar DECIMAL(10,2) NOT NULL,
    SiparisDurumu NVARCHAR(50) DEFAULT 'Hazırlanıyor', -- Bekliyor, Hazırlanıyor, Yolda, Teslim Edildi, İptal
    TeslimatAdresi NVARCHAR(255) NOT NULL,
    FOREIGN KEY (MusteriID) REFERENCES Musteriler(MusteriID),
    FOREIGN KEY (RestoranID) REFERENCES Restoranlar(RestoranID)
);
GO

-- Sipariş Detayları Tablosu
CREATE TABLE SiparisDetaylari (
    SiparisDetayID INT IDENTITY(1,1) PRIMARY KEY,
    SiparisID INT NOT NULL,
    UrunID INT NOT NULL,
    Adet INT NOT NULL CHECK (Adet > 0),
    BirimFiyat DECIMAL(10,2) NOT NULL,
    AraToplam DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (SiparisID) REFERENCES Siparisler(SiparisID) ON DELETE CASCADE,
    FOREIGN KEY (UrunID) REFERENCES Urunler(UrunID)
);
GO

-- Ödemeler Tablosu
CREATE TABLE Odemeler (
    OdemeID INT IDENTITY(1,1) PRIMARY KEY,
    SiparisID INT NOT NULL UNIQUE,
    OdemeYontemi NVARCHAR(50) NOT NULL, -- Kredi Kartı, Nakit, Yemek Kartı
    OdemeTarihi DATETIME DEFAULT GETDATE(),
    OdemeTutari DECIMAL(10,2) NOT NULL,
    OdemeDurumu NVARCHAR(50) DEFAULT 'Başarılı', -- Başarılı, Beklemede, İptal
    FOREIGN KEY (SiparisID) REFERENCES Siparisler(SiparisID) ON DELETE CASCADE
);
GO

-- ====================================================================
-- ÖRNEK VERİ EKLENMESİ (DML SORGULARI - INSERT)
-- ====================================================================

-- Müşteri Ekleme
INSERT INTO Musteriler (Ad, Soyad, Email, Telefon, Adres)
VALUES 
('Ali', 'Yılmaz', 'ali.yilmaz@email.com', '05551234567', 'Atatürk Mah. Cumhuriyet Cad. No:1 İstanbul'),
('Ayşe', 'Kaya', 'ayse.kaya@email.com', '05329876543', 'Bahçelievler Mah. Lale Sok. No:5 Ankara');
GO

-- Restoran Ekleme
INSERT INTO Restoranlar (RestoranAdi, Kategori, Telefon, Adres, Puan)
VALUES 
('Lezzet Dünyası', 'Kebap & Izgara', '02125554433', 'Kadıköy, İstanbul', 4.8),
('Pizza İtaliano', 'Fast Food', '02126667788', 'Beşiktaş, İstanbul', 4.5);
GO

-- Kategori Ekleme
INSERT INTO Kategoriler (KategoriAdi, Aciklama)
VALUES 
('Ana Yemekler', 'Kebap, Döner ve Izgara Çeşitleri'),
('Pizzalar', 'İtalyan usulü pizzalar'),
('İçecekler', 'Soğuk ve Sıcak İçecekler');
GO

-- Ürün Ekleme
INSERT INTO Urunler (RestoranID, KategoriID, UrunAdi, Aciklama, Fiyat, HazirlanmaSuresiDk)
VALUES 
(1, 1, 'Adana Kebap', 'Acılı zırh kebabı, közlenmiş biber ve domates ile', 250.00, 20),
(1, 3, 'Ayran', 'Açık Köpüklü Ayran', 25.00, 2),
(2, 2, 'Margherita Pizza', 'İnce hamur, domates sosu, mozzarella peyniri', 180.00, 15);
GO

-- Sipariş Ekleme
INSERT INTO Siparisler (MusteriID, RestoranID, ToplamTutar, SiparisDurumu, TeslimatAdresi)
VALUES 
(1, 1, 275.00, 'Teslim Edildi', 'Atatürk Mah. Cumhuriyet Cad. No:1 İstanbul');
GO

-- Sipariş Detay Ekleme
-- Sipariş 1 için Adana Kebap (1 adet) ve Ayran (1 adet)
INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat, AraToplam)
VALUES 
(1, 1, 1, 250.00, 250.00),
(1, 2, 1, 25.00, 25.00);
GO

-- Ödeme Ekleme
INSERT INTO Odemeler (SiparisID, OdemeYontemi, OdemeTutari, OdemeDurumu)
VALUES 
(1, 'Kredi Kartı', 275.00, 'Başarılı');
GO

-- ====================================================================
-- FAYDALI VERİ ÇEKME SORGULARI (DML SORGULARI - SELECT)
-- ====================================================================

-- 1. Tüm Müşterileri Listeleme
SELECT * FROM Musteriler;

-- 2. Belirli Bir Restoranın Menüsünü Listeleme (Lezzet Dünyası - ID: 1)
SELECT u.UrunAdi, u.Fiyat, k.KategoriAdi, r.RestoranAdi
FROM Urunler u
INNER JOIN Kategoriler k ON u.KategoriID = k.KategoriID
INNER JOIN Restoranlar r ON u.RestoranID = r.RestoranID
WHERE u.RestoranID = 1;

-- 3. Müşterinin Verdiği Tüm Siparişlerin Detaylı Listesi (Ali Yılmaz - ID: 1)
SELECT 
    s.SiparisID, 
    m.Ad + ' ' + m.Soyad AS MusteriBilgisi, 
    r.RestoranAdi, 
    s.ToplamTutar, 
    s.SiparisDurumu, 
    s.SiparisTarihi
FROM Siparisler s
INNER JOIN Musteriler m ON s.MusteriID = m.MusteriID
INNER JOIN Restoranlar r ON s.RestoranID = r.RestoranID
WHERE s.MusteriID = 1;

-- 4. Bir Siparişin (Fişin) İçeriğini Görüntüleme (Siparis ID: 1)
SELECT 
    sd.SiparisID, 
    u.UrunAdi, 
    sd.Adet, 
    sd.BirimFiyat, 
    sd.AraToplam
FROM SiparisDetaylari sd
INNER JOIN Urunler u ON sd.UrunID = u.UrunID
WHERE sd.SiparisID = 1;

-- 5. Restoranların Ortalama Ürün Fiyatlarını Bulma
SELECT 
    r.RestoranAdi, 
    AVG(u.Fiyat) AS OrtalamaUrunFiyati, 
    COUNT(u.UrunID) AS ToplamUrunSayisi
FROM Urunler u
INNER JOIN Restoranlar r ON u.RestoranID = r.RestoranID
GROUP BY r.RestoranAdi;

-- 6. En Çok Sipariş Verilen 5 Ürünü Listeleme (Popüler Ürünler)
SELECT TOP 5 
    u.UrunAdi, 
    SUM(sd.Adet) AS ToplamSiparisAdedi
FROM SiparisDetaylari sd
INNER JOIN Urunler u ON sd.UrunID = u.UrunID
GROUP BY u.UrunAdi
ORDER BY ToplamSiparisAdedi DESC;

-- 7. Sipariş Durumu "Hazırlanıyor" Olan Siparişleri Listeleme
SELECT * FROM Siparisler WHERE SiparisDurumu = 'Hazırlanıyor';
