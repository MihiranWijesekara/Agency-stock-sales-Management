import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final shopCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;

  Future<void> registerUser() async {
    // Validate input fields
    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your name")));
      return;
    }
    if (shopCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter shop name")));
      return;
    }
    if (phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter phone number")),
      );
      return;
    }
    if (passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter password")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
        "https://script.google.com/macros/s/AKfycbzSJAvLIqLT5jDhGYym9R1BZbJVkUHEJDa4gOmbk4xaOMVw-Pv0PGt0h-uh2Gr0okIM/exec",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameCtrl.text.trim(),
          "shopName": shopCtrl.text.trim(),
          "phone": phoneCtrl.text.trim(),
          "password": passCtrl.text.trim(),
        }),
      );

      setState(() {
        isLoading = false;
      });

      // Google Apps Script typically returns 200 or 302 for successful requests
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 302) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'success' ||
              responseData['result'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Registered Successfully!"),
                backgroundColor: Colors.green,
              ),
            );
            // Clear the form
            nameCtrl.clear();
            shopCtrl.clear();
            phoneCtrl.clear();
            passCtrl.clear();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(responseData['message'] ?? "Registration Failed"),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          // If response is not JSON, treat as success based on status code
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registered Successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          // Clear the form
          nameCtrl.clear();
          shopCtrl.clear();
          phoneCtrl.clear();
          passCtrl.clear();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Registration Failed (Status: ${response.statusCode})",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: shopCtrl,
              decoration: const InputDecoration(labelText: "Shop Name"),
            ),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : registerUser,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
