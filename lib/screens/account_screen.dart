import 'package:flutter/material.dart';
import 'package:foody/widgets/card_with_icon.dart';
import 'package:foody/widgets/bottom_navigation.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 20),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: Image.asset('lib/assets/images/background.avif')
                          .image,
                      fit: BoxFit.fill)),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Account 1',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView(
              children: [
                CardWithIcon(
                  icon: Icon(Icons.home),
                  title: 'Delivery Address',
                  description: 'skopje 1000',
                ),
                CardWithIcon(
                  icon: Icon(Icons.manage_accounts),
                  title: 'Account Details',
                  description: 'Details',
                ),
                CardWithIcon(
                  icon: Icon(Icons.login),
                  title: 'Sign Out',
                  color: Colors.red,
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: 2,
        onDestinationSelected: (index) {},
      ),
    );
  }
}
