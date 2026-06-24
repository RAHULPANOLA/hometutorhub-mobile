import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'loginScreen.dart';
class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          iconTheme:const  IconThemeData(color: Colors.black),
        ),
      drawer: Drawer(
        backgroundColor: CupertinoColors.activeGreen,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 30, bottom: 30),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage("assets/images/profile.png"),
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Noor Mustafa",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Rubik Regular",
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "noormustafa4556@gmail.com",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Rubik Regular",
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Home",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Rubik Medium",
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ListTile(
                          leading: const Icon(Icons.home_outlined, color: Colors.white),
                          title: const Text(
                            "Home",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Rubik Regular",
                            ),
                          ),
                          onTap: () {
                            // Home onTap action
                          },
                        ),

                        ListTile(
                          leading: const Icon(Icons.event_note_outlined, color: Colors.white),
                          title: const Text(
                            "Schedule",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Rubik Regular",
                            ),
                          ),
                          onTap: () {
                            // Schedule onTap action
                          },
                        ),

                        ListTile(
                          leading: const Icon(Icons.note_outlined, color: Colors.white),
                          title: const Text(
                            "Post Grade",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Rubik Regular",
                            ),
                          ),
                          onTap: () {
                            // Post Grade onTap action
                          },
                        ),

                        const Divider(),
                        const SizedBox(height: 10),

                        const Text(
                          "Personal",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Rubik Medium",
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ListTile(
                          leading: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                          title: const Text(
                            "Chat",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Rubik Regular",
                            ),
                          ),
                          onTap: () {
                            // Chat onTap action
                          },
                        ),

                        ListTile(
                          leading: const Icon(Icons.person, color: Colors.white),
                          title: const Text(
                            "Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Rubik Regular",
                            ),
                          ),
                          onTap: () {
                            // Profile onTap action
                          },
                        ),

                        const Divider(),
                        const SizedBox(height: 10),

                        const Text(
                          "Settings",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Rubik Medium",
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ListTile(
                          leading: const Icon(Icons.notifications_outlined, color: Colors.white),
                          title: const Text(
                            "Notifications",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Rubik Regular",
                            ),
                          ),
                          onTap: () {
                            // Notifications onTap action
                          },
                        ),

                        ListTile(
                          leading: const Icon(Icons.support_agent_outlined, color: Colors.white),
                          title: const Text(
                            "Support",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Rubik Regular",
                            ),
                          ),
                          onTap: () {
                            // Support onTap action
                          },
                        ),

                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.white),
                          title: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Rubik Regular",
                            ),
                          ),
                          onTap: () async {
                            SharedPreferences sp = await SharedPreferences.getInstance();
                            sp.clear();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text("Keep Track Your \nActivities ",
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: "Montserrat Semi Bold",
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 10, bottom: 40),
                child: Text("Recommended Courses For You",
                  style: TextStyle(
                    fontFamily: "Rubik Regular",
                    color: Colors.black87.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: Container(
                        height: 155,


                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10.0,
                                spreadRadius: 2,
                              ),
                            ]
                        ),
                        child: InkWell(
                          onTap: (){},
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, top: 10),
                                  child: Text("Schedule",
                                    style: TextStyle(
                                      fontFamily: "Rubik Regular",
                                      fontSize: 18,
                                      color: Colors.black87.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),

                                const Padding(
                                  padding: EdgeInsets.only(top: 20, left: 60),
                                  child:  Icon(
                                    Icons.event_note_outlined,
                                    size: 95,
                                    color: Color(0xff1CB78D),
                                  ),
                                ),
                              ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        height: 155,


                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10.0,
                                spreadRadius: 2,
                              ),
                            ]
                        ),
                        child: InkWell(
                          onTap: (){},
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20, top: 10),
                                child: Text("Progress",
                                  style: TextStyle(
                                    fontFamily: "Rubik Regular",
                                    fontSize: 18,
                                    color: Colors.black87.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),

                              const Padding(
                                padding: EdgeInsets.only(top: 20, left: 60),
                                child:  Icon(
                                  Icons.donut_small_outlined,
                                  size: 95,
                                  color: Color(0xff1CB78D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child:  Container(
                        height: 155,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10.0,
                                spreadRadius: 2,
                              ),
                            ]
                        ),
                        child: InkWell(
                          onTap: (){},
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20, top: 10),
                                child: Text("Notification",
                                  style: TextStyle(
                                    fontFamily: "Rubik Regular",
                                    fontSize: 18,
                                    color: Colors.black87.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                          
                              const Padding(
                                padding: EdgeInsets.only(top: 20, left: 60),
                                child:  Icon(
                                  Icons.campaign_outlined,
                                  size: 95,
                                  color: Color(0xff1CB78D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child:  Container(
                        height: 155,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10.0,
                                spreadRadius: 2,
                              ),
                            ]
                        ),
                        child: InkWell(
                          onTap: (){},
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20, top: 10),
                                child: Text("Chat",
                                  style: TextStyle(
                                    fontFamily: "Rubik Regular",
                                    fontSize: 18,
                                    color: Colors.black87.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                          
                              const Padding(
                                padding: EdgeInsets.only(top: 20, left: 60),
                                child:  Icon(
                                  Icons.chat_outlined,
                                  size: 95,
                                  color: Color(0xff1CB78D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child:  Container(
                        height: 155,

                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10.0,
                                spreadRadius: 2,
                              ),
                            ]
                        ),
                        child: InkWell(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20, top: 10),
                                child: Text("Support",
                                  style: TextStyle(
                                    fontFamily: "Rubik Regular",
                                    fontSize: 18,
                                    color: Colors.black87.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                          
                              const Padding(
                                padding: EdgeInsets.only(top: 20, left: 60),
                                child:  Icon(
                                  Icons.support_agent,
                                  size: 95,
                                  color: Color(0xff1CB78D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        height: 155,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10.0,
                                spreadRadius: 2,
                              ),
                            ]
                        ),
                        child: InkWell(
                          onTap: (){},
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20, top: 10),
                                child: Text("Profile",
                                  style: TextStyle(
                                    fontFamily: "Rubik Regular",
                                    fontSize: 18,
                                    color: Colors.black87.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),

                              const Padding(
                                padding: EdgeInsets.only(top: 20, left: 60),
                                child:  Icon(
                                  Icons.badge_outlined,
                                  size: 95,
                                  color: Color(0xff1CB78D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

            ],
          ),
      ),
        );
  }
}






