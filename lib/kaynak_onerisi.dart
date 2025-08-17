import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// Kaynak (Kitap) verilerini tutmak için model sınıfı
class Kaynak {
  final String category;
  final String productUrl;
  final String title;
  final String publisher;
  final String authors;
  final String imageUrl;
  final String branch;

  Kaynak({
    required this.category,
    required this.productUrl,
    required this.title,
    required this.publisher,
    required this.authors,
    required this.imageUrl,
    required this.branch,
  });

  factory Kaynak.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Kaynak(
      category: data['category'] ?? '',
      productUrl: data['product_url'] ?? '',
      title: data['title'] ?? '',
      publisher: data['publisher'] ?? '',
      authors: data['authors'] ?? '',
      imageUrl: data['image_urls'] ?? '',
      branch: data['branch'] ?? '',
    );
  }
}

class KaynakOnerisiPage extends StatefulWidget {
  const KaynakOnerisiPage({super.key});

  @override
  State<KaynakOnerisiPage> createState() => _KaynakOnerisiPageState();
}

class _KaynakOnerisiPageState extends State<KaynakOnerisiPage> {
  String? _selectedBranch = 'Matematik';
  String? _selectedCategory = 'Tümü';
  String? _selectedPublisher = 'Tümü'; // Yeni state değişkeni
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  final List<String> _branches = [
    'Matematik', 'Geometri', 'Fizik', 'Kimya', 'Biyoloji', 'Edebiyat',
    'Tarih', 'Din', 'Felsefe', 'Coğrafya'
  ];

  final List<String> _categories = [
    'Tümü', 'AYT Konu Anlatım', 'AYT Soru Bankası', 'TYT Konu Anlatım', 'TYT Soru Bankası'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _selectedPublisher = 'Tümü'; // Arama değiştiğinde yayınevini sıfırla
        _selectedCategory = 'Tümü'; // Arama değiştiğinde kategoriyi sıfırla
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              decoration: const InputDecoration(labelText: 'Ders Seçin', border: OutlineInputBorder()),
              value: _selectedBranch,
              items: _branches.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBranch = newValue;
                  _selectedCategory = 'Tümü';
                  _selectedPublisher = 'Tümü'; // Ders değiştiğinde yayınevini sıfırla
                  _searchController.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Kitap veya yazar ara...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Kategori Seçin', border: OutlineInputBorder()),
              value: _selectedCategory,
              items: _categories.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            // Yayınevi filtreleme menüsü
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('books')
                  .where('branch', isEqualTo: _selectedBranch)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                // Dinamik yayınevi listesini oluştur
                // Dinamik yayınevi listesini oluştur
                final allPublishers = snapshot.data!.docs
                    .map((doc) => doc['publisher'])
                    .where((publisher) => publisher != null) // publisher'ı null olmayanları filtrele
                    .cast<String>() // Kalanları String'e dönüştür
                    .toSet()
                    .toList();
                allPublishers.sort();
                allPublishers.insert(0, 'Tümü');

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Yayınevi Seçin', border: OutlineInputBorder()),
                  value: _selectedPublisher,
                  items: allPublishers.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPublisher = newValue;
                    });
                  },
                );
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
                'Kaynak Önerileri',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const Divider(height: 20, thickness: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('books')
                      .where('branch', isEqualTo: _selectedBranch)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text('Bir hata oluştu.'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('Bu ders için öneri bulunamadı.'));
                    }

                    final allBooks = snapshot.data!.docs.map((doc) => Kaynak.fromFirestore(doc)).toList();

                    final filteredBooks = allBooks.where((kaynak) {
                      final matchesCategory = _selectedCategory == 'Tümü' || kaynak.category == _selectedCategory;
                      final matchesPublisher = _selectedPublisher == 'Tümü' || kaynak.publisher == _selectedPublisher;
                      final matchesSearch = _searchQuery.isEmpty ||
                          kaynak.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          kaynak.authors.toLowerCase().contains(_searchQuery.toLowerCase());
                      return matchesCategory && matchesPublisher && matchesSearch;
                    }).toList();

                    if (filteredBooks.isEmpty) {
                      return const Center(child: Text('Aradığınız kriterlere uygun kaynak bulunamadı.'));
                    }

                    return ListView.builder(
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final kaynak = filteredBooks[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: InkWell(
                            onTap: () async {
                              final url = Uri.parse(kaynak.productUrl);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ürün sayfasına gidilemiyor.')),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                if (kaynak.imageUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      kaynak.imageUrl,
                                      width: 60,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.menu_book, color: Colors.blueAccent, size: 60);
                                      },
                                    ),
                                  ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        kaynak.title,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Yazar: ${kaynak.authors}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                      Text('Yayınevi: ${kaynak.publisher}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                      Text('Kategori: ${kaynak.category}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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