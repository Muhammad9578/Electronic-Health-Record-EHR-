import 'package:flutter/material.dart';

import '../../core/themes/themes.dart';

class MyScaffold extends StatelessWidget {
  final String? appBarTitle;
  final bool showAppbar;
  final Widget body;
  final bool? centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;

  const MyScaffold(
      {super.key,
      required this.body,
      this.appBarTitle,
      this.centerTitle,
      this.actions,
      this.floatingActionButton,
      this.showAppbar = true,
      this.leading});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      body: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: showAppbar == false
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                title: appBarTitle == null
                    ? null
                    : Text(
                        appBarTitle!,
                        style: TextStyle(
                          fontSize: 19,
                          color: MyColors.black333,
                          fontWeight: MyFonts.medium,
                        ),
                      ),
                centerTitle: centerTitle,
                actions: actions,
                leading: leading,
                titleSpacing: 0,
                // leadingWidth: 50,
                // automaticallyImplyLeading: false,
              ),
        body: Stack(
          children: [
            Positioned(left: 0, top: 0, right: 0, bottom: 0, child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget body;

  const GradientBackground({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
              left: 0,
              top: 0,
              child: Container(
                alignment: Alignment.topLeft,
                // height: MediaQuery.of(context).size.width / 2,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  MyImages.blueGradient,
                ),
              )),
          Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                alignment: Alignment.bottomRight,
                // height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(MyImages.greenGradient),
              )),
          Positioned(left: 0, top: 0, right: 0, bottom: 0, child: body),
        ],
      ),
    );
  }
}
