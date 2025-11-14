# ===============================
# 🧹 Advanced Windows Cleanup Script
# Deep clean: hibernation, bloatware, duplicates, broken apps, cache
# ===============================

# --- Check for Administrator privileges ---
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ This script requires Administrator privileges!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit
}

Write-Host "Starting DEEP Windows cleanup..." -ForegroundColor Cyan
Write-Host "This may take several minutes..." -ForegroundColor Yellow

# --- Get initial disk space ---
$beforeSpace = [math]::Round((Get-PSDrive C).Free / 1GB, 2)
Write-Host "Current free space: $beforeSpace GB" -ForegroundColor Cyan

# --- Disable and remove hibernation ---
Write-Host "`nDisabling Hibernation (removes hiberfil.sys)..." -ForegroundColor Yellow
powercfg -h off
Write-Host "Hibernation disabled successfully." -ForegroundColor Green

# --- Clean ALL temporary and cache files ---
Write-Host "`nCleaning temporary files, caches, and logs..." -ForegroundColor Yellow
$TempFolders = @(
    "$env:TEMP",
    "$env:LOCALAPPDATA\Temp",
    "C:\Windows\Temp",
    "C:\Windows\Prefetch",
    "C:\Windows\SoftwareDistribution\Download",
    "C:\Windows\Logs",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
    "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\ThumbCache*",
    "$env:LOCALAPPDATA\CrashDumps",
    "$env:LOCALAPPDATA\Microsoft\Windows\WER",
    "$env:PROGRAMDATA\Microsoft\Windows\WER"
)
$deletedFiles = 0
foreach ($folder in $TempFolders) {
    if ($folder -like "*`**") {
        $folders = Get-ChildItem -Path ($folder -replace '\*$', '') -Filter ($folder.Split('\')[-1]) -Directory -ErrorAction SilentlyContinue
    } else {
        $folders = @($folder)
    }
    
    foreach ($f in $folders) {
        if (Test-Path $f) {
            try {
                $items = Get-ChildItem -Path $f -Recurse -Force -ErrorAction SilentlyContinue
                foreach ($item in $items) {
                    try {
                        Remove-Item -Path $item.FullName -Force -Recurse -ErrorAction Stop
                        $deletedFiles++
                    } catch {}
                }
            } catch {}
        }
    }
}
Write-Host "Temporary files cleaned ($deletedFiles files removed)." -ForegroundColor Green

# --- Clear browser caches ---
Write-Host "`nClearing browser caches..." -ForegroundColor Yellow
$BrowserCaches = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*.default*\cache2"
)
foreach ($cache in $BrowserCaches) {
    if ($cache -like "*`**") {
        $paths = Get-ChildItem -Path ($cache -replace '\\[^\\]*$', '') -Filter ($cache.Split('\')[-1]) -Directory -Recurse -ErrorAction SilentlyContinue
    } else {
        $paths = @($cache)
    }
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            try {
                Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
            } catch {}
        }
    }
}
Write-Host "Browser caches cleared." -ForegroundColor Green

# --- Remove Windows Store cache ---
Write-Host "`nClearing Windows Store cache..." -ForegroundColor Yellow
Start-Process "wsreset.exe" -WindowStyle Hidden
Start-Sleep -Seconds 3
Get-Process WSReset -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "Windows Store cache cleared." -ForegroundColor Green

# --- Clean DNS cache ---
Write-Host "`nFlushing DNS cache..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Host "DNS cache flushed." -ForegroundColor Green

# --- Remove common OEM bloatware packages ---
Write-Host "`nRemoving common OEM bloatware..." -ForegroundColor Yellow
$BloatApps = @(
    # Dell bloatware
    "DellUpdate",
    "DellSupportAssist",
    "DellCustomerConnect",
    "DellDigitalDelivery",
    # HP bloatware
    "HPJumpStart",
    "HPRegistration",
    "HPSupportAssistant",
    # Lenovo bloatware
    "LenovoCompanion",
    "LenovoSettings",
    # General bloatware
    "McAfee",
    "WildTangent",
    "DropboxPromotion",
    "CandyCrush",
    "BubbleWitch",
    "March of Empires",
    "Disney"
)

$removedCount = 0
foreach ($app in $BloatApps) {
    $packages = Get-AppxPackage *$app* -AllUsers -ErrorAction SilentlyContinue
    foreach ($pkg in $packages) {
        Write-Host "Removing: $($pkg.Name)" -ForegroundColor Red
        try {
            Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
            $removedCount++
        } catch {
            Write-Host "  Could not remove $($pkg.Name)" -ForegroundColor DarkYellow
        }
    }
}

Write-Host "Bloatware removal complete ($removedCount apps removed)." -ForegroundColor Green

# --- Remove broken/orphaned AppX packages ---
Write-Host "`nScanning for broken AppX packages..." -ForegroundColor Yellow
$brokenPackages = Get-AppxPackage -AllUsers | Where-Object { 
    $_.InstallLocation -and -not (Test-Path $_.InstallLocation) 
}
$brokenCount = 0
foreach ($pkg in $brokenPackages) {
    Write-Host "Removing broken package: $($pkg.Name)" -ForegroundColor Red
    try {
        Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
        $brokenCount++
    } catch {}
}
Write-Host "Broken packages removed: $brokenCount" -ForegroundColor Green

# --- Clean Windows Update leftovers ---
Write-Host "`nCleaning Windows Update files..." -ForegroundColor Yellow
try {
    Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
    Stop-Service bits -Force -ErrorAction SilentlyContinue
    
    if (Test-Path "C:\Windows\SoftwareDistribution\Download") {
        Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Start-Service wuauserv -ErrorAction SilentlyContinue
    Start-Service bits -ErrorAction SilentlyContinue
    Write-Host "Windows Update cache cleaned." -ForegroundColor Green
} catch {
    Write-Host "Could not fully clean Windows Update cache." -ForegroundColor DarkYellow
}

# --- Run Disk Cleanup with all options ---
Write-Host "`nRunning Windows Disk Cleanup utility..." -ForegroundColor Yellow
try {
    # Set all cleanup options
    $volumeCaches = @(
        "Active Setup Temp Folders",
        "BranchCache",
        "Downloaded Program Files",
        "Internet Cache Files",
        "Memory Dump Files",
        "Old ChkDsk Files",
        "Previous Installations",
        "Recycle Bin",
        "Service Pack Cleanup",
        "Setup Log Files",
        "System error memory dump files",
        "System error minidump files",
        "Temporary Files",
        "Temporary Setup Files",
        "Thumbnail Cache",
        "Update Cleanup",
        "Upgrade Discarded Files",
        "User file versions",
        "Windows Defender",
        "Windows Error Reporting Archive Files",
        "Windows Error Reporting Queue Files",
        "Windows Error Reporting System Archive Files",
        "Windows Error Reporting System Queue Files",
        "Windows ESD installation files",
        "Windows Upgrade Log Files"
    )
    
    foreach ($key in $volumeCaches) {
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$key"
        if (Test-Path $regPath) {
            Set-ItemProperty -Path $regPath -Name StateFlags0001 -Value 2 -ErrorAction SilentlyContinue
        }
    }
    
    Start-Process cleanmgr.exe -ArgumentList "/sagerun:1" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
    Write-Host "Disk Cleanup completed." -ForegroundColor Green
} catch {
    Write-Host "Disk Cleanup had issues but continued." -ForegroundColor DarkYellow
}

# --- Find and remove duplicate files (in Downloads, Documents) ---
Write-Host "`nScanning for duplicate files in Downloads and Documents..." -ForegroundColor Yellow
$searchPaths = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Documents"
)

$fileHashes = @{}
$duplicates = @()

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $hash = (Get-FileHash -Path $_.FullName -Algorithm MD5 -ErrorAction Stop).Hash
                if ($fileHashes.ContainsKey($hash)) {
                    $duplicates += $_
                } else {
                    $fileHashes[$hash] = $_.FullName
                }
            } catch {}
        }
    }
}

