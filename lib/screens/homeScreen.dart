import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'post_request_screen.dart';
import 'teacher_requests_screen.dart';
import 'my_requests_screen.dart';
import 'find_teachers_screen.dart';
import 'accepted_students_screen.dart'; // Add this import
import 'post_course_screen.dart';
import 'buy_points_screen.dart';
import 'offline_request_screen.dart';
import 'feedback_screen.dart';
import 'my_offline_requests_screen.dart';
import 'teacher_courses_screen.dart';
import 'schedule_live_class_screen.dart';
import 'teacher_live_classes_screen.dart';
import 'teacher_payments_screen.dart';
import 'teacher_edit_profile_screen.dart';
import 'student_edit_profile_screen.dart';
import 'student_change_password_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String _userRole = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _showTeacherCourses() {
  // For now, show a dialog to select course
  // In production, fetch teacher's courses from API
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('My Courses'),
        content: Text('Course list coming soon. Select a course to manage.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
      _userRole = prefs.getString('user_role') ?? 'student';
    });
    print("Loaded user: $_userName, Role: $_userRole");
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }


  @override
  Widget build(BuildContext context) {
    print("Building HomeScreen with role: $_userRole");

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'HomeTutorHub',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: _logout,
                      ),
                    ),
                  ],
                ),
              ),

              // Welcome Card
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF6C63FF),
                      child: Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 28, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _userName,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D2D2D),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _userRole == 'teacher'
                                      ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                                      : const Color(0xFF6C63FF).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _userRole == 'teacher'
                                  ? '👨‍🏫 Teacher'
                                  : '🎓 Student',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color:
                                    _userRole == 'teacher'
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFF6C63FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content based on role
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
                      _userRole == 'teacher'
                          ? _buildTeacherDashboard()
                          : _buildStudentDashboard(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildStudentDashboard() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        // Post Request Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostRequestScreen()),
              );
              if (result == true) {
                // Request posted successfully
              }
            },
            icon: const Icon(Icons.post_add, size: 28),
            label: Text(
              'Post New Tuition Request',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 16),

// Change Password Button
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StudentChangePasswordScreen()),
      );
    },
    icon: Icon(Icons.key, size: 28),
    label: Text(
      'Change Password',
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: Color(0xFFEF4444),
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: Color(0xFFEF4444)),
    ),
  ),
),

// Edit Profile Button
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StudentEditProfileScreen()),
      );
    },
    icon: Icon(Icons.edit, size: 28),
    label: Text(
      'Edit Profile',
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: Color(0xFFF59E0B),
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: Color(0xFFF59E0B)),
    ),
  ),
),

        // My Offline Requests Button
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyOfflineRequestsScreen()),
      );
    },
    icon: const Icon(Icons.history, size: 28),
    label: Text(
      'My Offline Requests',
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF8B5CF6),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: const BorderSide(color: Color(0xFF8B5CF6)),
    ),
  ),
),
        
        // Buy Points Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuyPointsScreen()),
              );
            },
            icon: const Icon(Icons.monetization_on, size: 28),
            label: Text(
              'Buy Points',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF9800),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Color(0xFFFF9800)),
            ),
          ),
        ),
        const SizedBox(height: 16),

