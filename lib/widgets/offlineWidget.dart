import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';

import '../utils/tools.dart';

class OfflineWidget extends StatefulWidget {
  final Widget onlineWidget;
  //final bool isOfflineWidgetWithScaffold;
  const OfflineWidget({
    super.key,
    required this.onlineWidget,
    //this.isOfflineWidgetWithScaffold = false,
  });

  @override
  State<OfflineWidget> createState() => _OfflineWidgetState();
}

class _OfflineWidgetState extends State<OfflineWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool isConnected = connectivity != ConnectivityResult.none;

          if (isConnected) {
            return widget.onlineWidget;
          } else {
            Widget offlineWidget = Center(
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'لا يوجد لديك اتصال بالإنترنت',
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600),
                    ),
                    Image.asset('assets/no_connection.png')
                  ],
                ),
              ),
            );

            return offlineWidget;
          }
        },
        child: circularIndicator,
      ),
    );
  }
}
