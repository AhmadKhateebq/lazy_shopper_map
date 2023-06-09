import 'package:flutter/material.dart';
import 'test_1.dart';
import 'dummy_data/product_list.dart'; // Import the dummyProducts list

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My list',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/map': (context) => GoogleMapPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dummyProducts.length,
              itemBuilder: (context, index) {
                final product = dummyProducts[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.brand),
                  onTap: () {
                    // Handle product item tap
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/map');
            },
            child: Text('Show Map'),
          ),
        ],
      ),
    );
  }
}
