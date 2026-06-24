import 'package:flutter/material.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/countdown_timer.dart';

class PostCourseScreen extends StatefulWidget {
  const PostCourseScreen({super.key});

  @override
  State<PostCourseScreen> createState() => _PostCourseScreenState();
}

class _PostCourseScreenState extends State<PostCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _monthlyFeeController = TextEditingController();
  final TextEditingController _hourlyFeeController = TextEditingController();

  DateTime? _startDate;
  TimeOfDay? _startTime;

  bool _isLoading = false;
  String _teacherName = '';
  String _teacherEmail = '';

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
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _postCourse() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/post_course'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _titleController.text,
          'subject': _subjectController.text,
          'description': _descriptionController.text,
          'start_date_time': startDateTime.toIso8601String(),
          'monthly_fee': double.tryParse(_monthlyFeeController.text) ?? 0,
          'hourly_fee': double.tryParse(_hourlyFeeController.text) ?? 0,
          'teacher_name': _teacherName,
          'teacher_email': _teacherEmail,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Course posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to post course'),
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
                      'Post New Course',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

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
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6C63FF),
                            ),
                          )
                          : SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildTextField(
                                    _titleController,
                                    'Course Title',
                                    Icons.title,
                                    true,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    _subjectController,
                                    'Subject',
                                    Icons.book,
                                    true,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    _descriptionController,
                                    'Description',
                                    Icons.description,
                                    true,
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _selectDate,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today,
                                                  color: Color(0xFF6C63FF),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  _startDate == null
                                                      ? 'Select Date'
                                                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _selectTime,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time,
                                                  color: Color(0xFF6C63FF),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  _startTime == null
                                                      ? 'Select Time'
                                                      : _startTime!.format(
                                                        context,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          _monthlyFeeController,
                                          'Monthly Fee (₹)',
                                          Icons.currency_rupee,
                                          true,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildTextField(
                                          _hourlyFeeController,
                                          'Hourly Fee (₹)',
                                          Icons.access_time,
                                          true,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),

                                  if (_startDate != null && _startTime != null)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Course will start in:',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          CountdownTimer(
                                            targetDateTime: DateTime(
                                              _startDate!.year,
                                              _startDate!.month,
                                              _startDate!.day,
                                              _startTime!.hour,
                                              _startTime!.minute,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 30),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _postCourse,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6C63FF),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Post Course',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool validator, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
}


