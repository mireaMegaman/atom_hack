// dart
import 'dart:io';
import 'dart:convert';
// base flutter
import 'package:flutter/material.dart';
import 'package:mmt_auto/src/user/mobile/mobile_image.dart';
// external dependencies
import 'package:path/path.dart';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// app pages
import 'package:mmt_auto/src/user/mmt.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //


// ---------------------------------------------------------------------------------------------- //

class VideoMobile extends StatefulWidget {
  const VideoMobile({super.key});
  
  @override
  State<VideoMobile> createState() => VideoMobState();

}

// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //

class  VideoMobState extends State<VideoMobile>{
  final ScrollController _vertical = ScrollController(), _horizontal = ScrollController();
  bool flag = false;
  late var popup = '';
  bool _isLoading = false;
  late var newDataList = [];
  List<Widget> nameSlots = [];
  final _imageController = PageController();
  List<String> bboxImgs = [
    "./assets/images/loader.png",
    "./assets/images/loader.png",
  ];

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
            File('responce/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
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
      // newData = [];
      // newDataSRC = NewDataSource(NewData_Data: newData);
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
            title: Row(
              children: [
                  TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MainMobile()),
                    );
                  }, 
                  child: 
                    const Text(
                      "Фото",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        color: Color(0xFF62CA76),
                        // #75C732
                      ),
                    )
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VideoMobile()),
                    );
                  }, 
                  child: 
                    const Text(
                      "Видео",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        color: Color.fromARGB(255, 128, 128, 128)
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
                      "MMT",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        color: Color.fromARGB(255, 128, 128, 128)
                      ),
                    )
                ),
              ),
              // Padding(
              // padding: const EdgeInsets.fromLTRB(6,0,0,0),
              //   child: IconButton(
              //     icon: Image.asset('assets/images/github.png', color: const Color.fromARGB(255, 128, 128, 128), height: 22,),
                        
              //     padding: const EdgeInsets.all(12.0),
              //     onPressed: () {
              //       _repo();
              //     },
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                child:  IconButton(
                  icon: const Icon(
                    Icons.autorenew_outlined,
                    color: Color.fromARGB(255, 117, 199, 50),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      // flag = true;
                      // newDataList = [];
                      // clearFolders();
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
                thumbColor: const Color.fromARGB(47, 39, 176, 67),
                radius: const Radius.circular(20),
                child: RawScrollbar(
                  controller: _vertical,
                  // thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 7,
                  thumbColor: const Color.fromARGB(47, 39, 176, 67),
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
                                              backgroundColor: const Color(0xFF62CA76),
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
                                  height: 470,
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
                                            border: Border.all(color: const Color(0xFF62CA76)),
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
                                                            SizedBox(
                                                              width:730,
                                                              height: 700,
                                                              child: Stack(
                                                                children: [                           
                                                                  PageView.builder(
                                                                    controller: _imageController ,
                                                                    scrollDirection: Axis.horizontal,
                                                                    itemCount: bboxImgs.length,
                                                                    itemBuilder: (context, index) {
                                                                      return Align(
                                                                        alignment: Alignment.topCenter,
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                              vertical: 39, horizontal: 0),
                                                                          child: ClipRRect(
                                                                            borderRadius: BorderRadius.circular(5.0),
                                                                            child:
                                                                                Column(
                                                                                  children: [
                                                                                    Image.file(File(bboxImgs[index]),
                                                                                              height: 250,
                                                                                              width: MediaQuery.of(context).size.width * 1.15,
                                                                                              fit: BoxFit.contain,
                                                                                    ),
                                                                                    Text(basename(bboxImgs[index].toString()), 
                                                                                    style: const TextStyle(
                                                                                      fontWeight: FontWeight.w400,
                                                                                      fontStyle: FontStyle.normal,
                                                                                      fontSize: 18,
                                                                                      color: Color(0xFFF3F2F3),
                                                                                    ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                  Align(
                                                                    alignment: Alignment.bottomCenter,
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                      child: SmoothPageIndicator(
                                                                        controller: _imageController ,
                                                                        count: bboxImgs.length,
                                                                        axisDirection: Axis.horizontal,
                                                                        effect: const ExpandingDotsEffect(
                                                                          dotColor: Color(0xFF224429),
                                                                          activeDotColor: Color(0xFF62CA76),
                                                                          dotHeight: 10,
                                                                          dotWidth: 10,
                                                                          radius: 16,
                                                                          spacing: 7,
                                                                          expansionFactor: 2,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const Align(
                                                                    alignment: Alignment.topCenter,
                                                                    child: Padding(
                                                                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                                                      child: Row(
                                                                        children: [
                                                                        Text(
                                                                        "Video encoding",
                                                                        textAlign: TextAlign.center,
                                                                        overflow: TextOverflow.clip,
                                                                        style: TextStyle(
                                                                          fontWeight: FontWeight.w600,
                                                                          fontStyle: FontStyle.normal,
                                                                          fontSize: 14,
                                                                          color: Color(0xFFF3F2F3),
                                                                        ),
                                                                      ), ],
                                                                      ),
                                                                    ),
                                                                  ),  
                                                                ],
                                                              ),
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
                                // Container(
                                //   alignment: Alignment.center,
                                //   margin: const EdgeInsets.all(10),
                                //   padding: const EdgeInsets.all(0),
                                //   width: MediaQuery.of(context).size.width,
                                //   height: 60,
                                //   decoration: const BoxDecoration(
                                //     color: Color(0x00000000),
                                //     shape: BoxShape.rectangle,
                                //     borderRadius: BorderRadius.zero,
                                //   ),
                                //   child: 
                                //     Padding(
                                //       padding: const EdgeInsets.all(10),
                                //       child: MaterialButton(
                                //         onPressed: () async {
                                //           if (Platform.isWindows) {
                                //             try {
                                //               File file = File('./responce/data.txt');
                                //               if (file.existsSync()) {
                                //                   // _showPredict(context, popup);
                                //                   OpenFile.open(file.path);
                                //               }
                                //               else {
                                //                 // _showAlertPredict(context);
                                //               }
                                //             }
                                //             catch (e) {
                                //               Navigator.push(
                                //                 context,
                                //                 MaterialPageRoute(builder: (context) => const DataNotFound()),
                                //               );
                                //             }
                                //           }
                                //         },
                                //         color: const Color(0xFF62CA76),
                                //         elevation: 0,
                                //         shape: RoundedRectangleBorder(
                                //           borderRadius: BorderRadius.circular(20.0),
                                          
                                //         ),
                                //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                //         textColor: const Color(0xFF181818),
                                //         height: 60,
                                //         minWidth: 180,
                                //         child: const Text(
                                //           "Открыть predict",
                                //           style: TextStyle(
                                //             fontSize: 18,
                                //             fontWeight: FontWeight.w600,
                                //             fontStyle: FontStyle.normal,
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                // ),
                              ],
                            ),
                          ),
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
                          // Padding(
                          //   padding: const EdgeInsets.fromLTRB(10,0,20,0),
                          //   child: Container(
                          //         margin: const EdgeInsets.all(10.0),
                          //         constraints: BoxConstraints(minHeight: 400, maxHeight: MediaQuery.of(context).size.height * 0.85),
                          //         decoration: BoxDecoration(
                          //           border: Border.all(color: const Color(0xFF62CA76)),
                          //           borderRadius: const BorderRadius.all(Radius.circular(3)),
                          //         ),
                          //     )
                          // ),
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
                          // ConstrainedBox(constraints: const BoxConstraints(minWidth: 300, maxWidth: 580),
                          //   child: 
                          //   Column(
                          //     children: [
                          //       Padding(
                          //         padding: const EdgeInsets.all(20),
                          //         child: Column(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           crossAxisAlignment: CrossAxisAlignment.center,
                          //           mainAxisSize: MainAxisSize.min,
                          //           children: [
                          //               const Padding(
                          //                 padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
                          //                 child: Text('Таблица предсказаний',
                          //                   textAlign: TextAlign.center,
                          //                   overflow: TextOverflow.clip,
                          //                   style: TextStyle(
                          //                     fontWeight: FontWeight.w600,
                          //                     fontStyle: FontStyle.normal,
                          //                     fontSize: 18,
                          //                     color: Color(0xFFF3F2F3),
                          //                     ) 
                          //                 ),
                          //               ),
                          //               Row(
                          //                 mainAxisAlignment: MainAxisAlignment.center,
                          //                 crossAxisAlignment: CrossAxisAlignment.center,
                          //                 mainAxisSize: MainAxisSize.max,
                          //                 children: [
                          //                   Flexible(
                          //                     child: ConstrainedBox(
                          //                       constraints: const BoxConstraints(minWidth: 220, maxWidth: 500, maxHeight: 250),
                          //                       child: SfDataGridTheme(
                          //                         data: SfDataGridThemeData(
                          //                           headerColor: const Color(0xFF224429),
                          //                           headerHoverColor: const Color(0xFF62CA76),
                          //                           gridLineColor: const Color(0xFF62CA76), 
                          //                           // gridLineStrokeWidth: 2.0,
                          //                           rowHoverColor: const Color(0xFF224429),
                          //                           ),
                          //                         child: SfDataGrid(
                          //                             source: newDataSRC,
                          //                             showCheckboxColumn: true,
                          //                             checkboxColumnSettings:  const DataGridCheckboxColumnSettings(showCheckboxOnHeader: false),
                          //                             allowSorting: true,
                          //                             allowMultiColumnSorting: true,
                          //                             allowTriStateSorting: true,
                          //                             showColumnHeaderIconOnHover: true,
                          //                             columnWidthMode: ColumnWidthMode.lastColumnFill,
                          //                             onQueryRowHeight: (details) {
                          //                               return details.getIntrinsicRowHeight(details.rowIndex) + 8;
                          //                             },
                          //                             columns: <GridColumn>[
                          //                               GridColumn(
                          //                                   columnName: 'id',
                          //                                   label: Container(
                          //                                       padding: const EdgeInsets.all(8.0),
                          //                                       alignment: Alignment.center,
                          //                                       child: const Text(
                          //                                         'ID', 
                          //                                         style: TextStyle(
                          //                                               fontWeight: FontWeight.w600,
                          //                                               fontStyle: FontStyle.normal,
                          //                                               fontSize: 14,
                          //                                               color: Color(0xFFF3F2F3),
                          //                                             ),
                          //                                       )
                          //                                   )
                          //                               ),
                          //                               GridColumn(
                          //                                   columnName: 'autotype',
                          //                                   label: Container(
                          //                                       padding: const EdgeInsets.all(8.0),
                          //                                       alignment: Alignment.center,
                          //                                       child: const Text(
                          //                                         'Тип ТС',
                          //                                         style: TextStyle(
                          //                                               fontWeight: FontWeight.w600,
                          //                                               fontStyle: FontStyle.normal,
                          //                                               fontSize: 14,
                          //                                               color: Color(0xFFF3F2F3),
                          //                                             ),
                          //                                       )
                          //                                   )
                          //                               ),
                          //                               GridColumn(
                          //                                   columnName: 'polution',
                          //                                   label: Container(
                          //                                       padding: const EdgeInsets.all(8.0),
                          //                                       alignment: Alignment.center,
                          //                                       child: const Text(
                          //                                         'Уровень загрязнения',
                          //                                         style: TextStyle(
                          //                                               fontWeight: FontWeight.w600,
                          //                                               fontStyle: FontStyle.normal,
                          //                                               fontSize: 14,
                          //                                               color: Color(0xFFF3F2F3),
                          //                                             ),
                          //                                       )
                          //                                   )
                          //                               ),
                          //                               GridColumn(
                          //                                   columnName: 'count',
                          //                                   label: Container(
                          //                                       padding: const EdgeInsets.all(8.0),
                          //                                       alignment: Alignment.center,
                          //                                       child: const Text(
                          //                                         'Количество авто',
                          //                                         style: TextStyle(
                          //                                               fontWeight: FontWeight.w600,
                          //                                               fontStyle: FontStyle.normal,
                          //                                               fontSize: 14,
                          //                                               color: Color(0xFFF3F2F3),
                          //                                             ),
                          //                                       )
                          //                                   )
                          //                               ),
                          //                             ],
                          //                             footer: Container(
                          //                             color: const Color(0xFF224429),
                          //                             child: const Center(
                          //                                 child: 
                          //                                 Padding(
                          //                                   padding: EdgeInsets.all(5),
                                                      
                          //                                   child: Text("test", style: TextStyle(color: Color(0xFF224429),),),
                          //                                 ),
                          //                               )),
                          //                               gridLinesVisibility: GridLinesVisibility.both,
                          //                               navigationMode: GridNavigationMode.row,
                          //                               selectionMode: SelectionMode.multiple,
                          //                           ),
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 ],
                          //               ),
                          //           ],
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          
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