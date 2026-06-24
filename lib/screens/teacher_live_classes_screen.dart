import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';
import 'schedule_live_class_screen.dart';

class TeacherLiveClassesScreen extends StatefulWidget {
  @override
  _TeacherLiveClassesScreenState createState() => _TeacherLiveClassesScreenState();
}

class _TeacherLiveClassesScreenState extends State<TeacherLiveClassesScreen> {
  List<dynamic> _liveClasses = [];
  bool _isLoading = true;
  String _teacherEmail = '';
  int _selectedFilter = 0; // 0: Upcoming, 1: Today, 2: Past

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
    await _fetchLiveClasses();
  }

  Future<void> _fetchLiveClasses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/teacher_live_classes?email=${Uri.encodeComponent(_teacherEmail)}'),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        setState(() {
          _liveClasses = data;
        });
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading classes: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<dynamic> get _filteredClasses {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_selectedFilter == 0) {
      // Upcoming (future dates)
      return _liveClasses.where((c) {
        final classDate = DateTime.parse(c['class_date']);
        return classDate.isAfter(now);
      }).toList();
    } else if (_selectedFilter == 1) {
      // Today
      return _liveClasses.where((c) {
        final classDate = DateTime.parse(c['class_date']);
        return classDate.year == today.year && 
               classDate.month == today.month && 
               classDate.day == today.day;
      }).toList();
    } else {
      // Past
      return _liveClasses.where((c) {
        final classDate = DateTime.parse(c['class_date']);
        return classDate.isBefore(today);
      }).toList();
    }
  }

  Future<void> _deleteClass(int classId, String title) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Class'),
          content: Text('Are you sure you want to delete "$title"?'),
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
                    Uri.parse('${AppConfig.apiUrl}/delete_live_class'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'class_id': classId,
                    }),
                  );

                  final data = jsonDecode(response.body);

                  if (response.statusCode == 200 && data['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ Class deleted!'), backgroundColor: Colors.green),
                    );
                    await _fetchLiveClasses();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['message'] ?? 'Failed to delete'), backgroundColor: Colors.red),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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

  void _startClass(String meetingLink) {
    if (meetingLink.isNotEmpty) {
      // For web, open in new tab
      // For mobile, you would use url_launcher package
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening: $meetingLink'),
          backgroundColor: Colors.blue,
        ),
      );
      // TODO: Implement actual meeting link opening
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No meeting link available'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                      'Live Classes',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: _fetchLiveClasses,
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
                          MaterialPageRoute(builder: (context) => ScheduleLiveClassScreen()),
                        );
                        if (result == true) {
                          await _fetchLiveClasses();
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
              
              // Filter Tabs
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildFilterTab('Upcoming', 0),
                    _buildFilterTab('Today', 1),
                    _buildFilterTab('Past', 2),
                  ],
                ),
              ),
              
              // Classes List
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
                                'Loading classes...',
                                style: GoogleFonts.poppins(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : _filteredClasses.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.video_call, size: 80, color: Colors.grey.shade400),
                                  SizedBox(height: 20),
                                  Text(
                                    _selectedFilter == 0 ? 'No upcoming classes' :
                                    (_selectedFilter == 1 ? 'No classes today' : 'No past classes'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    'Schedule your first live class!',
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
                                        MaterialPageRoute(builder: (context) => ScheduleLiveClassScreen()),
                                      );
                                      if (result == true) {
                                        await _fetchLiveClasses();
                                      }
                                    },
                                    icon: Icon(Icons.add),
                                    label: Text('Schedule Class'),
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
                              onRefresh: _fetchLiveClasses,
                              child: ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: _filteredClasses.length,
                                itemBuilder: (context, index) {
                                  final classData = _filteredClasses[index];
                                  return _buildClassCard(classData);
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

  Widget _buildFilterTab(String title, int index) {
    bool isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: isSelected ? Color(0xFF6C63FF) : Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(dynamic classData) {
    DateTime classDate = DateTime.parse(classData['class_date']);
    bool isToday = classDate.year == DateTime.now().year &&
                   classDate.month == DateTime.now().month &&
                   classDate.day == DateTime.now().day;
    bool isUpcoming = classDate.isAfter(DateTime.now());
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: isToday ? Colors.green.withOpacity(0.1) : Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.video_call,
                    size: 24,
                    color: isToday ? Colors.green : Color(0xFF6C63FF),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classData['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        classData['course_name'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isToday 
                        ? Colors.green.withOpacity(0.1)
                        : (isUpcoming ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    isToday ? 'Today' : (isUpcoming ? 'Upcoming' : 'Past'),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isToday 
                          ? Colors.green
                          : (isUpcoming ? Colors.orange : Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Date & Time
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                SizedBox(width: 8),
                Text(
                  '${classDate.day}/${classDate.month}/${classDate.year}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                ),
                SizedBox(width: 16),
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                SizedBox(width: 8),
                Text(
                  '${classData['start_time']} - ${classData['end_time']}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            
            if (classData['description'] != null && classData['description'].isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  classData['description'],
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            
            SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startClass(classData['meeting_link'] ?? ''),
                    icon: Icon(Icons.play_arrow, size: 18),
                    label: Text(isToday ? 'Start Class' : 'View Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isToday ? Color(0xFF4CAF50) : Color(0xFF6C63FF),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _deleteClass(classData['id'], classData['title']),
                  icon: Icon(Icons.delete_outline, size: 18),
                  label: Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}