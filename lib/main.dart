import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class InvoiceItem {
  final String name;
  final double price;
  final int quantity;
  final double gstPercentage;

  InvoiceItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.gstPercentage,
  });

  double get subtotal => price * quantity;
  double get cgstAmount => subtotal * (gstPercentage / 2) / 100;
  double get sgstAmount => subtotal * (gstPercentage / 2) / 100;
  double get total => subtotal + cgstAmount + sgstAmount;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GST Billing App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<InvoiceItem> _items = [];
  
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _gstController = TextEditingController();

  void _addItem() {
    final name = _nameController.text;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final gstPercentage = double.tryParse(_gstController.text) ?? 0.0;

    if (name.isEmpty || price <= 0) return;

    setState(() {
      _items.add(InvoiceItem(
        name: name,
        price: price,
        quantity: quantity,
        gstPercentage: gstPercentage,
      ));
    });

    _nameController.clear();
    _priceController.clear();
    _quantityController.clear();
    _gstController.clear();
  }

  void _clearBill() {
    setState(() {
      _items.clear();
    });
  }

  double get _grandSubtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  double get _grandCgst => _items.fold(0, (sum, item) => sum + item.cgstAmount);
  double get _grandSgst => _items.fold(0, (sum, item) => sum + item.sgstAmount);
  double get _grandTotal => _items.fold(0, (sum, item) => sum + item.total);

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('GST Billing App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearBill,
            tooltip: 'Clear Bill',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _gstController,
                    decoration: const InputDecoration(labelText: 'GST %'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItem,
                  child: const Text('Add'),
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        'Qty: ${item.quantity} | Price: ₹${item.price.toStringAsFixed(2)} | GST: ${item.gstPercentage}%',
                      ),
                      trailing: Text(
                        '₹${item.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 32),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:'),
                      Text('₹${_grandSubtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('CGST:'),
                      Text('₹${_grandCgst.toStringAsFixed(2)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SGST:'),
                      Text('₹${_grandSgst.toStringAsFixed(2)}'),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grand Total:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        '₹${_grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
