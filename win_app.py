import sys
import os
import threading
import time
import urllib.request
import webbrowser
import subprocess

PORT = 5678

def run_server():
    from server import main as start_server
    start_server()

def launch_gui():
    time.sleep(1.0)
    url = f"http://127.0.0.1:{PORT}"
    
    # 1. Try pywebview for native Windows window experience
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
        return
    except ImportError:
        pass
        
    # 2. Try Chrome / Edge in App mode (--app=http://127.0.0.1:5678)
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
                return
            except Exception:
                pass
                
    # 3. Fallback to default system browser
    webbrowser.open(url)

if __name__ == "__main__":
    t = threading.Thread(target=run_server, daemon=True)
    t.start()
    launch_gui()
