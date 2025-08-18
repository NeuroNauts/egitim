import json
import requests
from bs4 import BeautifulSoup
import re
import time
from tqdm import tqdm

def get_youtube_profile_image(channel_url):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    }
    
    try:
        response = requests.get(channel_url, headers=headers, timeout=10)
        if response.status_code != 200:
            return None
        html = response.text
        match = re.search(r'"avatar":{"thumbnails":\[{"url":"(https://[^"]+)"', html)
        if match:
            img_url = match.group(1).replace("\\u0026", "&")
            return img_url
    except Exception as e:
        print(f"Hata: {e} - {channel_url}")
    return None

# JSON dosyasını oku
with open(r"scripts\hocalar.json", "r", encoding="utf-8") as f:
    hocalar = json.load(f)

# Her hocanın profil fotoğrafını çek
for hoc in tqdm(hocalar):
    link = hoc.get("link")
    if link:
        print(f"Profil fotoğrafı alınıyor: {link}")
        profile_img = get_youtube_profile_image(link)
        hoc["profileImage"] = profile_img
        time.sleep(1)  # isteğe bağlı, YouTube'u yavaş yormamak için

# JSON dosyasını tekrar kaydet
with open(r"scripts\hocalar.json", "w", encoding="utf-8") as f:
    json.dump(hocalar, f, ensure_ascii=False, indent=4)

print("Tüm profil fotoğrafları JSON'a kaydedildi.")
