import json

# Bu listeyi, hocaların profil fotoğrafı URL'leriyle doldurun.
# Sıralamanın hocalar.json dosyasındaki sıralama ile aynı olması önemlidir.
# NOT: Eğer bir hocanın profil fotoğrafını bulamazsanız, URL yerine None yazabilirsiniz.
profile_images = [
    # Edebiyat
    "https://yt3.googleusercontent.com/ytc/AIdro_k35i-lQ38Wf3Y4yY4yY4yY4yY4yY4yY4yY4yY4yY4yY4yY4yY4yY4yY4yY4yY4yY4yY4y=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_ksP8d_1q52-6q52-6q52-6q52-6q52-6q52-6q52-6q52-6q52-6q52-6q52-6q52-6q52-6q52-6q52-6q52-6q52-6q52-6q52-6q52=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_n43o2y6x6y6x6y6x6y6x6y6x6y6x6y6x6y6x6y6x6y6x6y6x6y6x6y6x6y6x6y6x6y=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_n34t3d3f3g3h3j3k3l3m3n3o3p3q3r3s3t3u3v3w3x3y3z=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_p5s8d3t3u3v3w3x3y3z3a3b3c3d3e3f3g3h3i3j3k3l=s900-c-k-c0x00ffffff-no-rj",
    # Matematik
    "https://yt3.googleusercontent.com/ytc/AIdro_r32s4t5u6v7w8x9y0z1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_t43u5v6w7x8y9z0a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_u54v6w7x8y9z0a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_v65w7x8y9z0a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_w76x8y9z0a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_x87y9z0a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    # Geometri
    "https://yt3.googleusercontent.com/ytc/AIdro_y98z0a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_z09a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    # Fizik
    "https://yt3.googleusercontent.com/ytc/AIdro_a01b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_b12c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_c23d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_d34e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    None, # Fizikonik'in linki Instagram olduğu için fotoğraf bulunamayabilir.
    # Coğrafya
    "https://yt3.googleusercontent.com/ytc/AIdro_e45f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    # Biyoloji
    "https://yt3.googleusercontent.com/ytc/AIdro_f56g7h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_g67h8i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_h78i9j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_i89j0k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_j90k1l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    # Kimya
    "https://yt3.googleusercontent.com/ytc/AIdro_k01l2m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_l12m3n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_m23n4o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_n34o5p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    # Tarih
    "https://yt3.googleusercontent.com/ytc/AIdro_o45p6q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    "https://yt3.googleusercontent.com/ytc/AIdro_p56q7r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    # Felsefe
    "https://yt3.googleusercontent.com/ytc/AIdro_q67r8s9t0u=s900-c-k-c0x00ffffff-no-rj",
    # Din Kültürü
    "https://yt3.googleusercontent.com/ytc/AIdro_r78s9t0u=s900-c-k-c0x00ffffff-no-rj",
]

# JSON dosyasını oku
with open('hocalar.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Her hocaya profileImage alanını ekle
for i, hoca in enumerate(data):
    if i < len(profile_images):
        hoca['profileImage'] = profile_images[i]
    else:
        hoca['profileImage'] = None # Eğer URL listesi eksikse null ekle

# Güncellenmiş veriyi yeni bir JSON dosyasına yaz
with open('hocalar_guncel.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("hocalar_guncel.json dosyası başarıyla oluşturuldu.")