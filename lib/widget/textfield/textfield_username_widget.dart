import 'package:flutter/material.dart';
import 'package:flutter_uilogin/provider/auth_provider.dart';
import 'package:provider/provider.dart';


class TextfieldUsernameWidget extends StatefulWidget {
  const TextfieldUsernameWidget({super.key, required this.controller});
  final TextEditingController controller;

  @override
  State<TextfieldUsernameWidget> createState() => _TextfieldUsernameWidgetState();
}

class _TextfieldUsernameWidgetState extends State<TextfieldUsernameWidget> {
  @override
  Widget build(BuildContext context) {
    var loadAuth = Provider.of<LocalAuthProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Username",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
        const SizedBox(height: 20,),
        TextFormField(
          controller: widget.controller,
          autovalidateMode:  AutovalidateMode.onUserInteraction,
          validator: (value) {
            if(value!.isEmpty || value == ""){
              return "Username can't be empty";
            }
            return null;
          },
          onSaved: (value) {
            loadAuth.enteredUsername = value!;
          },
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              hintText: "Insert Username...."
          ),
        )
      ],
    );
  }
}