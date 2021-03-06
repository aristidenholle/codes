import 'dart:async';
import 'package:animate_do/animate_do.dart ' as fade;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  bool editCityOrCommuneOrQuarter = false;
  StreamController<bool> sendState  = StreamController<bool>.broadcast();
  int gzCount = 1;
  int totalGzPrice = 0;
  int totalPrice = 0;


  _ValidateOrderPageState({this.listGzChosen});



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
          child: Column(
            children: [
              Container(
                height:  editCityOrCommuneOrQuarter == false ?  200 :  280,
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
                                    return editDialog(oldValue:
                                    (user.data.data() != null && user.data.data()["userLocation"] != null ) ?
                                    user.data.data()["userLocation"] : "", keyType: 'userLocation');

                                  }, icon: Icon( (user.data.data() != null && user.data.data()["userLocation"] != null ) ?
                              Icons.home : Icons.edit),

                                  label: Text((user.data.data() != null && user.data.data()["userLocation"] != null)  ?
                                  " ${user.data.data()["userLocation"]}" :  'Lieu de résidence')),
                            ],
                          )

                          /*Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 15),
                                child: Text("${user.data.data()["city"]} ${user.data.data()["commune"]} ${user.data.data()["quarter"]}"),
                              ),
                              IconButton(
                                  onPressed: (){
                                    setState(() {
                                      editCityOrCommuneOrQuarter = true;
                                    });
                                  },
                                  icon: Icon(Icons.edit, color: Colors.grey))
                            ],
                          )*/ : fade.FadeIn(
                            duration: Duration(milliseconds: 600),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(left: 15),
                                          child: Text("${(user.data.data() != null && user.data.data()["city"] != null ) ?
                                          user.data.data()["city"]: "Ville"} "),
                                        ),
                                        IconButton(
                                            onPressed: (){
                                              return editDialog(oldValue: (user.data.data() != null && user.data.data()["city"] != null ) ?
                                              user.data.data()["city"] : '', keyType: 'city');
                                            },
                                            icon: Icon(
                                                Icons.edit,color: Colors.grey))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(left: 15),
                                          child: Text("${(user.data.data() != null && user.data.data()["commune"] != null ) ?
                                              user.data.data()["commune"] : "Commune"}"),
                                        ),
                                        IconButton(
                                            onPressed: (){
                                              return editDialog(oldValue: (user.data.data() != null && user.data.data()["commune"] != null ) ?
                                              user.data.data()["commune"] : '', keyType: 'commune');
                                            },
                                            icon: Icon(Icons.edit,color: Colors.grey))
                                      ],
                                    ),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(left: 15),
                                      child: Text("${(user.data.data() != null && user.data.data()["quarter"] != null ) ?
                                          user.data.data()["quarter"]: "Quartier"}"),
                                    ),
                                    IconButton(
                                        onPressed: (){
                                          return editDialog(oldValue:
                                          (user.data.data() != null && user.data.data()["quarter"] != null ) ?
                                          user.data.data()["quarter"] : '', keyType: 'quarter');
                                        },
                                        icon: Icon(Icons.edit,color: Colors.grey))
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    FlatButton(onPressed: (){
                                      setState(() {
                                        editCityOrCommuneOrQuarter = false;
                                      });
                                    }, child: Text('Fermer'))
                                  ],
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
                padding: const EdgeInsets.only(top: 25),
                child: SingleChildScrollView(
                  child: Column(
                    children: buildGzChoice(),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('PRIX: ${getAllGzPrice()}frcfa'),
                      Text('Frais de livraison: 500 frcfa'),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 35),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('PRIX TOTAL: ${getAllPrice()}'),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.teal,
          height: 45,
          child: FlatButton(
              onPressed: () {
                return alertToShow(msg: "Vous confirmez votre achat?");
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
    totalPrice = price;

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
    totalGzPrice = price;

    return totalGzPrice;
  }

  List<Widget> buildGzChoice(){
    List<Widget> lgz = [];
    for(var i = 0; i < listGzChosen.keys.length;  i++){
      Widget g = Card(
        child: Container(
          height: 70,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                child: Text('${listGzChosen[listGzChosen.keys.toList()[i]][1]}'),
              ),
              Container(
                child: Text('${listGzChosen.keys.toList()[i]}'),
              ),
              Container(
                child: Text('${listGzChosen[listGzChosen.keys.toList()[i]][0]}'),
              ),

              /*Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    child: Container(
                      child: Card(
                        color:Colors.red,
                        elevation: 10.0,
                        child: Text('-',style: TextStyle(fontSize: 23.0,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center,),
                      ),
                      width: 35.0,
                      height: 35.0,
                    ),
                    onTap: (){
                      if(listGzChosen[listGzChosen.keys.toList()[i]][2] > 1){
                        setState(() {
                          int oldPrice = listGzChosen[listGzChosen.keys.toList()[i]][0];
                          listGzChosen[listGzChosen.keys.toList()[i]][2]--;
                          int newPrice  = listGzChosen[listGzChosen.keys.toList()[i]][0] - oldPrice;
                          listGzChosen[listGzChosen.keys.toList()[i]][0] = newPrice;
                        });
                      }
                    },
                  ),
                  SizedBox(width: 5.0),
                  Text("${listGzChosen[listGzChosen.keys.toList()[i]][2]}",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                  SizedBox(width: 5.0),
                  InkWell(
                    child: Container(
                      child: Card(
                        color:Colors.red,
                        elevation: 10.0,
                        child: Text('+',style: TextStyle(fontSize: 22.0,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center),
                      ),
                      width: 35.0,
                      height: 35.0,
                    ),
                    onTap: (){
                        setState(() {
                          listGzChosen[listGzChosen.keys.toList()[i]][2]++;
                          int newPrice  = listGzChosen[listGzChosen.keys.toList()[i]][0] * listGzChosen[listGzChosen.keys.toList()[i]][2];
                          listGzChosen[listGzChosen.keys.toList()[i]][0] = newPrice;
                        });
                    },
                  ),
                ],
              )*/

              updatePrice(
                  oldPrice: listGzChosen[listGzChosen.keys.toList()[i]][3],
                  countPrice: listGzChosen[listGzChosen.keys.toList()[i]][2],
                 gzs: listGzChosen[listGzChosen.keys.toList()[i]],
                key: listGzChosen.keys.toList()[i])
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
        InkWell(
          child: Container(
            child: Card(
              color:Colors.red,
              elevation: 10.0,
              child: Text('-',style: TextStyle(fontSize: 23.0,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center,),
            ),
            width: 35.0,
            height: 35.0,
          ),
          onTap: (){
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
        InkWell(
          child: Container(
            child: Card(
              color:Colors.red,
              elevation: 10.0,
              child: Text('+',style: TextStyle(fontSize: 22.0,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center),
            ),
            width: 35.0,
            height: 35.0,
          ),
          onTap: (){
            setState(() {
              int oldPrices = oldPrice;
              countPrice++;
              int newPrice  = oldPrices * countPrice;
              listGzChosen.addAll({"$key" : [newPrice, gzs[1],countPrice, oldPrice]});
              print(listGzChosen);
            });
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
                              if (phone.length == 0) {
                                return 'Contact réquis';
                              }else if (phone.length != 8) {
                                return 'Entrer un numéro correct';
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
                                editController.text != null) {
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
                                edit(value: editController.text, type: keyType);
                                Navigator.pop(context);
                              }
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
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid).update({
      '$type': (type  == "phoneNumber" || type  == "secondNumber") ? value : value.substring(0,1).toUpperCase() + value.substring(1).toLowerCase()
    }).catchError((err) => print(''));
    Fluttertoast.showToast(
        msg: "Modification effectuée",
        textColor: Colors.white,
        backgroundColor: Colors.green,
        gravity: ToastGravity.BOTTOM).catchError((er) => print('toast error'));
    editController.clear();

  }



  alertToShow({String msg}){
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
                    actions: <Widget>[FlatButton(
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
                          return saveOrder(order: listGzChosen);
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


  saveOrder({Map<String, List> order}){
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid)
        .collection("reservation")
        .doc().set({
      "orderNum": "$hashCode",
       'order': listGzChosen,
      "totalPrice": totalPrice,
      "userName" :"${widget.userName}" ,
      "userCity" :"${widget.userCity}" ,
      "userCommune" :"${widget.userCommune}" ,
      "userQuarter" :"${widget.userQuarter}" ,
      "phoneNumber" : "${widget.userFirstNumber}",
      "secondNumber": "${widget.userSecondNumber}"
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
}