if ($duplicates.Count -gt 0) {
    Write-Host "Found $($duplicates.Count) duplicate files. Remove them? (Y/N)" -ForegroundColor Yellow
    $response = Read-Host
    if ($response -eq 'Y' -or $response -eq 'y') {
        foreach ($dup in $duplicates) {
            try {
                Remove-Item -Path $dup.FullName -Force -ErrorAction Stop
                Write-Host "Removed duplicate: $($dup.Name)" -ForegroundColor Red
            } catch {}
        }
        Write-Host "Duplicates removed." -ForegroundColor Green
    } else {
        Write-Host "Skipped duplicate removal." -ForegroundColor Yellow
    }
} else {
    Write-Host "No duplicates found." -ForegroundColor Green
}

# --- Clear Recycle Bin ---
Write-Host "`nEmptying Recycle Bin..." -ForegroundColor Yellow
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Write-Host "Recycle Bin emptied." -ForegroundColor Green

# --- Optimize and defrag system files ---
Write-Host "`nOptimizing system drives..." -ForegroundColor Yellow
try {
    Optimize-Volume -DriveLetter C -ReTrim -ErrorAction Stop
    Write-Host "Drive C optimized." -ForegroundColor Green
} catch {
    Write-Host "Could not optimize drive (may not be SSD)." -ForegroundColor DarkYellow
}

# --- Summary ---
Write-Host "`n================================" -ForegroundColor Cyan
$afterSpace = [math]::Round((Get-PSDrive C).Free / 1GB, 2)
$freedSpace = [math]::Round($afterSpace - $beforeSpace, 2)
Write-Host "✅ DEEP CLEANUP COMPLETE!" -ForegroundColor Green
Write-Host "`nDisk Space Summary:" -ForegroundColor White
Write-Host "  Before:     $beforeSpace GB" -ForegroundColor White
Write-Host "  After:      $afterSpace GB" -ForegroundColor White
Write-Host "  Freed:      $freedSpace GB" -ForegroundColor Yellow
Write-Host "`nCleaned:" -ForegroundColor White
Write-Host "  - Hibernation file" -ForegroundColor Gray
Write-Host "  - Temporary files & caches" -ForegroundColor Gray
Write-Host "  - Browser caches" -ForegroundColor Gray
Write-Host "  - Windows Update leftovers" -ForegroundColor Gray
Write-Host "  - Broken app packages" -ForegroundColor Gray
Write-Host "  - Bloatware" -ForegroundColor Gray
Write-Host "  - Duplicate files (if confirmed)" -ForegroundColor Gray
Write-Host "  - System optimization" -ForegroundColor Gray
Write-Host "`nRESTART YOUR COMPUTER for all changes to take effect." -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Cyan
pause
