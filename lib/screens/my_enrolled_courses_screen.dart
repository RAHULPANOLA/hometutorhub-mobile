import 'package:flutter/material.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/countdown_timer.dart';

class MyEnrolledCoursesScreen extends StatefulWidget {
  const MyEnrolledCoursesScreen({super.key});

  @override
  State<MyEnrolledCoursesScreen> createState() =>
      _MyEnrolledCoursesScreenState();
}

class _MyEnrolledCoursesScreenState extends State<MyEnrolledCoursesScreen> {
  List<dynamic> _enrolledCourses = [];
  bool _isLoading = true;
  String _studentEmail = '';
  int _selectedTab = 0; // 0: Upcoming, 1: In Progress, 2: Completed

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentEmail = prefs.getString('user_email') ?? '';
    });
    await _fetchEnrolledCourses();
  }

  Future<void> _fetchEnrolledCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${AppConfig.apiUrl}/my_enrolled_courses?email=${Uri.encodeComponent(_studentEmail)}',
        ),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _enrolledCourses = data;
        });
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading enrolled courses: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<dynamic> get _filteredCourses {
    final now = DateTime.now();

    if (_selectedTab == 0) {
      // Upcoming: start date > now
      return _enrolledCourses.where((course) {
        final startDate = DateTime.parse(course['start_date_time']);
        return startDate.isAfter(now);
      }).toList();
    } else if (_selectedTab == 1) {
      // In Progress: started but not ended (assume 30 days duration)
      return _enrolledCourses.where((course) {
        final startDate = DateTime.parse(course['start_date_time']);
        final endDate = startDate.add(const Duration(days: 30));
        return startDate.isBefore(now) && endDate.isAfter(now);
      }).toList();
    } else {
      // Completed: ended
      return _enrolledCourses.where((course) {
        final startDate = DateTime.parse(course['start_date_time']);
        final endDate = startDate.add(const Duration(days: 30));
        return endDate.isBefore(now);
      }).toList();
    }
  }

  int get _upcomingCount =>
      _enrolledCourses
          .where(
            (course) => DateTime.parse(
              course['start_date_time'],
            ).isAfter(DateTime.now()),
          )
          .length;

  int get _inProgressCount =>
      _enrolledCourses.where((course) {
        final startDate = DateTime.parse(course['start_date_time']);
        final endDate = startDate.add(const Duration(days: 30));
        return startDate.isBefore(DateTime.now()) &&
            endDate.isAfter(DateTime.now());
      }).length;

  int get _completedCount =>
      _enrolledCourses.where((course) {
        final startDate = DateTime.parse(course['start_date_time']);
        final endDate = startDate.add(const Duration(days: 30));
        return endDate.isBefore(DateTime.now());
      }).length;

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
                      'My Courses',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _fetchEnrolledCourses,
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
                        title: 'Upcoming',
                        value: _upcomingCount.toString(),
                        icon: Icons.schedule,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'In Progress',
                        value: _inProgressCount.toString(),
                        icon: Icons.play_circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Completed',
                        value: _completedCount.toString(),
                        icon: Icons.verified,
                        color: Colors.blue,
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
                    _buildFilterTab('Upcoming', 0),
                    _buildFilterTab('In Progress', 1),
                    _buildFilterTab('Completed', 2),
                  ],
                ),
              ),

              // Courses List
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
                                  'Loading your courses...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : _filteredCourses.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _selectedTab == 0
                                      ? 'No upcoming courses'
                                      : (_selectedTab == 1
                                          ? 'No courses in progress'
                                          : 'No completed courses'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  'Browse and enroll in courses',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.search),
                                  label: const Text('Browse Courses'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C63FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : RefreshIndicator(
                            onRefresh: _fetchEnrolledCourses,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredCourses.length,
                              itemBuilder: (context, index) {
                                final course = _filteredCourses[index];
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
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
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

  Widget _buildCourseCard(dynamic course) {
    DateTime startDateTime = DateTime.parse(course['start_date_time']);
    DateTime now = DateTime.now();
    bool isUpcoming = startDateTime.isAfter(now);
    bool isInProgress =
        startDateTime.isBefore(now) &&
        startDateTime.add(const Duration(days: 30)).isAfter(now);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showCourseDetails(course);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Status Badge
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color:
                            isUpcoming
                                ? Colors.orange.withValues(alpha: 0.1)
                                : (isInProgress
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.blue.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isUpcoming
                            ? Icons.schedule
                            : (isInProgress
                                ? Icons.play_circle
                                : Icons.verified),
                        size: 28,
                        color:
                            isUpcoming
                                ? Colors.orange
                                : (isInProgress ? Colors.green : Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['title'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D2D2D),
                            ),
                          ),
                          Text(
                            course['subject'],
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
                            isUpcoming
                                ? Colors.orange.withValues(alpha: 0.1)
                                : (isInProgress
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.blue.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        isUpcoming
                            ? 'Upcoming'
                            : (isInProgress ? 'In Progress' : 'Completed'),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color:
                              isUpcoming
                                  ? Colors.orange
                                  : (isInProgress ? Colors.green : Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Teacher & Fee
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      course['teacher_name'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.currency_rupee, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '${course['monthly_fee']}/month',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress Bar (for in progress courses)
                if (isInProgress) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value:
                        0.5, // Example progress - calculate based on days completed
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Week 2 of 4',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '50% Complete',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Countdown Timer (for upcoming courses)
                if (isUpcoming) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CountdownTimer(targetDateTime: startDateTime),
                      OutlinedButton(
                        onPressed: () => _showCourseDetails(course),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: const BorderSide(color: Color(0xFF6C63FF)),
                        ),
                        child: const Text(
                          'Details',
                          style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Action Buttons for in progress
                if (isInProgress) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Join live class
                          },
                          icon: const Icon(Icons.video_call, size: 16),
                          label: const Text('Join Class'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(vertical: 10),
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
                            // View materials
                          },
                          icon: const Icon(Icons.folder, size: 16),
                          label: const Text('Materials'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Rating for completed courses
                if (!isUpcoming && !isInProgress) ...[
                  Row(
                    children: [
                      Text(
                        'Rate this course:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...List.generate(5, (index) {
                        return IconButton(
                          icon: const Icon(Icons.star_border, color: Colors.amber),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                        );
                      }),
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

  void _showCourseDetails(dynamic course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                course['title'],
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                course['subject'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('Teacher', course['teacher_name']),
              _buildDetailRow('Monthly Fee', '₹${course['monthly_fee']}'),
              _buildDetailRow('Hourly Fee', '₹${course['hourly_fee']}'),
              _buildDetailRow(
                'Start Date',
                DateTime.parse(
                  course['start_date_time'],
                ).toString().substring(0, 16),
              ),
              const SizedBox(height: 16),
              if (course['description'] != null &&
                  course['description'].isNotEmpty) ...[
                Text(
                  'Description',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  course['description'],
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
      ),
    );
  }
}


