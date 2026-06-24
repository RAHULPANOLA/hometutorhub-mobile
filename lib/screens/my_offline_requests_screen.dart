import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';

class MyOfflineRequestsScreen extends StatefulWidget {
  const MyOfflineRequestsScreen({super.key});

  @override
  _MyOfflineRequestsScreenState createState() => _MyOfflineRequestsScreenState();
}

class _MyOfflineRequestsScreenState extends State<MyOfflineRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String _studentEmail = '';
  int _selectedFilter = 0; // 0: All, 1: Pending, 2: Completed

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
    await _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/my_offline_requests?email=${Uri.encodeComponent(_studentEmail)}'),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        setState(() {
          _requests = data;
        });
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading requests: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<dynamic> get _filteredRequests {
    if (_selectedFilter == 0) {
      return _requests;
    } else if (_selectedFilter == 1) {
      return _requests.where((r) => r['status'] == 'pending').toList();
    } else {
      return _requests.where((r) => r['status'] == 'assigned' || r['status'] == 'completed').toList();
    }
  }

  int get _pendingCount {
    return _requests.where((r) => r['status'] == 'pending').length;
  }

  int get _activeCount {
    return _requests.where((r) => r['status'] == 'assigned').length;
  }

  int get _completedCount {
    return _requests.where((r) => r['status'] == 'completed').length;
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
                      'My Offline Requests',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _fetchRequests,
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
                        title: 'Pending',
                        value: _pendingCount.toString(),
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Assigned',
                        value: _activeCount.toString(),
                        icon: Icons.person_add,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Completed',
                        value: _completedCount.toString(),
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
                    _buildFilterTab('Pending', 1),
                    _buildFilterTab('Completed', 2),
                  ],
                ),
              ),
              
              // Requests List
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
                                'Loading requests...',
                                style: GoogleFonts.poppins(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : _filteredRequests.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No offline requests found',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    'Tap "Offline Home Tutor Request" to create one',
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
                                    icon: const Icon(Icons.home_work),
                                    label: const Text('Request Offline Tutor'),
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
                              onRefresh: _fetchRequests,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredRequests.length,
                                itemBuilder: (context, index) {
                                  final request = _filteredRequests[index];
                                  return _buildRequestCard(request);
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

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
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
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
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

  Widget _buildRequestCard(dynamic request) {
    String status = request['status'] ?? 'pending';
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status) {
      case 'assigned':
        statusColor = Colors.blue;
        statusIcon = Icons.person_add;
        statusText = 'Assigned';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['subject'] ?? 'Not specified',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      Text(
                        'Request #${request['id']}',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Details
            _buildDetailRow(Icons.school, 'Class', request['class_grade'] ?? 'Not specified'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.location_on, 'Address', request['student_address'] ?? 'Not specified'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time, 'Preferred Timing', request['preferred_timing'] ?? 'Not specified'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.currency_rupee, 'Budget', request['budget'] ?? 'Negotiable'),
            
            if (request['assigned_teacher_name'] != null && request['assigned_teacher_name'] != '')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildDetailRow(Icons.people, 'Assigned Teacher', request['assigned_teacher_name']),
              ),
            
            if (request['demo_date'] != null && request['demo_date'] != '')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildDetailRow(Icons.calendar_today, 'Demo Date', request['demo_date'].toString().substring(0, 10)),
              ),
            
            if (status == 'assigned')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Teacher assigned! You will be contacted soon for demo.',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF2D2D2D),
            ),
          ),
        ),
      ],
    );
  }
}
