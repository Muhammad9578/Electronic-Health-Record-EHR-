import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:platform_channel/platform_channel.dart';

class SecondScreen extends StatelessWidget {
  static const platform = MethodChannel('samples.flutter.dev/battery');

  void goToThirdScreen() async {
    try {
      // Invoke method to open third screen in Android
      // await PlatformChannel.invokeMethod('openThirdScreen');
      final result = await platform.invokeMethod('openThirdScreen');
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Second Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your Age'),
            ElevatedButton(
              onPressed: () async {
                await platform.invokeMethod('openThirdScreen');
                print('Method invoked successfully');
              },
              child: Text('Move to Android 1'),
            )
          ],
        ),
      ),
    );
  }
}
