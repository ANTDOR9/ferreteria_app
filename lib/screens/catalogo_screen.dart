import 'package:flutter/material.dart';
import 'carrito_screen.dart';

class CatalogoScreen extends StatefulWidget {
  final String rol;
  const CatalogoScreen({super.key, required this.rol});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final _busqueda = TextEditingController();
  String _categoriaSeleccionada = 'Todos';

  final List<Map<String, dynamic>> _productos = [
    {'nombre': 'Martillo 16oz Stanley', 'precio': 28.50, 'stock': 14, 'categoria': 'Herramientas'},
    {'nombre': 'Pintura latex blanco 4L', 'precio': 45.00, 'stock': 8, 'categoria': 'Pinturas'},
    {'nombre': 'Cinta teflon rollo', 'precio': 1.50, 'stock': 52, 'categoria': 'Plomeria'},
    {'nombre': 'Lija 120 pliego', 'precio': 2.80, 'stock': 3, 'categoria': 'Herramientas'},
    {'nombre': 'Silicona transparente', 'precio': 8.50, 'stock': 2, 'categoria': 'Pinturas'},
    {'nombre': 'Broca madera 1/4', 'precio': 5.00, 'stock': 0, 'categoria': 'Herramientas'},
  ];

  final List<String> _categorias = ['Todos', 'Herramientas', 'Pinturas', 'Plomeria'];
  final List<Map<String, dynamic>> _carrito = [];

  List<Map<String, dynamic>> get _productosFiltrados {
    return _productos.where((p) {
      final coincideCategoria = _categoriaSeleccionada == 'Todos' ||
          p['categoria'] == _categoriaSeleccionada;
      final coincideBusqueda = p['nombre']
          .toLowerCase()
          .contains(_busqueda.text.toLowerCase());
      return coincideCategoria && coincideBusqueda;
    }).toList();
  }

  void _agregarAlCarrito(Map<String, dynamic> producto) {
    setState(() {
      final idx = _carrito.indexWhere((p) => p['nombre'] == producto['nombre']);
      if (idx >= 0) {
        _carrito[idx]['cantidad']++;
      } else {
        _carrito.add({...producto, 'cantidad': 1});
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto['nombre']} agregado'),
        duration: const Duration(seconds: 1),
      ),
    );
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
            const Text('Catalogo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A3A6B)),
            ),
            Text('Rol: ${widget.rol}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF888780)),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1A3A6B)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CarritoScreen(carrito: _carrito),
                    ),
                  );
                },
              ),
              if (_carrito.isNotEmpty)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE24B4A),
                      shape: BoxShape.circle,
                    ),
                    child: Text('${_carrito.length}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              children: [
                TextField(
                  controller: _busqueda,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar producto...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categorias.map((cat) {
                      final sel = cat == _categoriaSeleccionada;
                      return GestureDetector(
                        onTap: () => setState(() => _categoriaSeleccionada = cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFFE6F1FB) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel ? const Color(0xFF185FA5) : const Color(0xFFD3D1C7),
                            ),
                          ),
                          child: Text(cat,
                            style: TextStyle(
                              fontSize: 12,
                              color: sel ? const Color(0xFF185FA5) : const Color(0xFF888780),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10,
                mainAxisSpacing: 10, childAspectRatio: 0.75,
              ),
              itemCount: _productosFiltrados.length,
              itemBuilder: (context, i) {
                final p = _productosFiltrados[i];
                final sinStock = p['stock'] == 0;
                final stockBajo = p['stock'] > 0 && p['stock'] <= 3;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sinStock ? const Color(0xFFF09595)
                          : stockBajo ? const Color(0xFFFAC775)
                          : const Color(0xFFD3D1C7),
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity, height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6FA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.hardware, color: Color(0xFFB4B2A9), size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(p['nombre'],
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text('S/ ${p['precio'].toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF185FA5)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sinStock ? 'Agotado' : stockBajo ? 'Stock bajo: ${p['stock']}' : 'Stock: ${p['stock']}',
                        style: TextStyle(
                          fontSize: 10,
                          color: sinStock ? const Color(0xFFA32D2D)
                              : stockBajo ? const Color(0xFFBA7517)
                              : const Color(0xFF888780),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: sinStock ? null : () => _agregarAlCarrito(p),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A3A6B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(sinStock ? 'Agotado' : '+ Agregar',
                            style: const TextStyle(fontSize: 11),
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
