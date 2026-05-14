-- ====================================================================
-- AŞAMA 3: VERİ İŞLEME DİLİ (DML) - ÖRNEK VERİLER VE SORGULAR
-- ====================================================================

USE YemekSiparisDB_V2;
GO

-- 1. ÖRNEK VERİLERİN EKLENMESİ (INSERT)
-- ==========================================

-- Müşteriler (Bakiye de ekleyelim)
INSERT INTO Musteriler (Ad, Soyad, Email, Telefon, Adres, Bakiye)
VALUES 
('Ahmet', 'Yılmaz', 'ahmet.y@email.com', '05550001122', 'Beşiktaş, İstanbul', 500.00),
('Ayşe', 'Kaya', 'ayse.k@email.com', '05553334455', 'Kadıköy, İstanbul', 150.00),
('Hayırsever', 'Vatandaş', 'hayirsever@email.com', '05001234567', 'Gizli Adres', 2000.00);
GO

-- Restoranlar
INSERT INTO Restoranlar (RestoranAdi, Kategori, Telefon, Adres, Puan)
VALUES 
('Lezzet-i Şark', 'Kebap', '02124445566', 'Fatih, İstanbul', 4.8),
('Pizza Italiano', 'Fast Food', '02127778899', 'Şişli, İstanbul', 4.5);
GO

-- Kategoriler
INSERT INTO Kategoriler (KategoriAdi, Aciklama)
VALUES 
('Ana Yemekler', 'Izgara, Kebap ve Tencere Yemekleri'),
('Pizzalar', 'İtalyan usulü pizzalar');
GO

-- Ürünler
INSERT INTO Urunler (RestoranID, KategoriID, UrunAdi, Fiyat)
VALUES 
(1, 1, 'Adana Kebap', 250.00),
(1, 1, 'Lahmacun', 80.00),
(2, 2, 'Margherita Pizza', 180.00);
GO

-- Askıda Yemek Havuzuna Bağış Ekleme
-- (Hayırsever Vatandaş - MusteriID: 3, 1000 TL gizli bağış yapıyor)
INSERT INTO AskidaYemekHavuzu (BagisciMusteriID, BaslangicTutari, KalanTutar, GizliBagisci)
VALUES 
(3, 1000.00, 1000.00, 1);
GO

-- Siparişler ve Sipariş Detayları (Normal Sipariş ve Askıdan Sipariş)

-- Normal Sipariş (Ahmet Yılmaz)
INSERT INTO Siparisler (MusteriID, RestoranID, ToplamTutar, SiparisDurumu)
VALUES (1, 1, 330.00, 'Teslim Edildi');
INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat)
VALUES (1, 1, 1, 250.00), (1, 2, 1, 80.00);

-- Askıdan Verilen Sipariş (Ayşe Kaya ihtiyacı olduğu için askıdan yemek alıyor)
-- Trigger bu sipariş eklendikten sonra çalışıp Havuzdan parayı kesecektir.
INSERT INTO Siparisler (MusteriID, RestoranID, ToplamTutar, SiparisDurumu, AskidaYemekKullanildi, KullanilanBagisID)
VALUES (2, 2, 180.00, 'Teslim Edildi', 1, 1);
INSERT INTO SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat)
VALUES (2, 3, 1, 180.00);
GO


-- 2. ANALİTİK SORGULAR (SELECT)
-- ==========================================

-- A) JOIN Sorgusu: 3 Tabloyu Birleştirme (İş İhtiyacı: Müşteri Sipariş Geçmişi Fişi)
-- Hangi müşteri, hangi restorandan, ne kadarlık sipariş vermiş?
SELECT 
    m.Ad + ' ' + m.Soyad AS MusteriAdi,
    r.RestoranAdi,
    s.SiparisTarihi,
    s.ToplamTutar,
    CASE 
        WHEN s.AskidaYemekKullanildi = 1 THEN 'Askıdan Ödendi' 
        ELSE 'Kişisel Ödeme' 
    END AS OdemeTuru
FROM Siparisler s
INNER JOIN Musteriler m ON s.MusteriID = m.MusteriID
INNER JOIN Restoranlar r ON s.RestoranID = r.RestoranID;
GO

-- B) Gruplama ve Agregasyon: GROUP BY ve HAVING (İş İhtiyacı: Restoran Performans Analizi)
-- Toplam satış cirosu 200 TL'den büyük olan restoranların toplam gelirleri.
SELECT 
    r.RestoranAdi,
    COUNT(s.SiparisID) AS ToplamSiparisSayisi,
    SUM(s.ToplamTutar) AS ToplamCiro
FROM Siparisler s
INNER JOIN Restoranlar r ON s.RestoranID = r.RestoranID
WHERE s.SiparisDurumu = 'Teslim Edildi'
GROUP BY r.RestoranAdi
HAVING SUM(s.ToplamTutar) > 200;
GO

-- C) Alt Sorgu (Subquery): IN Kullanımı (İş İhtiyacı: VIP veya Potansiyel Hedef Kitle Belirleme)
-- Sadece 'Kebap' kategorisinde restoranlardan yemek yiyen müşterilerin bilgileri.
SELECT Ad, Soyad, Telefon 
FROM Musteriler 
WHERE MusteriID IN (
    SELECT DISTINCT MusteriID 
    FROM Siparisler s
    INNER JOIN Restoranlar r ON s.RestoranID = r.RestoranID
    WHERE r.Kategori = 'Kebap'
);
GO
