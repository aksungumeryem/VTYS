$word = New-Object -ComObject Word.Application
$word.Visible = $false
$docPath = "c:\Users\aksun\OneDrive\Desktop\VTYS YS\Rapor_teslim_Sablonu.docx"
$txtPath = "c:\Users\aksun\OneDrive\Desktop\VTYS YS\Rapor_sablonu.txt"
$doc = $word.Documents.Open($docPath)
$doc.SaveAs([ref]$txtPath, [ref]2) # 2 corresponds to wdFormatText
$doc.Close([ref]0)
$word.Quit()
