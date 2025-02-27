import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/providers/login_provider.dart';
import 'package:social_app/widgets/chewie_video_widget.dart';



//todo Test screen  for Video list testing using ChewieVideoWidget

class TestScreen2 extends StatefulWidget {
  const TestScreen2({Key? key}) : super(key: key);

  @override
  State<TestScreen2> createState() => _TestScreen2State();
}

class _TestScreen2State extends State<TestScreen2> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LoginProvider>(context);

    List itemList = [];
    itemList.add("http://docs.evostream.com/sample_content/assets/bunny.mp4");
    itemList.add("http://docs.evostream.com/sample_content/assets/bun33s.mp4");
    itemList.add("http://docs.evostream.com/sample_content/assets/bunny.mp4");
    itemList.add("http://docs.evostream.com/sample_content/assets/bun33s.mp4");
    itemList.add("http://docs.evostream.com/sample_content/assets/bunny.mp4");
    itemList.add("http://docs.evostream.com/sample_content/assets/bun33s.mp4");

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Test 2 Screen"),
      ),
      body: SafeArea(
        child: Container(
            child:
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListView.separated(
                    shrinkWrap: true,
                    cacheExtent: 1000,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    // key: PageStorageKey(widget.position),
                    addAutomaticKeepAlives: true,
                    itemCount: itemList.isEmpty ? 0 : itemList.length,
                    itemBuilder: (BuildContext context, int index) =>
                        ChewieVideoWidget(
                          play: true,
                          url: itemList.elementAt(index),
                        ),
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                ],
              ),
            )
        ),

      ),
    );

  }

  @override
  void initState() {
    super.initState();

  }

}
