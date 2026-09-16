import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tattoo_zona/features/artist/bloc/artist_bloc.dart';
import 'package:tattoo_zona/features/artist/bloc/artist_event.dart';
import 'package:tattoo_zona/features/artist/bloc/artist_state.dart';
import 'package:tattoo_zona/features/artist/pages/artist_profile_page.dart';
import 'package:tattoo_zona/features/artist/pages/artist_dashboard_page.dart';
import 'package:tattoo_zona/features/artist/pages/artist_calendar_page.dart';
import 'package:tattoo_zona/features/artist/pages/artist_messages_page.dart';

class ArtistHomePage extends StatelessWidget {
  const ArtistHomePage({super.key});

  static const List<Widget> _pages = [
    ArtistDashboardPage(),
    ArtistCalendarPage(),
    ArtistMessagesPage(),
    ArtistProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArtistBloc(),
      child: BlocBuilder<ArtistBloc, ArtistState>(
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
                  context.read<ArtistBloc>().add(ArtistTabChanged(index)),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.grey[350],
              selectedItemColor: Colors.black,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: 'Calendar',
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