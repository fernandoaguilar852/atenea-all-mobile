import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/models/producto.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/productos_provider.dart';
import '../widgets/crear_producto_dialog.dart';
import '../widgets/editar_producto_dialog.dart';

class ProductosScreen extends ConsumerStatefulWidget {
  const ProductosScreen({super.key});

  @override
  ConsumerState<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends ConsumerState<ProductosScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  static const int _pageSize = 20;
  String? _searchQuery;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();

    // Listener para mostrar/ocultar botón scroll-to-top
    _scrollController.addListener(() {
      final showButton = _scrollController.offset > 200;
      if (showButton != _showScrollToTop) {
        setState(() {
          _showScrollToTop = showButton;
        });
      }
    });

    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final user = ref.read(currentUserProvider);
    final clienteId = user?.clienteId ?? 0;

    if (clienteId > 0) {
      ref.read(productosProvider.notifier).loadProductos(
            clienteId: clienteId,
            pageNumber: _currentPage,
            pageSize: _pageSize,
            search: _searchQuery,
          );
    }
  }

  void _nextPage() {
    if (_currentPage < _getTotalPages()) {
      setState(() => _currentPage++);
      _loadData();
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
      _loadData();
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  int _getTotalPages() {
    final state = ref.read(productosProvider);
    return state.totalElements > 0 ? (state.totalElements / _pageSize).ceil() : 0;
  }

  Future<void> _onRefresh() async {
    setState(() {
      _currentPage = 1;
    });

    final user = ref.read(currentUserProvider);
    final clienteId = user?.clienteId ?? 0;

    if (clienteId > 0) {
      ref.read(productosProvider.notifier).clearCache();
      await ref.read(productosProvider.notifier).loadProductos(
            clienteId: clienteId,
            pageNumber: _currentPage,
            pageSize: _pageSize,
            search: _searchQuery,
            forceRefresh: true,
          );
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query;
      _currentPage = 1;
    });
    ref.read(productosProvider.notifier).clearCache();
    _loadData();
  }

  void _onEditProducto(Producto producto) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditarProductoDialog(producto: producto),
    );

    // Si se editó exitosamente, recargar la lista
    if (result == true) {
      _onRefresh();
    }
  }

  void _onDeleteProducto(Producto producto) async {
    // Validar que el producto esté inactivo
    if (producto.activo) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Producto Activo'),
          content: const Text(
            'No se puede eliminar un producto activo. Primero desactívalo desde la opción de editar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de eliminar "${producto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = ref.read(currentUserProvider);
        final clienteId = user?.clienteId ?? 0;

        await ref.read(productosProvider.notifier).deleteProducto(
              productoId: producto.productoId,
              clienteId: clienteId,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Producto "${producto.nombre}" eliminado exitosamente'),
              backgroundColor: AppColors.success,
            ),
          );
          _onRefresh();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar producto: ${e.toString()}'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productosState = ref.watch(productosProvider);

    // Calcular total de páginas
    final totalPages = productosState.totalElements > 0
        ? (productosState.totalElements / _pageSize).ceil()
        : 0;

    final bodyContent = Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                  ),
                  onChanged: _onSearch,
                ),
              ),

              // Lista de productos
              if (productosState.isLoading && productosState.productos.isEmpty)
                const _ProductosSkeletonList()
              else if (productosState.error != null && productosState.productos.isEmpty)
                Container(
                  height: 400.h,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64.sp, color: AppColors.danger),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        productosState.error!,
                        style: TextStyle(fontSize: 14.sp),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: _onRefresh,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              else if (productosState.productos.isEmpty)
                Container(
                  height: 400.h,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64.sp, color: AppColors.grey400),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'No hay productos',
                        style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Column(
                    children: productosState.productos
                        .map((producto) => _ProductoCard(
                              producto: producto,
                              onEdit: () => _onEditProducto(producto),
                              onDelete: () => _onDeleteProducto(producto),
                            ))
                        .toList(),
                  ),
                ),

              // Paginación (parte inferior)
              if (productosState.productos.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.grey300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón Anterior
                      TextButton.icon(
                        onPressed: _currentPage > 1 ? _previousPage : null,
                        icon: Icon(Icons.chevron_left, size: 20.sp),
                        label: Text(
                          'Anterior',
                          style: TextStyle(fontSize: 14.sp, fontFamily: 'Inter'),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: _currentPage > 1
                              ? AppColors.primary
                              : AppColors.grey400,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        ),
                      ),
                      // Información de página
                      Text(
                        'Página $_currentPage de $totalPages',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                      // Botón Siguiente
                      TextButton.icon(
                        onPressed: _currentPage < totalPages ? _nextPage : null,
                        label: Text(
                          'Siguiente',
                          style: TextStyle(fontSize: 14.sp, fontFamily: 'Inter'),
                        ),
                        icon: Icon(Icons.chevron_right, size: 20.sp),
                        style: TextButton.styleFrom(
                          foregroundColor: _currentPage < totalPages
                              ? AppColors.primary
                              : AppColors.grey400,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        ),
                      ),
                    ],
                  ),
                ),

              // Espaciado al final
              SizedBox(height: 80.h),
            ],
          ),
        ),

        // Botón flotante scroll-to-top
        if (_showScrollToTop)
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(28.w),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(28.w),
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 56.w,
                  height: 56.w,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_upward,
                    color: AppColors.white,
                    size: 28.sp,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => const CrearProductoDialog(),
              );

              // Si se creó exitosamente, recargar la lista
              if (result == true) {
                _onRefresh();
              }
            },
          ),
        ],
      ),
      body: bodyContent,
    );
  }
}

