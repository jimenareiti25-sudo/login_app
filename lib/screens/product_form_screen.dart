import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product; // Si es null, es Creación (US06); si trae datos, es Edición (US07)

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _price;
  late String _description;
  late String _image;
  late String _category;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _title = widget.product?.title ?? '';
    _price = widget.product?.price ?? 0.0;
    _description = widget.product?.description ?? '';
    _image = widget.product?.image ?? '';
    _category = widget.product?.category ?? 'electronics';
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final productData = {
        'title': _title,
        'price': _price,
        'description': _description,
        'image': _image,
        'category': _category,
      };

      bool success;
      if (widget.product == null) {
        // US06: Crear
        success = await ApiService.createProduct(productData);
      } else {
        // US07: Actualizar
        success = await ApiService.updateProduct(widget.product!.id, productData);
      }

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.product == null ? 'Producto creado exitosamente' : 'Producto actualizado exitosamente')),
        );
        Navigator.pop(context, true); // Regresa indicando éxito
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar el producto'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        backgroundColor: const Color(0xFF536DFE),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _title,
                      decoration: const InputDecoration(labelText: 'Título del Producto'),
                      validator: (value) => value!.isEmpty ? 'Por favor ingresa un título' : null,
                      onSaved: (value) => _title = value!,
                    ),
                    TextFormField(
                      initialValue: _price == 0.0 ? '' : _price.toString(),
                      decoration: const InputDecoration(labelText: 'Precio'),
                      keyboardType: TextInputType.number,
                      validator: (value) => double.tryParse(value ?? '') == null ? 'Ingresa un precio válido' : null,
                      onSaved: (value) => _price = double.parse(value!),
                    ),
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty ? 'Ingresa una descripción' : null,
                      onSaved: (value) => _description = value!,
                    ),
                    TextFormField(
                      initialValue: _image,
                      decoration: const InputDecoration(labelText: 'URL de la Imagen'),
                      validator: (value) => value!.isEmpty ? 'Ingresa una URL de imagen' : null,
                      onSaved: (value) => _image = value!,
                    ),
                    TextFormField(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      validator: (value) => value!.isEmpty ? 'Ingresa una categoría' : null,
                      onSaved: (value) => _category = value!,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF536DFE),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _saveForm,
                      child: Text(isEditing ? 'Guardar Cambios' : 'Crear Producto', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}