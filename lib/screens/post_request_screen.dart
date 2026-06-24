import 'package:flutter/material.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  String _selectedTiming = 'Flexible';
  String _selectedMode = 'Both';
  bool _isLoading = false;
  String _studentName = '';
  String _studentEmail = '';
  int _currentStep = 0;

  final List<String> _timings = [
    'Morning (6AM-12PM)',
    'Afternoon (12PM-5PM)',
    'Evening (5PM-9PM)',
    'Weekend Only',
    'Flexible',
  ];

  final List<String> _modes = ['Online', 'Offline', 'Both'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentName = prefs.getString('user_name') ?? 'Student';
      _studentEmail = prefs.getString('user_email') ?? '';
    });
  }

  Future<void> _postRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/post_request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_name': _studentName,
          'student_email': _studentEmail,
          'subject': _subjectController.text,
          'class_level': _classController.text,
          'location':
              _locationController.text.isEmpty
                  ? 'Not specified'
                  : _locationController.text,
          'budget':
              _budgetController.text.isEmpty
                  ? 'Negotiable'
                  : _budgetController.text,
          'timing': _selectedTiming,
          'mode': _selectedMode,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Request posted successfully!'),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (!mounted) return;
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
              // Modern App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Post Tuition Request',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Indicator
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    _buildStepIndicator(0, 'Details', _currentStep >= 0),
                    const Expanded(
                      child: Divider(
                        color: Color.fromRGBO(255, 255, 255, 0.3),
                      ),
                    ),
                    _buildStepIndicator(1, 'Preferences', _currentStep >= 1),
                    const Expanded(
                      child: Divider(
                        color: Color.fromRGBO(255, 255, 255, 0.3),
                      ),
                    ),
                    _buildStepIndicator(2, 'Review', _currentStep >= 2),
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
                  child:
                      _isLoading
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: Color(0xFF6C63FF),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Posting your request...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Step 1: Basic Details
                                  if (_currentStep == 0) ...[
                                    _buildSectionHeader('📚 Course Details'),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _subjectController,
                                      label: 'Subject',
                                      hint: 'e.g., Mathematics, Physics',
                                      icon: Icons.book,
                                      validator: true,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _classController,
                                      label: 'Class/Standard',
                                      hint: 'e.g., 10th, 12th, Graduation',
                                      icon: Icons.school,
                                      validator: true,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _locationController,
                                      label: 'Location',
                                      hint: 'e.g., Mumbai, Delhi (Optional)',
                                      icon: Icons.location_on,
                                      validator: false,
                                    ),
                                  ],

                                  // Step 2: Preferences
                                  if (_currentStep == 1) ...[
                                    _buildSectionHeader('⚙️ Preferences'),
                                    const SizedBox(height: 16),
                                    _buildDropdownField(
                                      label: 'Preferred Timing',
                                      value: _selectedTiming,
                                      items: _timings,
                                      icon: Icons.access_time,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedTiming = value!;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildDropdownField(
                                      label: 'Teaching Mode',
                                      value: _selectedMode,
                                      items: _modes,
                                      icon: Icons.devices,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedMode = value!;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _budgetController,
                                      label: 'Budget',
                                      hint: 'e.g., 2000/month (Optional)',
                                      icon: Icons.currency_rupee,
                                      validator: false,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],

                                  // Step 3: Review
                                  if (_currentStep == 2) ...[
                                    _buildSectionHeader(
                                      '📋 Review Your Request',
                                    ),
                                    const SizedBox(height: 16),
                                    _buildReviewCard(),
                                  ],

                                  const SizedBox(height: 30),

                                  // Navigation Buttons
                                  Row(
                                    children: [
                                      if (_currentStep > 0)
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                _currentStep--;
                                              });
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 15,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              side: const BorderSide(
                                                color: Color(0xFF6C63FF),
                                              ),
                                            ),
                                            child: Text(
                                              'Back',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF6C63FF),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (_currentStep > 0) const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (_currentStep < 2) {
                                              if (_currentStep == 0 &&
                                                  _formKey.currentState!
                                                      .validate()) {
                                                setState(() {
                                                  _currentStep++;
                                                });
                                              } else if (_currentStep == 1) {
                                                setState(() {
                                                  _currentStep++;
                                                });
                                              }
                                            } else {
                                              _postRequest();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF6C63FF),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 15,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            _currentStep == 2
                                                ? 'Post Request'
                                                : 'Continue',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isActive
                    ? Colors.white
                    : const Color.fromRGBO(255, 255, 255, 0.3),
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: GoogleFonts.poppins(
                color: isActive ? const Color(0xFF6C63FF) : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color:
                isActive
                    ? Colors.white
                    : const Color.fromRGBO(255, 255, 255, 0.5),
          ),
        ),
      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
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
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator:
          validator
              ? (value) => value!.isEmpty ? 'Please enter $label' : null
              : null,
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
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items:
          items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildReviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewRow('Subject', _subjectController.text),
          const SizedBox(height: 12),
          _buildReviewRow('Class', _classController.text),
          const SizedBox(height: 12),
          if (_locationController.text.isNotEmpty)
            _buildReviewRow('Location', _locationController.text),
          if (_budgetController.text.isNotEmpty)
            _buildReviewRow('Budget', '₹${_budgetController.text}'),
          const SizedBox(height: 12),
          _buildReviewRow('Timing', _selectedTiming),
          const SizedBox(height: 12),
          _buildReviewRow('Mode', _selectedMode),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(color: const Color(0xFF2D2D2D)),
          ),
        ),
      ],
    );
  }
}