class _ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductoCard({
    required this.producto,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatCurrency(double value) {
    // Formato español: punto (.) para miles, coma (,) para decimales
    String valueStr = value.toString();

    // Si es entero, formatear sin decimales
    if (value == value.toInt()) {
      return '\$${NumberFormat('#,###', 'es').format(value.toInt())}';
    }

    // Si tiene decimales, mantenerlos tal cual con coma decimal
    // Separar parte entera y decimal
    List<String> parts = valueStr.split('.');
    String integerPart = NumberFormat('#,###', 'es').format(int.parse(parts[0]));
    String decimalPart = parts.length > 1 ? parts[1] : '';

    return '\$$integerPart${decimalPart.isNotEmpty ? ',$decimalPart' : ''}';
  }

  String _formatStock(double value) {
    // Formato español: coma (,) para decimales
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    // Mantener los decimales con coma
    return value.toString().replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: AppColors.borderColor, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nombre y Estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Código: ${producto.codExterno ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge de estado
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: producto.activo ? AppColors.success.withValues(alpha: 0.1) : AppColors.grey400.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    producto.activo ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: producto.activo ? AppColors.success : AppColors.grey400,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.sm),
            Divider(color: AppColors.borderColor, height: 1),
            SizedBox(height: AppSpacing.sm),

            // Información del producto
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.attach_money,
                    label: 'Precio',
                    value: _formatCurrency(producto.precio),
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Stock',
                    value: _formatStock(producto.stockTotal),
                    color: producto.stockTotal <= producto.stockMinimo ? AppColors.danger : AppColors.info,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.calculate,
                    label: 'IVA',
                    value: '${producto.ivaPorcentaje.toStringAsFixed(0)}%',
                    color: AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.category_outlined,
                    label: 'Unidad',
                    value: producto.sigla,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            if (producto.codBarras != null) ...[
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.qr_code, size: 14.sp, color: AppColors.textSecondary),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Código de barras: ${producto.codBarras}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: AppSpacing.md),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_outlined, size: 18.sp),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, size: 18.sp),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 16.sp, color: color),
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductosSkeletonList extends StatelessWidget {
  const _ProductosSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Container(
                width: 120.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
