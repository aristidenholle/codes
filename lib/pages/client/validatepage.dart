import 'dart:async';
import 'package:animate_do/animate_do.dart ' as fade;
import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phone_number/phone_number.dart';
import 'package:intl/date_symbol_data_local.dart';

class ValidateOrderPage extends StatefulWidget {
  final userName, userCommune, userQuarter, userFirstNumber, userSecondNumber, userCity;
  final Map<String, List> gzsChosen;

  const ValidateOrderPage({Key key, this.userName, this.userCommune, this.userQuarter, this.userFirstNumber, this.userSecondNumber, this.gzsChosen, this.userCity}) : super(key: key);

  @override
  _ValidateOrderPageState createState() => _ValidateOrderPageState(listGzChosen: gzsChosen);
}

class _ValidateOrderPageState extends State<ValidateOrderPage> with TickerProviderStateMixin{
  final Map<String, List>  listGzChosen;


  RegExp regExp = new RegExp(r'(^[a-zA-Z àáâãäåçèéêëìíîïðòóôõöœùúûüýÿ-]*$)');

  TextEditingController editController = new TextEditingController();
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  PhoneNumber phoneNumber = new PhoneNumber();
  bool editCityOrCommuneOrQuarter = false;
  StreamController<bool> sendState  = StreamController<bool>.broadcast();
  int gzCount = 1;
  int totalGzPrice = 0;
  int totalPrice = 0;

  //CUSTOM USER LOCATION
  bool editCity = false;
  bool editCommuneQuarter = false;

  GlobalKey<FormState> cityFormKey = new GlobalKey<FormState>();
  GlobalKey<FormState> communeOrQuarterFormKey = new GlobalKey<FormState>();
  TextEditingController editCityController = new TextEditingController();
  TextEditingController editCommuneQuarterController = new TextEditingController();
  FocusNode editCommuneOrQuarterControllerFocus = new FocusNode();
  bool cityInputError = false;

  bool userDataNotDefined = false;

  int citySelected;
  String cityChosen;
  List<String> ivoryCostCity = [
    'Abidjan-Yopougon',
    'Abidjan-Port-Bouë',
    'Abidjan-Deux-Plateaux',
    'Abidjan-Cocody',
    'Abidjan-Abobo',
    'Abidjan-Le Plateau',
    'Abidjan-Treichville',
    'Abidjan-Koumassi',
    'Abidjan-Marcory',
    'Abidjan-Anyama',
    'Abidjan-Adjamé',
    'Abidjan-Attécoubé',
    'Agboville',
    'Anyama',
    'Abengourou',
    'Akoupé',
    'Adzopé',
    'Agnibilékrou',
    'Bouaké',
    'Bingerville',
    'Bouaflé',
    'Boundiali',
    'Bondoukou',
    'Daloa',
    'Daoukro',
    'Divo',
    'Dimbokro',
    'Dabou',
    'Danané',
    'Duékoué',
    'Ferkessedougou',
    'Grand-Bassam',
    'Gagnoa',
    'Guiglo',
    'Issia',
    'Katiola',
    'Korhogo',
    'Lakota',
    'Man',
    'Odienné',
    'Oumé',
    'Séguéla',
    'San-Pédro',
    'Soubré',
    'Sinfra',
    'Tiassalé',
    'Tingréla',
    'Toumodi',
    'Vavoua',
    'Yamoussoukro',
    'Zuénoula',
    'Autre'
  ];

  int reservationTypeSelected;
  static List<String> reservationType = [
    'Maintenant',
    "Reservation à l\'avance",
  ];
  String reservationTypeChosen = reservationType[0];

  List<DropdownMenuItem<String>> drop = reservationType.map(
          (value) => DropdownMenuItem(child: Text(value), value: value)).toList();


  bool hourOrDayReservationNotChoose = false;
  String hourReservation;
  var hourReservationChoice;

  String reservationDay;
  var reservationDayChoice;

  _ValidateOrderPageState({this.listGzChosen});


  @override
  void initState() {
    initializeDateFormatting('fr_FR', null);
    super.initState();
  }

