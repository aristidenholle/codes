import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:device_info/device_info.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gzapp/pages/seller/sellerpage.dart';
import 'package:gzapp/pages/client/clienthomepage.dart';
import 'package:intent/intent.dart' as intent;
import 'package:intent/action.dart' as action;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'package:phone_number/phone_number.dart';
import 'dart:async';


class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  String pId = '';
  String pass = 'Ar93maXw77#MPfkg458kf4@@HRnPoLMkiyu';
  String mailer = '@gmail.com';

  bool client = false;
  bool personalDriver = false;
  bool seller = false;

  static List<String> userList = ['Client', 'Seller'];
  List<DropdownMenuItem<String>> drop = userList.map((e) => DropdownMenuItem(child: Text('$e'), value: e)).toList();
  String userChosen;
  bool userNotChosen = false;

  bool hideActionButton = false;
  bool splashUserConnectedVerification = true;
  bool showLoginButton = false;
  bool hideDialIcon = false;

  StreamController<bool> loginButtonState = StreamController<bool>.broadcast();
  TextEditingController passeController = new TextEditingController();
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  ScrollController scrollController;
  bool dialVisible = true;

  //TO USER WITCH WANT TO SUBSCRIBE
  StreamController<bool> changeState = StreamController<bool>.broadcast();
  PhoneNumber phoneNumber = new PhoneNumber();
  TextEditingController nameController = new TextEditingController();
  TextEditingController numberController = new TextEditingController();
  TextEditingController secondNumberController = new TextEditingController();
  TextEditingController requestController = new TextEditingController();


  GlobalKey<FormState> formKeyRegister = new GlobalKey<FormState>();
  bool hideNameLabelText = false;
  bool hideFirstNumLabelText = false;
  bool hideSecondNumLabelText = false;
  bool hideRequestPaLabelText = false;

/*
  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }
*/

  checkUserConnexion() async {
    setState(() {
      splashUserConnectedVerification = true;
    });
    if (FirebaseAuth.instance.currentUser != null) {
      print('USER CONNECTED');
      //USED TO AVOID Failed assertion: line 1995 pos 12: '!_debugLocked': I/flutter (24830): is not true.
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
          return ClientHomePage();
        }));
      });
    } else {
      print('USER NOT CONNECTED');
      setState(() {
          splashUserConnectedVerification = false;
        });
      return;
    }
  }

  @override
  void initState() {/*
    scrollController = ScrollController()
      ..addListener(() {
        setDialVisible(scrollController.position.userScrollDirection ==
            ScrollDirection.forward);
      });*/
    oneSignalConfig();
    super.initState();
    checkUserConnexion();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.teal,
        appBar: AppBar(
          leading: Text(''),
          elevation: 0.0,
          backgroundColor: Colors.teal,
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/giphygzempty.gif')
                )
              ),
            ),
            Center(
              child: Visibility(
                  visible: splashUserConnectedVerification,
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white))),
            )
          ],
        ),

        floatingActionButton:   showLoginButton == true ?
        CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)):
        Container(
          child: splashUserConnectedVerification ? Text('') : TextButton(
              onPressed: () {
                setState(() {
                  showLoginButton = true;
                });
                signUorLogin();
          },
          child: Text('Charger mon gaz', style: TextStyle(color: Colors.white))),
        ),
      ),
    );
  }


