import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';
import 'manage_course_screen.dart';
import 'post_course_screen.dart';

class TeacherCoursesScreen extends StatefulWidget {
  @override
  _TeacherCoursesScreenState createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  List<dynamic> _courses = [];
  bool _isLoading = true;
  String _teacherEmail = '';

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _teacherEmail = prefs.getString('user_email') ?? '';
    });
    await _fetchCourses();
  }

  Future<void> _fetchCourses() async {
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
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading courses: $e'), backgroundColor: Colors.red),
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
                      'My Courses',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: _fetchCourses,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.refresh, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PostCourseScreen()),
                        );
                        if (result == true) {
                          await _fetchCourses();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.add, color: Colors.white),
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
                                'Loading courses...',
                                style: GoogleFonts.poppins(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : _courses.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.book, size: 80, color: Colors.grey.shade400),
                                  SizedBox(height: 20),
                                  Text(
                                    'No Courses Yet',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    'Create your first course to start teaching!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => PostCourseScreen()),
                                      );
                                      if (result == true) {
                                        await _fetchCourses();
                                      }
                                    },
                                    icon: Icon(Icons.add),
                                    label: Text('Create Course'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF6C63FF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchCourses,
                              child: ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: _courses.length,
                                itemBuilder: (context, index) {
                                  final course = _courses[index];
                                  return _buildCourseCard(course);
                                },
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

  Widget _buildCourseCard(dynamic course) {
    int enrolledCount = course['enrolled_count'] ?? 0;
    bool isActive = course['status'] == 'active';
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManageCourseScreen(
                  courseId: course['id'],
                  courseName: course['course_name'],
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.book, size: 28, color: Color(0xFF6C63FF)),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['course_name'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.people, size: 14, color: Colors.grey.shade500),
                              SizedBox(width: 4),
                              Text(
                                '$enrolledCount enrolled',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green : Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                isActive ? 'Active' : 'Draft',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isActive ? Colors.green : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(Icons.currency_rupee, '₹${course['fee']}/month'),
                    SizedBox(width: 8),
                    _buildInfoChip(Icons.access_time, '${course['duration_weeks'] ?? 12} weeks'),
                    SizedBox(width: 8),
                    _buildInfoChip(Icons.people, '${course['max_students'] ?? 50} max'),
                  ],
                ),
                if (course['enrolled_count'] > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(
                      value: (course['enrolled_count'] / (course['max_students'] ?? 50)).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      color: Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}