<#
  Local dev server with live reload. Nothing to install.

  Start:  double-click start-dev.cmd
     or:  powershell -ExecutionPolicy Bypass -File dev-server.ps1 [-Port 5500] [-NoOpen]
  Stop:   Ctrl+C (or close the window)

  CSS changes are swapped in without a page reload; any other change reloads the page.
#>
param(
  [int]$Port = 5500,
  [switch]$NoOpen
)

$root = $PSScriptRoot
$rootPrefix = $root.TrimEnd('\') + '\'
$url = "http://localhost:$Port/"

$mime = @{
  ".html" = "text/html; charset=utf-8"; ".css" = "text/css; charset=utf-8"; ".js" = "text/javascript; charset=utf-8"
  ".json" = "application/json"; ".svg" = "image/svg+xml"; ".png" = "image/png"; ".jpg" = "image/jpeg"; ".jpeg" = "image/jpeg"
  ".gif" = "image/gif"; ".webp" = "image/webp"; ".ico" = "image/x-icon"; ".pdf" = "application/pdf"
  ".txt" = "text/plain; charset=utf-8"; ".md" = "text/plain; charset=utf-8"; ".woff2" = "font/woff2"
}

# Injected into every HTML page: polls for changes, swaps CSS in place, reloads for anything else
$client = @'
<script>
(() => {
  let base = null;
  setInterval(async () => {
    try {
      const v = await (await fetch("/__livereload", { cache: "no-store" })).json();
      if (!base) { base = v; return; }
      if (v.other !== base.other) return location.reload();
      if (v.css !== base.css) {
        base.css = v.css;
        document.querySelectorAll('link[rel="stylesheet"]').forEach((link) => {
          const u = new URL(link.href);
          if (u.origin !== location.origin) return;
          u.searchParams.set("v", v.css);
          link.href = u.href;
        });
      }
    } catch {}
  }, 1000);
})();
</script>
'@

# Latest modified time for CSS files and for everything else (plus file count, to catch deletes/renames)
function Get-Versions {
  $css = 0L; $other = 0L; $count = 0
  Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\\.git\\' } |
    ForEach-Object {
      $count++
      $t = $_.LastWriteTimeUtc.Ticks
      if ($_.Extension -eq ".css") { if ($t -gt $css) { $css = $t } }
      elseif ($t -gt $other) { $other = $t }
    }
  '{"css":"' + $css + '","other":"' + $other + '-' + $count + '"}'
}

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($url)
try { $listener.Start() }
catch {
  Write-Host "Couldn't start on port $Port. Is it already in use? Try: -Port 5501" -ForegroundColor Red
  exit 1
}

Write-Host "Serving $root"
Write-Host "Live reload running at $url  (Ctrl+C to stop)" -ForegroundColor Green
if (-not $NoOpen) { Start-Process $url }

try {
  while ($listener.IsListening) {
    $task = $listener.GetContextAsync()
    while (-not $task.Wait(250)) { }   # short waits keep Ctrl+C responsive
    $ctx = $task.Result
    $req = $ctx.Request
    $res = $ctx.Response
    $res.AddHeader("Cache-Control", "no-store")

    try {
      $path = [Uri]::UnescapeDataString($req.Url.AbsolutePath)

      if ($path -eq "/__livereload") {
        $res.ContentType = "application/json"
        $bytes = [Text.Encoding]::UTF8.GetBytes((Get-Versions))
      }
      else {
        $file = [IO.Path]::GetFullPath([IO.Path]::Combine($root, $path.TrimStart('/')))
        if ([IO.Directory]::Exists($file)) { $file = [IO.Path]::Combine($file, "index.html") }

        if (-not $file.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase) -or -not [IO.File]::Exists($file)) {
          $res.StatusCode = 404
          $res.ContentType = "text/plain; charset=utf-8"
          $bytes = [Text.Encoding]::UTF8.GetBytes("Not found: $path")
        }
        else {
          $ext = [IO.Path]::GetExtension($file).ToLower()
          $res.ContentType = if ($mime[$ext]) { $mime[$ext] } else { "application/octet-stream" }
          if ($ext -eq ".html") {
            $html = [IO.File]::ReadAllText($file)
            $i = $html.LastIndexOf("</body>", [StringComparison]::OrdinalIgnoreCase)
            $html = if ($i -ge 0) { $html.Insert($i, $client) } else { $html + $client }
            $bytes = [Text.Encoding]::UTF8.GetBytes($html)
          }
          else {
            $bytes = [IO.File]::ReadAllBytes($file)
          }
        }
        Write-Host ("{0} {1}" -f $res.StatusCode, $path) -ForegroundColor DarkGray
      }

      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    }
    catch {
      Write-Host "Error serving $($req.Url): $_" -ForegroundColor Red
    }
    finally {
      $res.Close()
    }
  }
}
finally {
  $listener.Stop()
  $listener.Close()
  Write-Host "Server stopped."
}