signUorLogin() async{
    DeviceInfoPlugin deviceInfoPlugin =  DeviceInfoPlugin();
    if(Platform.isAndroid) {
      AndroidDeviceInfo deviceInfo = await deviceInfoPlugin.androidInfo;
      print('D id ${deviceInfo.androidId}');
      FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: "${deviceInfo.androidId}@gmail.com",
          password: pass)
          .timeout(Duration(seconds: 15), onTimeout: timeOut)
          .then((value) {
      print('U id ${value.user.uid}');
        Navigator.pushReplacement(context, PageTransition(
            child: new ClientHomePage(),
            type: PageTransitionType.fadeIn,
            duration: Duration(milliseconds: 500)));
      }).catchError((authError){
        print('authError: $authError');
        if (authError.toString().contains('email-already-in-use')) {
          FirebaseAuth.instance.signInWithEmailAndPassword(
              email: "${deviceInfo.androidId}@gmail.com", password: pass)
              .timeout(Duration(seconds: 15), onTimeout: timeOut)
          .then((value){
            Navigator.pushReplacement(context,
                PageTransition(
                child: new ClientHomePage(),
                type: PageTransitionType.fadeIn,
                duration: Duration(milliseconds: 500)));
          }).catchError((signInError) {
            if (signInError.toString().contains('network-request-failed')) {
              setState(() {
                showLoginButton = false;
              });
              getErrorMsg(
                msg: 'Vérifiez votre connexion internet.',
              );
            }
          });
        } else if (authError.toString().contains('network-request-failed')) {
          setState(() {
            splashUserConnectedVerification = false;
            showLoginButton = false;
          });
          reset();
          getErrorMsg(
            msg: 'Vérifiez votre connexion internet.',
          );
        }else{
          setState(() {
            showLoginButton = false;
          });
          getErrorMsg(
            msg: 'Vérifiez votre connexion internet.',
          );
        }
      });
    }
  }

/*  Future login() async {
    return showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              height: 350,
              child: StreamBuilder<bool>(
                  stream: loginButtonState.stream,
                  builder: (context, snapshot) {
                    return SingleChildScrollView(
                      child: StatefulBuilder(
                          builder: (context, StateSetter setState) {
                        return Form(
                          key: formKey,
                          child: AlertDialog(
                            title: Text(
                                'Connexion ${snapshot.data == true ? 'en cours...' : ''}'),
                            content: (snapshot.data == true)
                                ? Container(
                                    height: 60,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.green)),
                                    ),
                                  )
                                : Container(
                                  margin: EdgeInsets.only(top: 10.0),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(12.0)),
                                  //height: 150.0,
                                  child: Column(
                                    children: [
                                      DropdownButton(
                                          items: drop,
                                          value: userChosen,
                                          iconEnabledColor: userNotChosen ? Colors.red: Colors.black87,
                                          hint: Text(userChosen!=null ? '$userChosen': 'Vous êtes?',
                                              style: TextStyle(color: userNotChosen ? Colors.red: Colors.black87)),
                                          onChanged: (String value){
                                            if(value == 'Client'){
                                              print(value);
                                              setState(() {
                                                client = true;
                                                seller = false;
                                                userNotChosen = false;
                                              });
                                            }
                                            else if(value == 'Seller'){
                                              print(value);
                                              setState(() {
                                                client = false;
                                                seller = true;
                                                userNotChosen = false;
                                              });
                                            }
                                            setState((){
                                              userChosen = value;
                                            });
                                          }),
                                      Theme(
                                        data: ThemeData(
                                            fontFamily: 'AppleGaramond',
                                            primaryColor: Colors.teal,
                                            primaryColorDark: Colors.white),
                                        child: TextFormField(
                                          validator: codeValidator,
                                          controller: passeController,
                                          smartDashesType:
                                          SmartDashesType.disabled,
                                          keyboardType: TextInputType.number,
                                          cursorColor: Colors.green,
                                          style: TextStyle(color: Colors.green),
                                          decoration: InputDecoration(
                                              enabledBorder:
                                              new UnderlineInputBorder(
                                                  borderSide: new BorderSide(
                                                      color:
                                                      Colors.green[300],
                                                      width: 3.0)),
                                              labelText: "Mot de passe",
                                              labelStyle: TextStyle(
                                                  color: Colors.green[300],
                                                  fontSize: 17)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                            actions: [
                              TextButton(
                                  onPressed: (snapshot.data == true)
                                      ? null
                                      : () {

                                          Navigator.pop(context);
                                          passeController.clear();
                                          setState(() {
                                            client = false;
                                            seller = false;
                                            userNotChosen =false;
                                            userChosen = null;
                                          });
                                        },
                                  child: Text('Annuler',
                                      style: TextStyle(color: Colors.grey))),
                              TextButton(
                                child: Text('Se connecter',
                                    style: TextStyle(color: Colors.green)),
                                onPressed: (snapshot.data == true)
                                    ? null
                                    : () {
                                        if (formKey.currentState.validate() && userChosen != null) {
                                          loginButtonState.sink.add(true);
                                          setState(() {
                                            hideDialIcon = true;
                                          });
                                          print('Client:$client');
                                          print('TaxiDriver:$seller');
                                          return signIn(
                                              pwd: pass,
                                              mail: passeController.text + mailer);
                                        }else if(userChosen == null){
                                          setState(() {
                                            userNotChosen = true;
                                          });
                                          Fluttertoast.showToast(
                                              msg: "Identifiez-vous",
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white);
                                        }
                                          else {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Veuillez définir votre code d'accès",
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white);
                                        }
                                      },
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  }),
            ),
          ),
        );
      },
      animationType: DialogTransitionType.slideFromBottomFade,
      curve: Curves.fastOutSlowIn,
      duration: Duration(seconds: 1),
    );
  }*/

  serviceCall() async {
    return intent.Intent()
      ..setAction(action.Action.ACTION_DIAL)
      ..setData(Uri(scheme: 'tel', path: '+2250153441343'))
      ..startActivity().catchError((e) => print(e));
  }



