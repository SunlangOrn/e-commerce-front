import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final productProvider = context.watch<ProductProvider>();

    // Filter products based on selected category chip
    final displayedProducts = _selectedCategory == null
        ? productProvider.products
        : productProvider.products.where((p) {
      final String? productCategory = p.categoryName;
      return productCategory?.toLowerCase() ==
          _selectedCategory!.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "All Products",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // --- Category Filter Chips ---
            if (categoryProvider.categories.isNotEmpty)
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categoryProvider.categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    // First chip is "All"
                    if (index == 0) {
                      final isSelected = _selectedCategory == null;
                      return ChoiceChip(
                        label: const Text("All"),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedCategory = null);
                        },
                        selectedColor: Colors.black,
                        backgroundColor: Colors.grey.shade100,
                        side: BorderSide.none,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }

                    final cat = categoryProvider.categories[index - 1];
                    final isSelected = _selectedCategory == cat.name;

                    return ChoiceChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = isSelected ? null : cat.name;
                        });
                      },
                      selectedColor: Colors.black,
                      backgroundColor: Colors.grey.shade100,
                      side: BorderSide.none,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            // --- Product Grid (2 Columns, Scrollable Down) ---
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<ProductProvider>().fetchProducts(),
                child: productProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : displayedProducts.isEmpty
                    ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 150),
                    Center(
                      child: Text(
                        "No products found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                )
                    : GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 items per row
                    childAspectRatio: 0.65, // Aspect ratio for card dimensions
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: displayedProducts.length,
                  itemBuilder: (context, index) {
                    final product = displayedProducts[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(
                            productId: product.id,
                          ),
                        ),
                      ),
                      onAddToCart: () {
                        context
                            .read<CartProvider>()
                            .addItem(productId: product.id, quantity: 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Added to cart"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}