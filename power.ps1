
# إنشاء مجلد على سطح المكتب
$desktop = [Environment]::GetFolderPath("Desktop")
$folder = "$desktop\CyberLesson"

New-Item -ItemType Directory -Path $folder -Force | Out-Null

# جمع معلومات النظام
$username = $env:USERNAME
$computer = $env:COMPUTERNAME
$os = (Get-CimInstance Win32_OperatingSystem).Caption
$cpu = (Get-CimInstance Win32_Processor).Name
$ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB,2)

# الحصول على IP الخارجي
$ip = Invoke-RestMethod "https://api.ipify.org"

# إنشاء النص
$data = @"
===== System Information =====

User Name: $username
Computer Name: $computer
Operating System: $os
Processor: $cpu
RAM: $ram GB
External IP: $ip

Date: $(Get-Date)

==============================
"@

# عرض المعلومات في PowerShell
Write-Host $data

# حفظ المعلومات في ملف
$file = "$folder\system_info.txt"
$data | Out-File $file

# ضغط الملف
Compress-Archive -Path $file -DestinationPath "$folder\info.zip" -Force

Write-Host "تم حفظ المعلومات هنا:"
Write-Host $file
