# Add Flutter to PATH
# Run this as Administrator for automatic setup

$flutterPath = "C:\src\flutter\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

Write-Host "Current PATH includes:" -ForegroundColor Cyan
Write-Host $currentPath -ForegroundColor Gray
Write-Host ""

if ($currentPath -like "*$flutterPath*") {
    Write-Host "[OK] Flutter is already in PATH!" -ForegroundColor Green
} else {
    Write-Host "Adding Flutter to PATH..." -ForegroundColor Yellow
    try {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterPath", "User")
        Write-Host "[OK] Flutter added to PATH successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "IMPORTANT: Please close and reopen your terminal/PowerShell" -ForegroundColor Red -BackgroundColor Yellow
        Write-Host "for the PATH changes to take effect." -ForegroundColor Red -BackgroundColor Yellow
    } catch {
        Write-Host "[ERROR] Could not add to PATH automatically." -ForegroundColor Red
        Write-Host "Please add manually:" -ForegroundColor Yellow
        Write-Host "  1. Win+R, type: sysdm.cpl" -ForegroundColor White
        Write-Host "  2. Advanced > Environment Variables" -ForegroundColor White
        Write-Host "  3. Find 'Path' in User variables > Edit" -ForegroundColor White
        Write-Host "  4. New > Add: $flutterPath" -ForegroundColor White
        Write-Host "  5. OK to save" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Flutter path: $flutterPath" -ForegroundColor Cyan



