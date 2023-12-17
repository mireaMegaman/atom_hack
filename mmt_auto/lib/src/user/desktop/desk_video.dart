// dart
import 'dart:io';
import 'dart:convert';
// base flutter
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
// external dependencies
// import 'package:path/path.dart';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:media_kit_video/media_kit_video.dart';

// app pages
import 'package:mmt_auto/src/user/mmt.dart';
import 'package:mmt_auto/src/user/desktop/desk_image.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';


// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //

final Uri repository = Uri.parse('https://github.com/mireaMegaman/atom_hack');

// ---------------------------------------------------------------------------------------------- //

class VideoDesktop extends StatefulWidget {
  const VideoDesktop({super.key});
  @override
  State<VideoDesktop> createState() => VideoDeskState();
}

// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //

class  VideoDeskState extends State<VideoDesktop>{
  final ScrollController _vertical = ScrollController(), _horizontal = ScrollController();
  bool flag = false;
  late var popup = '';
  bool _isLoading = false;
  late var newDataList = [];
  List<Widget> nameSlots = [];
  // final _imageController = PageController();
  List<String> bboxImgs = [
    "./assets/images/loader.png",
    "./assets/images/loader.png",
  ];
  Future<void> _repo() async {
    if (!await launchUrl(repository)) {
      throw Exception('Could not launch $repository');
    }
  }
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
// video player from media kit
  // control playback
  late final player = Player();
  // handle video output from [Player]
  late final controller = VideoController(
    player,
    configuration: const VideoControllerConfiguration(
      enableHardwareAcceleration: true,      // default: true
    ),
  );

