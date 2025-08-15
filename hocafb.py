import firebase_admin
from firebase_admin import credentials, firestore
import json

# JSON dosyanın yolu
json_path = "hocalar.json"

# Firebase Admin SDK JSON dosyan
cred = credentials.Certificate("egitim2-e4553-firebase-adminsdk-fbsvc-335bd6a501.json")
firebase_admin.initialize_app(cred)

db = firestore.client()


# JSON dosyasını oku
with open(json_path, "r", encoding="utf-8") as f:
    data = json.load(f)

# Her bir hocayı 'teachers' koleksiyonuna ekle
for item in data:
    doc_ref = db.collection("channels").document()  # otomatik ID
    doc_ref.set(item)

print("Veriler Firestore'a yüklendi.")