  @override
  void dispose() {
    sendState.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          elevation: 0.0,
          centerTitle: true,
          title: Text('LIVRAISON'),
          leading: IconButton(icon: Icon(Icons.arrow_back),
              onPressed: (){
                Navigator.pop(context);
                setState(() {
                  listGzChosen.clear();
                });
              }),
        ),
        body: Container(
          child: ListView(
            children: [
              Container(
                height:  editCityOrCommuneOrQuarter == false ?  200 :  302,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser.uid).snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> user) {
                    if (user.hasError) {
                      return Center(
                        child: Text(""),
                      );
                    } else if (!user.hasData) {
                      return Center(
                        child: SpinKitPulse(
                          color: Colors.green,
                          controller: AnimationController(vsync:
                          this, duration: Duration(milliseconds: 2000)),
                        ),
                      );
                    }
                    return Card(
                      color: userDataNotDefined == true ? Colors.red[100] : Colors.white,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 10, top: 15),
                            child: (user.data.data() != null || user.data.data()["userName"] != null) ? Row(
                              children: [
                                Text("${user.data.data()["userName"]}",style: TextStyle(fontWeight: FontWeight.bold))
                              ],
                            ) : Text('Nom et Prénom'),
                          ),

                          Row(
                            children: [
                              TextButton.icon(
                                  onPressed: (){

                                    return editDialog(oldValue:
                                    (user.data.data() != null && user.data.data()["phoneNumber"] != null ) ?
                                    user.data.data()["phoneNumber"] : "0000", keyType: 'phoneNumber');

                                  }, icon: Icon( (user.data.data() != null && user.data.data()["phoneNumber"] != null ) ?
                              Icons.call : Icons.edit),

                                  label: Text((user.data.data() != null && user.data.data()["phoneNumber"] != null)  ?
                                  " ${user.data.data()["phoneNumber"]}" :  'Numéro de téléphone')),
                            ],
                          ),

                          Row(
                            children: [
                              TextButton.icon(
                                  onPressed: (){

                                    return editDialog(oldValue:
                                    (user.data.data() != null && user.data.data()["secondNumber"] != null ) ?
                                    user.data.data()["secondNumber"] : "0000", keyType: 'secondNumber');

                                  }, icon: Icon( (user.data.data() != null && user.data.data()["secondNumber"] != null ) ?
                              Icons.call : Icons.edit),

                                  label: Text((user.data.data() != null && user.data.data()["secondNumber"] != null)  ?
                                  " ${user.data.data()["secondNumber"]}" :  'Autre numéro de téléphone')),
                            ],
                          ),

                          editCityOrCommuneOrQuarter == false ?
                          Row(
                            children: [
                              TextButton.icon(
                                  onPressed: (){
                                    return listOfCityDialog();

                                  }, icon: Icon( (user.data.data() != null && user.data.data()["userLocation"] != null ) ?
                              Icons.home : Icons.edit,size: 30),

                                  label: Row(
                                    children: [
                                      Text((user.data.data() != null && user.data.data()["userLocation"] != null)  ?
                                      " ${user.data.data()["userLocation"]}" :  'Lieu de résidence'),
                                      (user.data.data() != null && user.data.data()["userLocation"] != null )?
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 7, left: 5),
                                        child: Icon(Icons.edit,color: Colors.grey),
                                      ):Container(height: 0)
                                    ],
                                  ) ),


                            ],
                          )
                              : fade.FadeIn(
                            duration: Duration(milliseconds: 600),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(left: 40,top: 10),
                                      child: Text("Indiquez votre localité"),
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: saveUserLocation(),
                                )
                              ],
                            ),
                          ) ,


                        ],
                      ),
                    );
                  }
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: SingleChildScrollView(
                  child: Column(
                    children: buildGzChoice(),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('PRIX: ${price(price: getAllGzPrice())}'),
                      Text('FRAIS DE LIVRAISON: 500 Frcfa'),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('PRIX TOTAL: ${price(price: getAllPrice())}'),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('DELAI DE LIVRAISON'),
                        ],
                      ),

                      Card(
                        child: Container(
                          width: 250,
                          child: Center(
                            child: DropdownButton(
                              underline: Text(''),
                              hint: Text('$reservationTypeChosen'),
                              onChanged: (String value){
                                setState(() {
                                  reservationTypeChosen = value;
                                });
                              },
                              items: drop),
                          ),
                        ),
                      ),

                       (reservationTypeChosen.contains('Maintenant'))//lol
                          ? Container(
                          height: 30.0,
                          child: Center(
                              child: Text(
                                  'LIVRAISON IMMEDIATE'
                                      .toUpperCase(),
                                  style: TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 17.0))))
                          :  Row(
                         mainAxisAlignment: MainAxisAlignment.spaceAround,
                         children: [
                           TextButton.icon(
                               onPressed: () {
                                 return giveYourReservationDay();
                               },
                               icon: Icon(Icons.date_range, color: Colors.green),
                               label: (reservationDayChoice == null)
                                   ? Text('Jour'.toUpperCase(),
                                   style: TextStyle())
                                   : Text(
                                   '${reservationDay.toUpperCase()}',
                                   style: TextStyle(
                                       fontWeight:
                                       FontWeight
                                           .bold,
                                       fontSize: 17.0))),

                           TextButton.icon(
                               onPressed: () {
                                 return giveYourReservationTime();
                               },
                               icon: Icon(Icons.timer,
                                   color: Colors.green),
                               label: (hourReservationChoice == null)
                                   ? Text(
                                   'Heure'
                                       .toUpperCase(),
                                   style: TextStyle())
                                   : Text(
                                   '${hourReservation.toUpperCase()}',
                                   style: TextStyle(
                                       fontWeight:
                                       FontWeight
                                           .bold,
                                       fontSize: 17.0)))
                         ],
                       )

                    ],
                  )
                ),
              ),

            ],
          ),
        ),
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.teal,
          height: 45,
          child: TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser.uid)
                    .get()
                    .then((value){
                      if(value.data() != null && value.data()['userName'].toString().isNotEmpty && value.data()['phoneNumber'].toString().isNotEmpty &&
                          value.data()['userLocation'].toString().isNotEmpty){
                        if(reservationTypeChosen == "Maintenant"){
                          return alertToShow(msg: "Vous confirmez votre achat?",
                              userNumber: value.data()['phoneNumber'],userLocation: value.data()['userLocation'],
                              userSecondNumber: value.data()['secondNumber'],userName: value.data()['userName']);
                        }else{
                          if(reservationDay != null && hourReservation != null){
                            return alertToShow(msg: "Vous confirmez votre achat?",
                                userNumber: value.data()['phoneNumber'],userLocation: value.data()['userLocation'],
                                userSecondNumber: value.data()['secondNumber'],userName: value.data()['userName']);
                          }else{
                            return validate(errorMsg: "Définissez la date de livraison.");
                          }
                        }
                      }else{
                        setState(() {
                          userDataNotDefined = true;
                        });
                        return validate(errorMsg: "Veuillez définir vos infos.");
                      }
                }).catchError((err){
                  print('ERROR $err');
                });
              },
              child: Text('Valider',style: TextStyle(color: Colors.white))),
        ),
      ),
    );
  }

  int getAllPrice(){
    int price = 0;
    listGzChosen.values
        .forEach((value) {
      setState(() {
        price = price + value[0];
      });
    });
    setState(() {
      totalPrice = price;
    });

    return totalPrice + 500;
  }

  int getAllGzPrice(){
    int price = 0;
    listGzChosen.values
        .forEach((value) {
          setState(() {
            price = price + value[0];
          });
    });
    setState(() {
      totalGzPrice = price;
    });

    return totalGzPrice;
  }

  List<Widget> buildGzChoice(){
    List<Widget> lgz = [];
    for(var i = 0; i < listGzChosen.keys.length;  i++){
      Widget g = Card(
        child: Container(
          height: 80,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 70,
                width: 80,
                color: Colors.grey,
                child: Text('${listGzChosen[listGzChosen.keys.toList()[i]][1]}'),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Container(
                          child: Text('${listGzChosen.keys.toList()[i]}'),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            child: Text("${price(price: listGzChosen[listGzChosen.keys.toList()[i]][0])}"),
                          ),

                          updatePrice(
                              oldPrice: listGzChosen[listGzChosen.keys.toList()[i]][3],
                              countPrice: listGzChosen[listGzChosen.keys.toList()[i]][2],
                              gzs: listGzChosen[listGzChosen.keys.toList()[i]],
                              key: listGzChosen.keys.toList()[i])
                        ],
                      )
                    ],
                  ),
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

  //INCREMENTER LES PRIX, DES NOMBRES INDEPENDEMMENT DANS CHAQUE CARD OU DANS UNS LIST VIEW
  //POUR LES PRIX PAR EXEMPLE IL FAUT AVOIR UN PRIX QUI EST CONSTANT
  //LORSQUON INCREMENTE ON  MULTIPLIE TJR PAR CE PRIX ET ON A  UN NEW PRIX A SAVE
  Widget  updatePrice({int oldPrice, int countPrice, List  gzs, String key}){
    Map<String, List>  newListGzChosen = {};
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          child: Container(
            child: Card(
              color:Colors.red,
              elevation: 3.0,
              child: Center(child: Text('-',style: TextStyle(fontSize: 23.0,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center,)),
            ),
            width: 45.0,
            height: 35.0,
          ),
          onPressed: (){
            if(countPrice > 1){
              setState(() {
                int oldPrices = oldPrice;
                countPrice--;
                listGzChosen.addAll({"$key" : [listGzChosen[key][0] - oldPrices, gzs[1],countPrice, oldPrice]});
                print(listGzChosen);
              });
            }
          },
        ),
        SizedBox(width: 5.0),
        Text("$countPrice",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
        SizedBox(width: 5.0),
        TextButton(
          child: Container(
            child: Card(
              color:Colors.red,
              elevation: 5.0,
              child: Center(child: Text('+',style: TextStyle(fontSize: 22.0,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center)),
            ),
            width: 45.0,
            height: 35.0,
          ),
          onPressed: (){
            if(countPrice < 11){
              setState(() {
                int oldPrices = oldPrice;
                countPrice++;
                int newPrice  = oldPrices * countPrice;
                listGzChosen.addAll({"$key" : [newPrice, gzs[1],countPrice, oldPrice]});
                print(listGzChosen);
              });
            }
          },
        ),
      ],
    );
  }


  editDialog({String keyType, String oldValue}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context){
          return fade.FadeInDown(
            duration: Duration(milliseconds: 800),
            child: WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: Container(
                  height: 250,
                  child: SingleChildScrollView(
                    child: AlertDialog(
                      title: Text(''),
                      content: Container(
                        child: Form(
                          key: formKey,
                          child: TextFormField(
                            keyboardType: (keyType  == "phoneNumber" || keyType  == "secondNumber") ? TextInputType.number : TextInputType.text,
                            controller:  editController..text = (keyType  == "phoneNumber" || keyType  == "secondNumber") ? oldValue.substring(4) : oldValue,

                            validator: (keyType  == "phoneNumber" || keyType  == "secondNumber") ?
                                (String phone) {
                              String pattern = r'(^[0-9]*$)';
                              RegExp regExp = new RegExp(pattern);
                              if (phone.length != 8) {
                                return 'Entrer un numéro correct à 8 chiffres';
                              }
                              else if (!regExp.hasMatch(phone)) {
                                return 'Saisie  invalide';
                              }
                              return null;
                            }
                            : (value) {
                              if (value.isEmpty) {
                                return 'Entrez votre ${keyType == 'userLocation' ? "Localité" : keyType == 'commune' ? "commune" :
                                keyType == 'quarter' ? "quarter" : (keyType == 'phoneNumber' || keyType == 'secondNumber' ) ? "numéro" : ''}';
                              } else if (!regExp.hasMatch(value)) {
                                return "Votre saisie est invalide";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                hintText: 'Entrez votre ${keyType == 'city' ? "ville" : keyType == 'commune' ? "commune" :
                                keyType == 'quarter' ? "quarter" : (keyType == 'phoneNumber' || keyType == 'secondNumber' ) ? "numéro" : ''}'
                            ),
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                           editController.clear();
                          },
                          child: Text(
                              'Annuler', style: TextStyle(color: Colors.black)),
                        ),
                        FlatButton(
                          onPressed: () {
                            if (formKey.currentState.validate() &&
                                editController.text.isNotEmpty) {
                              print("${editController.text}, $oldValue");
                              if((keyType  == "phoneNumber" || keyType  == "secondNumber") && editController.text == oldValue.substring(4)){
                                Navigator.pop(context);
                                Fluttertoast.showToast(
                                    msg: "Aucune modification détectée.",
                                    textColor: Colors.white,
                                    backgroundColor: Colors.teal,
                                    gravity: ToastGravity.BOTTOM);
                                editController.clear();
                              } else if(editController.text == oldValue){
                                Fluttertoast.showToast(
                                    msg: "Aucune modification détectée.",
                                    textColor: Colors.white,
                                    backgroundColor: Colors.teal,
                                    gravity: ToastGravity.BOTTOM);
                                editController.clear();
                                Navigator.pop(context);
                              }else{
                                if((keyType  == "phoneNumber" || keyType  == "secondNumber") &&
                                editController.text != oldValue.substring(4)){
                                  phoneNumber.parse("${editController.text}", region: 'CI').then((value) {
                                    edit(value: editController.text, type: keyType);
                                    Navigator.pop(context);
                                  }).catchError((err) => validate(errorMsg: 'Votre numéro de téléphone est invalide'));
                                }else{
                                  edit(value: editController.text, type: keyType);
                                  Navigator.pop(context);
                                }
                              }
                            }else{
                              print("EDIT ${editCityController.text.length}");
                             return validate(errorMsg: 'Saisie invalide.');
                            }
                          },
                          child: Text('Ok',style: TextStyle(color: Colors.teal, fontSize: 19.0)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  void edit({String value, String type}) {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid).set({
      '$type': (type  == "phoneNumber" || type  == "secondNumber") ? "+225$value" : value.substring(0,1).toUpperCase() + value.substring(1).toLowerCase()
    },SetOptions(merge: true)).catchError((err) => print('ERROR TO SAVE DATA $err'));
    Fluttertoast.showToast(
        msg: "Succès",
        textColor: Colors.white,
        backgroundColor: Colors.green,
        gravity: ToastGravity.BOTTOM);
    editController.clear();
  }



  alertToShow({String msg, String userName, String userLocation,String userNumber ,String userSecondNumber}){
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: SingleChildScrollView(
              child: StreamBuilder<bool>(
                stream: sendState.stream,
                builder: (context, snapshot) {
                  return AlertDialog(
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none
                    ),
                    title:  Text(''),
                    content: Center(child:  snapshot.data == true ?
                    Text("En cours d'envoie...", textAlign: TextAlign.center)
                        :Text(msg, textAlign: TextAlign.center)),
                    actions: <Widget>[
                      FlatButton(
                      child:  Text('Non',style: TextStyle(color: Colors.grey[800])),
                      onPressed: () {
                        print('$listGzChosen');
                        Navigator.pop(context);
                      },
                    ),
                      FlatButton(
                        child: new Text('Oui',style: TextStyle(color: Colors.grey),),
                        onPressed: (){
                          sendState.sink.add(true);
                          return saveOrder(order: listGzChosen,
                          userName: userName,
                          userSecondNumber: userSecondNumber,
                          userLocation: userLocation,userNumber: userNumber);
                        },
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
        );
      },
    );

  }


  saveOrder({Map<String, List> order, String userName, String userLocation,String userNumber ,String userSecondNumber}){
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid)
        .collection("reservation")
        .doc().set({
      "orderNum": "$hashCode",
      'order': listGzChosen,
      "gzPlusDeliveryPrice": totalPrice,
      'gzPrice': totalGzPrice,
      "userName" :"$userName" ,
      "userLocation" :"$userLocation" ,
      "phoneNumber" : "$userNumber",
      "secondNumber": "$userSecondNumber",
      "reservationType": "$reservationTypeChosen",
      "reservationDay": "$reservationDay",
      "reservationHour": "$hourReservation"
    }).catchError((err) => print('error to set $err'));
    sendState.sink.add(false);
    Navigator.pop(context);
    return AwesomeDialog(
        context: context,
        dialogType: DialogType.SUCCES,
        animType: AnimType.TOPSLIDE,
        headerAnimationLoop: false,
        btnOkIcon: Icons.check_circle,
        btnOkColor: Colors.green,
        title: '',
        desc:"Nous avons bien réçu votre commande",
        btnOkOnPress: () {
          print('YES');
          Navigator.pop(context);
        }
    ).show();

    /*Fluttertoast.showToast(
        msg:"Nous avons bien réçu votre commande",
        backgroundColor: Colors.green,
        textColor: Colors.white);*/

  }

  Future<AlertDialog> listOfCityDialog({String clientLocation}) async{
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(
          child: SingleChildScrollView(
            child: FadeInDown(
              duration: Duration(milliseconds: 500),
              child: AlertDialog(
                title: Text('Lien de résidence'),
                content: Container(
                  height: 300,
                  child: StatefulBuilder(
                    builder: (context, StateSetter setState) {
                      return Container(
                        child: ListView.builder(
                            itemCount: ivoryCostCity.length,
                            itemBuilder: (context, i) {
                              return RadioListTile(
                                  title: Text('${ivoryCostCity[i]}'),
                                  value: i,
                                  groupValue: citySelected,
                                  onChanged: (value) {
                                    setState(() {
                                      citySelected = i;
                                      cityChosen = ivoryCostCity[value];
                                    });
                                  });
                            }),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      citySelected = null;
                      cityChosen = null;
                    });
                  }, child: Text('Annuler',style: TextStyle(color: Colors.grey))),

                  TextButton(onPressed: () {
                    if (cityChosen != null && cityChosen !='Autre') {
                      if (clientLocation != null && clientLocation.toLowerCase()
                          .length == cityChosen.toLowerCase().length) {
                        //ALREADY SAVED
                        setState(() {
                          citySelected = null;
                          cityChosen = null;
                        });
                        print('ALREADY SAVED');
                        Navigator.pop(context);
                      } else {
                        FirebaseFirestore.instance.collection('users').doc(
                            FirebaseAuth.instance.currentUser.uid).set({
                          'userLocation': cityChosen
                        },SetOptions(merge: true)).catchError((err) => print('Edited Error $err'));
                        Fluttertoast.showToast(
                            msg: "Succès",
                            textColor: Colors.white,
                            backgroundColor: Colors.green,
                            gravity: ToastGravity.BOTTOM);
                        Navigator.pop(context);
                        setState(() {
                          citySelected = null;
                          cityChosen = null;
                        });
                      }
                    }else if(cityChosen == 'Autre'){
                      setState(() {
                        citySelected = null;
                        editCityOrCommuneOrQuarter = true;
                      });
                      Navigator.pop(context);
                    }
                    else {
                      return validate(errorMsg: 'Indiquez votre localité');
                    }
                  }, child: Text('Ok',style: TextStyle(color: Colors.blueGrey))),

                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void validate({String errorMsg}) {
    Fluttertoast.showToast(
        msg: "$errorMsg",
        textColor: Colors.white,
        backgroundColor: Colors.red,
        gravity: ToastGravity.BOTTOM);
  }

  Widget saveUserLocation({bool noLocationInListMatchUserAddress, String oldCustomAddress}){
    return Column(
      children: [
        editCommuneQuarter == false ? Form(
          key: cityFormKey,
          child: Theme(
            data: ThemeData(
                primaryColor: Colors.grey,
                primaryColorDark: Colors.white
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: TextFormField(
                keyboardType: TextInputType.name,
                /*inputFormatters: [
                  FilteringTextInputFormatter.deny(rEp),
                  FilteringTextInputFormatter.allow(sRegExp)],*/
                validator: validateAddress,
                controller: editCityController,
                cursorColor: Colors.grey,
                style: TextStyle(color: Colors.grey,decoration: TextDecoration.none),
                decoration: InputDecoration(
                  fillColor: Colors.red,
                    prefixIcon: Icon(Icons.home_outlined,color: Colors.grey),
                    enabledBorder: new UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey,width: 2.0)
                    ),
                    hintText: 'Ville',
                    hintStyle: TextStyle(color: Colors.grey)
                ),
              ),
            ),
          ),
        ):
        fade.FadeIn(
          duration: Duration(milliseconds: 800),
          child: Form(
            key: communeOrQuarterFormKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: TextFormField(
               // inputFormatters: [FilteringTextInputFormatter.allow(regExp)],
                keyboardType: TextInputType.text,
                validator: validateAddress,
                focusNode: editCommuneOrQuarterControllerFocus,
                controller: editCommuneQuarterController,
                cursorColor: Colors.grey,
                style: TextStyle(color: Colors.grey,decoration: TextDecoration.none),
                decoration: InputDecoration(
                    fillColor: Colors.red,
                    prefixIcon: Icon(Icons.home_outlined,color: Colors.grey),
                    enabledBorder: new UnderlineInputBorder(
                        borderSide: new BorderSide(color: Colors.grey,width: 2.0)
                    ),
                    hintText: 'Commune et/ou quartier',
                    hintStyle: TextStyle(color: Colors.grey,decoration: TextDecoration.none)
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: (){
                  clearVar();
            }, child: Text('Annuler')),

            //VALIDATE CITY
            editCommuneQuarter == false ? TextButton(
                onPressed: (){
                  if(cityFormKey.currentState.validate()){
                    setState(() {
                      //PASS TO NEXT INPUT
                      editCommuneQuarter = true;
                      cityInputError = false;
                    });
                    editCommuneOrQuarterControllerFocus.requestFocus();
                  }else if(cityInputError == true){
                    return validate(errorMsg: "Saisissez une address correcte.");
                  }
                  else{
                    return validate(errorMsg: "Indiquez votre localité.");
                  }
            }, child: Text('Ok'))
                :
            //VALIDATE CommuneOrQuarter
            TextButton(
                onPressed: (){
                  if(communeOrQuarterFormKey.currentState.validate()){
                    return saveUserCustomLocation(value: editCityController.text + " " + editCommuneQuarterController.text);
                  }else if(cityInputError == true){
                    return validate(errorMsg: "Saisissez une address correcte.");
                  }
                  else{
                    return validate(errorMsg: "Indiquez votre localité.");
                  }
                }, child: Text('Valider'))
          ],
        )
      ],
    );
  }


  String validateAddress(String value) {
    RegExp regExp = new RegExp(r'(^[a-zA-Z àáâãäåçèéêëìíîïðòóôõöœùúûüýÿ-]*$)');
    if (value.length == 0  || value.length < 3 || value.length > 50 || !regExp.hasMatch(value)) {
      setState(() {
        cityInputError = true;
      });
      return '';
    }
    return null;
  }

  void saveUserCustomLocation({String value}) {
    FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid).set({
      'userLocation': value.substring(0,1).toUpperCase() + value.substring(1).toLowerCase()
    },SetOptions(merge: true)).catchError((err) => print('ERROR TO SAVE DATA $err'));
    Fluttertoast.showToast(
        msg: "Succès",
        textColor: Colors.white,
        backgroundColor: Colors.green,
        gravity: ToastGravity.BOTTOM);
    clearVar();
  }

  clearVar(){
    setState(() {
      editCommuneQuarter = false;
      editCityOrCommuneOrQuarter = false;
      editCity = false;
      cityInputError = false;
      editCommuneQuarterController.clear();
      editCityController.clear();
    });
  }

  String price({int price}){
    return price < 1000 ? '$price Frcfa' :
      price >= 1000 &&  price < 10000 ?
    '${price.toString().substring(0,1)+'.'+price.toString().substring(1)} Frcfa':
    price >= 10000 && price < 100000  ?
    '${price.toString().substring(0,2)+'.'+price.toString().substring(2)} Frcfa' :
    price >= 100000 && price < 1000000  ?
    '${price.toString().substring(0,3)+'.'+price.toString().substring(3)} Frcfa' :
    price >= 1000000 && price < 1000000000  ?
    '$price Frcfa' : '$price Frcfa';

  }


  Future<TimeOfDay> giveYourReservationTime() async {
    TimeOfDay time = await showTimePicker(
        cancelText: "Annuler",
        confirmText: 'Ok',
        context: context,
        initialTime: TimeOfDay.now());
    if (time != null) {
      setState(() {
        hourReservationChoice = time;
      });
      if (time.hour == DateTime.now().hour) {
        setState(() {
          hourReservation = '${time.hour + 1}h:${time.minute}min';
        });
        Fluttertoast.showToast(
            msg: "Livraison dans une heure ?",
            backgroundColor: Colors.green,
            textColor: Colors.white);
      } else if (time.hour < DateTime.now().hour) {
        Fluttertoast.showToast(
            msg: "Votre heure est mal choisi.",
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white);
      } else {
        setState(() {
          hourReservation = '${time.hour}h:${time.minute}min';
        });
      }
    }
    return null;
  }

  Future<TimeOfDay> giveYourReservationDay() async {
    DateTime date = await showDatePicker(
        cancelText: "Annuler",
        confirmText: 'Ok',
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2030, 12, 31));
    if (date != null) {
      if (date.day > DateTime.now().day + 3) {
        Fluttertoast.showToast(
            msg: "Le delai de livraison est trop long",
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white);
      } else {
        setState(() {
          reservationDayChoice = date;
          reservationDay =
          "${DateFormat.MMMMEEEEd('fr_FR').format(DateTime(date.year, date.month, date.day))}";
        });
      }
    }
    return null;
  }
}
