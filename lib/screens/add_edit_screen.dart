import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_flutter_fiap/screens/home/home_screen.dart';
import 'package:crud_flutter_fiap/utils/security_util.dart';
import 'package:crud_flutter_fiap/widgets/rounded_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/rounded_button.dart';
import '../widgets/rounded_dropdown.dart';

class AddEditScreen extends StatefulWidget {
  static const String id = "/addedit_screen";

  AddEditScreen({
    super.key,
    required this.idCollection,
    required this.level,
    required this.timeExperience,
    required this.skill
  });

  final String idCollection;
  String? level;
  String? timeExperience;
  String skill;

  @override
  State<StatefulWidget> createState() => StartState();
}

class StartState extends State<AddEditScreen> {
  final skillController = TextEditingController();

  String id = "";
  String userId = '';
  // String profileImg = "";
  Uint8List profileImg = base64Decode('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');


  final List<String> _levelValues = [
    "High",
    "Medium",
    "Low"
  ];

  final List<String> _timeExperienceValues = [
    "1",
    "2",
    "3",
    "4",
    "5+"
  ];

  @override
  void initState() {
    getUserId();
    getUserData();
    if (widget.idCollection != '_') {
      skillController.text = widget.skill;
    } else {
      widget.level = _levelValues[0];
      widget.timeExperience = _timeExperienceValues[0];
      widget.skill = "";
    }
    super.initState();
  }

  //#regionFutures
  Future<void> getUserId() async {
    SecurityPreferences pref = SecurityPreferences();
    String uId = await pref.getUserId();
    setState(() {
      userId = uId;
    });
  }

  Future<dynamic> getSkill() async {
    try {
      if (widget.idCollection != "_") {
        final document = await FirebaseFirestore.instance
            .collection('Skills')
            .doc(widget.idCollection)
            .get();

        if (document.exists) {
          widget.skill = document.data()?['skill'];
          widget.level = document.data()?['level'];
          widget.timeExperience = document.data()?['timeExperience'];
        }
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getUserData() async {
    try {
      await getUserId();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: userId)
          .get();

      Map<String, dynamic> data = querySnapshot.docs[0].data();
      setState(() {
        // profileImg = data['profilePicture'].toString();
        String _base64 = data['profilePicture'];
        Uint8List bytes = base64Decode(_base64);
        profileImg = bytes;
      });

      await getSkill();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  //#endregion

  @override
  Widget build(BuildContext context) {
    return initWidget();
  }

  initWidget() {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Column(
            children: [
              Text(
                widget.idCollection != '_' ? "Editar" : "Adicionar",
                style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w400),
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 60.0,
              backgroundImage: MemoryImage(profileImg),
            ),
            const SizedBox(height: 24),
            RoundedTextField(
              hint: 'Skill',
              textController: skillController,
              icon: const Icon(
                Icons.military_tech,
                color: Color(0xff2e2e2e),
              ),
              obscureText: false,
              maskType: 'none',
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
              padding: const EdgeInsets.only(left: 20, right: 20),
              height: 54,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(50),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  borderRadius: BorderRadius.circular(6),
                  isExpanded: true,
                  value: widget.level,
                  items: _levelValues.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: const Text("Level"),
                  onChanged: (String? value) {
                    setState(() {
                      widget.level = value;
                    });
                  },
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
              padding: const EdgeInsets.only(left: 20, right: 20),
              height: 54,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(50),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  borderRadius: BorderRadius.circular(6),
                  isExpanded: true,
                  value: widget.timeExperience,
                  items: _timeExperienceValues.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: const Text("Tempo de experiência"),
                  onChanged: (String? value) {
                    setState(() {
                      widget.timeExperience = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16, width: double.infinity),
            GestureDetector(
              onTap: () {
                onSave(context);
              },
              child: RoundedButton(color: const Color(0xff2e2e2e), text: widget.idCollection != '_' ? "Editar" : "Salvar"),
            ),
            GestureDetector(
              onTap: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ));
              },
              child: const RoundedButton(color: Color(0xffee4c83), text: "Cancelar"),
            ),
          ],
        )));
  }

  bool validateFields() {
    if (skillController.text.isEmpty || widget.level == null || widget.timeExperience == null) {
      return false;
    }

    return true;
  }
  void onSave(BuildContext context) {
    if (validateFields()) {
      save();
      final navigator = Navigator.of(context);
      navigator.pop();
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ));
    } else {
      var snackBar = const SnackBar(
        content: Text("Todos os campos devem ser preenchidos"),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> save() async {
    try {
      final skillToSave = <String, String?>{
        "skill": skillController.text,
        "level": widget.level,
        "timeExperience": widget.timeExperience,
        "userId": userId,
      };

      if (widget.idCollection != '_') {
        await FirebaseFirestore.instance
            .collection("Skills")
            .doc(widget.idCollection)
            .update(skillToSave);
      } else {
        await FirebaseFirestore.instance.collection("Skills").add(skillToSave);
      }
    } on FirebaseAuthException catch (_) {
      var snackBar = const SnackBar(
        content: Text("Problemas ao salvar! Tente novamente!"),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

}
