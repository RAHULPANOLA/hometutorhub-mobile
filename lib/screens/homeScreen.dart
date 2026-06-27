import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'post_request_screen.dart';
import 'teacher_requests_screen.dart';
import 'my_requests_screen.dart';
import 'find_teachers_screen.dart';
import 'accepted_students_screen.dart';
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
import 'my_enrollments_screen.dart';
import 'course_details_screen.dart';
import '../config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String _userRole = '';
  String _userEmail = '';
  int _selectedIndex = 0;
  int _points = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
      _userRole = prefs.getString('user_role') ?? 'student';
      _userEmail = prefs.getString('user_email') ?? '';
      _points = prefs.getInt('user_points') ?? 0;
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
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
              _buildAppBar(),
              // Main Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _userRole == 'teacher'
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.string(
                  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white" width="28" height="28"><path d="M12 3L1 9l11 6 11-6-11-6zM1 9l11 6 11-6M1 9v6l11 6 11-6V9"/></svg>',
                  width: 28,
                  height: 28,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'HomeTutorHub',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_points pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _logout,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== STUDENT DASHBOARD ====================
Widget _buildStudentDashboard() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Card
        _buildWelcomeCard('Student'),
        const SizedBox(height: 20),

        // Quick Stats
        _buildStudentStats(),
        const SizedBox(height: 20),

        // Quick Actions Grid
        _buildQuickActionsGrid(
          items: [
            QuickAction(
              icon: Icons.post_add,
              label: 'Post Request',
              color: const Color(0xFF6C63FF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PostRequestScreen()),
                );
              },
            ),
            QuickAction(
              icon: Icons.search,
              label: 'Find Tutors',
              color: const Color(0xFF4CAF50),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FindTeachersScreen()),
                );
              },
            ),
            QuickAction(
              icon: Icons.list_alt,
              label: 'My Requests',
              color: const Color(0xFFF59E0B),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyRequestsScreen()),
                );
              },
            ),
            QuickAction(
              icon: Icons.monetization_on,
              label: 'Buy Points',
              color: const Color(0xFFFF9800),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuyPointsScreen()),
                );
              },
            ),
            // ========== NEW: My Courses ==========
            QuickAction(
              icon: Icons.assessment,
              label: 'My Courses',
              color: const Color(0xFF3B82F6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyEnrollmentsScreen()),
                );
              },
            ),
            // =====================================
            QuickAction(
              icon: Icons.home_work,
              label: 'Offline Request',
              color: const Color(0xFF10B981),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OfflineRequestScreen()),
                );
              },
            ),
            QuickAction(
              icon: Icons.history,
              label: 'Offline Status',
              color: const Color(0xFF8B5CF6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOfflineRequestsScreen()),
                );
              },
            ),
            QuickAction(
              icon: Icons.edit,
              label: 'Edit Profile',
              color: const Color(0xFFF59E0B),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentEditProfileScreen()),
                );
              },
            ),
            QuickAction(
              icon: Icons.star_rate,
              label: 'Give Feedback',
              color: const Color(0xFFEF4444),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                );
              },
            ),
            QuickAction(
              icon: Icons.key,
              label: 'Change Password',
              color: const Color(0xFF8B5CF6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentChangePasswordScreen()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // How it works
        _buildHowItWorks(),
      ],
    ),
  );
}

  // ==================== TEACHER DASHBOARD ====================
  Widget _buildTeacherDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          _buildWelcomeCard('Teacher'),
          const SizedBox(height: 20),

          // Stats Row
          _buildTeacherStats(),
          const SizedBox(height: 20),

          // Quick Actions Grid
          _buildQuickActionsGrid(
            items: [
              QuickAction(
                icon: Icons.people,
                label: 'Student Requests',
                color: const Color(0xFF6C63FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeacherRequestsScreen()),
                  );
                },
              ),
              QuickAction(
                icon: Icons.verified_user,
                label: 'Accepted Students',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AcceptedStudentsScreen()),
                  );
                },
              ),
              QuickAction(
                icon: Icons.add_circle,
                label: 'Post Course',
                color: const Color(0xFFFF9800),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PostCourseScreen()),
                  );
                },
              ),
              QuickAction(
                icon: Icons.assessment,
                label: 'My Courses',
                color: const Color(0xFF3B82F6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeacherCoursesScreen()),
                  );
                },
              ),
              QuickAction(
                icon: Icons.video_call,
                label: 'Schedule Class',
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScheduleLiveClassScreen()),
                  );
                },
              ),
              QuickAction(
                icon: Icons.video_library,
                label: 'Live Classes',
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeacherLiveClassesScreen()),
                  );
                },
              ),
              QuickAction(
                icon: Icons.credit_card,
                label: 'Payments',
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeacherPaymentsScreen()),
                  );
                },
              ),
              QuickAction(
                icon: Icons.monetization_on,
                label: 'Buy Points',
                color: const Color(0xFFFF9800),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BuyPointsScreen()),
                  );
                },
              ),
              QuickAction(
                icon: Icons.edit,
                label: 'Edit Profile',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeacherEditProfileScreen()),
                  );
                },
              ),
              QuickAction(
                icon: Icons.star_rate,
                label: 'Give Feedback',
                color: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Teacher Tips
          _buildTeacherTips(),
        ],
      ),
    );
  }

  // ==================== WELCOME CARD ====================
  Widget _buildWelcomeCard(String role) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            role == 'Teacher' ? const Color(0xFF6C63FF) : const Color(0xFF4CAF50),
            role == 'Teacher' ? const Color(0xFF3F3D9E) : const Color(0xFF2E7D32),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                Text(
                  _userName,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role == 'Teacher' ? '👨‍🏫 Teacher' : '🎓 Student',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STUDENT STATS ====================
  Widget _buildStudentStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Requests', '0', Icons.post_add, const Color(0xFF6C63FF)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Tutors', '0', Icons.people, const Color(0xFF4CAF50)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Points', '$_points', Icons.star, const Color(0xFFFF9800)),
        ),
      ],
    );
  }

  // ==================== TEACHER STATS ====================
  Widget _buildTeacherStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Pending', '0', Icons.pending_actions, const Color(0xFFFF9800)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Accepted', '0', Icons.check_circle, const Color(0xFF4CAF50)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Earnings', '₹0', Icons.currency_rupee, const Color(0xFF6C63FF)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== QUICK ACTIONS GRID ====================
  Widget _buildQuickActionsGrid({required List<QuickAction> items}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildQuickActionCard(items[index]);
      },
    );
  }

  Widget _buildQuickActionCard(QuickAction action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                action.icon,
                color: action.color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2D2D),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HOW IT WORKS ====================
  Widget _buildHowItWorks() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStep('1', 'Post', 'Request')),
              const Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
              Expanded(child: _buildStep('2', 'Match', 'Teacher')),
              const Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
              Expanded(child: _buildStep('3', 'Pay', 'Connect')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String subtitle) {
    return Column(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF6C63FF),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ==================== TEACHER TIPS ====================
  Widget _buildTeacherTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF6C63FF).withOpacity(0.1), const Color(0xFF3F3D9E).withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Color(0xFF6C63FF), size: 24),
              const SizedBox(width: 10),
              Text(
                '💡 Teacher Tips',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('🎯', 'Respond quickly to student requests'),
          _buildTipItem('📚', 'Post detailed course descriptions'),
          _buildTipItem('⭐', 'Collect good ratings from students'),
          _buildTipItem('💰', 'Complete payment details for earnings'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF4A4A4A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM NAV BAR ====================
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
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
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==================== QUICK ACTION MODEL ====================
class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
