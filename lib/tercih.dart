import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Veri Modeli
// Firestore'dan gelen veriyi tutmak için bir sınıf oluşturun.
class UniData {
  final String bolum;
  final String universite;
  final String puanTuru;
  final Map<String, int> siralamalar;
  final Map<String, double> tabanPuanlar;
  final Map<String, int> kontenjanlar;

  UniData({
    required this.bolum,
    required this.universite,
    required this.puanTuru,
    required this.siralamalar,
    required this.tabanPuanlar,
    required this.kontenjanlar,
  });

  // Firestore DocumentSnapshot'ı UniData'ya dönüştüren fabrika constructor'ı
  factory UniData.fromMap(Map<String, dynamic> map) {
    return UniData(
      bolum: map['Bölüm'] ?? '',
      universite: map['Üniversite'] ?? '',
      puanTuru: map['PuanTürü'] ?? '',
      siralamalar: {
        '2021': map['Sıralama_2021'] as int? ?? 0,
        '2022': map['Sıralama_2022'] as int? ?? 0,
        '2023': map['Sıralama_2023'] as int? ?? 0,
        '2024': map['Sıralama_2024'] as int? ?? 0,
      },
      tabanPuanlar: {
        '2021': (map['TabanPuan_2021'] as num?)?.toDouble() ?? 0.0,
        '2022': (map['TabanPuan_2022'] as num?)?.toDouble() ?? 0.0,
        '2023': (map['TabanPuan_2023'] as num?)?.toDouble() ?? 0.0,
        '2024': (map['TabanPuan_2024'] as num?)?.toDouble() ?? 0.0,
      },
      kontenjanlar: {
        '2021': map['Kontenjan_2021_num'] as int? ?? 0,
        '2022': map['Kontenjan_2022_num'] as int? ?? 0,
        '2023': map['Kontenjan_2023_num'] as int? ?? 0,
        '2024': map['Kontenjan_2024_num'] as int? ?? 0,
      },
    );
  }
}

class TercihPage extends StatefulWidget {
  final double userRank;
  final String userPuanTuru;

  const TercihPage({
    super.key,
    required this.userRank,
    required this.userPuanTuru,
  });

  @override
  State<TercihPage> createState() => _TercihPageState();
}

class _TercihPageState extends State<TercihPage> {
  final TextEditingController _searchController = TextEditingController();
  List<UniData> _allUnis = [];
  List<UniData> _filteredUnis = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUnis();
    _searchController.addListener(_filterUnis);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUnis);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUnis() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('unis').get();
      _allUnis = querySnapshot.docs.map((doc) {
        return UniData.fromMap(doc.data());
      }).toList();
      
      // setState'i çağırmadan önce mounted kontrolü yap
      if (mounted) {
        _filterUnis();
      }
    } catch (e) {
      // setState'i çağırmadan önce mounted kontrolü yap
      if (mounted) {
        setState(() {
          _errorMessage = "Veri yüklenirken bir hata oluştu: $e";
        });
      }
    } finally {
      // setState'i çağırmadan önce mounted kontrolü yap
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterUnis() {
    final searchQuery = _searchController.text.toLowerCase();
    setState(() {
      _filteredUnis = _allUnis.where((uni) {
        final matchesPuanTuru = uni.puanTuru == widget.userPuanTuru;
        final matchesSearch = uni.bolum.toLowerCase().contains(searchQuery) ||
            uni.universite.toLowerCase().contains(searchQuery);
        return matchesPuanTuru && matchesSearch;
      }).toList();
      // Sıralamayı 2024 yılına göre küçükten büyüğe yap
      _filteredUnis.sort((a, b) => a.siralamalar['2024']!.compareTo(b.siralamalar['2024']!));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Üniversite Tercih Robotu'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Üniversite veya Bölüm Ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Expanded(
              child: Center(child: Text(_errorMessage!)),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _filteredUnis.length,
                itemBuilder: (context, index) {
                  final uni = _filteredUnis[index];
                  final siralama2024 = uni.siralamalar['2024'];
                  final bool isCloseRank = (siralama2024! >= widget.userRank * 0.9 && siralama2024 <= widget.userRank * 1.1) ||
                                           (siralama2024 <= widget.userRank * 0.9 && siralama2024 >= widget.userRank * 0.7);

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: isCloseRank ? Colors.lightGreen[50] : null,
                    child: ListTile(
                      title: Text(
                        uni.bolum,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        uni.universite,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      trailing: isCloseRank ? const Icon(Icons.star, color: Colors.amber) : null,
                      onTap: () {
                        // Detay sayfasına gitme fonksiyonu eklenebilir
                      },
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('2024 S.', style: TextStyle(fontSize: 10)),
                          Text(
                            siralama2024.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}