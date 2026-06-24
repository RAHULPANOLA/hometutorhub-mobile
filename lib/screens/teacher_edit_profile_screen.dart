import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';

class TeacherEditProfileScreen extends StatefulWidget {
  @override
  _TeacherEditProfileScreenState createState() => _TeacherEditProfileScreenState();
}

class _TeacherEditProfileScreenState extends State<TeacherEditProfileScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _subjectsController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _monthlyFeeController = TextEditingController();
  final TextEditingController _hourlyFeeController = TextEditingController();
  
  String _selectedMode = 'Both';
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _teacherName = '';
  String _teacherEmail = '';
  String _profilePhoto = '';

  final List<String> _modes = ['Online', 'Offline', 'Both'];

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _teacherName = prefs.getString('user_name') ?? 'Teacher';
      _teacherEmail = prefs.getString('user_email') ?? '';
    });
    await _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/teacher_profile?email=${Uri.encodeComponent(_teacherEmail)}'),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        setState(() {
          _phoneController.text = data['phone'] ?? '';
          _cityController.text = data['city'] ?? '';
          _qualificationController.text = data['qualification'] ?? '';
          _experienceController.text = data['experience']?.toString() ?? '';
          _subjectsController.text = data['subjects'] ?? '';
          _addressController.text = data['address'] ?? '';
          _whatsappController.text = data['whatsapp'] ?? '';
          _monthlyFeeController.text = data['monthly_fee']?.toString() ?? '';
          _hourlyFeeController.text = data['hourly_fee']?.toString() ?? '';
          _selectedMode = data['mode'] ?? 'Both';
          _profilePhoto = data['profile_photo'] ?? '';
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
        Uri.parse('${AppConfig.apiUrl}/update_teacher_profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _teacherEmail,
          'phone': _phoneController.text,
          'city': _cityController.text,
          'qualification': _qualificationController.text,
          'experience': int.tryParse(_experienceController.text) ?? 0,
          'subjects': _subjectsController.text,
          'address': _addressController.text,
          'whatsapp': _whatsappController.text,
          'monthly_fee': double.tryParse(_monthlyFeeController.text) ?? 0,
          'hourly_fee': double.tryParse(_hourlyFeeController.text) ?? 0,
          'mode': _selectedMode,
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
                              // Profile Photo
                              Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Color(0xFF6C63FF).withOpacity(0.1),
                                      child: _profilePhoto.isNotEmpty
                                          ? ClipOval(
                                              child: Image.network(
                                                _profilePhoto,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Icon(Icons.person, size: 50, color: Color(0xFF6C63FF));
                                                },
                                              ),
                                            )
                                          : Icon(Icons.person, size: 50, color: Color(0xFF6C63FF)),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      _teacherName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _teacherEmail,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextButton.icon(
                                      onPressed: () {
                                        // TODO: Implement photo upload
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Photo upload coming soon!')),
                                        );
                                      },
                                      icon: Icon(Icons.photo_camera),
                                      label: Text('Change Photo'),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Personal Details
                              Text(
                                'Personal Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              _buildTextField(_phoneController, 'Phone Number', Icons.phone, false),
                              SizedBox(height: 12),
                              _buildTextField(_whatsappController, 'WhatsApp Number', Icons.message, false),
                              SizedBox(height: 12),
                              _buildTextField(_cityController, 'City', Icons.location_city, false),
                              SizedBox(height: 12),
                              _buildTextField(_addressController, 'Address', Icons.home, false, maxLines: 2),
                              
                              SizedBox(height: 24),
                              
                              // Professional Details
                              Text(
                                'Professional Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              _buildTextField(_qualificationController, 'Qualification', Icons.school, false),
                              SizedBox(height: 12),
                              _buildTextField(_experienceController, 'Experience (Years)', Icons.timeline, false),
                              SizedBox(height: 12),
                              _buildTextField(_subjectsController, 'Subjects (comma separated)', Icons.book, false),
                              SizedBox(height: 12),
                              _buildTextField(_monthlyFeeController, 'Monthly Fee (₹)', Icons.currency_rupee, false),
                              SizedBox(height: 12),
                              _buildTextField(_hourlyFeeController, 'Hourly Fee (₹)', Icons.access_time, false),
                              SizedBox(height: 12),
                              
                              _buildDropdownField('Teaching Mode', _selectedMode, _modes, Icons.devices, (value) {
                                setState(() {
                                  _selectedMode = value!;
                                });
                              }),
                              
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

  Widget _buildDropdownField(String label, String value, List<String> items, IconData icon, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
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
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}