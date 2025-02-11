import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CategoryProductPage(),
    );
  }
}

class CategoryProductPage extends StatefulWidget {
  @override
  _CategoryProductPageState createState() => _CategoryProductPageState();
}

class _CategoryProductPageState extends State<CategoryProductPage> {
  List categories = [];
  List products = [];
  String? selectedCategoryId;
  int page = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() => isLoading = true);
    final url = Uri.parse('https://alpha.bytesdelivery.com/api/v3/product/category-products/123/null/1');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        categories = data['data']['categories'];
        selectedCategoryId = categories.isNotEmpty ? categories[0]['_id'] : null;
      });
      fetchProducts();
    }
    setState(() => isLoading = false);
  }

  Future<void> fetchProducts() async {
    if (selectedCategoryId == null) return;
    setState(() => isLoading = true);
    final url = Uri.parse('https://alpha.bytesdelivery.com/api/v3/product/category-products/123/$selectedCategoryId/$page');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() => products = data['data']['products']);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
  title: Text(
    'Vegetables & Fruits',
    style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05),
  ),
  backgroundColor: Colors.grey,
  actions: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal:10),
      child: IconButton(
        icon: Icon(Icons.search, size: MediaQuery.of(context).size.width * 0.07),
        onPressed: () {
          // Implement search functionality here
        },
      ),
    ),
  ],
),

      body:  Row(
  children: [
    // Left side category list (Vertical)
    SizedBox(
      width: screenWidth * 0.22,
       // Adjust width as needed
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategoryId = category['_id'];
                page = 1;
                fetchProducts();
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Container(
                    width: screenWidth * 0.14, // Adjust width dynamically
                    height: screenWidth * 0.14, // Keep width and height equal for a circle
                    padding: EdgeInsets.all(screenWidth * 0.015), // Responsive padding
                    decoration: BoxDecoration(
                      color: selectedCategoryId == category['_id']
              ? const Color.fromARGB(255, 191, 228, 192)
              : const Color.fromARGB(255, 231, 173, 173),
                      shape: BoxShape.circle, // Ensures circular shape
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: Center( // Ensures the image is centered
                      child: ClipOval(
                        child: Image.network(
              category['image'],
              width: screenWidth * 0.09, // Slightly smaller for padding
              height: screenWidth * 0.09, // Keep width and height the same
              fit: BoxFit.cover, // Ensures the image scales properly
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5), // Space between circle and text
                  SizedBox(
                    width: screenWidth * 0.14, // Ensure text fits within container width
                    child: Text(
                      category['title'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.03, // Responsive font size
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center, // Centered text
                      overflow: TextOverflow.ellipsis, // Prevents overflow
                    ),
                  ),
                ],
              ),
            )




          );
        },
      ),
    ),

    // Right side Product Grid
  Expanded(
  child: isLoading
      ? Center(child: CircularProgressIndicator())
      : GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth > 600 ? 3 : 2,
            childAspectRatio: 0.7,
             mainAxisSpacing: 12,   // Vertical spacing between grid items
    crossAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              product['image'][0]['url'],
                              height: screenHeight * 0.18,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          product['title'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
                          maxLines: 1,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${product['discountPrice']} ',
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              'MRP ₹${product['price']}',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.red,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            
                          ],
                        ),
                         SizedBox(height: 2),
                        
                      ],
                    ),
                  ),
                 
                  Positioned(
                    top: 120,
                        bottom: 52,
                        right: 3,
                        // Make button stretch across the card width
                        child: SizedBox(
                          width: screenWidth* 0.2, // Make button full width
                        height: screenHeight * 0.03, // Dynamic button height
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              
                              backgroundColor: const Color.fromARGB(255, 207, 236, 209),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              
                              shape: RoundedRectangleBorder(
                                
                                borderRadius: BorderRadius.circular(12),

                                side: BorderSide(color: Colors.green, width: 2),
                                
                              ),
                            ),
                            child: Center(child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 31, 4, 4),))),
                          ),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
),

  ],
),

    );
  }
}
