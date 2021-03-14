import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gps/gps.dart';
import 'package:gzapp/auth/splashscrean.dart';
import 'package:gzapp/pages/client/notificationpage.dart';
import 'package:ip_geolocation_api/ip_geolocation_api.dart';
import 'package:marquee/marquee.dart';
import 'package:gzapp/pages/client/validatepage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intent/intent.dart' as intent;
import 'package:intent/action.dart' as action;
import 'ordertrack.dart';
import 'package:http/http.dart' as http;
import 'package:http_client/console.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();


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

  String playerId;

  String text = '';
  GeolocationData geolocationData;

  String userPlayerIdKey = "userPlayerId";



  Future<void> getIp() async {
    geolocationData = await GeolocationAPI.getData();
    if (geolocationData != null) {
      setState(() {
        text = geolocationData.ip;
       print('IP  ${jsonEncode(geolocationData.toJson())}');
      });
    }
  }

  Future getUserLocation() async{
    print('IO ADD $text');
    await http.get('https://api.ipgeolocation.io/ipgeo?apiKey=c7d3a3517825444288bc280cc82bf0ed&ip=$text')
        .then((value) => print('RESULT ${value.body}'))
        .catchError((err) =>print('ERROR $err'));
  }

  Future location() async {
  final client = ConsoleClient();
  final rs = await client.send(Request('GET', 'https://api.ipgeolocation.io/ipgeo?apiKey=c7d3a3517825444288bc280cc82bf0ed&ip=$text'));
  final textContent = await rs.readAsString();
  print(textContent);
  await client.close();
}

  Future getLocation() async {//'http://ip-api.com/json/$text'

    await http.get('https://www.iplocate.io/api/lookup/$text')//https://www.iplocate.io/api/lookup/
    // 'http://ipwhois.app/json/$text' less than 10k request per month
    //https://ip-geolocation.whoisxmlapi.com/api/v1?apiKey=at_9bslGGkP0EjDl5YcaySG5PYvWLrWT&ipAddress=$text
        .then((value) => print('RESULT ${value.body}'))
        .catchError((err) =>print('ERROR $err'));
  }

  Future getClientLocation() async{
    var latlng = await Gps.currentGps();
      print(latlng.lat);
      print(latlng.lng);

  }


  @override
  void initState() {//"latitude":"5.3599517","longitude":"-4.0082563"
    checkIfFirstGzNameSaved();
    showBigTextNotification(msg: "Votre gaz est fini? rechargez la maintenant!!",
        title: '${DateTime.now().hour < 12 ? 'Bonjour et bienvenue':'Bonsoir et bienvenue'}');
    oneSignalConfig();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child:Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text('Recharge ton gaz'),
          actions: [
            IconButton(icon: Icon(Icons.settings,size: 30),
                onPressed: (){
                  print('LIST1 ${gzsList}');
                  print('LIST ${persistentStore}');
              /*showModalBottomSheet(context: context,
                  builder: (context) {
                    return Container(
                      color: Colors.blueGrey,
                      height: 50,
                     child: Column(
                       children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             TextButton.icon(onPressed: (){
                               Fluttertoast.showToast(
                                   msg:"Nous sommes à votre écoute!",
                                   backgroundColor: Colors.green,
                                   textColor: Colors.white);
                               return serviceCall();
                             }, icon: Icon(Icons.call,size: 30,color: Colors.white), label: Text('Contactez-nous',
                                 style: TextStyle(fontSize: 17,color: Colors.white))),

                             IconButton(icon: Icon(FlutterIcons.exit_to_app_mco,color: Colors.grey), onPressed: (){
                               return disconnection(msg: 'Voulez-vous vraiment vous déconnter?');
                             })
                           ],
                         )
                       ],
                     ),
                    );
                  });*/

            }),
            StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection("notification").snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('');
                  } else if (!snapshot.hasData) {
                    return Text('');
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      onPressed: (){
                        Navigator.push(
                            context, PageTransition(
                            child: NotificationPage(),
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
                                child: Text('${snapshot?.data?.docs?.length == 0 ? "0" : snapshot?.data?.docs?.length}',
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold,fontSize: 17))),
                          )
                        ],
                      ),
                    ),
                  );
                }
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection("reservation")
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('');
                  } else if (!snapshot.hasData) {
                    return IconButton(icon: Icon(Icons.notifications,color: Colors.transparent,), onPressed: () {});
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      onPressed: (){
                        Navigator.push(
                            context, PageTransition(
                            child: OrderTrackPage(
                              userIdPlayer: playerId,
                                gzList: gzsList.isNotEmpty ? gzsList : persistentStore),
                            type: PageTransitionType.fadeIn,
                            duration: Duration(milliseconds: 500)
                        ));
                      },
                      tooltip: 'notification',
                      icon: Stack(
                        alignment:Alignment.bottomRight,
                        children: [
                          Icon(FlutterIcons.gas_cylinder_mco,size: 40,color: Colors.white),
                          Container(
                            height: 20.0,
                            width: 20.0,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5.0)
                            ),
                            child: Center(
                                child: Text('${snapshot?.data?.docs?.length == 0 ? "0" : snapshot?.data?.docs?.length}',
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold,fontSize: 17))),
                          )
                        ],
                      ),
                    ),
                  );
                }
            )
          ],
        ),
        body:  Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(
                height: 30,
                child: Center(
                  child: Marquee(
                    text: "               Un service à votre écoute 24h/24 7j/7",
                    style: TextStyle(color: Colors.green, fontSize: 17.0),
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
                child: buildGzChoice(data: gzsList.isNotEmpty ? gzsList : persistentStore),
              ),
            ],
          ),
        ),

        //AVEC LA CASE A COCHER buildGzChoice FAIT DE CETTE MANIERE LA MISE A JOUR
        //EST FAITE POUR LA CONDITION QUE JE FAIS POUR AFFICHER OU PAS LE bottomNavigationBar
        bottomNavigationBar: gzChosen.keys.isEmpty  ?
        /*&&
            //TO BE SURE USER HAVE AT LEAST GZ CHECKED
            ((persistentStore.keys.length >=1 && persistentStore[persistentStore.keys.toList().first][0] == true) ||
           ( gzsList.keys.length >=1 && gzsList[gzsList.keys.toList().first][0] == true ))?*/
        Container(
          height: 0,
          child: Text(''),
        )
            : Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.blueGrey,
          height: 45,
          child: TextButton(
              onPressed: () {
                print('$gzChosen $gzsList, $gzsChosen');
                Navigator.push(context, PageTransition(
                    child: ValidateOrderPage(
                      userPlayerId: playerId,
                      userName: widget.userName,
                      userCommune: widget.commune,
                      userCity: widget.city,
                      userFirstNumber: widget.phoneNumber,
                      userQuarter: widget.quarter,
                      userSecondNumber: widget.secondNumber,
                      gzsChosen: gzsChosen,
                    ),
                    type: PageTransitionType.fadeIn,
                    duration: Duration(milliseconds: 500)));


                if(gzsList.keys.length >= 1){
                  for(int i = 0; i < gzsList.keys.length; i++){
                    if(gzsList[gzsList.keys.toList()[i]][0] == true){
                      setState(() {
                        gzsList[gzsList.keys.toList()[i]][0] = false;
                        gzChosen.clear();
                      });
                    }
                  }
                }else{
                  for(int i = 0; i < persistentStore.keys.length; i++){
                    if(persistentStore[persistentStore.keys.toList()[i]][0] == true){
                      setState(() {
                        persistentStore[persistentStore.keys.toList()[i]][0] = false;
                        gzChosen.clear();
                      });
                    }
                  }
                }

              },
              child: Text('SUIVANT',style: TextStyle(color: Colors.white),)),
        ),
        
      ),
    );
  }
   Widget buildGzChoice({Map<String, List> data}){
     return GridView.builder(
         shrinkWrap: true,
         itemCount: data.length,
         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 0.59),
         itemBuilder: (context, i){
           //WHEN YOU PUT i after context param IT DO AN INFITE LIST
           return Card(
             shape: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(12),
                 borderSide: BorderSide(width: 2,color: Colors.blueGrey)
             ),
             child: Container(
               child: Column(
                 children: [
                   Padding(
                     padding: const EdgeInsets.only(top: 5),
                     child: CachedNetworkImage(
                       imageBuilder: (context, imageProvider) =>
                           Container(
                             height: 150,
                             decoration: BoxDecoration(
                               //border:Border.all(width: 1, color: Color.fromRGBO(14,47,68,1)),
                               image: DecorationImage(
                                   image: imageProvider,
                                   fit: BoxFit.cover),
                             ),
                           ),

                       imageUrl: '${data[data.keys.toList()[i]][2]}',
                       progressIndicatorBuilder: (context, url, downloadProgress) {
                         return Container(
                           margin: const EdgeInsets.only(left: 5.0),
                           height: 150,
                           child: Center(
                             child: CircularProgressIndicator(
                               value: downloadProgress.progress,
                               valueColor: AlwaysStoppedAnimation(
                                   Color.fromRGBO(
                                       14, 47, 68, 1)),
                             ),
                           ),
                         );
                       },
                       errorWidget: (context, url, object) {
                         return Container(
                           margin: const EdgeInsets.only(left: 5.0),
                           height: 150,
                           child: Center(child: Text('')),
                         );
                       },
                     ),
                   ),

                   Padding(
                     padding: const EdgeInsets.only(top: 10),
                     child: Text('${data.keys.toList()[i]}'),
                   ),


                   Padding(
                     padding: const EdgeInsets.only(top: 22),
                     child: updatePrice(
                       gzListWitchWillBeUpdated: data,
                         checked: data[data.keys.toList()[i]][0],
                         oldPrice: data[data.keys.toList()[i]][4],
                         countPrice: data[data.keys.toList()[i]][3],
                         gzs: data[data.keys.toList()[i]],
                         key: data.keys.toList()[i]),
                   ),
                   Padding(
                     padding: const EdgeInsets.only(top: 0),
                     child: CheckboxListTile(
                       activeColor: Colors.green,
                       // title: Text('${data.keys.toList()[i]}'),
                       onChanged: (bool value) async{
                         setState((){
                           data[data.keys.toList()[i]][0] = value;
                         });
                         if(data[data.keys.toList()[i]][0] == true) {
                           setState((){
                             gzsChosen.addAll({"${data.keys.toList()[i]}": [data[data.keys.toList()[i]][1],data[data.keys.toList()[i]][2], data[data.keys.toList()[i]][3], data[data.keys.toList()[i]][4],data[data.keys.toList()[i]][5],data.keys.toList()[i]]});
                             gzChosen.addAll({"${data.keys.toList()[i]}": [data[data.keys.toList()[i]][1],data[data.keys.toList()[i]][2], data[data.keys.toList()[i]][3], data[data.keys.toList()[i]][4],data[data.keys.toList()[i]][5],data.keys.toList()[i]]});
                           });
                         }
                         else if(data[data.keys.toList()[i]][0] == false){
                           setState(() {
                             gzsChosen.remove(data.keys.toList()[i]);
                             gzChosen.remove(data.keys.toList()[i]);
                           });
                         }

                         print('$gzChosen');
                       }, value: data[data.keys.toList()[i]][0],

                     ),
                   )
                 ],
               ),
             ),
           );
         });
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

    for(var i = 0; i < gzsList.keys.length; i++){
      set.setString("keyId$i", gzsList[gzsList.keys.toList()[i]][5]);
    }

    getData();
  }

  getData() async{
    SharedPreferences get = await SharedPreferences.getInstance();
    var getFirstKeyName = get.getString(keyToCheckIFValueItSaved);
    var getGzNumber = get.getInt(gzNumber);
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
    var getGzNumber = get.getInt(gzNumber);

    if(getFirstKeyName != null){
      print('DATA IS SAVED IN PERSISTENT STORAGE $getFirstKeyName');
      //({"${gz.data()['gzname']}": [false, gz.data()['gzprice'], gz.data()['gzimage']]});
      for(var i = 0; i < getGzNumber; i++){
        setState(() {
          persistentStore.addAll(
              {"${get.getString("keyName$i")}" : [get.getBool("keyBool$i"), get.getInt("keyPrice$i"),get.getString("keyImg$i"),1,get.getInt("keyPrice$i"),get.getString("keyId$i"),get.getString("keyName$i")]});
        });
      }

      print('GZ LIST $persistentStore');
    }else{
      print('DATA NOT SAVED YET, MAKE FIRST READ');
      FirebaseFirestore.instance.collection('Gzlist')
          .get().then((value){
        for(QueryDocumentSnapshot gz in value.docs){
          setState(() {
            gzsList.addAll({"${gz.data()['gzname']}": [false, gz.data()['gzprice'], gz.data()['gzimage'], 1, gz.data()['gzprice'], gz.id,gz.data()['gzname']]});
          });
        }

        setData(gzList: gzsList);
      }).catchError((er) => print('UNABLE TO GET GZ LIST $er'));
    }
  }

  Widget  updatePrice({int oldPrice, int countPrice, List gzs, String key, bool checked,Map<String, List> gzListWitchWillBeUpdated}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          child: Card(
            shape: OutlineInputBorder(
                borderSide: BorderSide(style: BorderStyle.none),
                borderRadius: BorderRadius.circular(7)
            ),
            color:Colors.blueGrey,
            elevation: 3.0,
            child: Container(
              width: 40,
                child: Center(child: Text('-',style: TextStyle(fontSize: 23.0,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center,))),
          ),
          //  //{big gz: [false, 7500, , 1, 7500], G1: [false, 2300, , 1, 2300], G2: [false, 2500, imagegz2, 1, 2500]}
          onTap: (){
            if(countPrice > 1){
              setState(() {
                int oldPrices = oldPrice;
                int newPrice = gzListWitchWillBeUpdated[key][1] - oldPrices;
                countPrice--;
                gzListWitchWillBeUpdated.addAll({"$key" : [checked,newPrice, gzs[2],countPrice, oldPrice, gzs[5],key]});
                if(gzsChosen.keys.length >= 1 && gzsChosen["$key"] != null){
                  gzsChosen["$key"][0] = newPrice;
                  gzsChosen["$key"][2] = countPrice;
                }

                print("$gzsChosen");
              });
            }
          },
        ),
        SizedBox(width: 5.0),
        Card(
          shape: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)
          ),
            child: Container(
              height: 30,
              width: 55,
                child: Center(child: Text("$countPrice",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),)))),
        SizedBox(width: 5.0),
        InkWell(
          child: Card(
            shape: OutlineInputBorder(
                borderSide: BorderSide(style: BorderStyle.none),
              borderRadius: BorderRadius.circular(7)
            ),
            color:Colors.blueGrey,
            elevation: 3.0,
            child: Container(
              width: 40,
                child: Center(child: Text('+',style: TextStyle(fontSize: 22.0,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center))),
          ),
          onTap: (){
            setState(() {
              int oldPrices = oldPrice;
              countPrice++;
              int newPrice  = oldPrices * countPrice;
              gzListWitchWillBeUpdated.addAll({"$key" : [checked, newPrice, gzs[2],countPrice, oldPrice,gzs[5],key]});
              //print("$gzListWitchWillBeUpdated  $gzsChosen");
              if(gzsChosen.keys.length >= 1 && gzsChosen["$key"] != null){
                gzsChosen["$key"][0] = newPrice;
                gzsChosen["$key"][2] = countPrice;
              }
              print("$gzListWitchWillBeUpdated");
            });
          },
        ),
      ],
    );
  }

  void oneSignalConfig() async {
    OneSignal.shared.init('a0fb69a4-4f28-4eee-ad25-30bf5707bcd4');
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    OSPermissionSubscriptionState state = await OneSignal.shared.getPermissionSubscriptionState();
    OneSignal.shared.getPermissionSubscriptionState().then((value){
      print('HOME P ${value.subscriptionStatus.userId}');
    }).catchError((er) => print('$er'));
    print('HOME P ${state.subscriptionStatus.userId}');
    setState(() {
      playerId = state.subscriptionStatus.userId;
    });
    OneSignal.shared.setNotificationReceivedHandler((notification) {
      return notification.jsonRepresentation().replaceAll("\\n", "\n");
    });
  }

  getUserPlayerId() async{
    SharedPreferences get = await SharedPreferences.getInstance();
    var playerID = get.getString(userPlayerIdKey);
    if(playerID != null){

    }
  }

  Future<void> showBigTextNotification({String title, String msg}) async {
    var bigTextStyleInformation = BigTextStyleInformation('$msg',
        htmlFormatBigText: true,
        contentTitle: '<b>$title</b>',
        htmlFormatContentTitle: true,
        htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '$title',
        '$title',
        '$msg',
        styleInformation: bigTextStyleInformation);
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(0, '$title', '$msg', platformChannelSpecifics);
  }

  serviceCall() async {
    return intent.Intent()
      ..setAction(action.Action.ACTION_DIAL)
      ..setData(Uri(scheme: 'tel', path: '+2250153441343'))
      ..startActivity().catchError((e) => print(e));
  }

  disconnection({String msg}){
    return showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none
              ),
              title: new Text(''),
              content: Center(child: new Text(msg, textAlign: TextAlign.center)),
              actions: <Widget>[FlatButton(
                child: new Text('Non',style: TextStyle(color: Colors.grey[800])),
                onPressed: () => Navigator.pop(context),
              ),
                FlatButton(
                  child: new Text('Oui',style: TextStyle(color: Colors.grey),),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SplashScreenPage()
                        )
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
      animationType: DialogTransitionType.slideFromTopFade,
      curve: Curves.easeOut,
      duration: Duration(milliseconds: 500),
    );

  }
}
