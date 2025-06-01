import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'helperss/helper_token.dart';

class CreateTodoPage extends StatefulWidget {
  const CreateTodoPage({super.key});

  @override
  State<CreateTodoPage> createState() => _CreateTodoPageState();
}

class _CreateTodoPageState extends State<CreateTodoPage> {
  final listController = TextEditingController();
  final dateController = TextEditingController();
  final descriptionController = TextEditingController();
  int? userId; // nullable int
  String status = 'low';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId'); // null jika belum login
    });
  }

  Future<void> createTodo() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User belum login')),
    );
    return;
  }

 final response = await http.post(
  Uri.parse('http://127.0.0.1:8000/api/todos'),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  },
  body: jsonEncode({
    'list': listController.text,
    'tanggal': dateController.text,
    'deskripsi': descriptionController.text,
    'status': status,
    'id_users': userId,
  }),
);

print('Status Code: ${response.statusCode}');
print('Response Body: ${response.body}');

if (response.statusCode == 201) {
  Navigator.pop(context, true);
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Gagal: ${response.body}')),
  );
}
  }


 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF3E5AB), // krem vintage
    appBar: AppBar(
      backgroundColor: const Color(0xFF6B4226), // coklat tua
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Tambah Todo',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Georgia',
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1), // kertas kuning vintage
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD7CCC8), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Form Todo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
                color: Color(0xFF5D4037), // coklat klasik
              ),
            ),
            const SizedBox(height: 24),

            // Nama List
            TextField(
              controller: listController,
              style: const TextStyle(color: Color(0xFF4E342E)),
              decoration: InputDecoration(
                labelText: 'Nama List',
                labelStyle: const TextStyle(color: Color(0xFF6D4C41)),
                prefixIcon: const Icon(Icons.list_alt, color: Color(0xFF6D4C41)),
                filled: true,
                fillColor: Color(0xFFFFF3E0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 16),

            // Tanggal
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  String formattedDate = pickedDate.toIso8601String().split('T')[0];
                  setState(() {
                    dateController.text = formattedDate;
                  });
                }
              },
              style: const TextStyle(color: Color(0xFF4E342E)),
              decoration: InputDecoration(
                labelText: 'Tanggal',
                labelStyle: const TextStyle(color: Color(0xFF6D4C41)),
                prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF6D4C41)),
                filled: true,
                fillColor: const Color(0xFFFFF3E0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 16),

            // Deskripsi
            TextField(
              controller: descriptionController,
              maxLines: 3,
              style: const TextStyle(color: Color(0xFF4E342E)),
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                labelStyle: const TextStyle(color: Color(0xFF6D4C41)),
                prefixIcon: const Icon(Icons.description, color: Color(0xFF6D4C41)),
                filled: true,
                fillColor: const Color(0xFFFFF3E0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 16),

            // Prioritas
            const Text(
              'Prioritas',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Georgia',
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                border: Border.all(color: const Color(0xFFD7CCC8)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: status,
                isExpanded: true,
                underline: Container(),
                dropdownColor: const Color(0xFFFFF3E0),
                style: const TextStyle(color: Color(0xFF4E342E)),
                onChanged: (val) => setState(() => status = val!),
                items: ['low', 'medium', 'high'].map((e) {
                  IconData icon = e == 'low'
                      ? Icons.arrow_downward
                      : e == 'medium'
                          ? Icons.horizontal_rule
                          : Icons.arrow_upward;
                  Color color = e == 'low'
                      ? Colors.green[700]!
                      : e == 'medium'
                          ? Colors.orange[800]!
                          : Colors.red[900]!;
                  return DropdownMenuItem(
                    value: e,
                    child: Row(
                      children: [
                        Icon(icon, color: color),
                        const SizedBox(width: 10),
                        Text(e.toUpperCase()),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: createTodo,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D6E63), // coklat muda
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}