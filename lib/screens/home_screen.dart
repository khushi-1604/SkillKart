
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillkart/screens/login_screen.dart';
import 'package:skillkart/screens/upload_skill.dart';
import 'package:skillkart/screens/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


class SkillKartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [ExploreScreen(), UploadSkillScreen(), ProfileScreen()];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkillKart'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepOrange,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: 'Upload Skill',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> skills = [];
  List<Map<String, dynamic>> filteredSkills = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSkills();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredSkills = skills.where((skill) {
        final title = (skill['title'] ?? '').toString().toLowerCase();
        return title.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchSkills() async {
    final response = await supabase
        .from('skills')
        .select('*, users(name, phone,email)')
        .order('created_at', ascending: false);

    setState(() {
      skills = List<Map<String, dynamic>>.from(response);
      filteredSkills = skills;
    });
  }

  Future<void> launchUPIPayment(String upiId, String name, String amount) async {
    final uri = Uri.parse(
        'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(name)}&am=$amount&cu=INR');

  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    print("Error launching UPI payment: $e");
  }
}


void _showSkillDetails(BuildContext context, Map<String, dynamic> skill) {
  final user = skill['users'];

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage: skill['image_url'] != null
                  ? NetworkImage(skill['image_url'])
                  : AssetImage('assets/images/profile_default.png') as ImageProvider,
              backgroundColor: Colors.orange.shade100,
            ),
            const SizedBox(height: 16),
            Text(
              user['name'] ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              skill['title'] ?? '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepOrange),
            ),
            const SizedBox(height: 12),
            Text(
              skill['description'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 14),

            // 🔹 UPDATED CHIP WITH PAYMENT INTEGRATION
            InkWell(
              onTap: () {
                final amount = skill['rate'].toString();
                final upiId = '91${user['phone']}@upi'; // Create UPI ID
                final name = user['name'] ?? "User";

                launchUPIPayment(upiId, name, amount);
              },
              child: Chip(
                label: Text(
                  '₹${skill['rate']}/hr',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),

            const SizedBox(height: 10),
            Text(
              'Email: ${user['email'] ?? ''}',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final phone = user['phone'];
                      if (phone != null) {
                        final url = Uri.parse('https://wa.me/91$phone');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      }
                    },
                    icon: Icon(Icons.chat),
                    label: Text("Chat"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final phone = user['phone'];
                      if (phone != null) {
                        final url = Uri.parse('tel:$phone');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      }
                    },
                    icon: Icon(Icons.phone),
                    label: Text("Call"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search for skills...",
            prefixIcon: Icon(Icons.search),
            suffixIcon: Icon(Icons.filter_list),
            filled: true,
            fillColor: Colors.orange.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: filteredSkills.length,
          itemBuilder: (context, index) {
            final skill = filteredSkills[index];
            final user = skill['users'];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(20),
                shadowColor: Colors.orangeAccent.withOpacity(0.3),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.orange.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ListTile(
                    onTap: () => _showSkillDetails(context, skill),
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.orange.shade100,
                      backgroundImage: skill['image_url'] != null
                          ? NetworkImage(skill['image_url'])
                          : AssetImage('assets/images/profile_default.png') as ImageProvider,
                    ),
                    title: Text(
                      user['name'] ?? '',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        skill['title'] ?? '',
                        style: TextStyle(fontSize: 14, color: Colors.deepOrange),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.currency_rupee, color: Colors.blue, size: 18),
                        Text(
                          '${skill['rate']}/hr',
                          style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}
}