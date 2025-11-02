# Auto Install Flutter SDK for Windows
# Run this script as Administrator for automatic PATH setup

param(
    [string]$InstallPath = "C:\src\flutter",
    [switch]$AutoAddToPath = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Flutter Auto Installation Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is already installed
Write-Host "Checking if Flutter is already installed..." -ForegroundColor Yellow
$flutterInstalled = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterInstalled) {
    Write-Host "[OK] Flutter is already installed!" -ForegroundColor Green
    flutter --version
    Write-Host ""
    Write-Host "Running flutter doctor..." -ForegroundColor Yellow
    flutter doctor
    exit 0
}

# Check if Git is installed
Write-Host "Checking Git..." -ForegroundColor Yellow
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitInstalled) {
    Write-Host "[ERROR] Git is required but not installed!" -ForegroundColor Red
    Write-Host "Please install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Git is installed" -ForegroundColor Green
Write-Host ""

# Create install directory
Write-Host "Creating installation directory: $InstallPath" -ForegroundColor Yellow
$parentDir = Split-Path -Parent $InstallPath
if (-not (Test-Path $parentDir)) {
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
}
if (Test-Path $InstallPath) {
    Write-Host "[WARN] Directory already exists: $InstallPath" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to remove it and reinstall? (y/N)"
    if ($overwrite -eq "y" -or $overwrite -eq "Y") {
        Remove-Item -Path $InstallPath -Recurse -Force
    } else {
        Write-Host "Installation cancelled." -ForegroundColor Red
        exit 1
    }
}
Write-Host ""

# Method 1: Clone from GitHub (Recommended - always gets latest stable)
Write-Host "Installing Flutter SDK from GitHub (stable channel)..." -ForegroundColor Yellow
Write-Host "This may take a few minutes depending on your internet speed..." -ForegroundColor Gray
Write-Host ""

try {
    # Clone Flutter repository
    Write-Host "Cloning Flutter repository (this may take 5-15 minutes)..." -ForegroundColor Yellow
    Write-Host "Please be patient, downloading Flutter SDK..." -ForegroundColor Gray
    Write-Host ""
    
    $gitOutput = git clone https://github.com/flutter/flutter.git -b stable $InstallPath 2>&1
    $gitExitCode = $LASTEXITCODE
    
    if ($gitExitCode -ne 0) {
        Write-Host "Git clone output:" -ForegroundColor Yellow
        Write-Host $gitOutput -ForegroundColor Gray
        throw "Git clone failed with exit code $gitExitCode"
    }
    
    # Wait a moment for file system to catch up
    Start-Sleep -Seconds 2
    
    if (-not (Test-Path "$InstallPath\bin\flutter.bat")) {
        throw "Flutter installation failed - bin\flutter.bat not found. Installation may be incomplete."
    }
    
    Write-Host "[OK] Flutter SDK downloaded successfully!" -ForegroundColor Green
    Write-Host ""
    
    # Run flutter doctor to initialize
    Write-Host "Initializing Flutter (running first-time setup)..." -ForegroundColor Yellow
    $env:PATH = "$InstallPath\bin;$env:PATH"
    $flutterInit = & "$InstallPath\bin\flutter.bat" doctor --version 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Flutter initialized successfully!" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Flutter initialization had warnings (this is normal on first install)" -ForegroundColor Yellow
    }
    Write-Host ""
    
} catch {
    Write-Host "[ERROR] Failed to install Flutter: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative: Manual installation" -ForegroundColor Yellow
    Write-Host "1. Download from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host "2. Extract to: $InstallPath" -ForegroundColor White
    Write-Host "3. Add to PATH: $InstallPath\bin" -ForegroundColor White
    exit 1
}

# Add to PATH
Write-Host "Adding Flutter to PATH..." -ForegroundColor Yellow
$flutterBinPath = "$InstallPath\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$flutterBinPath*") {
    if ($AutoAddToPath -or $IsWindows) {
        try {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterBinPath", "User")
            Write-Host "[OK] Added to PATH successfully!" -ForegroundColor Green
            Write-Host "NOTE: Please restart your terminal/PowerShell for PATH changes to take effect." -ForegroundColor Yellow
        } catch {
            Write-Host "[WARN] Could not automatically add to PATH. Please add manually:" -ForegroundColor Yellow
            Write-Host "  $flutterBinPath" -ForegroundColor White
        }
    } else {
        Write-Host "[INFO] To add Flutter to PATH, run as Administrator or add manually:" -ForegroundColor Yellow
        Write-Host "  $flutterBinPath" -ForegroundColor White
    }
} else {
    Write-Host "[OK] Flutter is already in PATH" -ForegroundColor Green
}
Write-Host ""

# Verify installation
Write-Host "Verifying installation..." -ForegroundColor Yellow
$env:PATH = "$flutterBinPath;$env:PATH"
& "$flutterBinPath\flutter.bat" --version
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. CLOSE and reopen your terminal/PowerShell" -ForegroundColor White
Write-Host "2. Run: flutter doctor" -ForegroundColor White
Write-Host "3. Run: flutter doctor --android-licenses (if developing for Android)" -ForegroundColor White
Write-Host "4. For this project, run: flutter pub get" -ForegroundColor White
Write-Host ""
Write-Host "Installation path: $InstallPath" -ForegroundColor Cyan
Write-Host ""

