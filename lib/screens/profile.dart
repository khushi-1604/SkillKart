import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? userData;
  List<dynamic> skills = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    if (email == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final userResponse = await supabase
          .from('users')
          .select()
          .eq('email', email)
          .single();

      final skillResponse = await supabase
          .from('skills')
          .select()
          .eq('user_email', userResponse['email']);

      setState(() {
        userData = userResponse;
        skills = skillResponse;
        loading = false;
      });
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userData == null) {
      return const Center(child: Text("Profile not found."));
    }

    return Scaffold(
      backgroundColor: Color(0xFFFDFBFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 30, bottom: 5),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                   colors: [Color(0xFFFDFBFB), Color(0xFFFDFBFB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                 CircleAvatar(
  radius: 50,
  backgroundImage: const AssetImage('assets/profile.png'),
),

                  const SizedBox(height: 12),
                  Text(userData!['name'] ?? '',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                  Text(userData!['email'] ?? '',
                      style: const TextStyle(color: Colors.deepOrange)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _infoTile('📞 Phone    ', userData!['phone'] ?? 'Not available'),
            _infoTile('🎂 DOB    ', userData!['dob'] ?? 'Not provided'),
            _infoTile('👤 Gender    ', userData!['gender'] ?? 'Not specified'),
            _infoTile('📍 Address    ', userData!['address'] ?? 'Not added'),

            // Skills Summary
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🛠️ Skills Uploaded (${skills.length})',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (skills.isEmpty)
                    const Text("No skills uploaded yet."),
                  for (var skill in skills)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.deepOrange),
                        title: Text(skill['title'] ?? 'Unnamed Skill'),
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

  Widget _infoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