/*  signIn({String mail, String pwd}) async {
    print('LOGIN PART');
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: mail, password: pwd)
        .then((value) {
          if (value.user != null) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(value?.user?.uid)
                .get()
                .then((user) {
              if(client == true && user.data()['type'].toString() == 'client'){
                Navigator.pop(context); //close the connexion dialog
                print('THIS USER IS CLIENT');
                Navigator.pushReplacement(context, PageTransition(
                    child: new ClientHomePage(
                    ),
                    type: PageTransitionType.fadeIn,
                    duration: Duration(milliseconds: 500)));
                reset();
              }else if(personalDriver == true && user.data()['type'].toString() == 'seller'){
                Navigator.pop(context);
                print('THIS USER IS SELLER');
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                        child: SellerPage(),
                        type: PageTransitionType.rippleRightUp,
                        duration: Duration(milliseconds: 500)));//close the connexion dialog
                reset();
              }else{
                setState(() {
                  hideDialIcon = false;
                });
                loginButtonState.sink.add(false);
                Fluttertoast.showToast(
                    msg: "Veuillez bien définir vos informations.",
                    backgroundColor: Colors.red,
                    textColor: Colors.white);
              }
            }).catchError((err) {
              return getErrorMsg(
                  msg: 'Impossible de lire vos données, vérifier vos données internet svp.',
              );
            });

          } else {
            reset();
            getErrorMsg(
              msg: "Un problème de connexion est survenue, vérifier vos données internet svp.",
            );
          }
        })
        .timeout(Duration(seconds: 15), onTimeout: timeOut)
        .catchError((error) {
          reset();
          print('ERRORS: ${error.toString()}');
          if (error.toString().contains('network-request-failed')) {
            reset();
            getErrorMsg(
              msg: 'Vérifiez votre connexion internet, il semble que vous êtes hors connexion',
            );
          } else if (error.toString().contains('wrong-password')) {
            reset();
            Fluttertoast.showToast(
                msg: "Désolé votre code d'accès est invalide",
                backgroundColor: Colors.red,
                textColor: Colors.white);
          } else if (error.toString().contains('user-disabled')) {
            *//*Fluttertoast.showToast(msg: 'Désolé votre souscription a expiré!',
              backgroundColor: Colors.red,textColor: Colors.white);*//*
            reset();
            getErrorMsg(
              msg: 'Désolé votre souscription a expirée, pensez à souscrire à nouveau!',
            );
          } else if (error.toString().contains('user-not-found')) {
            reset();
            *//*Fluttertoast.showToast(msg: 'Désolé vous n\'avez pas de compte.',
              backgroundColor: Colors.red,textColor: Colors.white);*//*
            return getErrorMsg(
              msg: "Désolé ce code n'est pas associé à un compte.",
            );
          }
        });
  }*/



 reset(){
    setState(() {
      passeController.clear();
      hideDialIcon = false;
      splashUserConnectedVerification = false;
      client = false;
      seller = false;
      userChosen = null;
    });

    loginButtonState.sink.add(false);
  }

  getErrorMsg({String msg}){
    reset();
    Fluttertoast.showToast(
        msg: "$msg",
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  Future<Null> timeOut() {
    setState(() {
      showLoginButton = false;
    });
    return Fluttertoast.showToast(
            msg: "Vérifiez votre connexion internet",
            textColor: Colors.white,
            backgroundColor: Colors.red,
            gravity: ToastGravity.BOTTOM);
  }

  @override
  void dispose() {
    super.dispose();
    loginButtonState.close();
    changeState.close();
  }



/*  Future saveUserRequestToSubscribe(){
    return showDialog(
        context: context, builder: (context){
      return WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: FadeInUp(
            duration: Duration(seconds: 1),
            child: Container(
              height: 500,
              child: StreamBuilder(
                  stream: loginButtonState.stream,
                  builder: (context, snap){
                    return snap.data == true ?
                    AlertDialog(
                      content: Container(
                        height: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Envoie de votre demande en cours...",style: TextStyle(fontSize: 18),textAlign: TextAlign.center),
                            Padding(
                              padding: const EdgeInsets.only(top: 70.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        :
                    SingleChildScrollView(
                      child: StatefulBuilder(
                          builder: (context, StateSetter setState) {
                            return AlertDialog(
                              title: Text("Demande d'inscription"),
                              content: Form(
                                key: formKeyRegister,
                                child: Column(
                                  children: [
                                    Theme(
                                      data: ThemeData(
                                          primaryColor: Colors.grey,
                                          primaryColorDark: Colors.white),
                                      child: Container(
                                        height: 60,
                                        child: TextFormField(
                                          controller: nameController,
                                          validator: (String value) {
                                            RegExp regExp = RegExp(r'(^[a-zA-Z àáâãäåçèéêëìíîïðòóôõöœùúûüýÿ-]*$)');
                                            if (value.length == 0) {
                                              setState((){
                                                hideNameLabelText = true;
                                              });
                                              return 'Votre nom est réquis';
                                            }else if (!regExp.hasMatch(value)) {
                                              setState((){
                                                hideNameLabelText = true;
                                              });
                                              return 'Saisie du nom invalide';
                                            }
                                            return null;
                                          },
                                          smartDashesType:
                                          SmartDashesType.disabled,
                                          keyboardType: TextInputType.text,
                                          cursorColor: Colors.grey,
                                          style: TextStyle(color: Colors.black),
                                          decoration: InputDecoration(
                                              enabledBorder:
                                              new UnderlineInputBorder(
                                                  borderSide: new BorderSide(
                                                      color:
                                                      Colors.grey)),
                                              labelText: "${ hideNameLabelText == true ? "" : "Nom et prenom"}",
                                              labelStyle: TextStyle(
                                                  fontSize: 16)),
                                        ),
                                      ),
                                    ),
                                    Theme(
                                      data: ThemeData(
                                          primaryColor: Colors.grey,
                                          primaryColorDark: Colors.white),
                                      child: Container(
                                        height: 60,
                                        child: TextFormField(
                                          validator: (String phone) {
                                            String pattern = r'(^[0-9]*$)';
                                            RegExp regExp = new RegExp(pattern);
                                            if (phone.length == 0) {
                                              setState((){
                                                hideFirstNumLabelText = true;
                                              });
                                              return 'Contact 1 réquis';
                                            }else if (phone.length != 8) {
                                              setState((){
                                                hideFirstNumLabelText = true;
                                              });
                                              return 'Entrer nn numéro correct';
                                            }
                                            else if (!regExp.hasMatch(phone)) {
                                              setState((){
                                                hideFirstNumLabelText = true;
                                              });
                                              return 'Saisie contact 1 est invalide';
                                            }
                                            return null;
                                          },
                                          controller: numberController,
                                          smartDashesType:
                                          SmartDashesType.disabled,
                                          keyboardType: TextInputType.number,
                                          cursorColor: Colors.grey,
                                          style: TextStyle(color: Colors.black),
                                          decoration: InputDecoration(
                                              enabledBorder:
                                              new UnderlineInputBorder(
                                                  borderSide: new BorderSide(
                                                      color:
                                                      Colors.grey)),
                                              labelText: "${ hideFirstNumLabelText == true ? "" : "Numéro de téléphone"}",
                                              labelStyle: TextStyle(
                                                  fontSize: 16)),
                                        ),
                                      ),
                                    ),
                                    Theme(
                                      data: ThemeData(
                                          primaryColor: Colors.grey,
                                          primaryColorDark: Colors.white),
                                      child: Container(
                                        height: 60,
                                        child: TextFormField(
                                          validator: (String phone) {
                                            String pattern = r'(^[0-9]*$)';
                                            RegExp regExp = new RegExp(pattern);
                                            if (!regExp.hasMatch(phone)) {
                                              setState((){
                                                hideSecondNumLabelText = true;
                                              });
                                              return 'Saisie contact 2 est invalide';
                                            }
                                            return null;
                                          },
                                          controller: secondNumberController,
                                          smartDashesType:
                                          SmartDashesType.disabled,
                                          keyboardType: TextInputType.number,
                                          cursorColor: Colors.grey,
                                          style: TextStyle(color: Colors.black),
                                          decoration: InputDecoration(
                                              enabledBorder:
                                              new UnderlineInputBorder(
                                                  borderSide: new BorderSide(
                                                      color:
                                                      Colors.grey)),
                                              labelText: "${hideSecondNumLabelText == true ? "" : "Second contact"}",
                                              labelStyle: TextStyle(
                                                  fontSize: 16)),
                                        ),
                                      ),
                                    ),

                                    Theme(
                                      data: ThemeData(
                                          primaryColor: Colors.grey,
                                          primaryColorDark: Colors.white),
                                      child: Container(
                                        height: 80,
                                        child: TextFormField(
                                          maxLines: 5,
                                          readOnly: true,
                                          controller: requestController..text = "Je souhaite souscrire à votre service",
                                          *//*validator: (String value) {
                                            RegExp regExp = RegExp(r'(^[a-zA-Z àáâãäåçèéêëìíîïðòóôõöœùúûüýÿ-]*$)');
                                            if (value.length == 0) {
                                              setState((){
                                                hideRequestPaLabelText = true;
                                              });
                                              return 'Votre demande est réquis';
                                            }else if (!regExp.hasMatch(value)) {
                                              setState((){
                                                hideRequestPaLabelText = true;
                                              });
                                              return 'Saisie invalide';
                                            }
                                            return null;
                                          },*//*
                                          smartDashesType:
                                          SmartDashesType.disabled,
                                          keyboardType: TextInputType.text,
                                          cursorColor: Colors.grey,
                                          style: TextStyle(color: Colors.black),
                                          decoration: InputDecoration(
                                              enabledBorder:
                                              new UnderlineInputBorder(
                                                  borderSide: new BorderSide(
                                                      color:
                                                      Colors.grey)),
                                              labelText: "${ hideRequestPaLabelText == true ? "" : "Demande"}",
                                              labelStyle: TextStyle(
                                                  fontSize: 16)),
                                        ),
                                      ),
                                    ),
                                  ],


                                ),
                              ),


                              actions: [
                                TextButton(
                                    onPressed: (snap.data == true)
                                        ? null
                                        : () {

                                      Navigator.pop(context);
                                      cleanVariables();
                                      resetVar();
                                    },
                                    child: Text('Annuler',
                                        style: TextStyle(color: Colors.grey))),
                                TextButton(
                                  child: Text("Envoyer",
                                      style: TextStyle(color: Colors.green,fontSize: 18)),
                                  onPressed: (snap.data == true)
                                      ? null
                                      : () async{
                                    if (formKeyRegister.currentState.validate()) {
                                      if(secondNumberController.text.length > 0){
                                        print('TWO NUMBER GIVED');
                                        await phoneNumber.parse(numberController.text, region: 'CI').then((value) async{
                                          await phoneNumber.parse(secondNumberController.text, region: 'CI')
                                              .then((value){
                                            loginButtonState.sink.add(true);
                                            return saveRequest(
                                                requestText: requestController.text,
                                                firstNumber: numberController.text,
                                                secondNumber: secondNumberController.text,
                                                fullName: nameController.text
                                            );
                                          }).catchError((err){
                                            Fluttertoast.showToast(
                                                msg: "Le second numéro est invalide",
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white);
                                          });
                                        }).catchError((err){
                                          Fluttertoast.showToast(
                                              msg: "Le prémier numéro est invalide",
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white);
                                        });
                                      }else{
                                        print('ONE NUMBER GIVED');
                                        await phoneNumber.parse(numberController.text, region: 'CI').then((value){
                                          loginButtonState.sink.add(true);
                                          return saveRequest(
                                              requestText: requestController.text,
                                              firstNumber: numberController.text,
                                              secondNumber: secondNumberController.text,
                                              fullName: nameController.text
                                          );
                                        }).catchError((err){
                                          Fluttertoast.showToast(
                                              msg: "Le prémier numéro est invalide",
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white);
                                        });
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                          "Veuillez définir tous les champs",
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white);
                                    }
                                  },
                                ),
                              ],
                            );
                          }
                      ),
                    );
                  }),
            ),
          ),
        ),
      );
    });
  }*/

/*  saveRequest({String fullName, String firstNumber, String secondNumber, String requestText}) async{
    var url = 'https://taxfuncs.herokuapp.com/saveUserRequest';
    var data = {
      'id':"$pId",
      'date':
      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} à ${DateTime.now().hour}h:${DateTime.now().minute}min',
      "createAt": "${DateTime.now().millisecondsSinceEpoch}",
      "fullName" : "$fullName",
      "firstNumber":"+225$firstNumber",
      "secondNumber": "${secondNumber.isEmpty ? "" : "+225$secondNumber"}",
      "requestReason": '$requestText'
    };
    http.post(url,body: data).then((value){
      print('reasonPhrase: ${value.reasonPhrase}');
      print('statusCode: ${value.statusCode}');
      print('Response body: ${value.body}');
      print('Response body: ${value.body.contains('The email address is already in use')}');
      if(value.statusCode == 201){
        loginButtonState.sink.add(false);
        Navigator.pop(context);
        resetVar();
        cleanVariables();
        Fluttertoast.showToast(
            msg:
            "Nous avons bien reçu votre demande!",
            backgroundColor: Colors.green,
            textColor: Colors.white);

      }else if(value.statusCode == 503){
        loginButtonState.sink.add(false);
        Navigator.pop(context);
        resetVar();
        cleanVariables();
        Fluttertoast.showToast(
            msg:"Erreur, verifiez vos données internet svp.",
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }else{
        loginButtonState.sink.add(false);
        Navigator.pop(context);
        resetVar();
        cleanVariables();
        Fluttertoast.showToast(
            msg:"Désolé un probleme est survenue.",
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    }).catchError((err){
      print("ERROR FOUND $err");
      loginButtonState.sink.add(false);
      Navigator.pop(context);
      resetVar();
      cleanVariables();
      Fluttertoast.showToast(
          msg:"Désolé un probleme est survenue",
          backgroundColor: Colors.red,
          textColor: Colors.white);
    });
  }*/



  cleanVariables(){
    nameController.clear();
    passeController.clear();
    numberController.clear();
    secondNumberController.clear();
  }

  resetVar(){
    setState((){
      hideNameLabelText = false;
      hideFirstNumLabelText = false;
      hideSecondNumLabelText = false;
      hideRequestPaLabelText = false;
    });
  }

void oneSignalConfig() async {
    OneSignal.shared.init('2921221c-ad43-4310-a5c0-83db0ab952b3');
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    OSPermissionSubscriptionState state =
    await OneSignal.shared.getPermissionSubscriptionState();
    OneSignal.shared.getPermissionSubscriptionState().then((value){
      print('SPLASH P ${value.subscriptionStatus.userId}');
    }).catchError((er) => print('$er'));
    print('SPLASH PAGE ${state.subscriptionStatus.userId}');
    setState(() {
      pId = state.subscriptionStatus.userId;
    });
    OneSignal.shared.setNotificationReceivedHandler((notification) {
      return notification.jsonRepresentation().replaceAll("\\n", "\n");
    });
  }

  String codeValidator(String code) {
    String pattern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(pattern);
    if (code.length == 0) {
      return 'Ce champ est réquis';
    } else if (code.length != 5) {
      return 'Entrez un code de 5 chiffres';
    } else if (!regExp.hasMatch(code)) {
      return 'Votre saisie est invalide';
    }
    return null;
  }


}
