import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth/splashscrean.dart';

//my import

//AIzaSyBbJAjeoK9kTMHz4TpaQDAvlpNko42Ib84

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
 try {
    OneSignal.shared.init('a0fb69a4-4f28-4eee-ad25-30bf5707bcd4');
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
    OSPermissionSubscriptionState state =
        await OneSignal.shared.getPermissionSubscriptionState();
    print('MAIN PAGE ${state.subscriptionStatus.userId}');
    OneSignal.shared.setNotificationReceivedHandler((notification) {
      notification.jsonRepresentation().replaceAll("\\n", "\n");
    });
  } catch (e) {
    print('ONE SIGNAL ERROR IN MAIN $e');
  }

  //var initializationSettingsAndroid = AndroidInitializationSettings('taxsecurelogosc');
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
/*  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        print('id: $id, title: $title');
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });*/

}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return AppCycleLife(
      child:  MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Gaz',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          //SplashScreenPage()
          home: FutureBuilder(
              //[firebase_core/cloud_firestore] InitializeApp Error When Hot Restart
              future: _initialization,
              builder: (context, snapshot) {
                // Check for errors
                if (snapshot.hasError) {
                  print('FB ERROR ${snapshot.hasError}');
                  return Scaffold(
                      backgroundColor: Colors.white,
                      body: Center(
                        child: Text('Tratement en cours...'),
                      ));
                }

                // Once complete, show your application
                if (snapshot.connectionState == ConnectionState.done) {
                  print("FIREBASE INITIALIZE APP COMPLETED");
                  return SplashScreenPage();
                }
                return Scaffold(
                  backgroundColor: Colors.teal,
                  appBar: AppBar(
                    leading: Text(''),
                    elevation: 0.0,
                    backgroundColor: Colors.teal,
                  ),
                  body: Center(
                      child: Text('Veuillez patientez...',
                          style: TextStyle(color: Colors.white))),
                );
              }),
        ),
    );
  }
}

class AppCycleLife extends StatefulWidget {
  final Widget child;

  const AppCycleLife({Key key, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AppCycleLifeManagement();
}

class AppCycleLifeManagement extends State<AppCycleLife>
    with WidgetsBindingObserver {
  @override
  void initState() {
    oneSignalConfig();
    super.initState();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print('RESUMED');
        OneSignal.shared.setNotificationReceivedHandler((notification) {
          notification.jsonRepresentation().replaceAll("\\n", "\n");
        });
        break;
      case AppLifecycleState.inactive:
        print('INACTIVE');
        OneSignal.shared.setNotificationReceivedHandler((notification) {
          notification.jsonRepresentation().replaceAll("\\n", "\n");
        });
        break;
      case AppLifecycleState.paused:
        print('PAUSED');
        OneSignal.shared.setNotificationReceivedHandler((notification) {
          notification.jsonRepresentation().replaceAll("\\n", "\n");
        });
        break;
      case AppLifecycleState.detached:
        print('DETACHED');
        OneSignal.shared.setNotificationReceivedHandler((notification) {
          notification.jsonRepresentation().replaceAll("\\n", "\n");
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }


  void oneSignalConfig() async {
 OneSignal.shared.init('a0fb69a4-4f28-4eee-ad25-30bf5707bcd4');
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    OSPermissionSubscriptionState state =
    await OneSignal.shared.getPermissionSubscriptionState();
    OneSignal.shared.getPermissionSubscriptionState().then((value){
      print('MAIN P ${value.subscriptionStatus.userId}');
    }).catchError((er) => print('$er'));
    print('MAIN P ${state.subscriptionStatus.userId}');
    OneSignal.shared.setNotificationReceivedHandler((notification) {
      return notification.jsonRepresentation().replaceAll("\\n", "\n");
    });
  }
}
