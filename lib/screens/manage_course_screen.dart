import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';

class ManageCourseScreen extends StatefulWidget {
  final int courseId;
  final String courseName;
  
  const ManageCourseScreen({
    Key? key,
    required this.courseId,
    required this.courseName,
  }) : super(key: key);

  @override
  _ManageCourseScreenState createState() => _ManageCourseScreenState();
}

class _ManageCourseScreenState extends State<ManageCourseScreen> {
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  List<dynamic> _enrolledStudents = [];
  bool _isLoading = true;
  bool _isEditing = false;
  String _teacherName = '';

  @override
  void initState() {
    super.initState();
    _loadCourseData();
    _fetchEnrolledStudents();
  }

  Future<void> _loadCourseData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _teacherName = prefs.getString('user_name') ?? 'Teacher';
    });
    
    _courseNameController.text = widget.courseName;
  }

  Future<void> _fetchEnrolledStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/course_enrolled_students?course_id=${widget.courseId}'),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        setState(() {
          _enrolledStudents = data;
        });
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateCourse() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/update_course'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'course_id': widget.courseId,
          'course_name': _courseNameController.text,
          'fee': double.tryParse(_feeController.text) ?? 0,
          'description': _descriptionController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Course updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _isEditing = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to update course'),
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

  Future<void> _deleteCourse() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Course'),
          content: Text('Are you sure you want to delete "${widget.courseName}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                setState(() {
                  _isLoading = true;
                });

                try {
                  final response = await http.post(
                    Uri.parse('${AppConfig.apiUrl}/delete_course'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'course_id': widget.courseId,
                    }),
                  );

                  final data = jsonDecode(response.body);

                  if (response.statusCode == 200 && data['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Course deleted successfully!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(data['message'] ?? 'Failed to delete course'),
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
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
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
                      'Manage Course',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    if (!_isEditing)
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                      ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Color(0xFF6C63FF)),
                              SizedBox(height: 20),
                              Text(
                                'Loading...',
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
                              // Course Info Card
                              Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF6C63FF).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(Icons.book, color: Color(0xFF6C63FF), size: 28),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _isEditing ? 'Edit Course' : 'Course Details',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Teacher: $_teacherName',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    
                                    if (_isEditing) ...[
                                      TextFormField(
                                        controller: _courseNameController,
                                        decoration: InputDecoration(
                                          labelText: 'Course Name',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      TextFormField(
                                        controller: _feeController,
                                        decoration: InputDecoration(
                                          labelText: 'Fee (₹/month)',
                                          prefixIcon: Icon(Icons.currency_rupee),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                      SizedBox(height: 12),
                                      TextFormField(
                                        controller: _descriptionController,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          labelText: 'Description',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _updateCourse,
                                              child: Text('Save Changes'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xFF4CAF50),
                                                padding: EdgeInsets.symmetric(vertical: 12),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isEditing = false;
                                                });
                                              },
                                              child: Text('Cancel'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      _buildInfoRow('Course Name', widget.courseName),
                                      SizedBox(height: 12),
                                      _buildInfoRow('Teacher', _teacherName),
                                      SizedBox(height: 12),
                                      _buildInfoRow('Enrolled Students', '${_enrolledStudents.length}'),
                                    ],
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: 24),
                              
                              // Enrolled Students Section
                              Text(
                                'Enrolled Students',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              
                              if (_enrolledStudents.isEmpty)
                                Container(
                                  padding: EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.people_outline, size: 50, color: Colors.grey.shade400),
                                      SizedBox(height: 10),
                                      Text(
                                        'No students enrolled yet',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _enrolledStudents.length,
                                  itemBuilder: (context, index) {
                                    final student = _enrolledStudents[index];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Color(0xFF6C63FF).withOpacity(0.1),
                                            child: Text(
                                              student['student_name'][0].toUpperCase(),
                                              style: TextStyle(color: Color(0xFF6C63FF)),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  student['student_name'],
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  student['student_email'],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: student['payment_status'] == 'paid'
                                                  ? Colors.green.withOpacity(0.1)
                                                  : Colors.orange.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              student['payment_status'] == 'paid' ? 'Paid' : 'Trial',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: student['payment_status'] == 'paid'
                                                    ? Colors.green
                                                    : Colors.orange,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              
                              SizedBox(height: 24),
                              
                              // Delete Button
                              if (!_isEditing)
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _deleteCourse,
                                    icon: Icon(Icons.delete_outline),
                                    label: Text('Delete Course'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: BorderSide(color: Colors.red),
                                      padding: EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}