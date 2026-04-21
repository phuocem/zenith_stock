class Product {
  final String id;
  final String name;
  final String sku;
  final int? categoryId;
  final String? categoryName;
  final int? unitId;
  final String? unitName;
  final String? supplierId;
  final String? supplierName;
  final int minStockLevel;
  final int maxStockLevel;
  final int currentStock;
  final String? description;
  final String? imageUrl;
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    this.categoryId,
    this.categoryName,
    this.unitId,
    this.unitName,
    this.supplierId,
    this.supplierName,
    this.minStockLevel = 10,
    this.maxStockLevel = 1000,
    this.currentStock = 0,
    this.description,
    this.imageUrl,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      categoryId: json['category_id'] as int?,
      categoryName:
          (json['categories'] as Map<String, dynamic>?)?['name'] as String?,
      unitId: json['unit_id'] as int?,
      unitName: (json['units'] as Map<String, dynamic>?)?['name'] as String?,
      supplierId: json['supplier_id'] as String?,
      supplierName:
          (json['suppliers'] as Map<String, dynamic>?)?['name'] as String?,
      minStockLevel: (json['min_stock_level'] as num?)?.toInt() ?? 10,
      maxStockLevel: (json['max_stock_level'] as num?)?.toInt() ?? 1000,
      currentStock: (json['current_stock'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
  bool get isLowStock => currentStock <= minStockLevel;
  bool get isOutOfStock => currentStock == 0;
  StockStatus get stockStatus {
    if (isOutOfStock) return StockStatus.outOfStock;
    if (isLowStock) return StockStatus.low;
    return StockStatus.normal;
  }
}

enum StockStatus { normal, low, outOfStock }

class Category {
  final int id;
  final String name;
  const Category({required this.id, required this.name});
  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json['id'] as int, name: json['name'] as String);
}

class Unit {
  final int id;
  final String name;
  final String? abbreviation;
  const Unit({required this.id, required this.name, this.abbreviation});
  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
    id: json['id'] as int,
    name: json['name'] as String,
    abbreviation: json['abbreviation'] as String?,
  );
}

class Batch {
  final String id;
  final String productId;
  final String? productName;
  final String? productSku;
  final int? warehouseId;
  final String? warehouseName;
  final String batchCode;
  final int currentQuantity;
  final int initialQuantity;
  final double? costPrice;
  final DateTime? expiryDate;
  final DateTime createdAt;
  const Batch({
    required this.id,
    required this.productId,
    this.productName,
    this.productSku,
    this.warehouseId,
    this.warehouseName,
    required this.batchCode,
    required this.currentQuantity,
    required this.initialQuantity,
    this.costPrice,
    this.expiryDate,
    required this.createdAt,
  });
  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName:
          (json['products'] as Map<String, dynamic>?)?['name'] as String?,
      productSku:
          (json['products'] as Map<String, dynamic>?)?['sku'] as String?,
      warehouseId: json['warehouse_id'] as int?,
      warehouseName:
          (json['warehouses'] as Map<String, dynamic>?)?['name'] as String?,
      batchCode: json['batch_code'] as String,
      currentQuantity: (json['current_quantity'] as num?)?.toInt() ?? 0,
      initialQuantity: (json['initial_quantity'] as num?)?.toInt() ?? 0,
      costPrice: (json['cost_price'] as num?)?.toDouble(),
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'])
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class Warehouse {
  final int id;
  final String code;
  final String name;
  final String? location;
  const Warehouse({
    required this.id,
    required this.code,
    required this.name,
    this.location,
  });
  factory Warehouse.fromJson(Map<String, dynamic> json) => Warehouse(
    id: json['id'] as int,
    code: json['code'] as String? ?? '',
    name: json['name'] as String,
    location: json['location'] as String?,
  );
}
