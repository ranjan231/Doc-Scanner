import 'package:flutter/material.dart';
import 'package:flutterpracticeversion22/Screen/ProfileScreen/ProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> get _widgetOptions => <Widget>[
        _buildHomeScreen(),
        const Center(
            child: Text('Rewards Screen',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold))),
        const Center(
            child: Text('Camera Screen',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold))),
        const Center(
            child: Text('Tools Screen',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold))),
        profileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/home.png',
              width: 24,
              height: 24,
              color: _selectedIndex == 0 ? Colors.blue : Colors.black,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/docs.png',
              width: 24,
              height: 24,
              color: _selectedIndex == 1 ? Colors.blue : Colors.black,
            ),
            label: 'Docs',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Image.asset(
                  'assets/images/camera.png',
                  width: 24,
                  height: 24,
                  // color: Colors.blue,
                ),
                onPressed: () {
                  _onItemTapped(2);
                },
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/tools.png',
              width: 24,
              height: 24,
              color: _selectedIndex == 3 ? Colors.blue : Colors.black,
            ),
            label: 'Tools',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/user.png',
              width: 24,
              height: 24,
              color: _selectedIndex == 4 ? Colors.blue : Colors.black,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              hintText: "Search",
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildCardItem(Icons.camera, "Smart Scan", Colors.blue),
                  _buildCardItem(
                      Icons.picture_as_pdf, "PDF Tools", Colors.green),
                  _buildCardItem(Icons.image, "Import Picture", Colors.orange),
                  _buildCardItem(
                      Icons.insert_drive_file, "Import File", Colors.purple),
                  _buildCardItem(Icons.compress, "Compress PDF", Colors.pink),
                  _buildCardItem(
                      Icons.text_fields, "Image to Text", Colors.teal),
                  _buildCardItem(Icons.article, "PDF to Word", Colors.indigo),
                  _buildCardItem(Icons.more_horiz, "More", Colors.brown),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Recent Docs",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                leading:
                    Icon(Icons.insert_drive_file, color: Colors.grey, size: 40),
                title: Text("Document Name $index"),
                subtitle: Text("Accessed: 05-22-2023 20:45"),
                trailing: Icon(Icons.check_box_outline_blank),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(label,style: TextStyle(fontWeight: FontWeight.bold),),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: () {
        print('$label tapped');
      },
    );
  }

  Widget _buildCardItem(IconData iconData, String label, Color color) {
    return GestureDetector(
      onTap: () {
        print('$label clicked');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(iconData, color: color),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
