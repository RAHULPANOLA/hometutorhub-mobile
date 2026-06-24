import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';

class BuyPointsScreen extends StatefulWidget {
  const BuyPointsScreen({super.key});

  @override
  _BuyPointsScreenState createState() => _BuyPointsScreenState();
}

class _BuyPointsScreenState extends State<BuyPointsScreen> {
  bool _isLoading = false;
  int _currentPoints = 0;
  String _studentName = '';
  String _studentEmail = '';

  final List<Map<String, dynamic>> _pointPackages = [
    {'points': 49, 'price': 49, 'popular': false, 'save': 0},
    {'points': 100, 'price': 99, 'popular': true, 'save': 0},
    {'points': 500, 'price': 449, 'popular': false, 'save': '10%'},
    {'points': 1000, 'price': 799, 'popular': false, 'save': '20%'},
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentName = prefs.getString('user_name') ?? 'Student';
      _studentEmail = prefs.getString('user_email') ?? '';
      _currentPoints = prefs.getInt('user_points') ?? 0;
    });
  }

  Future<void> _purchasePoints(int points, int amount) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/create_point_order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'points': points,
          'amount': amount,
          'student_email': _studentEmail,
          'student_name': _studentName,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Open Razorpay payment
        _openRazorpayCheckout(data, points, amount);
      } else {
        _showError(data['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openRazorpayCheckout(dynamic orderData, int points, int amount) {
    // Make sure Razorpay is loaded
    if (orderData['key_id'] == null) {
      _showError('Payment gateway not configured');
      return;
    }

    // Razorpay checkout options prepared for future integration.
    // Currently mocked: payment flow handled by showing success dialog.
    _showPaymentSuccess(points);
  }

  void _showPaymentSuccess(int points) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text('Payment Successful!'),
            ],
          ),
          content: Text(
            '$points points have been added to your account.',
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updatePoints(points);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePoints(int points) async {
  // Update points in backend
  try {
    final response = await http.post(
      Uri.parse('${AppConfig.apiUrl}/add_points'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'student_email': _studentEmail,
        'points': points,
      }),
    );

    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200 && data['success'] == true) {
      // Update local points
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int newPoints = _currentPoints + points;
      await prefs.setInt('user_points', newPoints);
      
      // Also update user points in session via API call to refresh
      await _refreshUserPoints();
      
      setState(() {
        _currentPoints = newPoints;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${data['message'] ?? '$points points added!'}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Return to dashboard after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, true);
      });
    } else {
      _showError(data['message'] ?? 'Failed to add points');
    }
  } catch (e) {
    print('Error updating points: $e');
    _showError('Error updating points: $e');
  }
}

Future<void> _refreshUserPoints() async {
  // Fetch current points from backend
  try {
    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl}/get_student_points?email=${Uri.encodeComponent(_studentEmail)}'),
    );
    
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_points', data['points']);
      setState(() {
        _currentPoints = data['points'];
      });
    }
  } catch (e) {
    print('Error refreshing points: $e');
  }
}

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
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
                      'Buy Points',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                          const SizedBox(width: 5),
                          Text(
                            '$_currentPoints pts',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main Content
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
                                'Processing...',
                                style: GoogleFonts.poppins(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.monetization_on,
                                        size: 50,
                                        color: Color(0xFFFF9800),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Get More Points',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2D2D2D),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Unlock teacher contacts and access more features',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Point Packages Grid
                              Text(
                                'Choose a Package',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D2D2D),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.2,
                                ),
                                itemCount: _pointPackages.length,
                                itemBuilder: (context, index) {
                                  final package = _pointPackages[index];
                                  return _buildPackageCard(package);
                                },
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Info Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.info, color: Color(0xFF6C63FF), size: 20),
                                        const SizedBox(width: 10),
                                        Text(
                                          'How it works?',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2D2D2D),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow('1', 'Unlock teacher contact', 'Spend 49 points to see phone & email'),
                                    _buildInfoRow('2', 'Post tuition request', 'Free for all students'),
                                    _buildInfoRow('3', 'Enroll in courses', 'Free for all students'),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 20),
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

  Widget _buildPackageCard(Map<String, dynamic> package) {
    return GestureDetector(
      onTap: () => _purchasePoints(package['points'], package['price']),
      child: Container(
        decoration: BoxDecoration(
          gradient: package['popular'] 
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
                )
              : null,
          color: package['popular'] ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: package['popular'] 
              ? null 
              : Border.all(color: Colors.grey.shade200),
        ),
        child: Stack(
          children: [
            if (package['popular'])
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF9800),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    'POPULAR',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${package['points']}',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: package['popular'] ? Colors.white : const Color(0xFF6C63FF),
                    ),
                  ),
                  Text(
                    'Points',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: package['popular'] ? Colors.white.withValues(alpha: 0.9) : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₹${package['price']}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: package['popular'] ? Colors.white : const Color(0xFF2D2D2D),
                    ),
                  ),
                  if (package['save'] != 0)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Save ${package['save']}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: package['popular'] 
                          ? Colors.white.withValues(alpha: 0.2) 
                          : const Color(0xFF6C63FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Buy Now',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: package['popular'] ? Colors.white : const Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6C63FF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
