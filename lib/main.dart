import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'ads/ad_state.dart';
import 'ads/banner_ad.dart';
import 'ads/banner_ad_customised.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);
  runApp(Provider.value(
    value: adState,
    builder: (context, child) => MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Banner Ad Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Adaptive Banner Ad'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SpeedDial(
        //marginRight: 18, //FIXME check migration
        //marginBottom: 20, //FIXME check migration
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
              child: Icon(Icons.add_location,),
              backgroundColor: Colors.lightBlue,
              label: 'Add GPS Report',
              labelStyle: TextStyle(fontSize: 18.0),
          ),
          SpeedDialChild(
              child: Icon(Icons.add,
                  color: Colors.black),
              backgroundColor: Colors.amber,
              label: 'Add Placed Report',
              labelStyle: TextStyle(fontSize: 18.0),
              ),
          SpeedDialChild(
            child: Icon(
              Icons.my_location,
              color: Colors.black,
            ),
            backgroundColor: Colors.white,
            label: 'Center',
            labelStyle: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
      body:
      Column(
        children: [BannerAD(), //Container(), //BannerAD(),
          Expanded(child:Stack(children: [Container(),Container()])),
        ],
      ),
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   children: <Widget>[
        //     BannerAD(),
        //   ],
        // ),
      //), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
