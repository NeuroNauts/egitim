import 'package:flutter/material.dart';

class KaynakOnerisiPage extends StatefulWidget {
  const KaynakOnerisiPage({super.key});

  @override
  State<KaynakOnerisiPage> createState() => _KaynakOnerisiPageState();
}

class _KaynakOnerisiPageState extends State<KaynakOnerisiPage> {
  String? _selectedSubject = 'Matematik';
  String? _selectedDifficulty = 'Kolay';
  List<String> _recommendations = [];

  // Örnek kitap önerileri verisi.
  // Bu kısmı internetten topladığınız gerçek verilerle doldurabilirsiniz.
  final Map<String, Map<String, List<String>>> _sourceRecommendations = {
    'Matematik': {
      'Kolay': ['Antrenmanlarla Matematik', 'Karekök Yayınları MPS'],
      'Orta': ['Acil Matematik', '3D Yayınları', 'Limit Yayınları'],
      'Zor': ['Bilgi Sarmal Matematik', 'Çap Yayınları', 'Orijinal Yayınları'],
    },
    'Fizik': {
      'Kolay': ['Limit Yayınları MPS', 'Palme Yayınları'],
      'Orta': ['Esen Yayınları', 'Çap Yayınları Fasikülleri'],
      'Zor': ['Nihat Bilgin Yayınları', '3D Yayınları Fizik'],
    },
    'Kimya': {
      'Kolay': ['Palme Yayınları', 'Fen Bilimleri Yayınları'],
      'Orta': ['Aydın Yayınları', ' orbital Yayınları'],
      'Zor': ['Miray Yayınları', 'Bilgi Sarmal Kimya'],
    },
    'Biyoloji': {
      'Kolay': ['Palme Yayınları', 'Biyotik Yayınları'],
      'Orta': ['Limit Yayınları', 'Çap Yayınları'],
      'Zor': ['Apodemi Yayınları', '3D Yayınları'],
    },
  };

  void _getRecommendations() {
    setState(() {
      _recommendations = _sourceRecommendations[_selectedSubject]![_selectedDifficulty] ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    _getRecommendations(); // Sayfa açıldığında ilk önerileri listeler
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaynak Önerileri', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFBBDEFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSelectionSection(),
            const SizedBox(height: 20),
            _buildRecommendationList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Konu Seçin',
                border: OutlineInputBorder(),
              ),
              value: _selectedSubject,
              items: _sourceRecommendations.keys.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSubject = newValue;
                  _getRecommendations();
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Zorluk Seviyesi Seçin',
                border: OutlineInputBorder(),
              ),
              value: _selectedDifficulty,
              items: ['Kolay', 'Orta', 'Zor'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDifficulty = newValue;
                  _getRecommendations();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationList() {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kitap Önerileri',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const Divider(height: 20, thickness: 1),
              Expanded(
                child: _recommendations.isEmpty
                    ? const Center(
                        child: Text(
                          'Bu konu ve seviye için öneri bulunamadı.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _recommendations.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.book, color: Colors.blueAccent),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${index + 1}. ${_recommendations[index]}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}