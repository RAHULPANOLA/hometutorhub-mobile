class AppConfig {
  // Production URL
  static const String baseUrl = 'https://hometutorhub.in';
  static const String apiUrl = '$baseUrl/api';
  
  // Development URL (uncomment for local testing)
  // static const String baseUrl = 'http://localhost:5000';
  // static const String apiUrl = '$baseUrl/api';
  
  // API Endpoints
  static const String login = '$apiUrl/login';
  static const String register = '$apiUrl/register';
  static const String studentRegister = '$apiUrl/student_register';
  static const String teacherRegister = '$apiUrl/teacher_register';
  static const String teachers = '$apiUrl/teachers';
  static const String allCourses = '$apiUrl/all_courses';
  static const String enrollCourse = '$apiUrl/enroll_course';
  static const String myEnrolledCourses = '$apiUrl/my_enrolled_courses';
  static const String postRequest = '$apiUrl/post_request';
  static const String allRequests = '$apiUrl/all_requests';
  static const String myRequests = '$apiUrl/my_requests';
  static const String acceptRequest = '$apiUrl/accept_request';
  static const String acceptedStudents = '$apiUrl/accepted_students';
  static const String markEnrolled = '$apiUrl/mark_enrolled';
  static const String offlineRequest = '$apiUrl/offline_request';
  static const String myOfflineRequests = '$apiUrl/my_offline_requests';
  static const String submitFeedback = '$apiUrl/submit_feedback';
  static const String unlockContact = '$apiUrl/unlock_contact';
  static const String getStudentPoints = '$apiUrl/get_student_points';
  static const String addPoints = '$apiUrl/add_points';
  static const String createPointOrder = '$apiUrl/create_point_order';
  static const String teacherCourses = '$apiUrl/teacher_courses';
  static const String postCourse = '$apiUrl/post_course';
  static const String courseEnrolledStudents = '$apiUrl/course_enrolled_students';
  static const String updateCourse = '$apiUrl/update_course';
  static const String deleteCourse = '$apiUrl/delete_course';
  static const String scheduleLiveClass = '$apiUrl/schedule_live_class';
  static const String teacherLiveClasses = '$apiUrl/teacher_live_classes';
  static const String deleteLiveClass = '$apiUrl/delete_live_class';
  static const String teacherPaymentRequests = '$apiUrl/teacher_payment_requests';
  static const String teacherPaymentHistory = '$apiUrl/teacher_payment_history';
  static const String markPaymentReceived = '$apiUrl/mark_payment_received';
  static const String extendTrial = '$apiUrl/extend_trial';
  static const String scheduleDemo = '$apiUrl/schedule_demo';
  static const String teacherProfile = '$apiUrl/teacher_profile';
  static const String updateTeacherProfile = '$apiUrl/update_teacher_profile';
  static const String studentProfile = '$apiUrl/student_profile';
  static const String updateStudentProfile = '$apiUrl/update_student_profile';
  static const String studentChangePassword = '$apiUrl/student_change_password';
  static const String createCoursePaymentOrder = '$apiUrl/create_course_payment_order';
  static const String verifyCoursePayment = '$apiUrl/verify_course_payment';
}
