
// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController dobController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();

//   File? aadhaarImage;
//   final picker = ImagePicker();

//   Future<void> pickAadhaarImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         aadhaarImage = File(pickedFile.path);
//       });
//     }
//   }

//   void validateAndProceed() async {
//     if (_formKey.currentState!.validate()) {
//       if (aadhaarImage == null) {
//         Fluttertoast.showToast(msg: '📄 Please upload Aadhaar image');
//         return;
//       }

//       // Simulated OCR Aadhaar data
//       const extractedName = "Your Name";
//       const extractedDob = "16/03/2004";

//       if (nameController.text.trim() != extractedName ||
//           dobController.text.trim() != extractedDob) {
//         Fluttertoast.showToast(msg: "❌ Aadhaar details do not match");
//         return;
//       }

//       Fluttertoast.showToast(msg: "✅ Aadhaar Verified");
//       sendWhatsAppOtp(phoneController.text.trim());
//     }
//   }

//   void sendWhatsAppOtp(String phone) async {
//     String otp = (100000 + Random().nextInt(899999)).toString();

//     final supabase = Supabase.instance.client;
//     final now = DateTime.now();
//     final expiresAt = now.add(const Duration(minutes: 5));

//     await supabase.from('whatsapp_otps').upsert({
//       'phone': phone,
//       'otp': otp,
//       'expires_at': expiresAt.toIso8601String(),
//       'verified': false,
//     });

//     final response = await http.post(
//       Uri.parse("https://api.ultramsg.com/instanceXXXX/messages/chat"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "token": "YOUR_ULTRAMSG_TOKEN",
//         "to": "+91$phone",
//         "body": "Your OTP is $otp. It will expire in 5 minutes."
//       }),
//     );

//     if (response.statusCode == 200) {
//       showOtpDialog(phone);
//     } else {
//       Fluttertoast.showToast(msg: "❌ Failed to send OTP via WhatsApp");
//     }
//   }

//   void showOtpDialog(String phone) {
//     final otpController = TextEditingController();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text("Enter WhatsApp OTP"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text("OTP sent to WhatsApp: +91 $phone"),
//             const SizedBox(height: 10),
//             TextField(
//               controller: otpController,
//               keyboardType: TextInputType.number,
//               maxLength: 6,
//               decoration: const InputDecoration(labelText: "Enter 6-digit OTP"),
//             )
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               final enteredOtp = otpController.text.trim();
//               final supabase = Supabase.instance.client;

//               final result = await supabase
//                   .from('whatsapp_otps')
//                   .select()
//                   .eq('phone', phone)
//                   .eq('otp', enteredOtp)
//                   .gt('expires_at', DateTime.now().toIso8601String())
//                   .eq('verified', false)
//                   .maybeSingle();

//               if (result != null) {
//                 await supabase
//                     .from('whatsapp_otps')
//                     .update({'verified': true})
//                     .eq('phone', phone);

//                 Fluttertoast.showToast(msg: "✅ OTP Verified");

//                 await supabase.from('users').insert({
//                   'name': nameController.text.trim(),
//                   'dob': dobController.text.trim(),
//                   'phone': phone,
//                   'email': emailController.text.trim(),
//                   'password': passwordController.text.trim(),
//                   'address': addressController.text.trim(),
//                   'aadhaar_image_url': aadhaarImage?.path,
//                   'otp_verified': true,
//                 });

//                 Fluttertoast.showToast(msg: "🎉 User Registered Successfully");
//                 Navigator.of(context).pop(); // close dialog
//                 Navigator.of(context).pop(); // go to login
//               } else {
//                 Fluttertoast.showToast(msg: "❌ Invalid or expired OTP");
//               }
//             },
//             child: const Text("Verify"),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFDF8F0),
//       appBar: AppBar(
//         title: const Text('Sign Up'),
//         backgroundColor: Colors.deepOrange,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Create an Account",
//                   style: GoogleFonts.poppins(
//                       fontSize: 24, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 20),

//               TextFormField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: 'Full Name'),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter your name' : null,
//               ),
//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: dobController,
//                 decoration: const InputDecoration(labelText: 'Date of Birth (DD/MM/YYYY)'),
//                 validator: (value) {
//                   final regex = RegExp(r"^\\d{2}/\\d{2}/\\d{4}");
//                   return value == null || !regex.hasMatch(value)
//                       ? 'Enter DOB in DD/MM/YYYY format'
//                       : null;
//                 },
//               ),
//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: phoneController,
//                 keyboardType: TextInputType.phone,
//                 decoration: const InputDecoration(labelText: 'Phone Number'),
//                 validator: (value) => value!.length != 10
//                     ? 'Enter valid 10-digit phone number'
//                     : null,
//               ),
//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter your email' : null,
//               ),
//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: 'Password'),
//                 validator: (value) => value!.length < 6
//                     ? 'Password must be at least 6 characters'
//                     : null,
//               ),
//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: confirmPasswordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: 'Confirm Password'),
//                 validator: (value) => value != passwordController.text
//                     ? 'Passwords do not match'
//                     : null,
//               ),
//               const SizedBox(height: 10),

