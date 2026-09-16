import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tattoo_zona/features/client/bloc/client_bloc.dart';
import 'package:tattoo_zona/features/client/bloc/client_event.dart';
import 'package:tattoo_zona/features/client/bloc/client_state.dart';
import 'feed_page.dart';
import 'artists_page.dart';
import 'messages_page.dart';
import 'profile_page.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  static const List<Widget> _pages = [
    FeedPage(),
    ArtistsPage(),
    MessagesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientBloc(),
      child: BlocBuilder<ClientBloc, ClientState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Image.asset(
                'lib/images/tattoo_zone_logo.png',
                height: 40,
              ),
            ),
            body: IndexedStack(
              index: state.currentTab,
              children: _pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: state.currentTab,
              onTap: (index) =>
                  context.read<ClientBloc>().add(ClientTabChanged(index)),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.grey[350],
              selectedItemColor: Colors.black,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Feed',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  label: 'Artists',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}