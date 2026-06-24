import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';

class ManageStudentScreen extends StatefulWidget {
  final int studentId;
  final String studentName;
  final int enrollmentId;
  
  const ManageStudentScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.enrollmentId,
  });

  @override
  _ManageStudentScreenState createState() => _ManageStudentScreenState();
}

class _ManageStudentScreenState extends State<ManageStudentScreen> {
  bool _isLoading = false;
  DateTime? _demoDate;
  TimeOfDay? _demoTime;
  String _demoMode = 'online';
  String _meetingLink = '';

  final List<String> _demoModes = ['online', 'home', 'center'];

  @override
  void initState() {
    super.initState();
    _meetingLink = 'https://meet.google.com/';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _demoDate = picked;
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
        _demoTime = picked;
      });
    }
  }

  Future<void> _extendTrial() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/extend_trial'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'enrollment_id': widget.enrollmentId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Trial extended by 24 hours!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to extend trial'),
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

  Future<void> _scheduleDemo() async {
    if (_demoDate == null || _demoTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final demoDateTime = DateTime(
      _demoDate!.year,
      _demoDate!.month,
      _demoDate!.day,
      _demoTime!.hour,
      _demoTime!.minute,
    );

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/schedule_demo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'enrollment_id': widget.enrollmentId,
          'demo_date': demoDateTime.toIso8601String(),
          'demo_mode': _demoMode,
          'meeting_link': _meetingLink,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Demo scheduled successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to schedule demo'),
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
                      'Manage Student',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
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
                                'Processing...',
                                style: GoogleFonts.poppins(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Student Info
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                                      child: Text(
                                        widget.studentName[0].toUpperCase(),
                                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      widget.studentName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Student ID: ${widget.studentId}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Extend Trial Section
                              Text(
                                'Extend Trial',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, color: Color(0xFFFF9800)),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Give student 24 more hours of trial',
                                          style: GoogleFonts.poppins(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _extendTrial,
                                        icon: const Icon(Icons.add_circle),
                                        label: const Text('Extend Trial (+24 hours)'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFF9800),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Schedule Demo Section
                              Text(
                                'Schedule Demo Class',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  children: [
                                    // Date Picker
                                    GestureDetector(
                                      onTap: _selectDate,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.calendar_today, color: Color(0xFF6C63FF)),
                                            const SizedBox(width: 12),
                                            Text(
                                              _demoDate == null
                                                  ? 'Select Date'
                                                  : '${_demoDate!.day}/${_demoDate!.month}/${_demoDate!.year}',
                                              style: GoogleFonts.poppins(
                                                color: _demoDate == null ? Colors.grey.shade600 : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Time Picker
                                    GestureDetector(
                                      onTap: _selectTime,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time, color: Color(0xFF6C63FF)),
                                            const SizedBox(width: 12),
                                            Text(
                                              _demoTime == null
                                                  ? 'Select Time'
                                                  : _demoTime!.format(context),
                                              style: GoogleFonts.poppins(
                                                color: _demoTime == null ? Colors.grey.shade600 : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Demo Mode Dropdown
                                    DropdownButtonFormField<String>(
                                      initialValue: _demoMode,
                                      decoration: InputDecoration(
                                        labelText: 'Demo Mode',
                                        prefixIcon: const Icon(Icons.video_call, color: Color(0xFF6C63FF)),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                      items: _demoModes.map((mode) {
                                        return DropdownMenuItem(
                                          value: mode,
                                          child: Text(mode.toUpperCase()),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _demoMode = value!;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // Meeting Link
                                    TextFormField(
                                      initialValue: _meetingLink,
                                      onChanged: (value) {
                                        _meetingLink = value;
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'Meeting Link',
                                        hintText: 'https://meet.google.com/...',
                                        prefixIcon: const Icon(Icons.link, color: Color(0xFF6C63FF)),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _scheduleDemo,
                                        icon: const Icon(Icons.calendar_month),
                                        label: const Text('Schedule Demo'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF4CAF50),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 30),
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
}
