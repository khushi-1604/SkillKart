
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:path/path.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class UploadSkillScreen extends StatefulWidget {
//   @override
//   _UploadSkillScreenState createState() => _UploadSkillScreenState();
// }

// class _UploadSkillScreenState extends State<UploadSkillScreen> {
//   final ImagePicker _picker = ImagePicker();
//   File? selectedImage;
//   final supabase = Supabase.instance.client;
//   List<Map<String, dynamic>> uploadedSkills = [];
//   bool _isUploading = false;

//   Future<void> _fetchSkills() async {
//     final prefs = await SharedPreferences.getInstance();
//     final email = prefs.getString('email');
//     if (email == null) return;

//     final response = await supabase
//         .from('skills')
//         .select()
//         .eq('user_email', email)
//         .order('created_at', ascending: false);

//     setState(() {
//       uploadedSkills = List<Map<String, dynamic>>.from(response);
//     });
//   }

//   Future<String?> _uploadImageToSupabase(File imageFile) async {
//     final fileName = basename(imageFile.path);
//     final filePath = 'skills/$fileName';

//     final bytes = await imageFile.readAsBytes();
//     final response = await supabase.storage
//         .from('skill-images')
//         .uploadBinary(filePath, bytes, fileOptions: FileOptions(upsert: true));

//     if (response.isNotEmpty) {
//       return supabase.storage.from('skill-images').getPublicUrl(filePath);
//     }
//     return null;
//   }

//   Future<void> _saveSkillToDB(String skill, int rate, String desc, File image) async {
//     final prefs = await SharedPreferences.getInstance();
//     final email = prefs.getString('email');
//     if (email == null) return;

//     final imageUrl = await _uploadImageToSupabase(image);
//     if (imageUrl == null) return;

//     await supabase.from('skills').insert({
//       'user_email': email,
//       'title': skill,
//       'rate': rate,
//       'description': desc,
//       'image_url': imageUrl,
//     });

//     await _fetchSkills();
//   }

//   void _showAddSkillDialog(BuildContext context) {
//     final _skillController = TextEditingController();
//     final _rateController = TextEditingController();
//     final _descController = TextEditingController();
//     selectedImage = null;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
//       builder: (ctx) {
//         return StatefulBuilder(builder: (ctx, setModalState) {
//           return SafeArea(
//             child: Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(ctx).viewInsets.bottom,
//                 left: 20,
//                 right: 20,
//                 top: 20,
//               ),
//               child: SingleChildScrollView(
//                 child: AbsorbPointer(
//                   absorbing: _isUploading,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text("Add Your Skill",
//                           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
//                       const SizedBox(height: 16),
//                       GestureDetector(
//                         onTap: () async {
//                           final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//                           if (pickedFile != null) {
//                             setModalState(() {
//                               selectedImage = File(pickedFile.path);
//                             });
//                           }
//                         },
//                         child: CircleAvatar(
//                           radius: 40,
//                           backgroundImage: selectedImage != null
//                               ? FileImage(selectedImage!)
//                               : const AssetImage('assets/images/profile_default.png') as ImageProvider,
//                           backgroundColor: Colors.orange.shade50,
//                           child: selectedImage == null
//                               ? const Icon(Icons.camera_alt, color: Colors.orange)
//                               : null,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       _buildInput("Skill", _skillController),
//                       _buildInput("Cost (₹/hr)", _rateController, inputType: TextInputType.number),
//                       _buildInput("Description", _descController, lines: 3),
//                       const SizedBox(height: 12),

//                       _isUploading
//                           ? const CircularProgressIndicator()
//                           : ElevatedButton.icon(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.deepOrange,
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                               ),
//                               onPressed: () async {
//                                 if (_skillController.text.isEmpty || _rateController.text.isEmpty ||
//                                     _descController.text.isEmpty || selectedImage == null) return;

//                                 setModalState(() => _isUploading = true);
//                                 await _saveSkillToDB(
//                                   _skillController.text,
//                                   int.parse(_rateController.text),
//                                   _descController.text,
//                                   selectedImage!,
//                                 );
//                                 setModalState(() => _isUploading = false);
//                                 if (mounted) Navigator.pop(context);
//                               },
//                               icon: const Icon(Icons.check),
//                               label: const Text("Save Skill"),
//                             ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         });
//       },
//     );
//   }

//   Widget _buildInput(String hint, TextEditingController controller,
//       {TextInputType inputType = TextInputType.text, int lines = 1}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: TextField(
//         controller: controller,
//         keyboardType: inputType,
//         maxLines: lines,
//         decoration: InputDecoration(
//           hintText: hint,
//           filled: true,
//           fillColor: Colors.orange.shade50,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//         ),
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchSkills();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFDFBFB),
//       appBar: AppBar(
//         title: const Text("Your Uploaded Skills"),
//         backgroundColor: Colors.deepOrange,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(
//             left: 12,
//             right: 12,
//             top: 12,
//             bottom: MediaQuery.of(context).viewInsets.bottom + 80,
//           ),
//           child: uploadedSkills.isEmpty
//               ? const Center(child: Text("No skills uploaded yet.", style: TextStyle(fontSize: 16)))
//               : ListView.builder(
//                   itemCount: uploadedSkills.length,
//                   itemBuilder: (context, index) {
//                     final skill = uploadedSkills[index];
//                     return GestureDetector(
//                       onTap: () async {
//                         final shouldDelete = await showDialog<bool>(
//                           context: context,
//                           builder: (ctx) => AlertDialog(
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                             title: const Text("Delete Skill?", style: TextStyle(fontWeight: FontWeight.bold)),
//                             content: const Text("Are you sure you want to delete this skill?"),
//                             actions: [
//                               TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.red,
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                                 ),
//                                 onPressed: () => Navigator.pop(ctx, true),
//                                 child: const Text("Yes, Delete"),
//                               ),
//                             ],
//                           ),
//                         );

