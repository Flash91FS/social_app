

import 'package:flutter/material.dart';
import 'package:social_app/testing/csv_example.dart';
import 'package:social_app/testing/my_list.dart';
import 'package:social_app/testing/video_list.dart';

class TestHomePage extends StatefulWidget {
  const TestHomePage({Key? key}) : super(key: key);

  @override
  _TestHomePageState createState() => _TestHomePageState();
}

class _TestHomePageState extends State<TestHomePage> {
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Example 1'),
    Tab(text: 'Example 2'),
    Tab(text: 'Autoplay Video'),
    Tab(text: 'Custom Scroll View'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          title: Text('InViewNotifierList'),
          centerTitle: true,
          bottom: TabBar(
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            MyList(
              key: ValueKey("list1"),
              initialInViewIds: ['0'],
              inViewArea: Container(
                height: 1.0,
                color: Colors.redAccent,
              ),
            ),
            MyList(
              initialInViewIds: ['0'],
              inViewPortCondition: (double deltaTop, double deltaBottom, double vpHeight) {
                return (deltaTop < (0.5 * vpHeight) + 100.0 && deltaBottom > (0.5 * vpHeight) - 100.0);
              },
              inViewArea: Container(
                height: 200.0,
                color: Colors.redAccent.withOpacity(0.2),
              ),
            ),
            VideoList(),
            CSVExample(),
          ],
        ),
      ),
    );
  }
}