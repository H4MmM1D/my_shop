import 'package:flutter/material.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;
  @override
  void initState() {
    //Future.delayed(Duration.zero).then((_) async { //we remove it if we have listen false on the provider

    _isLoading = true; //this will run before build method runs

    Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then((_) {
      setState(() {
        _isLoading = false;
      });
    });

    //});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemBuilder: (context, index) => OrderItem(
                orderData.orders[index],
              ),
              itemCount: orderData.orders.length,
            ),
    );
  }
}
