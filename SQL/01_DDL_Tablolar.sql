-- ====================================================================
-- AŞAMA 1: VERİ TANIMLAMA (DDL) VE TABLOLARIN OLUŞTURULMASI
-- ====================================================================

-- Veritabanı Oluşturma
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'YemekSiparisDB_V2')
BEGIN
    CREATE DATABASE YemekSiparisDB_V2;
END
GO

USE YemekSiparisDB_V2;
GO

-- 1. Müşteriler Tablosu (Soft Delete ve Bakiye eklendi)
CREATE TABLE Musteriler (
    MusteriID INT IDENTITY(1,1) PRIMARY KEY,
    Ad NVARCHAR(50) NOT NULL,
    Soyad NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Telefon NVARCHAR(15),
    Adres NVARCHAR(255),
    Bakiye DECIMAL(10,2) DEFAULT 0.00 CHECK (Bakiye >= 0), -- Askıda yemek veya cüzdan için
    KayitTarihi DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1 -- Soft Delete için
);
GO

-- 2. Restoranlar Tablosu
CREATE TABLE Restoranlar (
    RestoranID INT IDENTITY(1,1) PRIMARY KEY,
    RestoranAdi NVARCHAR(100) NOT NULL,
    Kategori NVARCHAR(50),
    Telefon NVARCHAR(15),
    Adres NVARCHAR(255),
    Puan DECIMAL(3,2) CHECK (Puan >= 0 AND Puan <= 5),
    KayitTarihi DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);
GO

-- 3. Kategoriler Tablosu
CREATE TABLE Kategoriler (
    KategoriID INT IDENTITY(1,1) PRIMARY KEY,
    KategoriAdi NVARCHAR(50) NOT NULL,
    Aciklama NVARCHAR(255),
    IsActive BIT DEFAULT 1
);
GO

-- 4. Ürünler Tablosu
CREATE TABLE Urunler (
    UrunID INT IDENTITY(1,1) PRIMARY KEY,
    RestoranID INT NOT NULL,
    KategoriID INT NOT NULL,
    UrunAdi NVARCHAR(100) NOT NULL,
    Fiyat DECIMAL(10,2) NOT NULL CHECK (Fiyat > 0),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (RestoranID) REFERENCES Restoranlar(RestoranID),
    FOREIGN KEY (KategoriID) REFERENCES Kategoriler(KategoriID)
);
GO

-- 5. Askıda Yemek Havuzu (Yeni Modül)
-- Bağışçıların havuza bıraktığı tutarları ve kimlik gizliliğini yönetir.
CREATE TABLE AskidaYemekHavuzu (
    BagisID INT IDENTITY(1,1) PRIMARY KEY,
    BagisciMusteriID INT NOT NULL,
    BaslangicTutari DECIMAL(10,2) NOT NULL CHECK (BaslangicTutari > 0),
    KalanTutar DECIMAL(10,2) NOT NULL CHECK (KalanTutar >= 0),
    GizliBagisci BIT DEFAULT 0, -- 1 ise isim görünmez, 0 ise görünür
    BagisTarihi DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (BagisciMusteriID) REFERENCES Musteriler(MusteriID)
);
GO

-- 6. Siparişler Tablosu
CREATE TABLE Siparisler (
    SiparisID INT IDENTITY(1,1) PRIMARY KEY,
    MusteriID INT NOT NULL,
    RestoranID INT NOT NULL,
    SiparisTarihi DATETIME DEFAULT GETDATE(),
    ToplamTutar DECIMAL(10,2) NOT NULL,
    SiparisDurumu NVARCHAR(50) DEFAULT 'Hazırlanıyor',
    AskidaYemekKullanildi BIT DEFAULT 0, -- Sipariş havuzdan mı ödendi?
    KullanilanBagisID INT NULL, -- Hangi bağıştan harcandı? (Opsiyonel)
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (MusteriID) REFERENCES Musteriler(MusteriID),
    FOREIGN KEY (RestoranID) REFERENCES Restoranlar(RestoranID),
    FOREIGN KEY (KullanilanBagisID) REFERENCES AskidaYemekHavuzu(BagisID)
);
GO

-- 7. Sipariş Detayları Tablosu
CREATE TABLE SiparisDetaylari (
    SiparisDetayID INT IDENTITY(1,1) PRIMARY KEY,
    SiparisID INT NOT NULL,
    UrunID INT NOT NULL,
    Adet INT NOT NULL CHECK (Adet > 0),
    BirimFiyat DECIMAL(10,2) NOT NULL,
    AraToplam AS (Adet * BirimFiyat) PERSISTED, -- Otomatik hesaplanan kolon
    FOREIGN KEY (SiparisID) REFERENCES Siparisler(SiparisID),
    FOREIGN KEY (UrunID) REFERENCES Urunler(UrunID)
);
GO
