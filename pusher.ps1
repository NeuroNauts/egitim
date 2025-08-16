param(
    [string]$m
)

if (-not $m) {
    Write-Host "Lütfen commit mesajını girin."
    exit
}

# Git işlemleri
git init
git add .
git commit -m "$m"
git push origin main