//                         if (shouldDelete == true) {
//                           await supabase.from('skills').delete().eq('id', skill['id']);
//                           _fetchSkills();
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Skill deleted'), behavior: SnackBarBehavior.floating),
//                           );
//                         }
//                       },
//                       child: Card(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                         elevation: 4,
//                         child: ListTile(
//                           contentPadding: const EdgeInsets.all(12),
//                           leading: CircleAvatar(
//                             backgroundImage: skill['image_url'] != null
//                                 ? NetworkImage(skill['image_url'])
//                                 : const AssetImage('assets/images/profile_default.png') as ImageProvider,
//                             radius: 30,
//                           ),
//                           title: Text(skill['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(height: 4),
//                               Text(skill['description'] ?? '',
//                                   maxLines: 4, overflow: TextOverflow.ellipsis),
//                             ],
//                           ),
//                           trailing: Text('₹${skill['rate'] ?? 0}/hr',
//                               style: const TextStyle(color: Colors.blue, fontSize: 16)),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _showAddSkillDialog(context),
//         icon: const Icon(Icons.add),
//         label: const Text("Add Skill"),
//         backgroundColor: Colors.deepOrange,
//         foregroundColor: Colors.white,
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadSkillScreen extends StatefulWidget {
  @override
  _UploadSkillScreenState createState() => _UploadSkillScreenState();
}

class _UploadSkillScreenState extends State<UploadSkillScreen> {
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> uploadedSkills = [];
  bool _isUploading = false;

  Future<void> _fetchSkills() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email == null) return;

    final response = await supabase
        .from('skills')
        .select()
        .eq('user_email', email)
        .order('created_at', ascending: false);

    setState(() {
      uploadedSkills = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<String?> _uploadImageToSupabase(File imageFile) async {
    final fileName = basename(imageFile.path);
    final filePath = 'skills/$fileName';

    final bytes = await imageFile.readAsBytes();
    final response = await supabase.storage
        .from('skill-images')
        .uploadBinary(filePath, bytes, fileOptions: FileOptions(upsert: true));

    if (response.isNotEmpty) {
      return supabase.storage.from('skill-images').getPublicUrl(filePath);
    }
    return null;
  }

  Future<void> _saveSkillToDB(String skill, int rate, String desc, File image) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email == null) return;

    final imageUrl = await _uploadImageToSupabase(image);
    if (imageUrl == null) return;

    await supabase.from('skills').insert({
      'user_email': email,
      'title': skill,
      'rate': rate,
      'description': desc,
      'image_url': imageUrl,
    });

    await _fetchSkills();
  }

  void _showAddSkillDialog(BuildContext context) {
    final _skillController = TextEditingController();
    final _rateController = TextEditingController();
    final _descController = TextEditingController();
    selectedImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: AbsorbPointer(
                  absorbing: _isUploading,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Add Your Skill",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () async {
                          final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setModalState(() {
                              selectedImage = File(pickedFile.path);
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage!)
                              : const AssetImage('assets/images/profile_default.png') as ImageProvider,
                          backgroundColor: const Color.fromARGB(255, 241, 209, 157),
                          child: selectedImage == null
                              ? const Icon(Icons.camera_alt, color: Colors.orange)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInput("Skill Title", _skillController),
                      _buildInput("Rate (₹/hr)", _rateController, inputType: TextInputType.number),
                      _buildInput("Short Description", _descController, lines: 3),
                      const SizedBox(height: 12),
                      _isUploading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                              ),
                              onPressed: () async {
                                if (_skillController.text.isEmpty || _rateController.text.isEmpty ||
                                    _descController.text.isEmpty || selectedImage == null) return;

                                setModalState(() => _isUploading = true);
                                await _saveSkillToDB(
                                  _skillController.text,
                                  int.parse(_rateController.text),
                                  _descController.text,
                                  selectedImage!,
                                );
                                setModalState(() => _isUploading = false);
                                if (mounted) Navigator.pop(context);
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text("Save Skill"),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildInput(String hint, TextEditingController controller,
      {TextInputType inputType = TextInputType.text, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        maxLines: lines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color.fromARGB(255, 232, 205, 163),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.orange.shade100,
      appBar: AppBar(
        title: const Text("Your Uploaded Skills"),
        backgroundColor: Colors.deepOrange,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 80,
            ),
            child: uploadedSkills.isEmpty
                ? const Center(child: Text("No skills uploaded yet.", style: TextStyle(fontSize: 16)))
                : ListView.builder(
                    itemCount: uploadedSkills.length,
                    itemBuilder: (context, index) {
                      final skill = uploadedSkills[index];
                      return GestureDetector(
                        onTap: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text("Delete Skill?", style: TextStyle(fontWeight: FontWeight.bold)),
                              content: const Text("Are you sure you want to delete this skill?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Yes, Delete"),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true) {
                            await supabase.from('skills').delete().eq('id', skill['id']);
                            _fetchSkills();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Skill deleted'), behavior: SnackBarBehavior.floating),
                            );
                          }
                        },
                        child: Card(
  margin: const EdgeInsets.only(bottom: 14),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  elevation: 6,
  shadowColor: Colors.orangeAccent.withOpacity(0.3),
  child: DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.orange.shade50, Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: skill['image_url'] != null
                ? NetworkImage(skill['image_url'])
                : const AssetImage('assets/images/profile_default.png') as ImageProvider,
            radius: 35,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skill['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 6),
                Text(skill['description'] ?? '',
                    maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('₹${skill['rate'] ?? 0}/hr',
              style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  ),
),

                      );
                    },
                  ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSkillDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Skill"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
    );
  }
}