  var playable = Media(' ');

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].
    player.open(playable);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
  // unzip fastapi server responce
  Future<void> unzipFileFromResponse(List<int> responseBody) async {
    final archive = ZipDecoder().decodeBytes(responseBody);
    bboxImgs = [];
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        if (filename.contains('.jpg') || filename.contains('.jpeg') || filename.contains('.png')) {
          if (Platform.isWindows || Platform.isLinux) {
            File('./responce/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
            if (filename.contains('boxed_image')) {
              bboxImgs.add('./responce/$filename');
            }
          }
        }
        else {
          if (Platform.isWindows || Platform.isLinux) {
            File('./responce/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
            File file = File("./responce/$filename");
            // print(file.absolute.path);
            if (filename.contains('.mp4')) {
              // playable = Media(file.absolute.path);
              playable = Media(file.path);
              setState(() {
                _isLoading = false;
                player.open(playable);
              });                
            }
          }
        }
      } else {
        await Directory('responce/$filename').create(recursive: true);
      }
    }
  }
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
  // image upload to fastapi server
  Future<void> uploadVideo() async {
    setState(() {
      _isLoading = true;
    });
    final picker = ImagePicker();
    final XFile? file = await picker.pickVideo(
            source: ImageSource.gallery, maxDuration: const Duration(seconds: 20));
    final json = {'file': file?.path};
    final response = await http.post(
        Uri.parse('http://127.0.0.1:80/video'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode(json),
    );
    if (response.statusCode == 200) {
      unzipFileFromResponse(response.bodyBytes);
      setState(() {
        flag = true;
        _isLoading = false;
        if (Platform.isWindows) {
          if (bboxImgs.contains("./mmt_fl/assets/images/sml.png")) {
            bboxImgs.remove("./mmt_fl/assets/images/sml.png");
          }
          if (bboxImgs.contains("./assets/images/sml.png")) {
            bboxImgs.remove("./assets/images/sml.png");
          }
        }
      });
    }
    else {
      setState(() {
        _isLoading = false;
      });
    }
  }
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
  // clearing files on Windows and Android
  Future<void> clearFolders() async {
    popup = '';
    if (Platform.isWindows) {
      bboxImgs = [
      ];
      newData = [];
      newDataSRC = NewDataSource(NewData_Data: newData);
      deleteFilesInFolder("./responce");
    }
  }
  // function for delete files in responce folder
  Future<void> deleteFilesInFolder(String folderPath) async {
    final directory = Directory(folderPath);
    if (await directory.exists()) {
      await for (final entity in directory.list()) {
        if (entity is File) {
          await entity.delete();
        }
      }
    }
  }
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg_mmt.jpg"), fit: BoxFit.cover
        )
      ),
      child: 
        Scaffold(
          backgroundColor: const Color.fromARGB(105, 0, 0, 0),
          appBar: AppBar(
            elevation: 0,
            centerTitle: false,
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            backgroundColor: const Color.fromARGB(45, 0, 0, 0),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
              child: IconButton(
                icon: Image.asset('assets/images/loader.png'),
                padding: const EdgeInsets.all(12.0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainDesktop()),
                  );
                },
              ),
            ),
            title: Row(
              children: [
                  TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MainDesktop()),
                    );
                  }, 
                  child: 
                    const Text(
                      "Фото",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        color: Color.fromARGB(255, 128, 128, 128)
                      ),
                    )
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VideoDesktop()),
                    );
                  }, 
                  child: 
                    const Text(
                      "Видео",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        color: Color(0xFF75B6E5),
                      ),
                    )
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 5, 0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Megamen()),
                    );
                  }, 
                  child: 
                    const Text(
                      "Команда",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        color: Color.fromARGB(255, 128, 128, 128)
                      ),
                    )
                ),
              ),
              Padding(
              padding: const EdgeInsets.fromLTRB(6,0,0,0),
                child: IconButton(
                  icon: Image.asset('assets/images/github.png', color: const Color.fromARGB(255, 128, 128, 128), height: 22,),
                        
                  padding: const EdgeInsets.all(12.0),
                  onPressed: () {
                    _repo();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                child:  IconButton(
                  icon: const Icon(
                    Icons.autorenew_outlined,
                    color: Color(0xFF75B6E5),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      // flag = true;
                      // newDataList = [];
                      clearFolders();
                    });
                  },
                ),
              ),
            ],
          ),
          body: 
            Center(
              child: 
              RawScrollbar(
                controller: _horizontal,
                trackVisibility: true,
                thickness: 7,
                thumbColor: const Color(0xFF275F88),
                radius: const Radius.circular(20),
                child: RawScrollbar(
                  controller: _vertical,
                  // thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 7,
                  thumbColor: const Color(0xFF275F88),
                  radius: const Radius.circular(20),
                  notificationPredicate: (notif) => notif.depth == 1,
                  child: SingleChildScrollView(
                    controller: _horizontal,
                    child: SingleChildScrollView( 
                      controller: _vertical,
                      scrollDirection: Axis.horizontal,
                      child: 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ConstrainedBox(constraints: const BoxConstraints(minWidth: 300, maxWidth: 2000),
                            child: 
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          ElevatedButton.icon(
                                            icon: _isLoading
                                                ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Color(0xFF181818), )))
                                                : const Icon(Icons.add, color: Color(0xFF181818), size: 22,),
                                            label: Text(
                                              _isLoading ? 'Загрузка...' : 'Ваше видео',
                                              style: const TextStyle(fontSize: 20, color: Color(0xFF181818)),
                                            ),
                                            onPressed: () => _isLoading ? null : uploadVideo(),
                                              style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.all(14),
                                              backgroundColor: const Color(0xFF75B6E5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    "Для увеличения скорости обработки видео - используйте графические ускорители",
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 235, 232, 232),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 570,
                                  width: MediaQuery.of(context).size.width * 0.95,
                                  margin: const EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 730,
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(33, 85, 86, 87),
                                            border: Border.all(color: const Color(0xFF75B6E5)),
                                            borderRadius: const BorderRadius.all(Radius.circular(7)),
                                          ),
                                          child: Column(
                                            children: [
                                                Flexible(
                                                child: CustomScrollView(
                                                  shrinkWrap: true,
                                                  scrollDirection: Axis.horizontal,
                                                  slivers: <Widget>[
                                                    SliverPadding(
                                                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                                    sliver: SliverList(
                                                      delegate: SliverChildListDelegate(
                                                        <Widget>[
                                                          Padding(
                                                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                                                            child: 
                                                            Column(
                                                              children: [
                                                                const Align(
                                                                    alignment: Alignment.topCenter,
                                                                    child: Padding(
                                                                      padding: EdgeInsets.fromLTRB(20, 0, 0, 20),
                                                                      child: Row(
                                                                        children: [
                                                                        Text(
                                                                        "Video encoding",
                                                                        textAlign: TextAlign.center,
                                                                        overflow: TextOverflow.clip,
                                                                        style: TextStyle(
                                                                          fontWeight: FontWeight.w600,
                                                                          fontStyle: FontStyle.normal,
                                                                          fontSize: 18,
                                                                          color: Color(0xFFF3F2F3),
                                                                        ),
                                                                      ), ],
                                                                      ),
                                                                    ),
                                                                ),  
                                                                SizedBox(
                                                                  width: 700,
                                                                  height: 450,
                                                                  child: 
                                                                  Video(controller: controller),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ),
                  ),
                ),
              )
            ),
        ),
        
    );
  }
}