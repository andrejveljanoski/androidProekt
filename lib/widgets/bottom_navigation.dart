import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// A stateless widget that shows only the bottom navigation bar with three buttons.
class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      indicatorColor: const Color.fromARGB(255, 79, 165, 222),
      destinations: <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Badge(
            child: GestureDetector(
              onTap: () async {
                final currentUser = Supabase.instance.client.auth.currentUser;
                if (currentUser != null) {
                  final response = await Supabase.instance.client
                      .from('profiles')
                      .select('is_restaurant')
                      .eq('id', currentUser.id)
                      .single();
                  final dynamic userRole = response['is_restaurant'];
                 
                  if (userRole) {
                    Navigator.pushNamed(context, '/restauranthomepage'); // updated route
                  } else {
                    Navigator.pushNamed(context, '/homescreen');
                  }
                } 
              },
              child: Icon(Icons.home),
            ),
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Badge(
              child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/orders'),
                  child: Icon(Icons.article))),
          label: 'Orders',
        ),
        NavigationDestination(
          icon: Badge(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/account'),
              child: Icon(Icons.person),
            ),
          ),
          label: 'Account',
        ),
      ],
    );
  }
}
