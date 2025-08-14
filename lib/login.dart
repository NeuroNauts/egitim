import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart'; // HomePage'inizin burada olduğunu varsayıyorum

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Metin kontrolcülerinin bildirimi
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Formun giriş mi yoksa kayıt mı olduğunu belirten durum değişkeni
  bool _isLogin = true;

  // Seçilen sınıf ve alan için null safety uyumlu durum değişkenleri
  String? _selectedClass;
  String? _selectedTrack;

  // Sınıf ve alan seçenekleri
  final List<String> _classOptions = ['9', '10', '11', '12', 'Mezun'];
  final List<String> _trackOptions = ['Sayısal', 'Sözel'];

  /// Giriş/Kayıt formları arasında geçiş yapar.
  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
      // Form değiştirildiğinde sınıf ve alan seçimlerini sıfırla
      _selectedClass = null;
      _selectedTrack = null;
      // İsim alanını temizle
      _nameController.clear();
    });
  }

  /// Alan seçim alanının gösterilip gösterilmeyeceğini belirler.
  /// 11, 12 veya Mezun sınıfları için alan seçimi gösterilir.
  bool _showTrackField() {
    return _selectedClass == '11' || _selectedClass == '12' || _selectedClass == 'Mezun';
  }

  /// Form gönderim işlemini gerçekleştirir (Giriş veya Kayıt).
  Future<void> _submit() async {
    // Trim ile boşlukları temizle
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Temel boş alan kontrolü
    if (email.isEmpty || password.isEmpty) {
      _showMessage("Lütfen e-posta ve şifre giriniz.");
      return;
    }

    final usersRef = FirebaseFirestore.instance.collection('users');

    try {
      if (_isLogin) {
        // Giriş işlemi
        final query = await usersRef.where('mail', isEqualTo: email).get();

        if (query.docs.isEmpty) {
          _showMessage("Böyle bir kullanıcı bulunamadı.");
          return;
        }

        final userData = query.docs.first.data();

        // ❗ ÖNEMLİ: Şifreler genellikle sunucu tarafında hashlenmeli ve karşılaştırılmalıdır.
        // Bu örnek sadece Firestore üzerindeki mevcut yapıyı kullanır.
        if (userData['password'] != password) {
          _showMessage("Şifre hatalı.");
          return;
        }

        // Başarılı giriş sonrası HomePage'e yönlendirme
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userName: userData['name'] as String)),
        );
      } else {
        // Kayıt işlemi
        String fullName = _nameController.text.trim();

        // Kayıt için gerekli alanların boş olup olmadığını kontrol et
        if (fullName.isEmpty || _selectedClass == null) {
          _showMessage("Lütfen tüm bilgileri doldurun.");
          return;
        }

        // Alan seçimi gerekiyorsa ve seçilmemişse kontrol et
        if (_showTrackField() && _selectedTrack == null) {
          _showMessage("Lütfen alan seçiniz.");
          return;
        }

        // Mail adresinin zaten kayıtlı olup olmadığını kontrol et
        final query = await usersRef.where('mail', isEqualTo: email).get();
        if (query.docs.isNotEmpty) {
          _showMessage("Bu mail adresiyle zaten kayıt var.");
          return;
        }

        // Firestore'a yeni kullanıcı ekle
        await usersRef.add({
          'mail': email,
          'password': password, // ❗ GÜVENLİK UYARISI: Şifreler üretimde HASH'lenmelidir!
          'name': fullName,
          'grade': int.tryParse(_selectedClass!),
          'track': _selectedTrack,
          'registerDate': DateTime.now(),
          'chatids': [1], // Örnek başlangıç chatid
          'id': DateTime.now().millisecondsSinceEpoch, // Basit bir benzersiz id üretimi
        });

        // Başarılı kayıt sonrası HomePage'e yönlendirme
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userName: fullName)),
        );
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      _showMessage("Bir hata oluştu: $e");
    }
  }

  /// Kullanıcıya kısa bir mesaj (SnackBar) gösterir.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2), // Mesajın görünür kalma süresi
      ),
    );
  }

  @override
  void dispose() {
    // Controller'ları bellek sızıntısını önlemek için dispose et
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Klavyeyi kapatmak için dışarı tıklama algılayıcısı
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // Arka plan gradyanı ile estetik bir görünüm
        backgroundColor: Colors.transparent, // Gradient olduğu için şeffaf olmalı
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE0F7FA), // Açık Mavi
                Color(0xFFBBDEFB), // Daha Koyu Mavi
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lumina logosu veya ikonu
                  const Icon(
                    Icons.lightbulb_outline, // Işık temasına uygun bir ikon
                    size: 90,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 16),
                  // Uygulama adı
                  const Text(
                    'Lumina',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Slogan
                  const Text(
                    'Bilginin Işığında Yolunu Aydınlat',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Giriş/Kayıt Formu Kartı
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Köşeleri yuvarlat
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            _isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                          ),
                          const SizedBox(height: 24),

                          // Ad Soyad Alanı (Kayıt formunda görünür)
                          if (!_isLogin) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: _inputDecoration(
                                'Ad Soyad',
                                Icons.person,
                              ),
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email Alanı
                          TextFormField(
                            controller: _emailController,
                            decoration: _inputDecoration(
                              'Email',
                              Icons.email,
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Şifre Alanı
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true, // Şifreyi gizler
                            decoration: _inputDecoration(
                              'Şifre',
                              Icons.lock,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Sınıf Seçim Alanı (Kayıt formunda görünür)
                          if (!_isLogin) ...[
                            DropdownButtonFormField<String>(
                              decoration: _inputDecoration(
                                'Sınıf',
                                Icons.school,
                              ),
                              items: _classOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value == 'Mezun' ? 'Mezun' : '$value. Sınıf'),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedClass = value;
                                  _selectedTrack = null; // Sınıf değişince alanı sıfırla
                                });
                              },
                              value: _selectedClass,
                            ),
                            const SizedBox(height: 16),

                            // Alan Seçim Alanı (Sadece belirli sınıflar için görünür)
                            if (_showTrackField()) ...[
                              DropdownButtonFormField<String>(
                                decoration: _inputDecoration(
                                  'Alan',
                                  Icons.category,
                                ),
                                items: _trackOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedTrack = value;
                                  });
                                },
                                value: _selectedTrack,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ],

                          // Giriş Yap/Kayıt Ol Butonu
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Daha yumuşak köşeler
                                  ),
                                  backgroundColor: Colors.blueAccent // Buton rengi
                                  ),
                              child: Text(
                                _isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                                style: const TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Form değiştirme butonu
                          TextButton(
                            onPressed: _toggleForm,
                            child: Text(
                              _isLogin
                                  ? 'Hesabınız yok mu? Kayıt olun.'
                                  : 'Zaten hesabınız var mı? Giriş yapın.',
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Ortak InputDecoration stilini döndüren yardımcı fonksiyon.
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueGrey[400]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), // Kenarları yuvarlat
        borderSide: BorderSide.none, // Kenarlık olmasın
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.8), // Hafif şeffaf arka plan
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      // Odaklandığında kenarlık rengini ayarla
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }
}