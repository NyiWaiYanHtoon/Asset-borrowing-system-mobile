import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class textInput extends StatelessWidget {
  String label;
  TextEditingController controller;
  textInput({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: false,
        decoration: InputDecoration(
          hintText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
class numberInput extends StatelessWidget {
  TextEditingController controller;
  numberInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: controller,
        obscureText: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
class pswInput extends StatefulWidget {
  TextEditingController controller;
  String label;
  pswInput({super.key, required this.controller, required this.label});

  @override
  State<pswInput> createState() => _pswInputState();
}

class _pswInputState extends State<pswInput> {
  bool isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: widget.controller,
        obscureText: !isPasswordVisible,
        decoration: InputDecoration(
          hintText: widget.label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }
}

class LongTextInput extends StatelessWidget {
  final String label;
  TextEditingController controller;
  LongTextInput({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        minLines: 1,
        maxLines: 2,
        controller: controller,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}


class orDivider extends StatelessWidget {
  const orDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('or'),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}

class Label extends StatelessWidget {
  String label;
  Label({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class googleSignup extends StatelessWidget {
  const googleSignup({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.grey),
      ),
      icon: Image.asset(
        'images/google.webp',
        height: 24,
      ),
      onPressed: () {},
      label: const Text('Sign up with Google'),
    );
  }
}
class DropdownInput extends StatelessWidget {
  final List<String> items;
  final String value;
  final Function(String?) onChanged;

  DropdownInput({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }
}

class profileFieldInput extends StatelessWidget {
  IconData icon;
  TextEditingController controller;
  bool isPassword;
  String labelText;
  bool enabled;
  profileFieldInput(
      {super.key,
      required this.icon,
      required this.controller,
      required this.labelText,
      this.isPassword = false,
      this.enabled=true});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        trailing: isPassword
            ? IconButton(
                icon: const Icon(Icons.lock_outline),
                onPressed: () {},
              )
            : null,
        title: TextField(
          enabled: enabled,
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            labelText: labelText,
            border: InputBorder.none,
          ),
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}