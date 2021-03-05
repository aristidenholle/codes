import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:marquee/marquee.dart';
import 'package:gzapp/pages/client/validatepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ordertrack.dart';


class ClientHomePage extends StatefulWidget {
  final city, commune, quarter, phoneNumber, userName,secondNumber;

  const ClientHomePage({Key key, this.city, this.commune, this.quarter, this.phoneNumber, this.userName, this.secondNumber}) : super(key: key);
  @override
  _ClientHomePageState createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> with TickerProviderStateMixin{

  //TO AVOID MANY READ IN DB
  String keyToCheckIFValueItSaved = "keyName";
  String gzNumber = "gzsNumber";
  Map<String, List> persistentStore = {};

  Map<String, List> gzsList = {};

  Map<String, List> gzChosen = {};
  Map<String, List> gzsChosen = {};

  List carousel = ["images/imageone.jpg" , "images/imagetwo.png"];

  @override
  void initState() {
    checkIfFirstGzNameSaved();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child:Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text('Service Gz'),
          actions: [
            StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid)
                    .collection("reservation")
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('');
                  } else if (!snapshot.hasData) {
                    return Text('');
                  }else if (snapshot?.data?.docs?.length == 0) {
                    return Text('');
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      onPressed: (){
                        Navigator.push(
                            context, PageTransition(
                            child: OrderTrackPage(),
                            type: PageTransitionType.fadeIn,
                            duration: Duration(milliseconds: 500)
                        ));
                      },
                      tooltip: 'notification',
                      icon: Stack(
                        alignment:Alignment.topRight,
                        children: [
                          Icon(Icons.notifications,size: 37,color: Colors.white),
                          Container(
                            height: 25.0,
                            width: 20.0,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0)
                            ),
                            child: Center(
                                child: Text('${snapshot?.data?.docs?.length}',style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold,fontSize: 17))),
                          )
                        ],
                      ),
                    ),
                  );
                }
            )
          ],
        ),
        drawer: Drawer(),
        body:  Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(
                height: 30,
                child: Center(
                  child: Marquee(
                    text: "un service à votre écoute 24h/24 7j/7",
                    style: TextStyle(color: Colors.black, fontSize: 17.0),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    blankSpace: 5.0,
                    velocity: 100.0,
                    pauseAfterRound: Duration(seconds: 1),
                    startPadding: 1.0,
                    accelerationDuration: Duration(seconds: 2),
                    accelerationCurve: Curves.linear,
                    decelerationDuration: Duration(milliseconds: 900),
                    decelerationCurve: Curves.easeOut,
                  ),
                ),
              ),

              Expanded(
                child: gzsList.isEmpty ?
                Center(
                  child: Text('Chargement en cours...'),
                )
                    :
                SingleChildScrollView(
                  child: Column(
                    children:  buildGzChoice(),
                  ),
                ),
              ),
            ],
          ),
        ),

        //AVEC LA CASE A COCHER buildGzChoice FAIT DE CETTE MANIERE LA MISE A JOUR
        //EST FAITE POUR LA CONDITION QUE JE FAIS POUR AFFICHER OU PAS LE bottomNavigationBar
        bottomNavigationBar:gzChosen.keys.isEmpty ?
        Container(
          height: 45,
          child: Text(''),
        )
            : Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.teal,
          height: 45,
          child: FlatButton(
              onPressed: () {
                print('$gzChosen $gzsList');
                Navigator.push(context, PageTransition(
                    child: ValidateOrderPage(
                      userName: widget.userName,
                      userCommune: widget.commune,
                      userCity: widget.city,
                      userFirstNumber: widget.phoneNumber,
                      userQuarter: widget.quarter,
                      userSecondNumber: widget.secondNumber,
                      gzsChosen: gzsChosen,
                    ),
                    type: PageTransitionType.slideInLeft,
                    duration: Duration(milliseconds: 500)));


                for(int i = 0; i < gzsList.keys.length; i++){
                  if(gzsList[gzsList.keys.toList()[i]][0] == true){
                    setState(() {
                      gzsList[gzsList.keys.toList()[i]][0] = false;
                      gzChosen.clear();
                    });
                  }
                }
              },
              child: Text('Suivant')),
        ),
      )
    );
  }

  List<Widget> buildGzChoice(){
    List<Widget> lgz = [];
  for(var i = 0; i < gzsList.keys.length;  i++){
    Widget g = Card(
      child: Container(
        margin: const EdgeInsets.only(top: 25),
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Container(
              child: Text('${gzsList[gzsList.keys.toList()[i]][2]}'),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text('${gzsList.keys.toList()[i]}'),
                onChanged: (bool value) async{
                  setState((){
                    gzsList[gzsList.keys.toList()[i]][0] = value;
                  });
                  if(gzsList[gzsList.keys.toList()[i]][0] == true) {
                    setState((){
                      gzsChosen.addAll({"${gzsList.keys.toList()[i]}": [gzsList[gzsList.keys.toList()[i]][1],gzsList[gzsList.keys.toList()[i]][2], 1, gzsList[gzsList.keys.toList()[i]][1]]});
                      gzChosen.addAll({"${gzsList.keys.toList()[i]}": [gzsList[gzsList.keys.toList()[i]][1],gzsList[gzsList.keys.toList()[i]][2], 1, gzsList[gzsList.keys.toList()[i]][1]]});
                    });
                  }
                  else if(gzsList[gzsList.keys.toList()[i]][0] == false){
                    setState(() {
                      gzsChosen.remove(gzsList.keys.toList()[i]);
                      gzChosen.remove(gzsList.keys.toList()[i]);
                    });
                  }

                  print('$gzChosen');
                }, value: gzsList[gzsList.keys.toList()[i]][0],

              ),
            )
          ],
        ),
      ),
    );

    lgz.add(g);
  }

  return lgz;
}

