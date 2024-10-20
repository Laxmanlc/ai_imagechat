import 'dart:convert';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker
import 'package:http/http.dart' as http;

class ImageChat extends StatefulWidget {
  const ImageChat({super.key});

  @override
  State<ImageChat> createState() => _ImageChatState();
}

class _ImageChatState extends State<ImageChat> {
  PlatformFile? pickedImage; // Use PlatformFile for file_picker
  String mytext = '';
  bool scanning = false;

  TextEditingController prompt = TextEditingController();

  final apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key= USE YOUR OWN API KEY HERE ";

  final header = {
    'Content-Type': 'application/json',
  };

  Future<void> getImage() async {
    if (kIsWeb) {
      // Web platform
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null) {
        setState(() {
          pickedImage = result.files.first;
        });
      }
    } else {
      // Mobile and desktop platforms
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null) {
        setState(() {
          pickedImage = result.files.first;
        });
      }
    }
  }

  getdata(PlatformFile image, String promptValue) async {
    setState(() {
      scanning = true;
      mytext = '';
    });

    try {
      // Read file as bytes
      Uint8List imageBytes = image.bytes!;
      String base64File = base64.encode(imageBytes);

      final data = {
        "contents": [
          {
            "parts": [
              {"text": promptValue},
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64File,
                }
              }
            ]
          }
        ],
      };

      await http
          .post(Uri.parse(apiUrl), headers: header, body: jsonEncode(data))
          .then((response) {
        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          mytext = result['candidates'][0]['content']['parts'][0]['text'];

          // Remove ** from the text, if any
          mytext = mytext.replaceAll('**', '');
        } else {
          mytext = 'Response status : ${response.statusCode}';
        }
      }).catchError((error) {
        print('Error occurred ${error}');
      });
    } catch (e) {
      print('Error occurred ${e}');
    }

    setState(() {
      scanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Image Chat',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
              iconSize: 50,
              onPressed: () {
                getImage();
              },
              icon: const Icon(
                Icons.photo,
                color: Colors.black,
              )),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            pickedImage == null
                ? Container(
                    height: 340,
                    width: 180,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 240, 240, 240),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 208, 206, 206),
                          offset: Offset(4, 4),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Color.fromARGB(255, 255, 255, 255),
                          offset: Offset(-4, -4),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'No Image Selected',
                        style: TextStyle(fontSize: 22, color: Colors.black),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 340,
                    child: Center(
                        child: Image.memory(
                      pickedImage!.bytes!,
                      height: 400,
                    ))),
            const SizedBox(height: 20),
            // Neumorphic TextField with a hint of purple theme
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 240, 240),
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 208, 206, 206),
                    offset: Offset(4, 4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Color.fromARGB(255, 255, 255, 255),
                    offset: Offset(-4, -4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                controller: prompt,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.pending_sharp,
                    color: Colors.black,
                  ),
                  hintText: 'Enter your prompt here',
                  hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 114, 111, 121)),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Neumorphic button with purple theme and smaller size
            GestureDetector(
              onTap: () {
                if (pickedImage != null) {
                  getdata(pickedImage!, prompt.text);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 240, 240, 240),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 208, 206, 206),
                      offset: Offset(4, 4),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Color.fromARGB(255, 255, 255, 255),
                      offset: Offset(-4, -4),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.generating_tokens_rounded, color: Colors.black),
                    SizedBox(width: 10),
                    Text(
                      'Generate Answer',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            scanning
                ? const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                        child: SpinKitThreeBounce(
                      color: Colors.white,
                      size: 20,
                    )))
                : Text(
                    mytext,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, color: Colors.black),
                  ),
            const SizedBox(
              height: 30,
            ),
            const Text('Developed by @LaxmanLamichhane')
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
