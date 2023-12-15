// dart
import 'dart:io';
import 'dart:convert';
// base flutter
import 'package:flutter/material.dart';
import 'package:mmt_auto/src/user/mobile/mobile_video.dart';
// external dependencies
// import 'package:path/path.dart';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
// app pages
import 'package:mmt_auto/src/user/mmt.dart';
import 'package:mmt_auto/src/system/data_error.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// datagrid
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';


// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //

final Uri repository = Uri.parse('https://github.com/mireaMegaman/perm_hack');

// ---------------------------------------------------------------------------------------------- //

class MainMobile extends StatefulWidget {
  const MainMobile({super.key});

  @override
  State<MainMobile> createState() => MainMobState();
}

class  MainMobState extends State<MainMobile>{
  bool flag = false;
  late var popup = '';
  bool _isLoading = false;
  late var newDataList = [];
  List<Widget> nameSlots = [];
  DataGridRow? selectedRow;
  DataGridRow? emptyRow;
  int selectedIndex = 0;
  final _imageController = PageController();
  List<String> bboxImgs = [
    // "./assets/images/loader.png",
    // "./assets/images/loader.png",
  ];

  Future<void> _repo() async {
    if (!await launchUrl(repository)) {
      throw Exception('Could not launch $repository');
    }
  }

// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
  // unzip fastapi server responce
  Future<void> unzipFileFromResponse(List<int> responseBody) async {
    final archive = ZipDecoder().decodeBytes(responseBody);
    bboxImgs = [
      // "./assets/images/loader.png",
    ];
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        // print(filename);
        final data = file.content as List<int>;
        if (filename.contains('.jpg') || filename.contains('.jpeg') || filename.contains('.png')) {
          if (Platform.isWindows || Platform.isLinux) {
            File('./responce/$filename')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
            if (filename.contains('bbox_img')) {
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
  Future<void> uploadImage() async {
    setState(() {
      _isLoading = true;
      popup = '';
    });
    final picker = ImagePicker();
    List<XFile>? imageFileList = [];
    List<String>? pathFiles = [];
    final List<XFile> selectedImages = await picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
        imageFileList.addAll(selectedImages);
    }
    for (var i = 0; i < imageFileList.length; i++) {
      if (Platform.isWindows) {
        pathFiles.add(imageFileList[i].path.split("\\").last);
      }
      if (Platform.isLinux) {
        pathFiles.add(imageFileList[i].path.split("/").last);
      }
    }
    List<String>? base64list = [];
    for (var i = 0; i < imageFileList.length; i++) {
      final imageBytes1 = await imageFileList[i].readAsBytes();
      final base64Image1 = base64.encode(imageBytes1);
      base64list.add(base64Image1);
    }
    final json = {'files_names': pathFiles,'files': base64list};
    final response = await http.post(
        Uri.parse('http://127.0.0.1:80/photo'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode(json),
    );
    if (response.statusCode == 200) {
      unzipFileFromResponse(response.bodyBytes);
      String path = '';
      if (Platform.isWindows || Platform.isLinux) {
        path = "./responce/data.txt";
      }
      if (Platform.isAndroid) { 
        path = "/storage/emulated/0/Android/data/com.example.mmt_fl/files/downloads/data.txt";
      }
      File dataFile = File(path);
      String dataString = dataFile.readAsStringSync();
      final responceMap = jsonDecode(dataString);
      List<dynamic> dataMap = jsonDecode(jsonEncode(responceMap["data"]));
      List<List> dataList = dataMap
            .map((element) => [element['id'], element['image_path'], element['autotype'], 
                                element['pollution'], element['count']]).toList();
      // 
      setState(() {
        flag = true;
        _isLoading = false;
        newDataList = dataMap; 
        newData = [];
        popup = 'файл-короткое-длинное-вооруженные\n';
        for (var i = 0; i < dataList.length; i++) {
          newData.add(NewData(dataList[i][0].toString(), dataList[i][1].toString(), 
                              dataList[i][2].toString(), dataList[i][3].toString(), dataList[i][4].toString()));
          popup += '${dataList[i][0]}             ${dataList[i][1]}              ${dataList[i][2]}                 ${dataList[i][3]}';
          popup += '\n';
        }
        popup += '\n';
        popup += jsonEncode(responceMap["data"]);
        newDataSRC = NewDataSource(NewData_Data: newData);
      });
    } else {
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
    if (Platform.isWindows || Platform.isLinux) {
      bboxImgs = [
        // "./assets/images/loader.png",
      ];
      selectedIndex = 0;
      selectedRow = emptyRow;
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
  // init State for page
  @override
  void initState() {
    super.initState();
    newData;
    newDataSRC = NewDataSource(NewData_Data: newData);
    getNewDataData();
  }
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
  // error popup for prediction
  void _showAlertPredict(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          title: const Text("Ошибка!", 
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  fontSize: 16,
                  color: Color(0xFFF3F2F3),
                )
              ),
          backgroundColor: const Color(0xFF224429),
          content: const Text("Файл предсказания модели не существует!", 
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              color: Color(0xFFF3F2F3),
                            )
                          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK", 
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            color: Color(0xFFF3F2F3),
                        )
                      ),
            ),
          ],
        );
      },
    );
  }
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
  // popup for prediction
  void _showPredict(BuildContext context, String fileContext) {
    if (fileContext != '') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            title: const Text("Содержание предикта модели", 
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    fontSize: 16,
                    color: Color(0xFFF3F2F3),
                  )
                ),
            backgroundColor: const Color(0xFF224429),
            content: Text(fileContext, 
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                fontSize: 16,
                                color: Color(0xFFF3F2F3),
                              )
                            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK", 
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              color: Color(0xFFF3F2F3),
                          )
                        ),
              ),
            ],
          );
        },
      );
    }
    else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            title: const Text("Ошибка!", 
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    fontSize: 16,
                    color: Color(0xFFF3F2F3),
                  )
                ),
            backgroundColor: const Color(0xFF224429),
            content: const Text("Файл предсказания пуст!", 
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.normal,
                                fontSize: 16,
                                color: Color(0xFFF3F2F3),
                              )
                            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK", 
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              color: Color(0xFFF3F2F3),
                          )
                        ),
              ),
            ],
          );
        },
      );
    }
  }

// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
  // page design
  final ScrollController _vertical = ScrollController(), _horizontal = ScrollController();
  final DataGridController _dataDridCont = DataGridController();


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
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
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
                    color: Color(0xFF62CA76),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      flag = true;
                      newDataList = [];
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ConstrainedBox(constraints: const BoxConstraints(minWidth: 300, maxWidth: 630, minHeight: 620),
                            child: 
                            Column(
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
                                              _isLoading ? 'Загрузка...' : 'Ваше фото',
                                              style: const TextStyle(fontSize: 20, color: Color(0xFF181818)),
                                            ),
                                            onPressed: () => _isLoading ? null : uploadImage(),
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
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        const Padding(
                                          padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
                                          child: Text('Таблица предсказаний',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 18,
                                              color: Color(0xFFF3F2F3),
                                              ) 
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Flexible(
                                              child: ConstrainedBox(
                                                constraints: const BoxConstraints(minWidth: 220, maxWidth: 570, maxHeight: 350),
                                                child: SfDataGridTheme(
                                                  data: SfDataGridThemeData(
                                                    headerColor: const Color.fromARGB(255, 14, 28, 17),
                                                    headerHoverColor: const Color(0xFF224429),
                                                    gridLineColor: const Color(0xFF62CA76), 
                                                    selectionColor: const Color.fromARGB(30, 34, 68, 41),
                                                    rowHoverColor: const Color.fromARGB(125, 34, 68, 41),
                                                    
                                                    ),
                                                  child: SfDataGrid(
                                                      source: newDataSRC,
                                                      showCheckboxColumn: true,
                                                      checkboxColumnSettings:  
                                                        const DataGridCheckboxColumnSettings(
                                                          showCheckboxOnHeader: false, 
                                                          backgroundColor: Color.fromARGB(55, 14, 28, 17),
                                                          width: 35,
                                                        ),
                                                      allowSorting: true,
                                                      allowTriStateSorting: true,
                                                      showColumnHeaderIconOnHover: true,
                                                      columnWidthMode: ColumnWidthMode.lastColumnFill,
                                                      onQueryRowHeight: (details) {
                                                        return details.getIntrinsicRowHeight(details.rowIndex) + 8;
                                                      },
                                                      columns: <GridColumn>[
                                                        GridColumn(
                                                            columnName: 'id',
                                                            label: Container(
                                                                padding: const EdgeInsets.all(8.0),
                                                                alignment: Alignment.center,
                                                                child: const Text(
                                                                  'ID', 
                                                                  style: TextStyle(
                                                                        fontWeight: FontWeight.w600,
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 14,
                                                                        color: Color(0xFFF3F2F3),
                                                                      ),
                                                                )
                                                            )
                                                        ),
                                                        GridColumn(
                                                            columnName: 'file',
                                                            label: Container(
                                                                padding: const EdgeInsets.all(8.0),
                                                                alignment: Alignment.center,
                                                                child: const Text(
                                                                  'Файл',
                                                                  style: TextStyle(
                                                                        fontWeight: FontWeight.w600,
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 14,
                                                                        color: Color(0xFFF3F2F3),
                                                                      ),
                                                                )
                                                            )
                                                        ),
                                                        GridColumn(
                                                            columnName: 'autotype',
                                                            label: Container(
                                                                padding: const EdgeInsets.all(8.0),
                                                                alignment: Alignment.center,
                                                                child: const Text(
                                                                  'Тип ТС',
                                                                  style: TextStyle(
                                                                        fontWeight: FontWeight.w600,
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 14,
                                                                        color: Color(0xFFF3F2F3),
                                                                      ),
                                                                )
                                                            )
                                                        ),
                                                        GridColumn(
                                                            columnName: 'polution',
                                                            label: Container(
                                                                padding: const EdgeInsets.all(8.0),
                                                                alignment: Alignment.center,
                                                                child: const Text(
                                                                  'Уровень загрязнения',
                                                                  style: TextStyle(
                                                                        fontWeight: FontWeight.w600,
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 14,
                                                                        color: Color(0xFFF3F2F3),
                                                                      ),
                                                                )
                                                            )
                                                        ),
                                                        GridColumn(
                                                            columnName: 'count',
                                                            label: Container(
                                                                padding: const EdgeInsets.all(8.0),
                                                                alignment: Alignment.center,
                                                                child: const Text(
                                                                  'Количество авто',
                                                                  style: TextStyle(
                                                                        fontWeight: FontWeight.w600,
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 14,
                                                                        color: Color(0xFFF3F2F3),
                                                                      ),
                                                                )
                                                            )
                                                        ),
                                                      ],
                                                      footer: Container(
                                                      color: const Color.fromARGB(255, 14, 28, 17),
                                                      child: const Center(
                                                          child: 
                                                          Padding(
                                                            padding: EdgeInsets.all(5),
                                                      
                                                            child: Text("test", style: TextStyle(color: const Color.fromARGB(255, 14, 28, 17),),),
                                                          ),
                                                        )),
                                                        gridLinesVisibility: GridLinesVisibility.both,
                                                        navigationMode: GridNavigationMode.row,
                                                        controller: _dataDridCont,
                                                        selectionMode: SelectionMode.single,
                                                    ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: MaterialButton(
                                          onPressed: () {
                                            selectedRow = _dataDridCont.selectedRow;
                                            selectedIndex = _dataDridCont.selectedIndex + 1;
                                            setState(() {
                                              
                                            });
                                            print(selectedRow);
                                            print(selectedIndex);
                                            print(selectedRow?.getCells()[2].value);
                                          },
                                          color: const Color(0xFF62CA76),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                            
                                          ),
                                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          textColor: const Color(0xFF181818),
                                          height: 50,
                                          minWidth: 120,
                                          child: const Text(
                                            "Показать",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
                          ConstrainedBox(constraints: const BoxConstraints(minWidth: 300, maxWidth: 700),
                            child: 
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 470,
                                  width: 650,
                                  
                                  margin: const EdgeInsets.all(20.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF62CA76)),
                                    color: const Color.fromARGB(33, 85, 86, 87),
                                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 360,
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
                                                            width:360,
                                                            height: 980,
                                                            child: Stack(
                                                              children: [                           
                                                                PageView.builder(
                                                                  controller: _imageController,
                                                                  scrollDirection: Axis.horizontal,
                                                                  itemCount: 1,
                                                                  itemBuilder: (context, index) {
                                                                    return const Align(
                                                                      alignment: Alignment.center,
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                            vertical: 40, horizontal: 0),
                                                                        child: ClipRRect(
                                                                          child:
                                                                              Column(
                                                                                // height: 600,
                                                                                children: [
                                                                                  // Image.file(File(bboxImgs[selectedIndex]),
                                                                                  //           height: 245,
                                                                                  //           width: MediaQuery.of(context).size.width * 1,
                                                                                  //           fit: BoxFit.fitHeight,
                                                                                  // ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
                                                                                    child: Text('no image detected', 
                                                                                    style: 
                                                                                      const TextStyle(
                                                                                        fontWeight: FontWeight.w400,
                                                                                        fontStyle: FontStyle.normal,
                                                                                        fontSize: 16,
                                                                                        color: Color(0xFFF3F2F3),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                                const Align(
                                                                  alignment: Alignment.topCenter,
                                                                  child: Padding(
                                                                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                                                    child: Row(
                                                                      children: [
                                                                      Text(
                                                                      "Yolo BBOX",
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
                                      Container(
                                        height: 470,
                                        width: 250,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            left: BorderSide(color: Color(0xFF62CA76)),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: 
                                            <Widget> [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                child: Text('Файл: ${selectedRow?.getCells()[1].value.toString() ?? ''}', style: const TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Ubuntu',
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                    color: Color.fromARGB(255, 197, 194, 194)
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                child: Text('Тип ТС: ${selectedRow?.getCells()[2].value.toString() ?? ''}', style: const TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Ubuntu',
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                    color: Color.fromARGB(255, 197, 194, 194)
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                child: Text('Уровень CO2: ${selectedRow?.getCells()[3].value.toString() ?? ''}', style: const TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Ubuntu',
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                    color: Color.fromARGB(255, 197, 194, 194)
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                child: Text('Количество авто: ${selectedRow?.getCells()[4].value.toString() ?? ''}', style: const TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Ubuntu',
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                    color: Color.fromARGB(255, 197, 194, 194)
                                                  ),
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.fromLTRB(0, 70, 0, 5),
                                                child: Text('Отметьте ниже - верно ли предсказание:', style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Ubuntu',
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle: FontStyle.normal,
                                                    color: Color.fromARGB(255, 197, 194, 194)
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                                                    child:  IconButton(
                                                      icon: const Icon(
                                                        Icons.add_circle_outlined,
                                                        color: Color(0xFF62CA76),
                                                        size: 30,
                                                      ),
                                                      onPressed: () {
                                                        
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                                                    child:  IconButton(
                                                      icon: const Icon(
                                                        Icons.remove_circle_outlined,
                                                        color: Color(0xFF62CA76),
                                                        size: 30,
                                                      ),
                                                      onPressed: () {
                                                        
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.all(10),
                                  padding: const EdgeInsets.all(0),
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Color(0x00000000),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: 
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          if (Platform.isWindows) {
                                            try {
                                              File file = File('./responce/data.txt');
                                              if (file.existsSync()) {
                                                  _showPredict(context, popup);
                                                  OpenFile.open(file.path);
                                              }
                                              else {
                                                _showAlertPredict(context);
                                              }
                                            }
                                            catch (e) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => const DataNotFound()),
                                              );
                                            }
                                          }
                                        },
                                        color: const Color(0xFF62CA76),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                          
                                        ),
                                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        textColor: const Color(0xFF181818),
                                        height: 60,
                                        minWidth: 180,
                                        child: const Text(
                                          "Открыть predict",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
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
                ),
              )
            ),
        ),
        
    );
  }
}

// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
// table data class
class NewData {
  NewData(this.id, this.file, this.autotype, this.polution, this.count);
  final String id;
  final String file;
  final String count;
  final String autotype;
  final String polution;
}


List<NewData> newData = <NewData>[];
late NewDataSource newDataSRC;
List<NewData> getNewDataData() {
      return [
        NewData('10001', 'James', 'Project Leeeeead', '20000', '34567'),
        NewData('10002', 'Kathryn', 'Manager', '30000', '45678'),
        NewData('10003', 'Lara', 'Developer', '15000', '34567'),
      ];
    }


class NewDataSource extends DataGridSource {
  NewDataSource({required List<NewData> NewData_Data}) {
    _NewData_Data = NewData_Data
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'id', value: e.id),
              DataGridCell<String>(columnName: 'file', value: e.file),
              DataGridCell<String>(columnName: 'autotype', value: e.autotype),
              DataGridCell<String>(columnName: 'polution', value: e.polution),
              DataGridCell<String>(columnName: 'count', value: e.count),
            ]))
        .toList();
  }
  List<DataGridRow> _NewData_Data = [];
  @override
  List<DataGridRow> get rows => _NewData_Data;
  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      TextStyle? getTextStyle() {
        if (e.columnName == 'id') {
          return const TextStyle(color: Color.fromARGB(255, 255, 64, 64));
        } else {
          return const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                  fontSize: 15,
                  color: Color(0xFFF3F2F3),
                );
        }
      }
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(
          e.value.toString(), 
          style: getTextStyle(),
          ),
      );
    }).toList());
  }
}


// const Color(0xFF62CA76)
// const Color(0xFF181818)
// Color(0xFF224429)