//TO AVOID MANY READ IN FIREBASE

  void setData({Map<String, List> gzList}) async{
    SharedPreferences set = await SharedPreferences.getInstance();

    if(gzsList.keys.isNotEmpty){
      set.setString(keyToCheckIFValueItSaved, gzsList.keys.first);
      set.setInt(gzNumber, gzsList.keys.length);
    }

    //({"${gz.data()['gzname']}": [false, gz.data()['gzprice'], gz.data()['gzimage']]});
    for(var i = 0; i < gzsList.keys.length; i++){
      set.setString("keyName$i", gzsList.keys.toList()[i]);
    }
    for(var i = 0; i < gzsList.keys.length; i++){
      set.setBool("keyBool$i", gzsList[gzsList.keys.toList()[i]][0]);
    }
    for(var i = 0; i < gzsList.keys.length; i++){
      set.setInt("keyPrice$i", gzsList[gzsList.keys.toList()[i]][1]);
    }

    for(var i = 0; i < gzsList.keys.length; i++){
      set.setString("keyImg$i", gzsList[gzsList.keys.toList()[i]][2]);
    }

    getData();
  }

  getData() async{
    SharedPreferences get = await SharedPreferences.getInstance();
    var getFirstKeyName = get.getString(keyToCheckIFValueItSaved);
    var getGzNumber = get.getInt(gzNumber);
    print('DATA $getFirstKeyName, $getGzNumber');

    //({"${gz.data()['gzname']}": [false, gz.data()['gzprice'], gz.data()['gzimage']]});
    for(var i = 0; i < gzsList.keys.length; i++){
      var getGzName = get.getString("keyName$i");
      if(getGzName != null){
        print('DATA :$getGzName');
        persistentStore.addAll({});
      }
    }
/*    for(var i = 0; i < gzsList.keys.length; i++){
      var getGzBool = get.getString("keyBool$i");
      if(getGzBool != null){
        print('DATA :$getGzBool');
      }
    }
    for(var i = 0; i < gzsList.keys.length; i++){
      var getGzPrice = get.getString("keyPrice$i");
      if(getGzPrice != null){
        print('DATA :$getGzPrice');
      }
    }

    for(var i = 0; i < gzsList.keys.length; i++){
      var getGzImg = get.getString("keyImg$i");
      if(getGzImg != null){
        print('DATA :$getGzImg');
      }
    }*/

  }

  void checkIfFirstGzNameSaved() async{
    SharedPreferences get = await SharedPreferences.getInstance();
    var getFirstKeyName = get.getString(keyToCheckIFValueItSaved);

    if(getFirstKeyName != null){
      print('DATA IS SAVED IN PERSISTENT STORAGE $getFirstKeyName');

    }else{
      print('DATA NOT SAVED YET, MAKE FIRST READ');
      FirebaseFirestore.instance.collection('Gzlist')
          .get().then((value){
        for(QueryDocumentSnapshot gz in value.docs){
          setState(() {
            gzsList.addAll({"${gz.data()['gzname']}": [false, gz.data()['gzprice'], gz.data()['gzimage'], 1]});
          });
        }

        setData(gzList: gzsList);
        getData();
      }).catchError((er) => print('UNABLE TO GET GZ LIST $er'));
    }
  }

}
