class AppConfig {
  // Production URL - Main website (API is integrated)
  static const String baseUrl = 'https://hometutorhub.in';
  static const String apiUrl = '$baseUrl/api';
  
  // For Development (local testing)
  // static const String baseUrl = 'http://localhost:5000';
  // static const String apiUrl = '$baseUrl';
  
  // Your API endpoints
  static const String login = '$apiUrl/login';
  static const String teachers = '$apiUrl/teachers';
  static const String register = '$apiUrl/register';
  static const String studentRegister = '$apiUrl/student_register';
  static const String teacherRegister = '$apiUrl/teacher_register';
  static const String allCourses = '$apiUrl/all_courses';
  static const String enrollCourse = '$apiUrl/enroll_course';
  static const String myEnrolledCourses = '$apiUrl/my_enrolled_courses';
  static const String postRequest = '$apiUrl/post_request';
  static const String allRequests = '$apiUrl/all_requests';
  static const String teacherCourses = '$apiUrl/teacher_courses';
  static const String unlockContact = '$apiUrl/unlock_contact';
  static const String offlineRequest = '$apiUrl/offline_request';
  static const String myOfflineRequests = '$apiUrl/my_offline_requests';
  static const String submitFeedback = '$apiUrl/submit_feedback';
  static const String teacherPaymentRequests = '$apiUrl/teacher_payment_requests';
  static const String teacherPaymentHistory = '$apiUrl/teacher_payment_history';
}