// Give Feedback Button
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FeedbackScreen()),
      );
    },
    icon: const Icon(Icons.star_rate, size: 28),
    label: Text(
      'Give Feedback',
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFF59E0B),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: const BorderSide(color: Color(0xFFF59E0B)),
    ),
  ),
),
                
        
        // Offline Request Button - ADD THIS
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OfflineRequestScreen()),
              );
            },
            icon: const Icon(Icons.home_work, size: 28),
            label: Text(
              'Offline Home Tutor Request',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Color(0xFF10B981)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // My Courses Button
        // My Courses Button (for teacher)
// My Courses Button (for teacher)
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
      // Navigate to teacher's courses list
      _showTeacherCourses();
    },
    icon: Icon(Icons.assessment, size: 28),
    label: Text(
      'My Courses',
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: Color(0xFF6C63FF),
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: Color(0xFF6C63FF)),
    ),
  ),
),
        
        // My Requests Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyRequestsScreen()),
              );
            },
            icon: const Icon(Icons.list_alt, size: 28),
            label: Text(
              'My Requests',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Color(0xFF6C63FF)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Find Teachers Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FindTeachersScreen()),
              );
            },
            icon: const Icon(Icons.search, size: 28),
            label: Text(
              'Find Teachers',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 30),
        
        // Info Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📚 How it works?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildStep('1', 'Post', 'Request')),
                  const Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
                  Expanded(child: _buildStep('2', 'Match', 'Teacher')),
                  const Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
                  Expanded(child: _buildStep('3', 'Pay ₹49', 'Connect')),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildStep(String number, String title, String subtitle) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF6C63FF),
          child: Text(
            number,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

Widget _buildTeacherDashboard() {
  return SingleChildScrollView(
    padding: EdgeInsets.all(20),
    child: Column(
      children: [
        // Stats Row
        Row(
          children: [
            Expanded(child: _buildStatCard('Pending', '0', Icons.pending_actions, Colors.orange)),
            SizedBox(width: 15),
            Expanded(child: _buildStatCard('Accepted', '0', Icons.check_circle, Colors.green)),
            SizedBox(width: 15),
            Expanded(child: _buildStatCard('Earnings', '₹0', Icons.currency_rupee, Colors.blue)),
          ],
        ),
        SizedBox(height: 20),

// Edit Profile Button
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TeacherEditProfileScreen()),
      );
    },
    icon: Icon(Icons.edit, size: 28),
    label: Text(
      'Edit Profile',
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: Color(0xFFF59E0B),
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: Color(0xFFF59E0B)),
    ),
  ),
),

// Payments Button
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TeacherPaymentsScreen()),
      );
    },
    icon: Icon(Icons.credit_card, size: 28),
    label: Text(
      'Payments',
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: Color(0xFF10B981),
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: Color(0xFF10B981)),
    ),
  ),
),

        // Schedule Live Class Button
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScheduleLiveClassScreen()),
      );
    },
    icon: Icon(Icons.video_call, size: 28),
    label: Text(
      'Schedule Live Class',
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF10B981),
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
),

// My Live Classes Button
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TeacherLiveClassesScreen()),
      );
    },
    icon: Icon(Icons.video_library, size: 28),
    label: Text(
      'My Live Classes',
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: Color(0xFF8B5CF6),
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: Color(0xFF8B5CF6)),
    ),
  ),
),
        // Student Requests Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TeacherRequestsScreen()),
              );
            },
            icon: Icon(Icons.people, size: 28),
            label: Text('View Student Requests'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6C63FF),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Accepted Students Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AcceptedStudentsScreen()),
              );
            },
            icon: Icon(Icons.verified_user, size: 28),
            label: Text('Accepted Students'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(0xFF4CAF50),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Color(0xFF4CAF50)),
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Post Course Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostCourseScreen()),
              );
            },
            icon: Icon(Icons.add_circle, size: 28),
            label: Text('Post New Course'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF9800),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Give Feedback Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackScreen()),
              );
            },
            icon: Icon(Icons.star_rate, size: 28),
            label: Text('Give Feedback'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(0xFFF59E0B),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Color(0xFFF59E0B)),
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // My Courses Button
       // My Courses Button
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TeacherCoursesScreen()),
      );
    },
    icon: Icon(Icons.assessment, size: 28),
    label: Text(
      'My Courses',
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: Color(0xFF6C63FF),
      padding: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: Color(0xFF6C63FF)),
    ),
  ),
),
        
        SizedBox(height: 30),
        
        // Info Card
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '👨‍🏫 Teacher Dashboard',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Manage requests, accept students, and track your earnings.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ], // ← Make sure this closing bracket exists
    ),
  );
} // ← Make sure this closing brace exists

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}


