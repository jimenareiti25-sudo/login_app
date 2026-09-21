import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'dashboard_screen.dart';

class CatalogScreen extends StatefulWidget {
  final UserModel user;

  const CatalogScreen({super.key, required this.user});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<ProductModel>> _futureProducts;
  late Future<List<String>> _futureCategories;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureProducts = ApiService.getProducts();
      _futureCategories = ApiService.getCategories();
      _selectedCategory = null; // Limpieza de memoria / Estado inicial
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      // US04: Limpiar arreglo anterior y cargar los de la categoría seleccionada
      _futureProducts = ApiService.getProductsByCategory(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        backgroundColor: const Color(0xFF536DFE),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Mi Panel',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen(user: widget.user)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // US04: Componente interactivo y accesible de categorías (Chips deslizables)
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FutureBuilder<List<String>>(
              future: _futureCategories,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final categories = snapshot.data!;
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: const Text('Ver todos'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) => _loadData(),
                      ),
                    ),
                    ...categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat.toUpperCase()),
                          selected: _selectedCategory == cat,
                          onSelected: (selected) => _filterByCategory(cat),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          // US03: Manejo de estados (Carga, Error, Éxito) y vistas reciclables con ListView.builder
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularIndicatorWidget());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                          const SizedBox(height: 10),
                          const Text(
                            'Error de red o servidor no disponible.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF536DFE), foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final products = snapshot.data!;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            // Carga asíncrona en segundo plano nativa de Flutter con indicador temporal
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                width: 50,
                                height: 50,
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                          ),
                        ),
                        title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // US05: Navegar al detalle pasando el ID y el rol local del usuario
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                productId: product.id,
                                userRole: widget.user.role,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CircularIndicatorWidget extends StatelessWidget {
  const CircularIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF536DFE)),
    );
  }
}