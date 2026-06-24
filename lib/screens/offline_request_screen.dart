import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';

class OfflineRequestScreen extends StatefulWidget {
  const OfflineRequestScreen({super.key});

  @override
  _OfflineRequestScreenState createState() => _OfflineRequestScreenState();
}

class _OfflineRequestScreenState extends State<OfflineRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _timingController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();
  
  String _selectedGender = 'any';
  bool _isLoading = false;
  String _studentName = '';
  String _studentEmail = '';
  String _studentPhone = '';

  final List<String> _genders = ['any', 'male', 'female'];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentName = prefs.getString('user_name') ?? 'Student';
      _studentEmail = prefs.getString('user_email') ?? '';
      _studentPhone = prefs.getString('user_phone') ?? '';
    });
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/offline_request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_name': _studentName,
          'student_email': _studentEmail,
          'student_phone': _studentPhone,
          'subject': _subjectController.text,
          'class_grade': _classController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'preferred_timing': _timingController.text,
          'budget': _budgetController.text.isEmpty ? 'Negotiable' : _budgetController.text,
          'additional_info': _additionalInfoController.text,
          'preferred_tutor_gender': _selectedGender,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Offline request posted successfully! Admin will contact you soon.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to post request'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Offline Home Tutor Request',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form Card
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(color: Color(0xFF6C63FF)),
                              const SizedBox(height: 20),
                              Text(
                                'Submitting request...',
                                style: GoogleFonts.poppins(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader('📚 Course Details'),
                                const SizedBox(height: 16),
                                _buildTextField(_subjectController, 'Subject *', Icons.book, true),
                                const SizedBox(height: 16),
                                _buildTextField(_classController, 'Class/Grade *', Icons.school, true),
                                const SizedBox(height: 16),
                                
                                _buildSectionHeader('📍 Address Details'),
                                const SizedBox(height: 16),
                                _buildTextField(_addressController, 'Full Address *', Icons.home, true, maxLines: 2),
                                const SizedBox(height: 16),
                                _buildTextField(_cityController, 'City *', Icons.location_city, true),
                                const SizedBox(height: 16),
                                
                                _buildSectionHeader('⏰ Preferences'),
                                const SizedBox(height: 16),
                                _buildTextField(_timingController, 'Preferred Timing *', Icons.access_time, true),
                                const SizedBox(height: 16),
                                _buildTextField(_budgetController, 'Budget (₹/month)', Icons.currency_rupee, false, keyboardType: TextInputType.number),
                                const SizedBox(height: 16),
                                
                                _buildDropdownField(
                                  label: 'Preferred Tutor Gender',
                                  value: _selectedGender,
                                  items: _genders,
                                  icon: Icons.person,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField(_additionalInfoController, 'Additional Info', Icons.info, false, maxLines: 3),
                                const SizedBox(height: 30),
                                
                                // Info Box
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info, color: Colors.blue.shade700),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Admin will review your request and assign a suitable teacher. You will be contacted within 24 hours.',
                                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue.shade700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _submitRequest,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6C63FF),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text(
                                      'Submit Request',
                                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2D2D2D),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool validator, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator ? (value) => value!.isEmpty ? 'Please enter $label' : null : null,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item.toUpperCase()));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
