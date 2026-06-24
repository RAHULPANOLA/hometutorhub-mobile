import 'package:flutter/material.dart';
import '../config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class FindTeachersScreen extends StatefulWidget {
  const FindTeachersScreen({super.key});

  @override
  State<FindTeachersScreen> createState() => _FindTeachersScreenState();
}

class _FindTeachersScreenState extends State<FindTeachersScreen> {
  List<dynamic> _teachers = [];
  List<dynamic> _filteredTeachers = [];
  bool _isLoading = true;
  String _studentEmail = '';

  // Search and filters
  String _searchQuery = '';
  String _selectedSubject = 'All';
  String _selectedCity = 'All';
  double _maxFee = 5000;

  final List<String> _subjects = [
    'All',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Hindi',
    'Computer Science',
  ];
  final List<String> _cities = [
    'All',
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Chennai',
    'Kolkata',
    'Hyderabad',
    'Pune',
  ];

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
    await _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/teachers'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _teachers = data;
          _filteredTeachers = data;
        });
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading teachers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredTeachers =
          _teachers.where((teacher) {
            // Search filter
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              final name = teacher['name'].toString().toLowerCase();
              final subject = teacher['subject'].toString().toLowerCase();
              if (!name.contains(query) && !subject.contains(query)) {
                return false;
              }
            }

            // Subject filter
            if (_selectedSubject != 'All' &&
                teacher['subject'] != _selectedSubject) {
              return false;
            }

            // City filter
            if (_selectedCity != 'All' && teacher['city'] != _selectedCity) {
              return false;
            }

            // Fee filter
            final fee = teacher['monthly_fee'] ?? 0;
            if (fee > _maxFee) {
              return false;
            }

            return true;
          }).toList();
    });
  }

  Future<void> _unlockContact(dynamic teacher) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const Icon(Icons.lock_open, size: 60, color: Color(0xFFFF9800)),
              const SizedBox(height: 15),
              Text(
                'Unlock Contact Details',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pay ₹49 to get teacher contact info',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                      child: Text(
                        teacher['name'][0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacher['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${teacher['subject']} • ${teacher['experience']} years exp',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          final response = await http.post(
                            Uri.parse('${AppConfig.apiUrl}/unlock_contact'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              'teacher_id': teacher['id'],
                              'student_email': _studentEmail,
                            }),
                          );

                          final data = jsonDecode(response.body);

                          if (response.statusCode == 200 &&
                              data['success'] == true) {
                            // Show contact details
                            _showContactDetails(teacher, data);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  data['message'] ?? 'Payment failed',
                                ),
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
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Pay ₹49',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'You will get phone number and email address',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showContactDetails(dynamic teacher, dynamic data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.verified, color: Colors.green),
              SizedBox(width: 10),
              Text('Contact Unlocked!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                  child: Text(
                    teacher['name'][0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  teacher['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              _buildContactTile(
                Icons.phone,
                'Phone Number',
                data['phone'] ?? '+91 98765 43210',
              ),
              _buildContactTile(
                Icons.email,
                'Email Address',
                data['email'] ?? teacher['email'],
              ),
              _buildContactTile(
                Icons.location_on,
                'City',
                teacher['city'] ?? 'Not specified',
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, size: 16, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You can now contact this teacher directly',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Launch phone dialer
                Navigator.pop(context);
              },
              icon: const Icon(Icons.call),
              label: const Text('Call Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                      'Find Teachers',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _fetchTeachers,
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

              // Search Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name or subject...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _applyFilters();
                                });
                              },
                            )
                            : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Filter Chips
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFilterChip('Subject', _selectedSubject, _subjects, (
                      value,
                    ) {
                      setState(() {
                        _selectedSubject = value;
                        _applyFilters();
                      });
                    }),
                    const SizedBox(width: 10),
                    _buildFilterChip('City', _selectedCity, _cities, (value) {
                      setState(() {
                        _selectedCity = value;
                        _applyFilters();
                      });
                    }),
                    const SizedBox(width: 10),
                    _buildPriceFilterChip(),
                  ],
                ),
              ),

              // Results Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_filteredTeachers.length} teachers found',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    if (_filteredTeachers.length != _teachers.length)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedSubject = 'All';
                            _selectedCity = 'All';
                            _maxFee = 5000;
                            _applyFilters();
                          });
                        },
                        child: Text(
                          'Clear Filters',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Teachers List
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
                                  'Loading teachers...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : _filteredTeachers.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No teachers found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  'Try adjusting your filters',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredTeachers.length,
                            itemBuilder: (context, index) {
                              final teacher = _filteredTeachers[index];
                              return _buildTeacherCard(teacher);
                            },
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String selectedValue,
    List<String> values,
    Function(String) onSelected,
  ) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select $label',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...values.map((value) {
                    return ListTile(
                      title: Text(value),
                      trailing:
                          selectedValue == value
                              ? const Icon(Icons.check, color: Color(0xFF6C63FF))
                              : null,
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(value);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $selectedValue',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceFilterChip() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            double tempMaxFee = _maxFee;
            return StatefulBuilder(
              builder: (context, setStateSheet) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Maximum Monthly Fee',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '₹${tempMaxFee.round()}',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                      Slider(
                        value: tempMaxFee,
                        min: 500,
                        max: 10000,
                        divisions: 19,
                        label: '₹${tempMaxFee.round()}',
                        onChanged: (value) {
                          setStateSheet(() {
                            tempMaxFee = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _maxFee = tempMaxFee;
                                  _applyFilters();
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                              ),
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Max Fee: ₹${_maxFee.round()}',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherCard(dynamic teacher) {
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
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Avatar and Name
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                      child: Text(
                        teacher['name'][0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacher['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D2D2D),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                teacher['rating']?.toString() ?? '4.5',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' • ${teacher['experience']} years exp',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subject and Fee
                Row(
                  children: [
                    _buildInfoChip(Icons.book, teacher['subject']),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.location_on, teacher['city']),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.currency_rupee,
                      '₹${teacher['monthly_fee']}/month',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Hourly Fee
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hourly: ₹${teacher['hourly_fee']}/hour',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // View profile
                        },
                        icon: const Icon(Icons.person_outline, size: 18),
                        label: const Text('Profile'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _unlockContact(teacher),
                        icon: const Icon(Icons.lock_open, size: 18),
                        label: const Text('Unlock ₹49'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
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


