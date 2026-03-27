import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instancia = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ferreteria.db');
    return _database!;
  }

  Future<Database> _initDB(String archivo) async {
    final ruta = await getDatabasesPath();
    final rutaCompleta = join(ruta, archivo);
    return await openDatabase(
      rutaCompleta,
      version: 1,
      onCreate: _crearDB,
    );
  }

  Future _crearDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_padre INTEGER,
        nombre TEXT NOT NULL,
        activo INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_categoria INTEGER,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        precio_venta REAL NOT NULL,
        precio_costo REAL,
        unidad_medida TEXT DEFAULT 'unid',
        codigo_barra TEXT,
        FOREIGN KEY (id_categoria) REFERENCES categorias(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE inventario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_producto INTEGER NOT NULL,
        stock_actual INTEGER DEFAULT 0,
        stock_minimo INTEGER DEFAULT 5,
        FOREIGN KEY (id_producto) REFERENCES productos(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        total REAL NOT NULL,
        igv REAL NOT NULL,
        metodo_pago TEXT DEFAULT 'efectivo',
        estado TEXT DEFAULT 'pagada'
      )
    ''');

    await db.execute('''
      CREATE TABLE detalle_venta (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_venta INTEGER NOT NULL,
        id_producto INTEGER NOT NULL,
        cantidad INTEGER NOT NULL,
        precio_unitario REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (id_venta) REFERENCES ventas(id),
        FOREIGN KEY (id_producto) REFERENCES productos(id)
      )
    ''');

    await _insertarDatosIniciales(db);
  }

  Future _insertarDatosIniciales(Database db) async {
    await db.insert('categorias', {'nombre': 'Herramientas', 'id_padre': null});
    await db.insert('categorias', {'nombre': 'Pinturas', 'id_padre': null});
    await db.insert('categorias', {'nombre': 'Plomeria', 'id_padre': null});
    await db.insert('categorias', {'nombre': 'Electricidad', 'id_padre': null});
    await db.insert('categorias', {'nombre': 'Fijaciones', 'id_padre': null});

    await db.insert('productos', {
      'id_categoria': 1, 'nombre': 'Martillo 16oz Stanley',
      'precio_venta': 28.50, 'precio_costo': 18.00, 'unidad_medida': 'unid'
    });
    await db.insert('productos', {
      'id_categoria': 2, 'nombre': 'Pintura latex blanco 4L',
      'precio_venta': 45.00, 'precio_costo': 30.00, 'unidad_medida': 'unid'
    });
    await db.insert('productos', {
      'id_categoria': 3, 'nombre': 'Cinta teflon rollo',
      'precio_venta': 1.50, 'precio_costo': 0.50, 'unidad_medida': 'unid'
    });
    await db.insert('productos', {
      'id_categoria': 1, 'nombre': 'Lija 120 pliego',
      'precio_venta': 2.80, 'precio_costo': 1.20, 'unidad_medida': 'unid'
    });
    await db.insert('productos', {
      'id_categoria': 2, 'nombre': 'Silicona transparente',
      'precio_venta': 8.50, 'precio_costo': 5.00, 'unidad_medida': 'unid'
    });
    await db.insert('productos', {
      'id_categoria': 1, 'nombre': 'Broca madera 1/4',
      'precio_venta': 5.00, 'precio_costo': 2.50, 'unidad_medida': 'unid'
    });

    await db.insert('inventario', {'id_producto': 1, 'stock_actual': 14, 'stock_minimo': 5});
    await db.insert('inventario', {'id_producto': 2, 'stock_actual': 8, 'stock_minimo': 5});
    await db.insert('inventario', {'id_producto': 3, 'stock_actual': 52, 'stock_minimo': 10});
    await db.insert('inventario', {'id_producto': 4, 'stock_actual': 3, 'stock_minimo': 5});
    await db.insert('inventario', {'id_producto': 5, 'stock_actual': 2, 'stock_minimo': 5});
    await db.insert('inventario', {'id_producto': 6, 'stock_actual': 0, 'stock_minimo': 5});
  }

  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.*, i.stock_actual, i.stock_minimo, c.nombre as categoria
      FROM productos p
      LEFT JOIN inventario i ON i.id_producto = p.id
      LEFT JOIN categorias c ON c.id = p.id_categoria
    ''');
  }

  Future<List<Map<String, dynamic>>> obtenerCategorias() async {
    final db = await database;
    return await db.query('categorias', where: 'activo = 1');
  }

  Future<int> agregarProducto(Map<String, dynamic> producto, int stock) async {
    final db = await database;
    final id = await db.insert('productos', producto);
    await db.insert('inventario', {
      'id_producto': id,
      'stock_actual': stock,
      'stock_minimo': 5,
    });
    return id;
  }

  Future actualizarStock(int idProducto, int nuevoStock) async {
    final db = await database;
    await db.update(
      'inventario',
      {'stock_actual': nuevoStock},
      where: 'id_producto = ?',
      whereArgs: [idProducto],
    );
  }

  Future<int> registrarVenta(double total, double igv, String metodoPago,
      List<Map<String, dynamic>> items) async {
    final db = await database;
    final idVenta = await db.insert('ventas', {
      'fecha': DateTime.now().toIso8601String(),
      'total': total,
      'igv': igv,
      'metodo_pago': metodoPago,
      'estado': 'pagada',
    });
    for (final item in items) {
      await db.insert('detalle_venta', {
        'id_venta': idVenta,
        'id_producto': item['id'],
        'cantidad': item['cantidad'],
        'precio_unitario': item['precio_venta'],
        'subtotal': ((item['precio_venta'] as num) * (item['cantidad'] as num)).toDouble(),
      });
      final inv = await db.query('inventario',
          where: 'id_producto = ?', whereArgs: [item['id']]);
      if (inv.isNotEmpty) {
        final stockActual = inv.first['stock_actual'] as int;
        await actualizarStock(item['id'], stockActual - (item['cantidad'] as num).toInt());
      }
    }
    return idVenta;
  }

  Future<List<Map<String, dynamic>>> obtenerVentasHoy() async {
    final db = await database;
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day).toIso8601String();
    return await db.query('ventas',
        where: 'fecha >= ?', whereArgs: [inicio], orderBy: 'fecha DESC');
  }

  Future<List<Map<String, dynamic>>> obtenerProductosBajoStock() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.nombre, i.stock_actual, i.stock_minimo
      FROM inventario i
      JOIN productos p ON p.id = i.id_producto
      WHERE i.stock_actual <= i.stock_minimo
      ORDER BY i.stock_actual ASC
    ''');
  }
}
