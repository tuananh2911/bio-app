# Script to check Flutter installation on Windows
# Run as Administrator for automatic PATH setup

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Checking Flutter Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Git
Write-Host "Checking Git..." -ForegroundColor Yellow
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue
if ($gitInstalled) {
    Write-Host "[OK] Git is installed" -ForegroundColor Green
    git --version
} else {
    Write-Host "[FAIL] Git is not installed" -ForegroundColor Red
    Write-Host "   Download from: https://git-scm.com/download/win" -ForegroundColor Yellow
}
Write-Host ""

# Check Flutter
Write-Host "Checking Flutter..." -ForegroundColor Yellow
$flutterInstalled = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterInstalled) {
    Write-Host "[OK] Flutter is installed" -ForegroundColor Green
    flutter --version
    Write-Host ""
    Write-Host "Running Flutter Doctor..." -ForegroundColor Yellow
    flutter doctor
} else {
    Write-Host "[FAIL] Flutter is not installed" -ForegroundColor Red
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  FLUTTER INSTALLATION GUIDE" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Download Flutter SDK from:" -ForegroundColor Yellow
    Write-Host "   https://flutter.dev/docs/get-started/install/windows" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Extract to: C:\src\flutter" -ForegroundColor Yellow
    Write-Host "   (Or any folder, but NOT Program Files)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Add Flutter to PATH:" -ForegroundColor Yellow
    Write-Host "   a) Press Win+R, type: sysdm.cpl" -ForegroundColor White
    Write-Host "   b) Advanced tab > Environment Variables" -ForegroundColor White
    Write-Host "   c) Find 'Path' in User variables, click Edit" -ForegroundColor White
    Write-Host "   d) Click New and add: C:\src\flutter\bin" -ForegroundColor White
    Write-Host "   e) Click OK to save" -ForegroundColor White
    Write-Host ""
    Write-Host "   OR run this command (as Admin):" -ForegroundColor Yellow
    Write-Host "   [Environment]::SetEnvironmentVariable('Path', `$env:Path + ';C:\src\flutter\bin', 'User')" -ForegroundColor White
    Write-Host ""
    Write-Host "4. CLOSE and reopen this PowerShell/Terminal" -ForegroundColor Red -BackgroundColor Yellow
    Write-Host ""
    Write-Host "5. Run this script again to verify" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Checking Other Dependencies" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Java
Write-Host "Checking Java..." -ForegroundColor Yellow
$javaInstalled = Get-Command java -ErrorAction SilentlyContinue
if ($javaInstalled) {
    Write-Host "[OK] Java is installed" -ForegroundColor Green
    java -version
} else {
    Write-Host "[WARN] Java is not installed (needed for Android)" -ForegroundColor Yellow
    Write-Host "   Android Studio will install Java automatically" -ForegroundColor Gray
}
Write-Host ""

# Check Android SDK
Write-Host "Checking Android SDK..." -ForegroundColor Yellow
$androidHome = $env:ANDROID_HOME
if ($androidHome) {
    Write-Host "[OK] ANDROID_HOME is set: $androidHome" -ForegroundColor Green
} else {
    $defaultPath = "$env:LOCALAPPDATA\Android\Sdk"
    if (Test-Path $defaultPath) {
        Write-Host "[WARN] ANDROID_HOME not set but found SDK at: $defaultPath" -ForegroundColor Yellow
    } else {
        Write-Host "[FAIL] Android SDK is not installed" -ForegroundColor Red
        Write-Host "   Install Android Studio from: https://developer.android.com/studio" -ForegroundColor Yellow
    }
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "After installing Flutter, run:" -ForegroundColor Yellow
Write-Host "  flutter doctor" -ForegroundColor White
Write-Host ""
Write-Host "See HUONG_DAN_CAI_DAT_FLUTTER.md for detailed instructions in Vietnamese." -ForegroundColor Cyan
Write-Host ""
