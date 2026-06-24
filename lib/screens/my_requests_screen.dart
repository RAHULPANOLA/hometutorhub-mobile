import 'package:flutter/material.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String _studentEmail = '';
  int _selectedFilter = 0; // 0: All, 1: Pending, 2: Accepted

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
    await _fetchMyRequests();
  }

  Future<void> _fetchMyRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${AppConfig.apiUrl}/my_requests?email=${Uri.encodeComponent(_studentEmail)}',
        ),
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
        SnackBar(
          content: Text('Error loading requests: $e'),
          backgroundColor: Colors.red,
        ),
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
      return _requests.where((r) => r['status'] == 'accepted').toList();
    }
  }

  int get _pendingCount {
    return _requests.where((r) => r['status'] == 'pending').length;
  }

  int get _acceptedCount {
    return _requests.where((r) => r['status'] == 'accepted').length;
  }

  Future<void> _deleteRequest(int requestId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Request'),
          content: const Text('Are you sure you want to delete this request?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // TODO: Implement delete API
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request deleted'),
                    backgroundColor: Colors.orange,
                  ),
                );
                await _fetchMyRequests();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
                      'My Requests',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _fetchMyRequests,
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
                        value: _requests.length.toString(),
                        icon: Icons.list_alt,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                        title: 'Accepted',
                        value: _acceptedCount.toString(),
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
                    _buildFilterTab('Accepted', 2),
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
                                  'Loading your requests...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : _filteredRequests.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No requests found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  'Tap "Post Request" to create one',
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
                                  icon: const Icon(Icons.add),
                                  label: const Text('Post New Request'),
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
                            onRefresh: _fetchMyRequests,
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
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
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(dynamic request) {
    bool isAccepted = request['status'] == 'accepted';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Show request details
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Status
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            isAccepted
                                ? Colors.green.withValues(alpha: 0.1)
                                : const Color(0xFF6C63FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isAccepted ? Icons.check_circle : Icons.pending,
                        color: isAccepted ? Colors.green : const Color(0xFF6C63FF),
                        size: 24,
                      ),
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
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade500,
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
                            isAccepted
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        request['status'] ?? 'pending',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isAccepted ? Colors.green : Colors.orange,
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
                      request['class_level'] ?? 'Not specified',
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      Icons.location_on,
                      request['location'] ?? 'Not specified',
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      Icons.currency_rupee,
                      request['budget'] ?? 'Negotiable',
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Timing
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      request['timing'] ?? 'Flexible',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                if (isAccepted) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.green, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Request accepted! Teacher will contact you soon.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (!isAccepted) ...[
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _deleteRequest(request['id']),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Edit request
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
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


