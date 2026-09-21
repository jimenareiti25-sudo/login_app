import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final String userRole; // Variable de sesión local

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.userRole,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<ProductModel?> _futureProduct;

  @override
  void initState() {
    super.initState();
    _futureProduct = ApiService.getProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.userRole == 'Administrador';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        backgroundColor: const Color(0xFF536DFE),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<ProductModel?>(
        future: _futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // US05: Si falla o no existe el producto, muestra alerta y regresa automáticamente
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: const Text('Producto no disponible'),
                    content: const Text('El artículo seleccionado ya no existe o ocurrió un error al consultarlo.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Cierra diálogo
                          Navigator.pop(context); // Regresa al catálogo
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                );
              }
            });
            return const SizedBox.shrink();
          }

          final product = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(
                    product.image,
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                  ),
                ),
                const SizedBox(height: 20),
                Chip(
                  label: Text(product.category.toUpperCase(), style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.blueGrey,
                ),
                const SizedBox(height: 10),
                Text(
                  product.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const Divider(height: 30),
                const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(
                  product.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 30),

                // US05 REGLA DE ROLES: Exclusión absoluta del árbol visual (Sin ocultar con opacidad, se omiten si no es Admin)
                if (isAdmin) ...[
                  const Divider(),
                  const Text('Panel de Administración', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Acción de Editar simulada')),
                            );
                          },
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text('Editar', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Acción de Eliminar simulada')),
                            );
                          },
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}