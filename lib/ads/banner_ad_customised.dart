import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'ad_state.dart';
import 'anchored_adaptive_banner_adSize.dart';

class BannerADCustomised extends StatefulWidget {
  const BannerADCustomised({Key? key}) : super(key: key);

  @override
  _BannerADCustomisedState createState() => _BannerADCustomisedState();
}

class _BannerADCustomisedState extends State<BannerADCustomised> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  BannerAd? banner;

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  AnchoredAdaptiveBannerAdSize? size;

  String? now;
  Timer? everySecond;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // sets first value
    now = DateTime.now().second.toString();

    // defines a timer to update ad ui according to latest adStatus value from AdState class
    // this timer is set to setState every 5 seconds
    // we are using it to hide ad loading status if ad fails to load due to any case other than internet
    everySecond = Timer.periodic(Duration(seconds: 5), (Timer t) {
      if (mounted) {
        setState(() {
          now = DateTime.now().second.toString();
        });
      }
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _connectionStatus = result;
      if (banner != null) {
        banner!.load();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((value) async {
      size = await anchoredAdaptiveBannerAdSize(context);
      setState(() {
        if (adState.bannerAdUnitId != null) {
          banner = BannerAd(
            listener: adState.adListener,
            adUnitId: adState.bannerAdUnitId!,
            request: AdRequest(),
            size: size!,
          )..load();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Connection Status: ${_connectionStatus.toString()}');
    return banner == null
        ? SizedBox()
        : _connectionStatus == ConnectivityResult.none
            ? Container(
                height: AdSize.banner.height.toDouble() + 10,
                width: size!.width.toDouble(),
                color: Colors.grey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'To support the app please connect to internet.',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Container(
                color: AdState.adStatus ? Colors.grey : Colors.transparent,
                width: AdState.adStatus ? size!.width.toDouble() : 0,
                height: AdState.adStatus ? size!.height.toDouble() : 0,
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AdState.adStatus
                                ? Expanded(
                                    child: Text(
                                      'Ad loading...\nThanks for your support',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                    AdState.adStatus
                        ? AdWidget(
                            ad: banner!,
                          )
                        : Container(),
                  ],
                ),
              );
  }
}