//               TextFormField(
//                 controller: addressController,
//                 decoration: const InputDecoration(labelText: 'Address'),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter your address' : null,
//               ),
//               const SizedBox(height: 20),

//               aadhaarImage != null
//                   ? Image.file(aadhaarImage!, height: 100)
//                   : const Text('No Aadhaar Image Selected'),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: pickAadhaarImage,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
//                 child: const Text("Upload Aadhaar Card"),
//               ),

//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: validateAndProceed,
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                   backgroundColor: Colors.deepOrange,
//                 ),
//                 child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:xml/xml.dart' as xml;
import 'login_screen.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();


File? aadhaarImage;
final picker = ImagePicker();

Future<void> captureAadhaarQR() async {
  final pickedFile = await picker.pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.rear,
  );
  if (pickedFile != null) {
    aadhaarImage = File(pickedFile.path);
    scanQRCodeFromImage(aadhaarImage!);
    // You can now call scanQRCodeFromImage(aadhaarImage!) here
  }
}
Future<void> scanQRCodeFromImage(File imageFile) async {
  final inputImage = InputImage.fromFile(imageFile);
  final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

  final barcodes = await barcodeScanner.processImage(inputImage);

  for (Barcode barcode in barcodes) {
    final rawValue = barcode.rawValue;
    if (rawValue != null && rawValue.contains('<PrintLetterBarcodeData')) {
      print('✅ Aadhaar QR Found');
      print(rawValue); // Aadhaar XML data

      // Now you can parse the XML (Name, DOB, Gender, UID)
    } else {
      print("❌ Not a valid Aadhaar QR");
    }
  }

  barcodeScanner.close();
}



String? extractedName;
String? extractedDob;
void validateAndProceed() async {
  if (_formKey.currentState!.validate()) {
    if (aadhaarImage == null) {
      Fluttertoast.showToast(msg: '📄 Please capture Aadhaar card first');
      return;
    }

    final inputImage = InputImage.fromFile(aadhaarImage!);
    final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

    final barcodes = await barcodeScanner.processImage(inputImage);
    barcodeScanner.close();

    if (barcodes.isEmpty) {
      Fluttertoast.showToast(
          msg: '❌ No QR code found! Place the camera clearly over the Aadhaar QR code.');
      return;
    }

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || !rawValue.contains('<PrintLetterBarcodeData')) {
      Fluttertoast.showToast(msg: '❌ Invalid Aadhaar QR code');
      return;
    }

    try {
      final document = xml.XmlDocument.parse(rawValue);
      final data = document.rootElement;

      extractedName = data.getAttribute('name');
      extractedDob = data.getAttribute('dob') ?? data.getAttribute('yob');

      if (extractedName == null || extractedDob == null) {
        Fluttertoast.showToast(msg: '❌ Could not extract name or DOB from Aadhaar');
        return;
      }

      final inputName = nameController.text.trim().toLowerCase();
      final inputDob = dobController.text.trim();

      final aadhaarName = extractedName!.toLowerCase();
      final aadhaarDob = extractedDob!;

      // Compare both fields separately
      if (inputName != aadhaarName && inputDob != aadhaarDob) {
        Fluttertoast.showToast(
            msg: "❌ Name and Date of Birth both do not match Aadhaar record.");
        return;
      } else if (inputName != aadhaarName) {
        Fluttertoast.showToast(
            msg: "❌ Name does not match Aadhaar. Please enter the exact name as per Aadhaar card.");
        return;
      } else if (inputDob != aadhaarDob) {
        Fluttertoast.showToast(
            msg: "❌ Date of Birth does not match Aadhaar. Please recheck your DOB.");
        return;
      }

      Fluttertoast.showToast(msg: "✅ Aadhaar verified successfully. Sending OTP...");
      sendEmailOtp(emailController.text.trim());

    } catch (e) {
      Fluttertoast.showToast(msg: '❌ Failed to parse Aadhaar QR code');
    }
  }
}


