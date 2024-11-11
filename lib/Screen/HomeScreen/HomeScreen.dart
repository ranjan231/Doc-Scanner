// import 'package:flutter/material.dart';
// import 'package:flutterpracticeversion22/Components/CustomBottomBar.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//   var len = 0;

//   List<Widget> get _widgetOptions => <Widget>[
//         const Text('Home Screen',
//             style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
//         const Text('Rewards Screen',
//             style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
//         const Text('Search Screen',
//             style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
//         const Text('Profile Screen',
//             style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
//         const Text('About Screen',
//             style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
//       ];

//   @override
//   void initState() {
//     super.initState();
//     print('chk $len');
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Bottom Navigation Bar Example'),
//         ),
//         body: Column(
//           children: [
//             Card(
//               shadowColor: Color.fromARGB(255, 150, 210, 237),
//               margin: const EdgeInsets.all(10),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 5,
//               color: Colors.white,
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: GridView.count(
//                   crossAxisCount: 4,
//                   shrinkWrap: true,
//                   mainAxisSpacing: 5,
//                   crossAxisSpacing: 5,
//                   children: [
//                     _buildCardItem(Icons.camera, "Smart Scan", Colors.red),
//                     _buildCardItem(Icons.picture_as_pdf, "PDF Tools", Colors.green),
//                     _buildCardItem(Icons.image, "Import Picture", Colors.orange),
//                     _buildCardItem(Icons.insert_drive_file, "Import File", Colors.purple),
//                     _buildCardItem(Icons.compress, "Compress PDF", Colors.pink),
//                     _buildCardItem(Icons.text_fields, "Image to Text", Colors.teal),
//                     _buildCardItem(Icons.article, "PDF to Word", Colors.indigo),
//                     _buildCardItem(Icons.more_horiz, "More", Colors.brown),
//                   ],
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Container(
//                 color: Colors.white,
//                 child: Center(
//                   child: _widgetOptions.elementAt(_selectedIndex),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         bottomNavigationBar: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 10,
//                     offset: Offset(0, -3),
//                   ),
//                 ],
//               ),
//               child: CustomBottomNavBar(
//                 selectedIndex: _selectedIndex,
//                 onItemTapped: _onItemTapped,
//               ),
//             ),
//             Positioned(
//               bottom: 10,
//               left: MediaQuery.of(context).size.width / 2 - 39,
//               child: IconButton(
//                 icon: Icon(Icons.camera, size: 55),
//                 onPressed: () {
//                   _onItemTapped(2);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCardItem(IconData iconData, String label, Color color) {
//     return GestureDetector(
//       onTap: () {
//         print('$label clicked');
//       },
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             radius: 22,
//             backgroundColor: color.withOpacity(0.2),
//             child: Icon(iconData, color: color),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 10),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Field
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
            // Action Buttons Grid
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
                      _buildCardItem(Icons.picture_as_pdf, "PDF Tools", Colors.green),
                      _buildCardItem(Icons.image, "Import Picture", Colors.orange),
                      _buildCardItem(Icons.insert_drive_file, "Import File", Colors.purple),
                      _buildCardItem(Icons.compress, "Compress PDF", Colors.pink),
                      _buildCardItem(Icons.text_fields, "Image to Text", Colors.teal),
                      _buildCardItem(Icons.article, "PDF to Word", Colors.indigo),
                      _buildCardItem(Icons.more_horiz, "More", Colors.brown),
                    ],
                  ),
                ),
              ),
            ),
            // Recent Docs
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
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 5, // Adjust based on the number of recent docs you have
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.insert_drive_file, color: Colors.grey, size: 40),
                  title: Text("Document Name $index"),
                  subtitle: Text("Accessed: 05-22-2023 20:45"),
                  trailing: Icon(Icons.check_box_outline_blank),
                );
              },
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Docs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add action for scan button
        },
        child: Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

