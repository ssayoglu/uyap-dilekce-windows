import sys
import os
import threading
import time
import urllib.request
import webbrowser
import subprocess

# Windows pythonw.exe altında sys.stderr ve sys.stdout None olabilir, yönlendir
if sys.stderr is None:
    try:
        sys.stderr = open(os.devnull, "w", encoding="utf-8")
    except Exception:
        pass
if sys.stdout is None:
    try:
        sys.stdout = open(os.devnull, "w", encoding="utf-8")
    except Exception:
        pass

PORT = 5678

def run_server():
    # Sunucu tarafının kendiliğinden mükerrer sekme açmasını engelle
    if "--no-browser" not in sys.argv:
        sys.argv.append("--no-browser")
    import server
    if hasattr(server, "main"):
        server.main()
    elif hasattr(server, "run"):
        server.run()

def wait_for_server(port, timeout=6.0):
    url = f"http://127.0.0.1:{port}/"
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=0.5) as resp:
                if resp.status == 200:
                    return True
        except Exception:
            time.sleep(0.15)
    return False

def launch_gui():
    url = f"http://127.0.0.1:{PORT}"
    
    # 1. pywebview varsa yerel pencere olarak çalıştır (bloklayıcı)
    try:
        import webview
        webview.create_window(
            "⚖️ UYAP Dilekçe & Şablon Yöneticisi",
            url,
            width=1024,
            height=850,
            resizable=True,
            min_size=(800, 600)
        )
        webview.start()
        return True # webview.start() bloklayıcıdır, pencere kapanınca biter
    except ImportError:
        pass
        
    # 2. Chrome / Edge App modunda çalıştır (--app=http://127.0.0.1:5678)
    edge_paths = [
        os.path.expandvars(r"%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"),
        os.path.expandvars(r"%ProgramFiles%\Microsoft\Edge\Application\msedge.exe")
    ]
    chrome_paths = [
        os.path.expandvars(r"%ProgramFiles%\Google\Chrome\Application\chrome.exe"),
        os.path.expandvars(r"%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"),
        os.path.expandvars(r"%LocalAppData%\Google\Chrome\Application\chrome.exe")
    ]
    
    for browser_exe in edge_paths + chrome_paths:
        if os.path.exists(browser_exe):
            try:
                subprocess.Popen([browser_exe, f"--app={url}"])
                return False # Asenkron açıldı, ana süreç canlı tutulmalı
            except Exception:
                pass
                
    # 3. Varsayılan tarayıcıda aç
    webbrowser.open(url)
    return False

if __name__ == "__main__":
    # Arka planda sunucuyu başlat
    t = threading.Thread(target=run_server, daemon=True)
    t.start()
    
    # Sunucunun gerçekten ayağa kalkmasını ve HTTP 200 dönmesini bekle
    wait_for_server(PORT)
    
    # Kullanıcı arayüzünü aç
    is_blocking = launch_gui()
    
    # Eğer açılan arayüz bloklayıcı değilse (Edge/Chrome/Browser), sunucu sürecini canlı tut!
    if not is_blocking:
        try:
            while t.is_alive():
                time.sleep(1)
        except (KeyboardInterrupt, SystemExit):
            pass
