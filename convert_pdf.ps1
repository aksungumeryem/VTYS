$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0 # wdAlertsNone
$pdfPath = "c:\Users\aksun\OneDrive\Desktop\VTYS YS\VTYS-1_Donem_Projesi__Cevrimici_Yemek_Siparis_Platformu_Veritabani_Tasarimi.pdf"
$txtPath = "c:\Users\aksun\OneDrive\Desktop\VTYS YS\VTYS_PDF_Text.txt"
$doc = $word.Documents.Open($pdfPath, $false, $true, $false, "", "", $false, "", "", 0)
$doc.SaveAs([ref]$txtPath, [ref]2)
$doc.Close([ref]0)
$word.Quit()
