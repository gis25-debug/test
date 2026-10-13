# VocaFlow Local Web Server (Zero-Dependency PowerShell Server)
$port = 5050
$url = "http://localhost:$port/"
$folder = $PSScriptRoot

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  🌊 VocaFlow - 영어 단어 학습 앱 로컬 서버" -ForegroundColor Yellow
Write-Host "  주소: $url" -ForegroundColor Green
Write-Host "  종료하려면 이 창에서 Ctrl + C 를 누르세요." -ForegroundColor Gray
Write-Host "==================================================" -ForegroundColor Cyan

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)

try {
    $listener.Start()
} catch {
    Write-Host "포트 $port 시작 실패. 브라우저에서 index.html을 직접 열어보세요." -ForegroundColor Red
    Start-Process "$folder\index.html"
    exit
}

# 브라우저 자동 실행
Start-Process $url

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    $path = $request.Url.LocalPath.TrimStart('/')
    if ([string]::IsNullOrWhiteSpace($path)) {
        $path = "index.html"
    }

    $filePath = Join-Path $folder $path

    if (Test-Path $filePath -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
        $contentType = switch ($ext) {
            ".html" { "text/html; charset=utf-8" }
            ".css"  { "text/css; charset=utf-8" }
            ".js"   { "application/javascript; charset=utf-8" }
            ".json" { "application/json; charset=utf-8" }
            ".svg"  { "image/svg+xml" }
            ".png"  { "image/png" }
            default { "application/octet-stream" }
        }

        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentType = $contentType
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $response.StatusCode = 404
        $notFoundMsg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
        $response.OutputStream.Write($notFoundMsg, 0, $notFoundMsg.Length)
    }

    $response.OutputStream.Close()
}
