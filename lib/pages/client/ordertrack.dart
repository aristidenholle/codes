import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OrderTrackPage extends StatefulWidget {
  @override
  _OrderTrackPageState createState() => _OrderTrackPageState();
}

class _OrderTrackPageState extends State<OrderTrackPage> with TickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text('Votre commande'),
        centerTitle: true,
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
                child: Text("Aucun commande"),
              );
            }

            //print('${snapshot.data.docs.first.data()['order']}');
            Map<String, dynamic> order = snapshot.data.docs.first.data()['order'];
            //print(mp.map((key, value) =>  MapEntry(key, value)));
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, i){
                return Card(
                  child: ExpansionTile(
                      title: (snapshot.data.docs[i].data()['confirmed'] != null && snapshot.data.docs[i].data()['confirmed'] == null)
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Confirmée'),
                          Icon(Icons.remove_done, color: Colors.white)
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
                          children: buildGzChoice(order: order),
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
            Container(
              child: Text('${order[order.keys.toList()[i]][1]}'),
            ),
            Container(
              child: Text('${order.keys.toList()[i]}'),
            ),
            Container(
              child: Text('${order[order.keys.toList()[i]][0]}'),
            ),
          ],
        ),
      );

      lgz.add(g);
    }

    return lgz;
  }
}
