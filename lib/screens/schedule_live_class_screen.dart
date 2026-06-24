import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';

class ScheduleLiveClassScreen extends StatefulWidget {
  final int? courseId;
  final String? courseName;
  
  const ScheduleLiveClassScreen({Key? key, this.courseId, this.courseName}) : super(key: key);

  @override
  _ScheduleLiveClassScreenState createState() => _ScheduleLiveClassScreenState();
}

class _ScheduleLiveClassScreenState extends State<ScheduleLiveClassScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _meetingLinkController = TextEditingController();
  
  DateTime? _classDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  int? _selectedCourseId;
  String _selectedCourseName = '';
  List<dynamic> _courses = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _teacherEmail = '';

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
    _meetingLinkController.text = 'https://meet.google.com/';
  }

  Future<void> _loadTeacherData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _teacherEmail = prefs.getString('user_email') ?? '';
    });
    await _fetchTeacherCourses();
  }

  Future<void> _fetchTeacherCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/teacher_courses?email=${Uri.encodeComponent(_teacherEmail)}'),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        setState(() {
          _courses = data;
        });
        
        // If courseId was passed, select it
        if (widget.courseId != null) {
          for (var course in _courses) {
            if (course['id'] == widget.courseId) {
              setState(() {
                _selectedCourseId = course['id'];
                _selectedCourseName = course['course_name'];
              });
              break;
            }
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _classDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
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

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _scheduleClass() async {
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a course'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter class title'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_classDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select date and time'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final startDateTime = DateTime(
      _classDate!.year,
      _classDate!.month,
      _classDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      _classDate!.year,
      _classDate!.month,
      _classDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (!endDateTime.isAfter(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End time must be after start time'), backgroundColor: Colors.red),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/schedule_live_class'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'course_id': _selectedCourseId,
          'course_name': _selectedCourseName,
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'class_date': _classDate!.toIso8601String(),
          'start_time': '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00',
          'end_time': '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00',
          'meeting_link': _meetingLinkController.text.trim(),
          'teacher_email': _teacherEmail,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Live class scheduled successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to schedule class'),
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
                      'Schedule Live Class',
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
                                _isSubmitting ? 'Scheduling...' : 'Loading courses...',
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
                              // Course Selection
                              Text(
                                'Select Course *',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    isExpanded: true,
                                    hint: Text('Select a course'),
                                    value: _selectedCourseId,
                                    items: _courses.map<DropdownMenuItem<int>>((course) {
                                      return DropdownMenuItem<int>(
                                        value: course['id'] as int?,
                                        child: Text(course['course_name'] ?? ''),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCourseId = value;
                                        final selected = _courses.firstWhere((c) => c['id'] == value);
                                        _selectedCourseName = selected['course_name'] ?? '';
                                      });
                                    },
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Class Title
                              Text(
                                'Class Title *',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  hintText: 'e.g., Introduction to Python',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Description
                              Text(
                                'Description',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'What will be covered in this class?',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Date
                              Text(
                                'Class Date *',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: _selectDate,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Color(0xFF6C63FF)),
                                      SizedBox(width: 12),
                                      Text(
                                        _classDate == null
                                            ? 'Select Date'
                                            : '${_classDate!.day}/${_classDate!.month}/${_classDate!.year}',
                                        style: GoogleFonts.poppins(
                                          color: _classDate == null ? Colors.grey.shade600 : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Start & End Time
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Start Time *',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: _selectStartTime,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.access_time, color: Color(0xFF6C63FF)),
                                                SizedBox(width: 12),
                                                Text(
                                                  _startTime == null
                                                      ? 'Start Time'
                                                      : _startTime!.format(context),
                                                  style: GoogleFonts.poppins(
                                                    color: _startTime == null ? Colors.grey.shade600 : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'End Time *',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: _selectEndTime,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey.shade300),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.access_time, color: Color(0xFF6C63FF)),
                                                SizedBox(width: 12),
                                                Text(
                                                  _endTime == null
                                                      ? 'End Time'
                                                      : _endTime!.format(context),
                                                  style: GoogleFonts.poppins(
                                                    color: _endTime == null ? Colors.grey.shade600 : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              SizedBox(height: 16),
                              
                              // Meeting Link
                              Text(
                                'Meeting Link',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _meetingLinkController,
                                decoration: InputDecoration(
                                  hintText: 'https://meet.google.com/...',
                                  prefixIcon: Icon(Icons.link, color: Color(0xFF6C63FF)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              
                              SizedBox(height: 30),
                              
                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _scheduleClass,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4CAF50),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Schedule Class',
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
}