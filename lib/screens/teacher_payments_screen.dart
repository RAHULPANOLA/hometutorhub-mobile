import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';

class TeacherPaymentsScreen extends StatefulWidget {
  @override
  _TeacherPaymentsScreenState createState() => _TeacherPaymentsScreenState();
}

class _TeacherPaymentsScreenState extends State<TeacherPaymentsScreen> {
  List<dynamic> _paymentRequests = [];
  List<dynamic> _paymentHistory = [];
  bool _isLoading = true;
  String _teacherEmail = '';
  int _selectedTab = 0; // 0: Pending, 1: History

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
    await _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch pending payment requests
      final pendingResponse = await http.get(
        Uri.parse('${AppConfig.apiUrl}/teacher_payment_requests?email=${Uri.encodeComponent(_teacherEmail)}'),
      );
      
      final pendingData = jsonDecode(pendingResponse.body);
      if (pendingResponse.statusCode == 200) {
        setState(() {
          _paymentRequests = pendingData;
        });
      }

      // Fetch payment history
      final historyResponse = await http.get(
        Uri.parse('${AppConfig.apiUrl}/teacher_payment_history?email=${Uri.encodeComponent(_teacherEmail)}'),
      );
      
      final historyData = jsonDecode(historyResponse.body);
      if (historyResponse.statusCode == 200) {
        setState(() {
          _paymentHistory = historyData;
        });
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading payments: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _markAsReceived(int paymentId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/mark_payment_received'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payment_id': paymentId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Payment marked as received!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await _fetchPayments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to update'),
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
                      'Payments',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: _fetchPayments,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.refresh, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Stats Cards
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Pending',
                        value: _paymentRequests.length.toString(),
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Received',
                        value: _paymentHistory.length.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Amount',
                        value: '₹${_calculateTotalAmount()}',
                        icon: Icons.currency_rupee,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tabs
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildTab('Pending Requests', 0),
                    _buildTab('Payment History', 1),
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
                      : _selectedTab == 0
                          ? _buildPendingRequests()
                          : _buildPaymentHistory(),
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
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

  Widget _buildPendingRequests() {
    if (_paymentRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 20),
            Text(
              'No pending payment requests',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _paymentRequests.length,
      itemBuilder: (context, index) {
        final payment = _paymentRequests[index];
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
                Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.payment, color: Colors.orange, size: 24),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment['course_name'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Student: ${payment['student_name']}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Pending',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.currency_rupee, size: 14, color: Colors.grey.shade500),
                    SizedBox(width: 4),
                    Text(
                      'Amount: ₹${payment['amount']}',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                    SizedBox(width: 4),
                    Text(
                      payment['requested_date'],
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _markAsReceived(payment['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Mark as Received'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentHistory() {
    if (_paymentHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 20),
            Text(
              'No payment history',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _paymentHistory.length,
      itemBuilder: (context, index) {
        final payment = _paymentHistory[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment['course_name'],
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Student: ${payment['student_name']}',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${payment['amount']}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    Text(
                      payment['paid_date'],
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _calculateTotalAmount() {
    int total = 0;
    for (var payment in _paymentHistory) {
      total += (payment['amount'] as num).toInt();
    }
    return total;
  }
}