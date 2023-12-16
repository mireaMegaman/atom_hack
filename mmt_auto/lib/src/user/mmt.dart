import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mmt_auto/src/user/desktop/desk_image.dart';

final Uri gun = Uri.parse('https://github.com/mireaMegaman/perm_hack');
final Uri train = Uri.parse('https://github.com/mireaMegaman/sochi_hack');
final Uri ocr = Uri.parse('https://github.com/mireaMegaman/nn_hackaton');

final Uri atom_yolo = Uri.parse('https://github.com/mireaMegaman/atom_hack');
final Uri atom_flutter = Uri.parse('https://github.com/mireaMegaman/atom_hack');
final Uri atom_fastapi = Uri.parse('https://github.com/mireaMegaman/atom_hack');

  Future<void> _gun() async {
    if (!await launchUrl(gun)) {
      throw Exception('Could not launch $gun');
    }
  }

  Future<void> _train() async {
    if (!await launchUrl(train)) {
      throw Exception('Could not launch $train');
    }
  }

  Future<void> _ocr() async {
    if (!await launchUrl(ocr)) {
      throw Exception('Could not launch $ocr');
    }
  }

    Future<void> _atom_yolo() async {
    if (!await launchUrl(atom_yolo)) {
      throw Exception('Could not launch $atom_yolo');
    }
  }

  Future<void> _atom_flutter() async {
    if (!await launchUrl(atom_flutter)) {
      throw Exception('Could not launch $atom_flutter');
    }
  }

  Future<void> _atom_fastapi() async {
    if (!await launchUrl(atom_fastapi)) {
      throw Exception('Could not launch $atom_fastapi');
    }
  }


// ignore: must_be_immutable
class Megamen extends StatelessWidget {

  static double getGlobalWidth() {
    if (Platform.isAndroid || Platform.isIOS) {
      return 0.9;
    } else if (Platform.isWindows || Platform.isLinux) {
      return 0.5;
    } else {
      return 1.0;
    }
  }

  static double scw = getGlobalWidth();

  const Megamen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg_mmt.jpg"), fit: BoxFit.cover
        )
      ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(15, 0, 0, 0),
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          backgroundColor: const Color.fromARGB(45, 0, 0, 0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF75B6E5),
              size: 20,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainDesktop()),
              );
            },
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 300),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 5),
                    child: Text(
                      "Команда megamen представляет MMT-WW",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        fontSize: 22,
                        color: Color(0xffffffff),
                      ),
                    ),
                  ),
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(15, 20, 15, 15),
                                child: Text(
                                  "MMT - решения и продукты",
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 22,
                                    color: Color(0xFF75B6E5),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * scw,
                                height: 175,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(200, 24, 24, 24),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                      color: const Color(0xFF275F88), width: 2),
                                ),
                                child: ListView(
                                children: <Widget>[
                                  ListTile(
                                    leading: IconButton(
                                          iconSize: 35,
                                          icon: const Icon(Icons.camera_enhance),
                                          color: const Color(0xFF75B6E5),
                                          onPressed: () {
                                            _gun();
                                            // 
                                          },
                                        ),
                                    title: const Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            "MMT-GUNS — приложение для распознавания вооруженных людей;",
                                            textAlign: TextAlign.left,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 18,
                                              color: Color(0xffffffff),
                                            ),
                                          ),
                                        ),
                                  ),
                                  ListTile(
                                    leading: IconButton(
                                            iconSize: 35,
                                            // ads_click_sharp
                                            icon: const Icon(Icons.directions_transit_filled_rounded),
                                            color: const Color(0xFF75B6E5),
                                            onPressed: () {
                                              _train();
                                            },
                                          ),
                                    title: const Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            "MMT-VAGON — приложение для распознавания номеров вагонов;",
                                            textAlign: TextAlign.left,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 18,
                                              color: Color(0xffffffff),
                                            ),
                                          ),
                                        ),
                                  ),
                                  ListTile(
                                    leading: IconButton(
                                              iconSize: 35,
                                              icon: const Icon(Icons.auto_stories_rounded),
                                              color: const Color(0xFF75B6E5),
                                              onPressed: () {
                                                _ocr();
                                              },
                                            ),
                                    title: const Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            "MMT-CR — модель для определения корректного рейтинга компании по пресс-релизу;",
                                            textAlign: TextAlign.left,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 18,
                                              color: Color(0xffffffff),
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
                      ),
                    ],
                  ),
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(15, 20, 15, 15),
                                child: Text(
                                  "Коротко об этом решении",
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 22,
                                    color: Color(0xFF75B6E5),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * scw,
                                height: 175,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(200, 24, 24, 24),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                      color: const Color(0xFF275F88), width: 2),
                                ),
                                child: ListView(
                                children: <Widget>[
                                  ListTile(
                                    leading: IconButton(
                                            iconSize: 35,
                                            icon: const Icon(Icons.ads_click_sharp),
                                            color: const Color(0xFF75B6E5),
                                            onPressed: () {
                                              _train();
                                            },
                                          ),
                                    title: const Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            "Для распознавания был использован ансамбль моделей YOLOv8 и RT-DETR;",
                                            textAlign: TextAlign.left,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 18,
                                              color: Color(0xffffffff),
                                            ),
                                          ),
                                        ),
                                  ),
                                  ListTile(
                                    leading: IconButton(
                                            iconSize: 35,
                                            icon: const Icon(Icons.ads_click_sharp),
                                            color: const Color(0xFF75B6E5),
                                            onPressed: () {
                                              _train();
                                            },
                                          ),
                                    title: const Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            "Для создания мультиплатформенного приложения был выбран Flutter;",
                                            textAlign: TextAlign.left,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 18,
                                              color: Color(0xffffffff),
                                            ),
                                          ),
                                        ),
                                  ),
                                  ListTile(
                                    leading: IconButton(
                                            iconSize: 35,
                                            icon: const Icon(Icons.ads_click_sharp),
                                            color: const Color(0xFF75B6E5),
                                            onPressed: () {
                                              _train();
                                            },
                                          ),
                                    title: const  Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            "BackEnd часть проекта построена на FastAPI;",
                                            textAlign: TextAlign.left,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 18,
                                              color: Color(0xffffffff),
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
                      ),
                    ],
                  ),
