import 'package:flutter/material.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common Fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Teacher fields
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _subjectsController = TextEditingController();
  final TextEditingController _classesController = TextEditingController();
  final TextEditingController _monthlyFeeController = TextEditingController();
  final TextEditingController _hourlyFeeController = TextEditingController();

  // Student fields
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();

  String _selectedRole = 'student';
  String _selectedMode = 'Both';

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;

  final List<String> _modes = ['Online', 'Offline', 'Both'];

  @override
  Widget build(BuildContext context) {
    int maxStep = _selectedRole == 'teacher' ? 3 : 2;

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
                      'Create Account',
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
                    _buildStepIndicator(0, 'Role', _currentStep >= 0),
                    Expanded(
                      child: Divider(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    _buildStepIndicator(1, 'Profile', _currentStep >= 1),
                    Expanded(
                      child: Divider(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    _buildStepIndicator(2, 'Details', _currentStep >= 2),
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
                                  'Creating your account...',
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
                                  // Step 0: Role Selection
                                  if (_currentStep == 0) ...[
                                    _buildSectionHeader('🎯 I want to join as'),
                                    const SizedBox(height: 20),
                                    _buildImageRoleSelector(),
                                    const SizedBox(height: 30),
                                    Center(
                                      child: Text(
                                        'Choose your role to continue',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Step 1: Basic Profile
                                  if (_currentStep == 1) ...[
                                    _buildSectionHeader('👤 Basic Information'),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      _fullNameController,
                                      'Full Name',
                                      Icons.person,
                                      true,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      _emailController,
                                      'Email Address',
                                      Icons.email,
                                      true,
                                      TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      _phoneController,
                                      'Phone Number',
                                      Icons.phone,
                                      true,
                                      TextInputType.phone,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      _cityController,
                                      'City',
                                      Icons.location_city,
                                      true,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      _stateController,
                                      'State',
                                      Icons.map,
                                      true,
                                    ),
                                  ],

                                  // Step 2: Role Specific Details
                                  if (_currentStep == 2) ...[
                                    if (_selectedRole == 'teacher') ...[
                                      _buildSectionHeader(
                                        '👨‍🏫 Professional Details',
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        _qualificationController,
                                        'Qualification',
                                        Icons.school,
                                        true,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        _experienceController,
                                        'Experience (Years)',
                                        Icons.timeline,
                                        true,
                                        TextInputType.number,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        _subjectsController,
                                        'Subjects (comma separated)',
                                        Icons.book,
                                        true,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        _classesController,
                                        'Classes (comma separated)',
                                        Icons.class_,
                                        true,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        _monthlyFeeController,
                                        'Monthly Fee (₹)',
                                        Icons.currency_rupee,
                                        true,
                                        TextInputType.number,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        _hourlyFeeController,
                                        'Hourly Fee (₹)',
                                        Icons.access_time,
                                        true,
                                        TextInputType.number,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildDropdownField(
                                        'Teaching Mode',
                                        _selectedMode,
                                        _modes,
                                        Icons.devices,
                                        (value) {
                                          setState(
                                            () => _selectedMode = value!,
                                          );
                                        },
                                      ),
                                    ] else ...[
                                      _buildSectionHeader(
                                        '🎓 Academic Details',
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        _qualificationController,
                                        'Qualification',
                                        Icons.school,
                                        false,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        _fatherNameController,
                                        "Father's Name",
                                        Icons.man,
                                        false,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        _motherNameController,
                                        "Mother's Name",
                                        Icons.woman,
                                        false,
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    _buildPasswordField(
                                      _passwordController,
                                      'Password',
                                      _obscurePassword,
                                      () {
                                        setState(
                                          () =>
                                              _obscurePassword =
                                                  !_obscurePassword,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildPasswordField(
                                      _confirmPasswordController,
                                      'Confirm Password',
                                      _obscureConfirmPassword,
                                      () {
                                        setState(
                                          () =>
                                              _obscureConfirmPassword =
                                                  !_obscureConfirmPassword,
                                        );
                                      },
                                    ),
                                  ],

                                  const SizedBox(height: 30),

                                  // Navigation Buttons
                                  Row(
                                    children: [
                                      if (_currentStep > 0)
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed:
                                                () => setState(
                                                  () => _currentStep--,
                                                ),
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
                                            if (_currentStep < maxStep) {
                                              if (_currentStep == 0) {
                                                setState(() => _currentStep++);
                                              } else if (_formKey.currentState!
                                                  .validate()) {
                                                setState(() => _currentStep++);
                                              }
                                            } else {
                                              _register();
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
                                            _currentStep == maxStep
                                                ? 'Register'
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
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
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
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildImageRoleSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedRole = 'student'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    _selectedRole == 'student'
                        ? const Color(0xFF6C63FF).withValues(alpha: 0.1)
                        : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      _selectedRole == 'student'
                          ? const Color(0xFF6C63FF)
                          : Colors.grey.shade300,
                  width: _selectedRole == 'student' ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        _selectedRole == 'student'
                            ? const Color(0xFF6C63FF).withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipOval(
                    child: Image.network(
                      'https://cdn.pixabay.com/photo/2015/07/17/22/43/student-849825_640.jpg',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Student',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          _selectedRole == 'student'
                              ? const Color(0xFF6C63FF)
                              : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Looking for tutors',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (_selectedRole == 'student')
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Icon(
                        Icons.check_circle,
                        color: Color(0xFF6C63FF),
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedRole = 'teacher'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    _selectedRole == 'teacher'
                        ? const Color(0xFF6C63FF).withValues(alpha: 0.1)
                        : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      _selectedRole == 'teacher'
                          ? const Color(0xFF6C63FF)
                          : Colors.grey.shade300,
                  width: _selectedRole == 'teacher' ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        _selectedRole == 'teacher'
                            ? const Color(0xFF6C63FF).withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ClipOval(
                    child: Image.network(
                      'https://cdn.pixabay.com/photo/2015/01/08/18/26/teacher-593357_640.jpg',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.green,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Teacher',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          _selectedRole == 'teacher'
                              ? Colors.green
                              : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Share your knowledge',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (_selectedRole == 'teacher')
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool validator, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
      validator:
          validator
              ? (value) => value!.isEmpty ? 'Please enter $label' : null
              : null,
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    bool obscure,
    VoidCallback onToggle,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF6C63FF)),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
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
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
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
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final endpoint =
          _selectedRole == 'teacher'
              ? '${AppConfig.apiUrl}/teacher_register'
              : '${AppConfig.apiUrl}/student_register';

      final body =
          _selectedRole == 'teacher'
              ? {
                'full_name': _fullNameController.text,
                'email': _emailController.text,
                'password': _passwordController.text,
                'phone': _phoneController.text,
                'qualification': _qualificationController.text,
                'experience': int.tryParse(_experienceController.text) ?? 0,
                'subjects': _subjectsController.text,
                'classes': _classesController.text,
                'city': _cityController.text,
                'state': _stateController.text,
                'monthly_fee': double.tryParse(_monthlyFeeController.text) ?? 0,
                'hourly_fee': double.tryParse(_hourlyFeeController.text) ?? 0,
                'mode': _selectedMode,
                'status': 'pending',
                'is_verified': 0,
              }
              : {
                'full_name': _fullNameController.text,
                'email': _emailController.text,
                'password': _passwordController.text,
                'phone': _phoneController.text,
                'father_name': _fatherNameController.text,
                'mother_name': _motherNameController.text,
                'city': _cityController.text,
                'state': _stateController.text,
                'qualification': _qualificationController.text,
                'address': _addressController.text,
                'points': 0,
              };

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Registration successful! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }
}


