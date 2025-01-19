import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:math' show max;
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/painting.dart';
import 'user_role.dart';  // Add this import

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    GempaBumiPage(),
    PrakiraanCuacaPage(),
    AsmaulHusnaPage(),
    RegistrationListPage(), // Add this new page
    TentangAplikasiPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1,
              blurRadius: 10,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed, // Change this to fixed
            selectedItemColor: Colors.blue[700],
            unselectedItemColor: Colors.grey,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.terrain),
                label: 'Gempa Bumi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cloud),
                label: 'Cuaca',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mosque),
                label: 'Asmaul Husna',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Pendaftar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.info),
                label: 'Tentang',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nrpController = TextEditingController();
  List<String> selectedMatkul = [];
  final List<String> matkulList = ['OOP', 'Jarkom', 'PCD'];
  bool isSubmitting = false;

  @override
  void dispose() {
    _namaController.dispose();
    _nrpController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && selectedMatkul.isNotEmpty) {
      setState(() => isSubmitting = true);
      try {
        await FirebaseFirestore.instance.collection('aslab').add({
          'nama': _namaController.text,
          'nrp': _nrpController.text,
          'matkul': selectedMatkul,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Text('Pendaftaran Berhasil'),
              ],
            ),
            content: Text('Data pendaftaran Anda telah berhasil disimpan.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetForm();
                },
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Error: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => isSubmitting = false);
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange, size: 30),
              SizedBox(width: 10),
              Text('Form Belum Lengkap'),
            ],
          ),
          content: Text('Mohon lengkapi semua field dan pilih minimal satu mata kuliah.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _namaController.clear();
    _nrpController.clear();
    setState(() => selectedMatkul = []);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Text(
            'Pendaftaran Asisten Lab',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.blue),
              onPressed: _resetForm,
              tooltip: 'Reset Form',
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 24),
                  _buildRegistrationForm(),
                  SizedBox(height: 16),
                  _buildSubmitButton(),
                  SizedBox(height: 16),
                  _buildLogoutButton(),
                ],
              ),
            ),
            if (isSubmitting)
              Container(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.school, color: Colors.white, size: 40),
          SizedBox(height: 16),
          Text(
            'Pendaftaran Asisten Laboratorium',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Lengkapi form di bawah ini dengan data yang valid',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(
                controller: _namaController,
                label: 'Nama Lengkap',
                icon: Icons.person,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Nama tidak boleh kosong' : null,
              ),
              SizedBox(height: 20),
              _buildInputField(
                controller: _nrpController,
                label: 'NRP',
                icon: Icons.badge,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'NRP tidak boleh kosong' : null,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              Text(
                'Pilih Mata Kuliah:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: matkulList.map((matkul) {
                  return FilterChip(
                    label: Text(matkul),
                    selected: selectedMatkul.contains(matkul),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedMatkul.add(matkul);
                        } else {
                          selectedMatkul.remove(matkul);
                        }
                      });
                    },
                    selectedColor: Colors.blue[100],
                    checkmarkColor: Colors.blue[700],
                    labelStyle: TextStyle(
                      color: selectedMatkul.contains(matkul)
                          ? Colors.blue[700]
                          : Colors.grey[800],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Text(
          isSubmitting ? 'Mendaftarkan...' : 'Daftar Sekarang',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        icon: Icon(Icons.logout, color: Colors.red),
        label: Text(
          'Keluar',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class GempaBumiPage extends StatefulWidget {
  @override
  _GempaBumiPageState createState() => _GempaBumiPageState();
}

class _GempaBumiPageState extends State<GempaBumiPage> {
  List<dynamic> gempaBumiData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGempaBumiData();
  }

  Future<void> fetchGempaBumiData() async {
    try {
      final response = await http.get(
        Uri.parse('https://data.bmkg.go.id/DataMKG/TEWS/gempadirasakan.json'),
      );

      if (response.statusCode == 200) {
        setState(() {
          gempaBumiData = json.decode(response.body)['Infogempa']['gempa'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Data Gempa Bumi',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue),
            onPressed: fetchGempaBumiData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : gempaBumiData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, size: 64, color: Colors.orange),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada data gempa',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Statistik Gempa',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      GempaBumiStats(gempaBumiData: gempaBumiData),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Daftar Gempa Terkini',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: gempaBumiData.length,
                        itemBuilder: (context, index) {
                          var gempa = gempaBumiData[index];
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                // Show detailed view if needed
                              },
                              child: Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getMagnitudeColor(double.parse(gempa['Magnitude'])),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'M ${gempa['Magnitude']}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${gempa['Tanggal']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Text(
                                              '${gempa['Jam']}',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(height: 24),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 16, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            gempa['Wilayah'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildInfoRow(Icons.explore, 'Koordinat: ${gempa['Coordinates']}'),
                                              SizedBox(height: 8),
                                              _buildInfoRow(Icons.compass_calibration, 'Lintang: ${gempa['Lintang']}'),
                                              SizedBox(height: 8),
                                              _buildInfoRow(Icons.compass_calibration, 'Bujur: ${gempa['Bujur']}'),
                                              SizedBox(height: 8),
                                              _buildInfoRow(Icons.waves, 'Kedalaman: ${gempa['Kedalaman']}'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (gempa['Dirasakan'] != null && gempa['Dirasakan'].isNotEmpty) ...[
                                      SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.orange[300]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.warning_amber, size: 16, color: Colors.orange[800]),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Dirasakan:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange[800],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              gempa['Dirasakan'],
                                              style: TextStyle(color: Colors.orange[900]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude >= 7.0) return Colors.red[700]!;
    if (magnitude >= 6.0) return Colors.red;
    if (magnitude >= 5.0) return Colors.orange;
    if (magnitude >= 4.0) return Colors.yellow[700]!;
    return Colors.green;
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue[700]),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }
}

class GempaBumiStats extends StatelessWidget {
  final List<dynamic> gempaBumiData;

  GempaBumiStats({required this.gempaBumiData});

  Map<String, int> _getMagnitudeDistribution() {
    Map<String, int> distribution = {};
    for (var gempa in gempaBumiData) {
      double magnitude = double.parse(gempa['Magnitude']);
      String range = '${magnitude.floor()}-${magnitude.floor() + 1}';
      distribution[range] = (distribution[range] ?? 0) + 1;
    }
    return Map.fromEntries(
      distribution.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
  }

  @override
  Widget build(BuildContext context) {
    final magnitudeData = _getMagnitudeDistribution();
    final maxCount = magnitudeData.values.reduce(max);

    return Column(
      children: [
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Distribusi Magnitudo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: magnitudeData.length,
                    itemBuilder: (context, index) {
                      String range = magnitudeData.keys.elementAt(index);
                      int count = magnitudeData[range]!;
                      double percentage = count / maxCount;
                      
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              count.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: 40,
                              height: 140 * percentage,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.7),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'M$range',
                              style: TextStyle(fontSize: 12),
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
        // Data table with improved styling
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
              dataTextStyle: TextStyle(
                color: Colors.black87,
              ),
              columnSpacing: 24,
              horizontalMargin: 12,
              columns: [
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Magnitudo')),
                DataColumn(label: Text('Kedalaman')),
                DataColumn(label: Text('Wilayah')),
              ],
              rows: gempaBumiData.map<DataRow>((gempa) {
                return DataRow(
                  cells: [
                    DataCell(Text(gempa['Tanggal'])),
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getMagnitudeColor(double.parse(gempa['Magnitude'])).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          gempa['Magnitude'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    DataCell(Text(gempa['Kedalaman'])),
                    DataCell(Text(gempa['Wilayah'])),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude >= 7.0) return Colors.red[700]!;
    if (magnitude >= 6.0) return Colors.red;
    if (magnitude >= 5.0) return Colors.orange;
    if (magnitude >= 4.0) return Colors.yellow[700]!;
    return Colors.green;
  }
}

class PrakiraanCuacaPage extends StatefulWidget {
  @override
  _PrakiraanCuacaPageState createState() => _PrakiraanCuacaPageState();
}

class _PrakiraanCuacaPageState extends State<PrakiraanCuacaPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? cuacaData;
  bool _isLoading = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    fetchPrakiraanCuaca();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> fetchPrakiraanCuaca() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=32.73.14.1002'),
      );

      if (response.statusCode == 200) {
        // Print raw response untuk debugging
        print('Raw response: ${response.body}');
        
        final decodedData = json.decode(response.body);
        setState(() {
          cuacaData = decodedData;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data cuaca: ${e.toString()}')),
        );
      }
    }
  }

  String formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      final hari = _getDayName(dt.weekday);
      final bulan = _getMonthName(dt.month);
      return '$hari, ${dt.day} $bulan ${dt.year}\n${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error formatting date: $e');
      return dateTimeStr;
    }
  }

  String _getDayName(int day) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    return days[day % 7];
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  List<dynamic> _extractCuacaList(Map<String, dynamic> data) {
    try {
      final List<dynamic> dataList = data['data'];
      if (dataList.isEmpty) return [];
      
      final firstData = dataList[0];
      if (firstData == null) return [];
      
      final cuacaData = firstData['cuaca'];
      if (cuacaData is List && cuacaData.isNotEmpty && cuacaData[0] is List) {
        return cuacaData[0];
      }
      return [];
    } catch (e) {
      print('Error extracting cuaca list: $e');
      return [];
    }
  }

  IconData _getWeatherIcon(String? weatherDesc) {
    if (weatherDesc == null) return Icons.cloud_off;
    weatherDesc = weatherDesc.toLowerCase();
    if (weatherDesc.contains('hujan')) return Icons.water_drop;
    if (weatherDesc.contains('cerah')) return Icons.wb_sunny;
    if (weatherDesc.contains('berawan')) return Icons.cloud;
    if (weatherDesc.contains('mendung')) return Icons.cloud_queue;
    if (weatherDesc.contains('kabut')) return Icons.foggy;
    return Icons.cloud;
  }

  Color _getWeatherColor(String? weatherDesc) {
    if (weatherDesc == null) return Colors.grey;
    weatherDesc = weatherDesc.toLowerCase();
    if (weatherDesc.contains('hujan')) return Colors.blue;
    if (weatherDesc.contains('cerah')) return Colors.orange;
    if (weatherDesc.contains('berawan')) return Colors.grey;
    if (weatherDesc.contains('mendung')) return Colors.blueGrey;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Prakiraan Cuaca',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue),
            onPressed: fetchPrakiraanCuaca,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 16),
                  Text('Memuat data cuaca...'),
                ],
              ),
            )
          : cuacaData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada data cuaca',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: fetchPrakiraanCuaca,
                        icon: Icon(Icons.refresh),
                        label: Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchPrakiraanCuaca,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLocationHeader(cuacaData!['lokasi']),
                        SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Prakiraan 24 Jam Kedepan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildWeatherList(_extractCuacaList(cuacaData!)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildLocationHeader(Map<String, dynamic> lokasi) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Lokasi Saat Ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildLocationInfo(Icons.business, '${lokasi['provinsi'] ?? '-'}'),
            _buildLocationInfo(Icons.location_city, '${lokasi['kotkab'] ?? '-'}'),
            _buildLocationInfo(Icons.place, '${lokasi['kecamatan'] ?? '-'}'),
            _buildLocationInfo(Icons.home, '${lokasi['desa'] ?? '-'}'),
            if (lokasi['lat'] != null && lokasi['lon'] != null)
              _buildLocationInfo(
                Icons.gps_fixed,
                '${lokasi['lat']}, ${lokasi['lon']}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherList(List<dynamic> cuacaList) {
    if (cuacaList.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Data cuaca tidak tersedia'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: cuacaList.length,
      itemBuilder: (context, index) {
        final cuaca = cuacaList[index];
        final weatherColor = _getWeatherColor(cuaca['weather_desc']);
        
        return Card(
          elevation: 3,
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              // Could show detailed view
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatDateTime(cuaca['local_datetime'] ?? ''),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              cuaca['weather_desc'] ?? 'Tidak tersedia',
                              style: TextStyle(
                                color: weatherColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _getWeatherIcon(cuaca['weather_desc']),
                        size: 40,
                        color: weatherColor,
                      ),
                    ],
                  ),
                  Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildWeatherInfo(
                          Icons.thermostat,
                          'Suhu',
                          '${cuaca['t'] ?? '-'}°C',
                          Colors.red,
                        ),
                      ),
                      Expanded(
                        child: _buildWeatherInfo(
                          Icons.water_drop,
                          'Kelembaban',
                          '${cuaca['hu'] ?? '-'}%',
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildWeatherInfo(
                          Icons.air,
                          'Angin',
                          '${cuaca['ws'] ?? '-'} km/j',
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (cuaca['tcc'] != null)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: _buildProgressInfo(
                        'Tutupan Awan',
                        double.parse(cuaca['tcc'].toString()) / 100,
                        '${cuaca['tcc']}%',
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherInfo(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressInfo(String label, double progress, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 8,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TentangAplikasiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Tentang Aplikasi',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // App Icon
            CircleAvatar(
              radius: 40, // Reduced from 80
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.computer,
                size: 50, // Reduced from 100
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 12), // Reduced spacing
            
            // App Title
            Text(
              'Aplikasi Pendaftaran\nAsisten Laboratorium Informatika',
              style: TextStyle(
                fontSize: 16, // Reduced from 20
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            
            // App Description
            Text(
              'Aplikasi untuk memudahkan proses pendaftaran dan seleksi Asisten Laboratorium di Jurusan Informatika.',
              style: TextStyle(
                fontSize: 14, // Reduced from 16
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            
            // Features
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPointText('Menyederhanakan proses pendaftaran'),
                _buildPointText('Mengelola data calon asisten laboratorium'),
                _buildPointText('Membantu administrasi pemilihan aslab'),
              ],
            ),
            SizedBox(height: 16),
            
            // Developer Section
            Text(
              'Tim Pengembang',
              style: TextStyle(
                fontSize: 16, // Reduced from 18
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 8),
            
            // Developer Cards in Row
            Row(
              children: [
                Expanded(
                  child: _buildDeveloperCard(
                    nama: 'Daffa Faris',
                    nim: '152022196',
                    role: 'Pengembang Utama',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildDeveloperCard(
                    nama: 'Naufal Zaidan',
                    nim: '152022168',
                    role: 'Pengembang Pendukung',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2), // Reduced padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16), // Reduced size
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14), // Reduced font size
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard({
    required String nama,
    required String nim,
    required String role
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              nama,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'NIM: $nim',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              role,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AsmaulHusnaPage extends StatefulWidget {
  @override
  _AsmaulHusnaPageState createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends State<AsmaulHusnaPage> {
  List<dynamic> asmaulHusnaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAsmaulHusna();
  }

  Future<void> fetchAsmaulHusna() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.myquran.com/v2/husna/semua'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          asmaulHusnaList = data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Asmaul Husna',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue),
            onPressed: fetchAsmaulHusna,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: fetchAsmaulHusna,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: asmaulHusnaList.length,
                itemBuilder: (context, index) {
                  final asma = asmaulHusnaList[index];
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${asma['id']}',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      asma['latin'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                    Text(
                                      asma['indo'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            child: Text(
                              asma['arab'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                height: 1.5,
                                fontSize: 32,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class RegistrationListPage extends StatelessWidget {
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diterima':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(BuildContext context, String docId, String currentStatus) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Diterima'),
                onTap: () async {
                  await _changeStatus(docId, 'Diterima');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Ditolak'),
                onTap: () async {
                  await _changeStatus(docId, 'Ditolak');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Pending'),
                onTap: () async {
                  await _changeStatus(docId, 'Pending');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _changeStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('aslab')
          .doc(docId)
          .update({'status': newStatus});
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  Future<void> _confirmDelete(BuildContext context, String docId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus data ini?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('aslab')
                    .doc(docId)
                    .delete();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Data Pendaftar Aslab',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.people_outline, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text(
                  'Daftar Semua Pendaftar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('aslab')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              return _buildRegistrationCard(context, doc.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildRegistrationCard(BuildContext context, String docId, Map<String, dynamic> data) {
    var timestamp = data['timestamp'] as Timestamp?;
    var formattedDate = timestamp != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate())
        : 'Waktu tidak tersedia';
    var status = data['status'] ?? 'Pending';

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue[700]),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['nama'] ?? 'Nama tidak tersedia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'NRP: ${data['nrp'] ?? '-'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Mata Kuliah'),
                SizedBox(height: 8),
                _buildMatkulList(data['matkul'] as List<dynamic>?),
                SizedBox(height: 16),
                _buildSectionTitle('Informasi Tambahan'),
                SizedBox(height: 8),
                _buildInfoRow(
                  Icons.access_time,
                  'Waktu Pendaftaran',
                  formattedDate,
                ),
                // Add more info rows as needed
              ],
            ),
          ),
          // Only show action bar for admin
          if (UserRole.role == 'admin') _buildActionBar(context, docId, status),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildMatkulList(List<dynamic>? matkul) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: matkul?.map((m) => _buildMatkulChip(m.toString())).toList() ?? [],
    );
  }

  Widget _buildMatkulChip(String matkul) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Text(
        matkul,
        style: TextStyle(
          color: Colors.blue[700],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, String docId, String status) {
    if (UserRole.role != 'admin') return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            icon: Icon(Icons.edit, size: 18),
            label: Text('Update Status'),
            onPressed: () => _updateStatus(context, docId, status),
          ),
          SizedBox(width: 8),
          TextButton.icon(
            icon: Icon(Icons.delete, size: 18, color: Colors.red),
            label: Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () => _confirmDelete(context, docId),
          ),
        ],
      ),
    );
  }

  void _showActionSheet(BuildContext context, String docId, String status) {
    // Only show action sheet for admin
    if (UserRole.role != 'admin') return;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Update Status'),
              onTap: () {
                Navigator.pop(context);
                _updateStatus(context, docId, status);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Hapus', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, docId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat data...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text('Error: $error'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada pendaftar',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
