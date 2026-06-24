import 'package:flutter/material.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manage_student_screen.dart';

class AcceptedStudentsScreen extends StatefulWidget {
  const AcceptedStudentsScreen({super.key});

  @override
  State<AcceptedStudentsScreen> createState() => _AcceptedStudentsScreenState();
}

class _AcceptedStudentsScreenState extends State<AcceptedStudentsScreen> {
  List<dynamic> _acceptedStudents = [];
  bool _isLoading = true;
  String _teacherEmail = '';
  int _selectedFilter = 0; // 0: All, 1: Pending Demo, 2: Enrolled

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
    await _fetchAcceptedStudents();
  }

  Future<void> _fetchAcceptedStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${AppConfig.apiUrl}/accepted_students?email=${Uri.encodeComponent(_teacherEmail)}',
        ),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _acceptedStudents = data;
        });
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading accepted students: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<dynamic> get _filteredStudents {
    if (_selectedFilter == 0) {
      return _acceptedStudents;
    } else if (_selectedFilter == 1) {
      return _acceptedStudents
          .where((s) => s['demo_status'] == 'pending')
          .toList();
    } else {
      return _acceptedStudents
          .where((s) => s['demo_status'] == 'completed')
          .toList();
    }
  }

  int get _totalCount => _acceptedStudents.length;
  int get _pendingCount =>
      _acceptedStudents.where((s) => s['demo_status'] == 'pending').length;
  int get _enrolledCount =>
      _acceptedStudents.where((s) => s['demo_status'] == 'completed').length;

  Future<void> _scheduleDemo(dynamic student) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = DateTime.now();
        TimeOfDay selectedTime = TimeOfDay.now();

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Schedule Demo Class'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Student: ${student['student_name']}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF6C63FF),
                    ),
                    title: const Text('Select Date'),
                    subtitle: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setStateDialog(() {
                          selectedDate = date;
                        });
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time, color: Color(0xFF6C63FF)),
                    title: const Text('Select Time'),
                    subtitle: Text(selectedTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setStateDialog(() {
                          selectedTime = time;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Demo scheduled for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at ${selectedTime.format(context)}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // TODO: Send notification to student
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                  child: const Text('Schedule'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _markEnrolled(dynamic student) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark as Enrolled'),
          content: Text(
            'Has ${student['student_name']} completed the demo and ready to start classes?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                setState(() {
                  _isLoading = true;
                });

                try {
                  final response = await http.post(
                    Uri.parse('${AppConfig.apiUrl}/mark_enrolled'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'request_id': student['request_id'],
                      'teacher_email': _teacherEmail,
                    }),
                  );

                  final data = jsonDecode(response.body);

                  if (response.statusCode == 200 && data['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Student marked as enrolled!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    await _fetchAcceptedStudents();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(data['message'] ?? 'Failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                setState(() {
                  _isLoading = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: const Text('Yes, Enroll'),
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
                      'Accepted Students',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _fetchAcceptedStudents,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Cards
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total',
                        value: _totalCount.toString(),
                        icon: Icons.people,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Pending Demo',
                        value: _pendingCount.toString(),
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Enrolled',
                        value: _enrolledCount.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildFilterTab('All', 0),
                    _buildFilterTab('Pending Demo', 1),
                    _buildFilterTab('Enrolled', 2),
                  ],
                ),
              ),

              // Students List
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
                                  'Loading students...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : _filteredStudents.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No students yet',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  'Accept student requests to see them here',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : RefreshIndicator(
                            onRefresh: _fetchAcceptedStudents,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = _filteredStudents[index];
                                return _buildStudentCard(student);
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(dynamic student) {
    bool isPending = student['demo_status'] == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          isPending
                              ? Colors.orange.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                      child: Text(
                        student['student_name'][0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isPending ? Colors.orange : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['student_name'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D2D2D),
                            ),
                          ),
                          Text(
                            student['subject'] ?? 'Not specified',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isPending
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        isPending ? 'Demo Pending' : 'Enrolled',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isPending ? Colors.orange : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Details
                Row(
                  children: [
                    _buildDetailChip(
                      Icons.school,
                      student['class_level'] ?? 'Not specified',
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      Icons.location_on,
                      student['location'] ?? 'Not specified',
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      Icons.currency_rupee,
                      student['budget'] ?? 'Negotiable',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Contact Info
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        student['student_phone'] ?? '+91 XXXXX XXXXX',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Icon(Icons.email, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          student['student_email'] ?? 'student@example.com',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                if (isPending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _scheduleDemo(student),
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text('Schedule Demo'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageStudentScreen(
          studentId: student['id'],
          studentName: student['student_name'],
          enrollmentId: student['id'],
        ),
      ),
    );
  },
  icon: const Icon(Icons.manage_accounts, size: 18),
  label: const Text('Manage'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF6C63FF),
    padding: const EdgeInsets.symmetric(vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _markEnrolled(student),
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Mark Enrolled'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Start class
                          },
                          icon: const Icon(Icons.video_call, size: 18),
                          label: const Text('Start Class'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Send message
                          },
                          icon: const Icon(Icons.message, size: 18),
                          label: const Text('Message'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}


