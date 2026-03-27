import 'package:flutter/material.dart';

class CarritoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> carrito;
  const CarritoScreen({super.key, required this.carrito});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.carrito);
  }

  double get _subtotal => _items.fold(0, (sum, p) => sum + p['precio'] * p['cantidad']);
  double get _igv => _subtotal * 0.18;
  double get _total => _subtotal + _igv;

  void _cambiarCantidad(int idx, int delta) {
    setState(() {
      _items[idx]['cantidad'] += delta;
      if (_items[idx]['cantidad'] <= 0) _items.removeAt(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Carrito de venta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A3A6B)),
            ),
            Text('${_items.length} articulos',
              style: const TextStyle(fontSize: 11, color: Color(0xFF888780)),
            ),
          ],
        ),
      ),
      body: _items.isEmpty
          ? const Center(
              child: Text('El carrito esta vacio',
                style: TextStyle(fontSize: 14, color: Color(0xFF888780)),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final p = _items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD3D1C7)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['nombre'],
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Text('S/ ${p['precio'].toStringAsFixed(2)} c/u',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF888780)),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _cambiarCantidad(i, -1),
                                  child: Container(
                                    width: 24, height: 24,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFD3D1C7)),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.remove, size: 14),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text('${p['cantidad']}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _cambiarCantidad(i, 1),
                                  child: Container(
                                    width: 24, height: 24,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFD3D1C7)),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.add, size: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Text('S/ ${(p['precio'] * p['cantidad']).toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A3A6B)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFD3D1C7))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(fontSize: 13, color: Color(0xFF888780))),
                          Text('S/ ${_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('IGV (18%)', style: TextStyle(fontSize: 13, color: Color(0xFF888780))),
                          Text('S/ ${_igv.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A3A6B)),
                          ),
                          Text('S/ ${_total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF185FA5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _items.isEmpty ? null : () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Venta confirmada'),
                                content: Text('Total cobrado: S/ ${_total.toStringAsFixed(2)}'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D6A5A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Confirmar venta', style: TextStyle(fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
