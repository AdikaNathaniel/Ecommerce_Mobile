import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_page.dart'; // Import RegisterPage
import 'add_product.dart'; // Import AddProductPage
import 'user_screen.dart'; // Import UserListScreen
import 'summary_page.dart'; // Import SummaryPage
import 'product_page.dart';
import 'delivery_management.dart'; // Import DeliveryManagementPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe with your publishable key
  Stripe.publishableKey = 'pk_test_51Ql8Us4GUh5P0VNWFj1S5Fk5aP2hN9YE0pXPqvdV7IvmkLQurgeYB7lfO2m31qLnVjy7HFSz21HsuRK5ecrSSgu700Bt9em69W';
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/register': (context) => RegisterPage(), // Define the route for RegisterPage
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _typeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final userType = _typeController.text;

    if (email.isEmpty || password.isEmpty || userType.isEmpty) {
      _showSnackbar("Email, Password, and User Type are required!", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3100/api/v1/users/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success']) {
        _showSnackbar("Login successful", Colors.green);
        
        if (userType.toLowerCase() == 'seller') {
          // Navigate to the Add Products Page for sellers
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DeliveryManagementPage(userEmail: email, userPassword: password),
            ),
          );
        } else if (userType.toLowerCase() == 'customer') {
          // Navigate to the Products Page for customers
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProductsPage(userEmail: email),
            ),
          );
        } else if (userType.toLowerCase() == 'admin') {
          // Fetch totals and navigate to SummaryPage
          int totalProducts = await _fetchTotalProducts();
          int totalItemsInCart = await _fetchTotalItemsInCart();
          int totalOrders = await _fetchTotalOrders();
          int totalUsers = await _fetchTotalUsers();
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SummaryPage(
                totalProducts: totalProducts,
                totalItemsInCart: totalItemsInCart,
                totalOrders: totalOrders,
                totalUsers: totalUsers,
                userEmail: email, // Pass userEmail to SummaryPage
              ),
            ),
          );
        } else {
          _showSnackbar("Invalid user type.", Colors.red);
        }
      } else {
        _showSnackbar(responseData['message'] ?? "Wrong credentials.", Colors.red);
      }
    } catch (error) {
      _showSnackbar("Failed to connect to the server.", Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<int> _fetchTotalProducts() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3100/api/v1/products'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result']['products'].length; // Return total number of products
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print('Error fetching total products: $error');
      return 0; // Return 0 if there's an error
    }
  }

  Future<int> _fetchTotalItemsInCart() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3100/api/v1/cart'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'].length; // Return total number of items in the cart
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (error) {
      print('Error fetching total items in cart: $error');
      return 0; // Return 0 if there's an error
    }
  }

  Future<int> _fetchTotalOrders() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3100/api/v1/orders'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'].length; // Return total number of orders
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (error) {
      print('Error fetching total orders: $error');
      return 0; // Return 0 if there's an error
    }
  }

  Future<int> _fetchTotalUsers() async {
    try {
      // Fetch counts for each user type
      final customerResponse = await http.get(Uri.parse('http://localhost:3100/api/v1/users?type=customer'));
      final sellerResponse = await http.get(Uri.parse('http://localhost:3100/api/v1/users?type=seller'));
      final adminResponse = await http.get(Uri.parse('http://localhost:3100/api/v1/users?type=admin'));

      int customerCount = 0;
      int sellerCount = 0;
      int adminCount = 0;

      if (customerResponse.statusCode == 200) {
        final customerData = json.decode(customerResponse.body);
        customerCount = customerData['result'].length; // Total customers
      }

      if (sellerResponse.statusCode == 200) {
        final sellerData = json.decode(sellerResponse.body);
        sellerCount = sellerData['result'].length; // Total sellers
      }

      if (adminResponse.statusCode == 200) {
        final adminData = json.decode(adminResponse.body);
        adminCount = adminData['result'].length; // Total admins
      }

      return customerCount + sellerCount + adminCount; // Return total number of users
    } catch (error) {
      print('Error fetching total users: $error');
      return 0; // Return 0 if there's an error
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Container(
          width: double.infinity,
          child: Center(
            child: Text(
              'Welcome to Digizone',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.email, color: Colors.blue),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.lock, color: Colors.blue),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: true,
            ),
            SizedBox(height: 15),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(
                labelText: 'User Type (Admin, Customer, or Seller)',
                labelStyle: TextStyle(color: Colors.blue),
                prefixIcon: Icon(Icons.person_outline, color: Colors.blue),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/register'); // Navigate to RegisterPage
                  },
                  child: Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}