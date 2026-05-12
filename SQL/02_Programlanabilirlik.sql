-- ====================================================================
-- AŞAMA 2: VERİTABANI PROGRAMLANABİLİRLİK NESNELERİ
-- (Görünümler, Tetikleyiciler, İndeksler)
-- ====================================================================

USE YemekSiparisDB_V2;
GO

-- ==========================================
-- 1. GÖRÜNÜMLER (VIEWS)
-- ==========================================

-- Görünüm 1: Aktif Restoranlar ve Menüleri
-- Sadece silinmemiş (IsActive = 1) restoranları ve ürünlerini listeler.
CREATE OR ALTER VIEW vw_AktifMenuler AS
SELECT 
    r.RestoranAdi, 
    k.KategoriAdi, 
    u.UrunAdi, 
    u.Fiyat
FROM Urunler u
INNER JOIN Restoranlar r ON u.RestoranID = r.RestoranID
INNER JOIN Kategoriler k ON u.KategoriID = k.KategoriID
WHERE u.IsActive = 1 AND r.IsActive = 1 AND k.IsActive = 1;
GO

-- Görünüm 2: Askıda Yemek Havuzu Durumu
-- Hangi bağışta ne kadar bakiye kaldığını gizlilik kurallarına uygun gösterir.
CREATE OR ALTER VIEW vw_AskidaYemekHavuzu AS
SELECT 
    h.BagisID,
    CASE 
        WHEN h.GizliBagisci = 1 THEN 'Gizli Hayırsever'
        ELSE m.Ad + ' ' + SUBSTRING(m.Soyad, 1, 1) + '.' 
    END AS BagisciIsmi,
    h.KalanTutar,
    h.BagisTarihi
FROM AskidaYemekHavuzu h
INNER JOIN Musteriler m ON h.BagisciMusteriID = m.MusteriID
WHERE h.KalanTutar > 0 AND h.IsActive = 1;
GO

-- ==========================================
-- 2. TETİKLEYİCİLER (TRIGGERS)
-- ==========================================

-- Trigger: Askıda Yemek Kullanıldığında Bakiyeyi Düşürme
-- Bir sipariş askıdan kullanılmışsa, bağışın kalan tutarından düşer.
CREATE OR ALTER TRIGGER trg_AskidaYemekKullanimi
ON Siparisler
AFTER INSERT
AS
BEGIN
    DECLARE @SiparisID INT, @ToplamTutar DECIMAL(10,2), @KullanilanBagisID INT, @AskidaYemekKullanildi BIT;

    SELECT @SiparisID = SiparisID, @ToplamTutar = ToplamTutar, 
           @KullanilanBagisID = KullanilanBagisID, @AskidaYemekKullanildi = AskidaYemekKullanildi
    FROM inserted;

    IF @AskidaYemekKullanildi = 1 AND @KullanilanBagisID IS NOT NULL
    BEGIN
        -- Bağış tutarından sipariş tutarını düş
        UPDATE AskidaYemekHavuzu
        SET KalanTutar = KalanTutar - @ToplamTutar
        WHERE BagisID = @KullanilanBagisID;

        -- Güvenlik kontrolü: Eğer bakiye eksiye düştüyse işlemi geri al (Rollback)
        IF (SELECT KalanTutar FROM AskidaYemekHavuzu WHERE BagisID = @KullanilanBagisID) < 0
        BEGIN
            RAISERROR ('HATA: Seçilen askıda yemeğin bakiyesi bu sipariş için yetersiz!', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
END;
GO

-- ==========================================
-- 3. İNDEKSLEME (INDEXES)
-- ==========================================

-- Performans Artırıcı İndeks 1: Sipariş Tarihi
-- Genellikle belirli tarihler arası siparişler sorgulandığı için indeks eklendi.
CREATE NONCLUSTERED INDEX IDX_Siparisler_SiparisTarihi 
ON Siparisler(SiparisTarihi DESC);
GO

-- Performans Artırıcı İndeks 2: Restoran Kategorisi
-- Kullanıcılar en çok kategoriye göre (Örn: Kebap, Pizza) arama yapacağı için eklendi.
CREATE NONCLUSTERED INDEX IDX_Restoranlar_Kategori 
ON Restoranlar(Kategori);
GO
