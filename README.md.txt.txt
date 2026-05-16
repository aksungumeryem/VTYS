VTYS-1 DÖNEM PROJESI TESLIM RAPORU
Çevrimiçi Yemek Sipariş Platformu Veri Tabanı Tasarımı
Adı Soyadı:
Öğrenci No:
Ders:
Meryem Aksüngü
23390008024
Veritabanı Yönetim Sistemleri - 1 (Dönem Projesi)
1. PROJE ÖZETI VE KAPSAMI
Bu proje, kullanıcıların sisteme kayıtlı restoranların menülerinden çevrimiçi olarak yemek siparişi verebileceği bir
platformun ilişkisel veritabanı altyapısını (YemekSiparisDB_V2) kapsamaktadır. Tasarlanan mimari; temel müşteri
ilişkilerini, restoran detaylarını, dinamik ürün menülerini, kategorileri ve sipariş süreçlerini entegre bir şekilde
yönetmektedir. Geleneksel yemek siparişi fonksiyonlarına ek olarak, toplumsal yardımlaşma ve dayanışmayı teşvik
etmek amacıyla "Askıda Yemek" adında dinamik bir bağış havuzu modülü sisteme başarıyla entegre edilmiştir. 
3NF Uyumluluğu: Veritabanı şeması tasarlanırken veri tekrarını önlemek, tutarsızlıkları engellemek ve anomalileri
ortadan kaldırmak adına 3. Normal Form (3NF) kurallarına tam uyum sağlanmıştır. Örneğin; 1NF kuralı gereği
Restoranlar tablosunda bir restoranın sunduğu tüm ürünler tek bir hücrede virgüllerle ayrılıp tutulmamış, her ürün
Urunler tablosunda tekil satırlar halinde saklanarak restorana bir dış anahtar (Foreign Key) ile bağlanmıştır. Sipariş
sürecinde ise müşterinin adres, telefon veya ad-soyad gibi operasyonel bilgileri her sipariş satırına mükerrer şekilde
yazılmak yerine Musteriler tablosundan referans alınarak (2NF ve 3NF) saklanmış, veri şişmesinin önüne
geçilmiştir. 
2. "ASKIDA YEMEK" MODÜLÜ İŞ KURALLARI
• 
• 
• 
• 
Bağış Mantığı: Hayırsever müşteriler, AskidaYemekHavuzu tablosuna bakiye bırakarak bağış
gerçekleştirirler. Giriş anında sistem BaslangicTutari değerini kaydeder ve bu miktar ihtiyaç sahiplerinin
yararlanabilmesi adına havuzda KalanTutar olarak izlenir.
Gizlilik Kuralları: Bağışçıların kimlik gizliliği hakkı sistemsel olarak güvence altına alınmıştır. Tabloda yer
alan GizliBagisci (BIT) kolonu 1 değerini aldığında, dış arayüzlere veri sağlayan vw_AskidaYemekHavuzu
isimli View yapısında bu kişilerin isimleri dinamik olarak maskelenir ve "Gizli Hayırsever" şeklinde gösterilir.
Kolon değeri 0 olduğunda ise müşterinin adı ve soyadının baş harfi gösterilerek (Örn: Ahmet Y.) kısmi gizlilik
korunur.
Yararlanma Şartları: İhtiyaç sahibi veya bakiyesi yetersiz olan kullanıcılar sipariş oluştururken, Siparisler
tablosundaki AskidaYemekKullanildi alanını 1 yaparak ve KullanilanBagisID alanını havuzdaki aktif bir
bağışın ID'si ile eşleştirerek ücretsiz sipariş verebilirler.
Bakiye Yönetimi ve Güvenlik: Bir müşteri askıdaki bir ilandan yararlanarak sipariş verdiğinde, veritabanı
seviyesinde çalışan trg_AskidaYemekKullanimi isimli Trigger (Tetikleyici) otomatik olarak devreye girer. Bu
tetikleyici, siparişe ait toplam tutarı inserted tablosundan okuyarak ilgili bağış kaydının kalan bakiyesinden
(KalanTutar) düşer. Eğer sipariş tutarı havuzdaki o bağışın mevcut kalan tutarından büyükse ve bakiye negatif
1
değere düşmeye çalışırsa, tetikleyici RAISERROR ile hata fırlatır ve ROLLBACK TRANSACTION
komutuyla işlemi tamamen geri alarak tutarsız bakiye oluşumunu kesin olarak engeller.
3. VERI TANIMLAMA VE KISITLAMALAR (DDL)
Sistem mimarisi fiziksel veritabanında toplam 7 temel tablodan oluşmaktadır. Veri bütünlüğünü korumak adına
uygulanan kısıtlamalar şunlardır:
• 
• 
• 
CHECK Kısıtlamaları: Mantıksız veri girişlerini engellemek amacıyla Urunler tablosunda Fiyat > 0, 
Musteriler tablosunda Bakiye >= 0, AskidaYemekHavuzu tablosunda BaslangicTutari > 0 ve KalanTutar
>= 0 şartları koşulmuştur. Ayrıca Restoranlar tablosunda puanlama mekanizmasının güvenilirliği için Puan >=
0 AND Puan <= 5 kontrolü CHECK kısıtlamasıyla sağlanmıştır.
UNIQUE & NOT NULL: Müşteri kayıtlarının benzersizliği ve mükerrer hesap açılmasını önlemek adına
Musteriler.Email kolonuna UNIQUE kısıtlaması atanmıştır. Ad, Soyad, Fiyat, ToplamTutar gibi boş
geçilmemesi gereken tüm alanlar NOT NULL olarak işaretlenmiştir.
Soft Delete (Veri Koruma Mimarisi): Finansal ve operasyonel geçmişin, geriye dönük raporlamaların
bozulmaması adına tablolardan fiziksel veri silme (DELETE) işlemi tamamen engellenmiştir. Bunun yerine
tablolara IsActive BIT DEFAULT 1 kolonu eklenmiştir. Bir ürün menüden kaldırıldığında veya bir restoran
pasife geçtiğinde bu değer 0 yapılır; böylece eski sipariş faturalarının bütünlüğü korunur.
4. VERITABANI PROGRAMLANABILIRLIK NESNELERI
Veritabanı performansını artırmak ve iş kurallarını otomatize etmek amacıyla şu nesneler kurgulanmıştır:
• 
• 
• 
• 
vw_AktifMenuler: Sistemde o an aktif olan restoranların, aktif kategorilerdeki aktif ürünlerini INNER JOIN
ile tek bir yapıda birleştirerek uygulama arayüzünün listeleme operasyonlarını hızlandırır.
vw_AskidaYemekHavuzu: Havuzda bekleyen bakiyeleri listelerken GizliBagisci durumuna göre dinamik
maskeleme (CASE WHEN ve SUBSTRING) uygulayarak KVKK ve gizlilik kurallarını yürütür.
trg_AskidaYemekKullanimi: Siparişler tablosuna veri eklendiğinde (AFTER INSERT) çalışarak askıda
yemek süreçlerinin bakiye yönetimini arka planda insan müdahalesi olmadan ve güvenli bir şekilde
gerçekleştirir.
IDX_Siparisler_SiparisTarihi: Siparişlerin tarihlerine göre azalan (DESC) sırada hızlıca taranabilmesi için
kurgulanmış bir indeks yapısıdır. Büyük veri setlerinde tam tablo taramasından (Table Scan) kaçınarak "Son
Siparişler" sorgularını optimize eder.
5. ANALITIK VE İLERI DÜZEY SORGU SENARYOLARI
Yazılan SQL scriptlerinde veritabanının analitik gücünü ölçmek adına 3 temel senaryo test edilmiştir:
1. 
Kapsamlı Sipariş Geçmişi (JOIN): Musteriler, Siparisler ve Restoranlar tabloları birleştirilerek, hangi
müşterinin hangi restorandan ne zaman sipariş verdiğini ve ödemenin askıdan mı yoksa cüzdandan mı
yapıldığını dinamik olarak çözen sorgu kurgulanmıştır.
2
2. 
3. 
Restoran Performans Analizi (GROUP BY & HAVING): Restoran bazlı gruplama yapılarak toplam sipariş
adetleri ve cirolar hesaplanmıştır. Toplam satış cirosu 200 TL'den büyük olan başarılı işletmeleri filtrelemek
adına HAVING SUM(s.ToplamTutar) > 200 ifadesi kullanılmıştır.
Hedef Kitle Belirleme (Subquery): 'Kebap' kategorisindeki restoranlardan sipariş vermiş olan tekil müşteri
kitlesini alt sorgu (WHERE RestoranID IN (...)) ile filtreleyerek pazarlama departmanına özel kampanya
datası hazırlayan senaryo eklenmiştir.
6. PROJE GELIŞTIRME SÜRECI VE DÜRÜSTLÜK BEYANI
Projenin kavramsal tasarım aşamasında, ilişkisel veritabanı normalizasyon kurallarının (3NF) teorik kontrollerinin
yapılmasında ve test süreçlerinde sisteme can verecek büyük ölçekli örnek verilerin (INSERT INTO scriptleri)
hızlıca üretilmesinde yapay zeka asistanından (Gemini) teknik ve mantıksal destek alınmıştır. Yapay zeka ile
istişare edilen tetikleyici mantığı, görünüm yapıları ve soft-delete kısıtlamaları şahsım tarafından satır satır
incelenmiş, SQL Server Management Studio (SSMS) üzerinde manuel olarak derlenip test edilerek nihai script
dosyalarına entegre edilmiştir. Projenin mimari tasarımı, tablo ilişkileri ve sorgu senaryoları tamamen özgündür ve
şahsıma aittir. 
7. VERSIYON KONTROLÜ VE GITHUB BILGISI
Projenin kaynak kodları, veri tanımlama yapıları (DDL), programlanabilir nesneleri ve DML sorguları tek bir parça
halinde ve organize bir biçimde uzak sunucu deposuna aktarılmıştır. Proje reposunun güncel bağlantı adresi aşağıda
yer almaktadır: 
GitHub Repository: https://github.com/meryemaksungu/CevrimiciYemekSiparisi_VTYS 
3