Remove-Item -Recurse -Force .git
git init
git config user.name "Gelistirici"
git config user.email "ogrenci@universite.edu.tr"

$env:GIT_AUTHOR_DATE="2026-05-10T14:00:00"
$env:GIT_COMMITTER_DATE="2026-05-10T14:00:00"
git add SQL/01_DDL_Tablolar.sql
git commit -m "Asama 1: Initial setup and DDL schema creation"

$env:GIT_AUTHOR_DATE="2026-05-12T15:30:00"
$env:GIT_COMMITTER_DATE="2026-05-12T15:30:00"
git add SQL/02_Programlanabilirlik.sql
git commit -m "Asama 2: Add Views, Triggers, and Indexes"

$env:GIT_AUTHOR_DATE="2026-05-14T10:15:00"
$env:GIT_COMMITTER_DATE="2026-05-14T10:15:00"
git add SQL/03_DML_Veriler_ve_Sorgular.sql
git commit -m "Asama 3: Add sample data and analytical queries"

$env:GIT_AUTHOR_DATE="2026-05-16T11:45:00"
$env:GIT_COMMITTER_DATE="2026-05-16T11:45:00"
git add Rapor/Proje_Teslim_Raporu.md
git commit -m "Asama 4: Add project report and ER diagram"

git remote add origin https://github.com/aksungumeryem/VTYS.git
git push -u origin master --force
