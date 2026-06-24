import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';

class StudentEditProfileScreen extends StatefulWidget {
  @override
  _StudentEditProfileScreenState createState() => _StudentEditProfileScreenState();
}

class _StudentEditProfileScreenState extends State<StudentEditProfileScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _fatherPhoneController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _motherPhoneController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _studentName = '';
  String _studentEmail = '';

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
    });
    await _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/student_profile?email=${Uri.encodeComponent(_studentEmail)}'),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        setState(() {
          _phoneController.text = data['phone'] ?? '';
          _cityController.text = data['city'] ?? '';
          _stateController.text = data['state'] ?? '';
          _pincodeController.text = data['pincode'] ?? '';
          _qualificationController.text = data['qualification'] ?? '';
          _specializationController.text = data['specialization'] ?? '';
          _addressController.text = data['address'] ?? '';
          _fatherNameController.text = data['father_name'] ?? '';
          _fatherPhoneController.text = data['father_phone'] ?? '';
          _motherNameController.text = data['mother_name'] ?? '';
          _motherPhoneController.text = data['mother_phone'] ?? '';
        });
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/update_student_profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _studentEmail,
          'phone': _phoneController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'pincode': _pincodeController.text,
          'qualification': _qualificationController.text,
          'specialization': _specializationController.text,
          'address': _addressController.text,
          'father_name': _fatherNameController.text,
          'father_phone': _fatherPhoneController.text,
          'mother_name': _motherNameController.text,
          'mother_phone': _motherPhoneController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Profile updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to update profile'),
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
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Edit Profile',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading || _isSubmitting
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Color(0xFF6C63FF)),
                              SizedBox(height: 20),
                              Text(
                                _isSubmitting ? 'Updating...' : 'Loading profile...',
                                style: GoogleFonts.poppins(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Header
                              Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Color(0xFF6C63FF).withOpacity(0.1),
                                      child: Text(
                                        _studentName[0].toUpperCase(),
                                        style: TextStyle(fontSize: 40, color: Color(0xFF6C63FF)),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      _studentName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _studentEmail,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Contact Details
                              Text(
                                'Contact Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              _buildTextField(_phoneController, 'Phone Number', Icons.phone, false),
                              SizedBox(height: 12),
                              _buildTextField(_cityController, 'City', Icons.location_city, false),
                              SizedBox(height: 12),
                              _buildTextField(_stateController, 'State', Icons.map, false),
                              SizedBox(height: 12),
                              _buildTextField(_pincodeController, 'Pincode', Icons.pin_drop, false),
                              SizedBox(height: 12),
                              _buildTextField(_addressController, 'Address', Icons.home, false, maxLines: 2),
                              
                              SizedBox(height: 24),
                              
                              // Academic Details
                              Text(
                                'Academic Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              _buildTextField(_qualificationController, 'Qualification', Icons.school, false),
                              SizedBox(height: 12),
                              _buildTextField(_specializationController, 'Specialization', Icons.star, false),
                              
                              SizedBox(height: 24),
                              
                              // Parent/Guardian Details
                              Text(
                                'Parent / Guardian Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              _buildTextField(_fatherNameController, "Father's Name", Icons.man, false),
                              SizedBox(height: 12),
                              _buildTextField(_fatherPhoneController, "Father's Phone", Icons.phone_android, false),
                              SizedBox(height: 12),
                              _buildTextField(_motherNameController, "Mother's Name", Icons.woman, false),
                              SizedBox(height: 12),
                              _buildTextField(_motherPhoneController, "Mother's Phone", Icons.phone_iphone, false),
                              
                              SizedBox(height: 30),
                              
                              // Update Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF6C63FF),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Update Profile',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool validator, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF6C63FF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator ? (value) => value!.isEmpty ? 'Please enter $label' : null : null,
    );
  }
}