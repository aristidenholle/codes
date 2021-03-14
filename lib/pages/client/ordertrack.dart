import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_transition/flutter_page_transition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gzapp/pages/client/historic.dart';

class OrderTrackPage extends StatefulWidget {
  final Map<String, List> gzList;
  final String userIdPlayer;

  const OrderTrackPage({Key key, this.gzList, this.userIdPlayer}) : super(key: key);
  @override
  _OrderTrackPageState createState() => _OrderTrackPageState();
}

class _OrderTrackPageState extends State<OrderTrackPage> with TickerProviderStateMixin{

  @override
  void initState() {
    print("Track Page ${widget.gzList}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Votre commande'),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.history,color: Colors.white), onPressed: (){
            Navigator.push(
                context, PageTransition(
                child: HistoricPage(
                  playerId: widget.userIdPlayer,
                    gzsList: widget.gzList),
                type: PageTransitionType.fadeIn,
                duration: Duration(milliseconds: 500)
            ));
          })
        ],
      ),

      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid)
              .collection("reservation").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(""),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: SpinKitPulse(
                  color: Colors.green,
                  controller: AnimationController(vsync:
                  this, duration: Duration(milliseconds: 2000)),
                ),
              );
            }else if(snapshot.data.docs.length == 0){
              return Center(
                child: Text("Vous n'avez aucune commande"),
              );
            }

            //print('${snapshot.data.docs.first.data()['order']}');
            //print(mp.map((key, value) =>  MapEntry(key, value)));
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, i){
                return Card(
                  color: (snapshot.data.docs[i].data()['confirmed'] != null && snapshot.data.docs[i].data()['confirmed'] == 'yes')
                  ? Colors.green[200]: Colors.white,
                  child: ExpansionTile(
                      title: !(snapshot.data.docs[i].data()['confirmed'] != null && snapshot.data.docs[i].data()['confirmed'] == 'yes')
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Confirmée'),
                          Padding(
                            padding: const EdgeInsets.only(left: 35),
                            child: InkWell(
                              onTap: (){
                                Fluttertoast.showToast(
                                  backgroundColor: Colors.blueGrey,
                                    msg: 'Veuillez taper deux fois pour supprimer!');
                              },
                                onDoubleTap: (){
                                  List orderId  = [];
                                  snapshot.data.docs[i].data()['order'].keys.toList().forEach((order){
                                    orderId.add(snapshot.data.docs[i].data()['order'][order][4]);
                                  });
                                  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid)
                                      .collection("Historic")
                                      .doc('${orderId.first}').set({
                                    //I GAME WITH MAP SAVE IN BD
                                    "orderId":FieldValue.arrayUnion(orderId),
                                    "userName" :"${snapshot.data.docs[i].data()['userName']}" ,
                                    "userLocation" :"${snapshot.data.docs[i].data()['userLocation']}" ,
                                    "phoneNumber" : "${snapshot.data.docs[i].data()['phoneNumber']}",
                                    "secondNumber": "${snapshot.data.docs[i].data()['secondNumber']}",
                                    "createAt":'${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} à ${DateTime.now().hour}h:${DateTime.now().minute}min',
                                  },SetOptions(merge: true)).catchError((err) => print('error to set $err'));

                                  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser.uid)
                                      .collection("reservation").doc(snapshot.data.docs[i].id).delete();
                                  Fluttertoast.showToast(
                                      msg:"Suppression éffectuée",
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white);
                                  print(widget.gzList);
                                },
                                child: Icon(Icons.delete, color: Colors.redAccent)),
                          )
                        ],
                      )
                          :  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                         Text('En attente de confirmation'),
                          SpinKitCircle(
                            color: Colors.teal,
                            controller: AnimationController(vsync:
                            this, duration: Duration(milliseconds: 2000)),
                          )
                        ],
                      ),

                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text('Cmd n°${snapshot.data.docs[i].data()['orderNum']}'),
                          )
                        ],
                      ),
                      Container(
                        child: Column(
                          children: buildGzChoice(order: snapshot.data.docs[i].data()['order']),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          }
        ),
      ),
    );
  }

  List<Widget> buildGzChoice({Map<String, dynamic> order }){
    List<Widget> lgz = [];
    for(var i = 0; i < order.keys.length;  i++){
      Widget g = Container(
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CachedNetworkImage(
              imageBuilder: (context, imageProvider) =>
                  Container(
                    height: 60,
                    width: 70,
                    decoration: BoxDecoration(
                      //border:Border.all(width: 1, color: Color.fromRGBO(14,47,68,1)),
                      image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover),
                    ),
                  ),

              imageUrl: '${order[order.keys.toList()[i]][1]}',
              progressIndicatorBuilder: (context, url, downloadProgress) {
                return Container(
                  margin: const EdgeInsets.only(left: 5.0),
                  height: 70,
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
                  height: 70,
                  child: Center(child: Icon(Icons.photo)),
                );
              },
            ),
            Container(
              child: Text('${order.keys.toList()[i]}'),
            ),
            Container(
              child: Text('${price(price: order[order.keys.toList()[i]][0])}'),
            ),
          ],
        ),
      );

      lgz.add(g);
    }

    return lgz;
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
}
