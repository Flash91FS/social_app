import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_app/models/feed.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - CatagoryCard - ";

class CatagoryCard extends StatelessWidget {
  final double verticalPadding;
  final bool darkMode;
  final String id;
  final String category;
  final String assetName;

  CatagoryCard(
      {Key? key,
      required this.darkMode,
      this.id = "1",
      this.category = "General",
      this.assetName = "ic_general_144.png",
      this.verticalPadding = 10})
      : super(key: key);

  String getImageNameForCategory(String categoryID) {
    switch (categoryID) {
      case "1":
        {
          return "ic_atm";
        }
        break;
      case "2":
        {
          return "ic_brawl";
        }
        break;
      case "3":
        {
          return "ic_doctor";
        }
        break;
      case "4":
        {
          return "ic_fire";
        }
        break;
      case "5":
        {
          return "ic_hospital";
        }
        break;
      case "6":
        {
          return "ic_info";
        }
        break;
      case "7":
        {
          return "ic_job";
        }
        break;
      case "8":
        {
          return "ic_party";
        }
        break;
      case "9":
        {
          return "ic_pharmacy";
        }
        break;
      case "10":
        {
          return "ic_theft";
        }
        break;
      case "11":
        {
          return "ic_police";
        }
        break;
      case "12":
        {
          return "ic_car_accident";
        }
        break;
      case "13":
        {
          return "ic_general";
        }
        break;
      case "14":
        {
          return "ic_speed_detector";
        }
        break;
      case "15":
        {
          return "ic_find_number_plate";
        }
        break;
      case "16":
        {
          return "ic_find_atm";
        }
        break;
      case "17":
        {
          return "ic_find_doctor";
        }
        break;
      case "18":
        {
          return "ic_find_hospital";
        }
        break;
      case "19":
        {
          return "ic_find_party";
        }
        break;
      case "20":
        {
          return "ic_find_hair_stylist";
        }
        break;
      case "21":
        {
          return "ic_find_health_expert";
        }
        break;
      case "22":
        {
          return "ic_find_pharmacy";
        }
        break;
      case "23":
        {
          return "ic_find_gym";
        }
        break;
      case "24":
        {
          return "ic_find_restaurant";
        }
        break;
      case "25":
        {
          return "ic_find_tattooist";
        }
        break;
      case "26":
        {
          return "ic_find_woman";
        }
        break;
      case "27":
        {
          return "ic_find_man";
        }
        break;
      case "28":
        {
          return "ic_find_car";
        }
        break;
      case "29":
        {
          return "ic_find_something";
        }
        break;

      default:
        {
          return "ic_general";
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // log("$TAG build() darkMode = $darkMode");

    String iconName = getImageNameForCategory(id);

    return Container(
      color: darkMode ? cardColorDark : cardColorLight,
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 16),
      child: Row(
        children: [
          // CircleAvatar(
          //   backgroundImage: NetworkImage(
          //     showUnsplashImage ? unsplashImageURL : (comment != null ? comment!.user!.profile!.profile : snap.data()['profilePic']),
          //   ),
          //   radius: 18,
          // ),
          Container(
            width: 40,
            height: 40,
            // color: Colors.amberAccent,
            child: Image.asset(
              // "assets/map_icons/ic_general_144.png",
              "assets/map_icons/${iconName}_144.png",
              width: 40,
              height: 40,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: darkMode ? Colors.white : Colors.black),
                      children: [
                        TextSpan(
                            // text: ("Catagory name"),
                            text: (category),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        // TextSpan(
                        //   text: (comment != null ? ' ${comment!.comment}' : ' ${snap.data()['text']}'),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
