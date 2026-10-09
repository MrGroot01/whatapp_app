import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'welcome_screen.dart';

// One contact = one small card of information
class Contact {
  final String name;
  final String message;
  final String time;
  final Color color;

  const Contact(this.name, this.message, this.time, this.color);
}

class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _bg = Color(0xFF0F1B3D);
  static const Color _accent = Color(0xFF00C2A8);
  static const Color _card = Color(0xFF1A2A55);
  static const Color _text = Color(0xFFE0E6F5);

  final searchController = TextEditingController();
  String searchText = '';

  final List<Contact> contacts = const [
    Contact('Amma', 'Did you eat lunch?', '6:20 pm', Color(0xFFE91E63)),
    Contact('Appa', 'Call me when you are free', '5:50 pm', Color(0xFF3F51B5)),
    Contact('Arjun', 'Bro, the project is done', '4:42 pm', Color(0xFF009688)),
    Contact('Ravi', 'Please send the report', '3:57 pm', Color(0xFFFF9800)),
    Contact('Chaitra', 'Okay, see you tomorrow', '3:51 pm', Color(0xFF9C27B0)),
    Contact('Divya', 'Thanks a lot!', '2:30 pm', Color(0xFF795548)),
    Contact('Kiran', 'Let us play cricket', '1:15 pm', Color(0xFF607D8B)),
    Contact('Meena', 'Happy birthday!', '12:40 pm', Color(0xFFF44336)),
    Contact('Naveen', 'I will send the code', '11:05 am', Color(0xFF4CAF50)),
    Contact('Priya', 'Notes are in the group', '10:22 am', Color(0xFF2196F3)),
    Contact('Rahul', 'Where are you?', 'Yesterday', Color(0xFFFF5722)),
    Contact('Suresh', 'Good morning', 'Yesterday', Color(0xFF00BCD4)),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ---------- LOGOUT ----------
  Future<void> confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Log out?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(color: _text, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _text, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFFF8A80),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      // go to Welcome screen and remove all old screens
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shownContacts = contacts
        .where((c) => c.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ChatNest',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: _card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) {
              if (value == 'logout') confirmLogout();
            },
            itemBuilder: (context) => [
              // shows who is logged in (not clickable)
              PopupMenuItem<String>(
                enabled: false,
                child: Row(
                  children: [
                    const Icon(Icons.account_circle,
                        color: _accent, size: 26),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _text, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Color(0xFFFF8A80)),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFFF8A80),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _accent,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add_comment),
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: _accent,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(color: _text, fontSize: 16),
                prefixIcon: const Icon(Icons.search, color: _text),
                filled: true,
                fillColor: _card,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // CONTACT LIST
          Expanded(
            child: shownContacts.isEmpty
                ? const Center(
              child: Text(
                'No contacts found',
                style: TextStyle(color: _text, fontSize: 17),
              ),
            )
                : ListView.builder(
              itemCount: shownContacts.length,
              itemBuilder: (context, index) {
                final contact = shownContacts[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: contact.color,
                    child: Text(
                      contact.name[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    contact.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _text, fontSize: 15),
                  ),
                  trailing: Text(
                    contact.time,
                    style: const TextStyle(color: _text, fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          name: contact.name,
                          color: contact.color,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}