// ---------------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------- //
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                          child: Text(
                            "Наша команда",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontSize: 22,
                              color: Color(0xFF75B6E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width * scw,
                    height: 280,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(188, 24, 24, 24),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: const Color(0xFF275F88), width: 2),
                    ),
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.all(7),
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      children: const [
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Image(
                                    image: AssetImage("assets/images/mmt_PoletaevVA.png"), 
                                    height: 130,
                                    width: 130,
                                    fit: BoxFit.contain,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(30, 10, 0, 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(3),
                                          child: Text(
                                            "Poletaev Vladislav",
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 18,
                                              color: Color(0xffffffff),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(3),
                                          child: Text(
                                            "ML ENGINEER",
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 18,
                                              color: Color(0xFF75B6E5),
                                            ),
                                          ),
                                        ),
                                        
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(100, 0, 100, 0),
                          child: Divider(
                            height: 2,
                            thickness: 2,
                            indent: 20,
                            endIndent: 0,
                            color: Color(0xFFF3F2F3),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  
                                  Image(
                                    image: AssetImage("assets/images/mmt_ChufistovGA.png"),
                                    height: 130,
                                    width: 130,
                                    fit: BoxFit.contain,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(30, 10, 0, 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(3),
                                          child: Text(
                                            "Chufistov George",
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 18,
                                              color: Color(0xffffffff),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "DEPLOYMENT",
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 18,
                                            color: Color(0xFF75B6E5),
                                          ),
                                        ),
                                        Text(
                                          "ENGINEER",
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 18,
                                            color: Color(0xFF75B6E5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(100, 0, 100, 0),
                          child: Divider(
                            height: 2,
                            thickness: 2,
                            indent: 20,
                            endIndent: 0,
                            color: Color(0xFFF3F2F3),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  
                                  Image(
                                    image: AssetImage("assets/images/mmt_KalininAS.png"),
                                    height: 130,
                                    width: 130,
                                    fit: BoxFit.contain,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(30, 10, 0, 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(3),
                                          child: Text(
                                            "Kalinin Aleksandr",
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 18,
                                              color: Color(0xffffffff),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "BACKEND",
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 18,
                                            color: Color(0xFF75B6E5),
                                          ),
                                        ),
                                        Text(
                                          "DEVELOPER",
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 18,
                                            color: Color(0xFF75B6E5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(100, 0, 100, 0),
                          child: Divider(
                            height: 2,
                            thickness: 2,
                            indent: 20,
                            endIndent: 0,
                            color: Color(0xFFF3F2F3),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  
                                  Image(
                                    image: AssetImage("assets/images/mmt_LunyakovAA.png"),
                                    height: 130,
                                    width: 130,
                                    fit: BoxFit.contain,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(32, 10, 0, 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          "Alexey Lunyakov",
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.normal,
                                            fontSize: 18,
                                            color: Color(0xffffffff),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(3),
                                          child: Text(
                                            "DESIGNER",
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.clip,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.normal,
                                              fontSize: 18,
                                              color: Color(0xFF75B6E5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Color(0xff000000),
                    height: 18,
                    thickness: 5,
                    indent: 0,
                    endIndent: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