void sendEmailOtp(String email) async {
  String otp = (100000 + Random().nextInt(899999)).toString();

  final supabase = Supabase.instance.client;
  final now = DateTime.now();
  final expiresAt = now.add(const Duration(minutes: 5));

  // Save to Supabase
  await supabase.from('email_otps').upsert({
    'email': email.trim().toLowerCase(),
    'otp': otp,
    'expires_at': expiresAt.toIso8601String(),
    'verified': false,
  });

  final smtpServer = gmail('khushiyshukla@gmail.com', 'ubod xhnv xghb cngf');
  final message = Message()
    ..from = Address('khushiyshukla@gmail.com', 'Z+ Secure') // ✅ your real sender
    ..recipients.add(email)
    ..subject = '🔐 Your SkillKart OTP Code – Expires in 5 Minutes'
    ..text = '''
🛡️ Welcome to SkillKart!

Your One-Time Password (OTP) is: 🔐 $otp

This code is valid for **5 minutes** only.

Please enter this OTP in the app to complete your secure registration process.

Need help? Just reply to this email — we’re here for you.

Thank you for choosing SkillKart. Let’s unlock your potential together! 🚀

Warm regards,  
Team SkillKart
''';


  try {
    await send(message, smtpServer);
    Fluttertoast.showToast(msg: '📩 OTP sent to $email');
    showOtpDialog(context,email.trim().toLowerCase());
  } catch (e) {
    print('❌ Email Error: $e');
    Fluttertoast.showToast(msg: "❌ Failed to send OTP via Email");
  }
}

void showOtpDialog(BuildContext parentContext, String email) {
  final otpController = TextEditingController();
  bool isVerifying = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white.withOpacity(0.95),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, color: Colors.amber, size: 40),
                const SizedBox(height: 10),
                Text(
                  "Email Verification",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20),
                ),
                const SizedBox(height: 15),
                Text(
                  "We've sent a 6-digit OTP to:\n$email",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoMono(fontSize: 20, letterSpacing: 8),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '______',
                    hintStyle: const TextStyle(letterSpacing: 10, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.verified, size: 20),
                  label: Text(
                    isVerifying ? "Verifying..." : "Verify",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  onPressed: isVerifying
                      ? null
                      : () async {
                          setState(() => isVerifying = true);
                          final enteredOtp = otpController.text.trim();
                          final supabase = Supabase.instance.client;

                          final result = await supabase
                              .from('email_otps')
                              .select()
                              .eq('email', email)
                              .eq('otp', enteredOtp)
                              .gt('expires_at', DateTime.now().toIso8601String())
                              .eq('verified', false)
                              .maybeSingle();

                          if (result != null) {
                            await supabase
                                .from('email_otps')
                                .update({'verified': true})
                                .eq('id', result['id']);

                            final insertRes = await supabase.from('users').insert({
                              'name': nameController.text.trim(),
                              'dob': dobController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'email': email,
                              'password': passwordController.text.trim(),
                              'address': addressController.text.trim(),
                              'aadhaar_image_url': aadhaarImage?.path ?? '',
                              'otp_verified': true,
                            });
Fluttertoast.showToast(
    msg: "🎉 Registered Successfully. Redirecting to Login...",
    backgroundColor: Colors.green,
  );

  Navigator.of(context).pop(); // Close dialog
  Future.delayed(const Duration(seconds: 1), () {
   if (parentContext.mounted) {
      Navigator.of(parentContext).pushReplacementNamed('/login');
    }
  });
                          } else {
                            Fluttertoast.showToast(msg: "❌ Invalid or expired OTP");
                          }

                          setState(() => isVerifying = false);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}
@override
Widget build(BuildContext context) {
  return SafeArea(  // ✅ Added SafeArea here
    child: Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Create an Account",
                  style: GoogleFonts.poppins(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'As per Aadhaar Card',
                ),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: dobController,
                decoration: const InputDecoration(
                    labelText: 'Date of Birth (DD/MM/YYYY)',hintText: 'As per Aadhaar Card'),
                    
                validator: (value) {
                  final regex = RegExp(r"^\d{2}/\d{2}/\d{4}");
                  return value == null || !regex.hasMatch(value)
                      ? 'Enter DOB in DD/MM/YYYY format'
                      : null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value!.length != 10
                    ? 'Enter valid 10-digit phone number'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your email' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) => value!.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                validator: (value) =>
                    value != passwordController.text
                        ? 'Passwords do not match'
                        : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your address' : null,
              ),
              const SizedBox(height: 20),
              aadhaarImage != null
                  ? Image.file(aadhaarImage!, height: 100)
                  : const Text('No Aadhaar Image Selected'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: captureAadhaarQR,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                ),
                child: const Text("📷 Capture Aadhaar QR using camera"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: validateAndProceed,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}