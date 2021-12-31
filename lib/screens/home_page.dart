import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rupiassignment1/providers/token_provider.dart';
import 'package:rupiassignment1/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:rupiassignment1/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:rupiassignment1/utils/multipart_request.dart';

class HomePage extends StatefulWidget {

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = const FlutterSecureStorage();

  bool _loading = false;
  bool _uploadingImage = false;
  bool _deletingImage = false;
  double _value = 0.0;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {

    deleteImage() async {
      if(context.read<UserProvider>().getUser != null && context.read<UserProvider>().getUser!.imageURL != null){
        setState(() {
          _deletingImage = true;
        });
        final response = await http.delete(Uri.parse("$apiURL/file"),
            headers: <String, String>{
              'Authorization': "Bearer ${context.read<TokenProvider>().getAccess}",
            },
        );
        // print(response.statusCode);
        context.read<UserProvider>().deleteImage();
        setState(() {
          _deletingImage = false;
        });
      }
    }

    uploadImage(String? filename) async {
      if(context.read<UserProvider>().getUser != null){
        setState(() {
          _uploadingImage = true;
        });
        var request = MultipartRequest('POST', Uri.parse("$apiURL/file/upload"),
          onProgress: (int bytes, int total) {
            final progress = bytes / total;
            setState(() {
              _value = progress;
            });
          },
        );
        request.files.add(await http.MultipartFile.fromPath('file', filename!,contentType: MediaType('image', 'jpeg/png'),));
        request.headers.addAll({"Authorization":"Bearer ${context.read<TokenProvider>().getAccess!}"});
        http.Response response = await http.Response.fromStream(await request.send());
        // print(response.statusCode);
        if(response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          context.read<UserProvider>().updateImageURL(data["imageURL"]);
        }else{
          print(response.body);
        }
        setState(() {
          _uploadingImage = false;
        });
      }
    }

    Widget checkIfUserHaveImage(){
      if(context.read<UserProvider>().getUser != null) {
        String? url = context
            .watch<UserProvider>()
            .getUser!
            .imageURL;
        // print("Hi $url");
        if (url != null) {
          return Image.network(url);
        } else {
          return Column(
              crossAxisAlignment:CrossAxisAlignment.center,
              children:const [Text("No image uploaded")]);
        }
      }
      return Column(
          crossAxisAlignment:CrossAxisAlignment.center,
          children:const [Text("Logged Out")]);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 30.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if(context.read<UserProvider>().getUser != null)
                    Text("Welcome ${context.watch<UserProvider>().getUser!.name}",
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  !_loading?ElevatedButton(onPressed: () async {
                    setState(() {
                      _loading = true;
                    });
                    String? token = await storage.read(key: "token");
                    try {
                      await http.delete(Uri.parse("$apiURL/auth/logout"),
                          headers: <String, String>{
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode(<String, String>{
                            'token': token!,
                          })
                      );
                      context.read<UserProvider>().deleteUser();
                      context.read<TokenProvider>().deleteToken();
                      await storage.delete(key: "token");
                    }catch (err){
                      print(err);
                    }
                    _loading = false;
                    Navigator.pushReplacementNamed(context, '/login');
                  }, child: const Text("Logout")):const CircularProgressIndicator(),
                ],
              ),
              const SizedBox(height:20.0),
              Center(
                child:(!_uploadingImage && !_deletingImage) ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(onPressed: () async {
                          var file = await _picker.pickImage(source: ImageSource.gallery);
                          // print(file?.path);
                          uploadImage(file?.path);
                        }, child: const Text("Upload Image")),
                        ElevatedButton(onPressed: () async {
                          deleteImage();
                        }, child: const Text("Remove Image")),
                      ],
                    ),
                    const SizedBox(height:15.0),
                    SizedBox(
                      width:450.0,
                      height:450.0,
                      child:checkIfUserHaveImage(),
                    ),
                  ],
                ):!_deletingImage ?
                SizedBox(
                    width:150.0,
                    height: 150.0,
                    child: CircularProgressIndicator(value: _value,)
                ):
                const SizedBox(
                    width:150.0,
                    height: 150.0,
                    child: CircularProgressIndicator(),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
