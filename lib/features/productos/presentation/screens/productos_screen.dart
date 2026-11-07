import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../core/datasources/producto_datasource.dart';
import '../../../../core/models/producto.dart';
import '../../../../core/providers/catalogs_providers.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/productos_provider.dart' hide productoDatasourceProvider;
import '../widgets/crear_producto_dialog.dart';
import '../widgets/editar_producto_dialog.dart';

class ProductosScreen extends ConsumerStatefulWidget {
  const ProductosScreen({super.key});

  @override
  ConsumerState<ProductosScreen> createState() => _ProductosScreenState();
}

enum ProductoEstadoFiltro { todos, activos, inactivos }

class _ProductosScreenState extends ConsumerState<ProductosScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _currentPage = 1;
  static const int _pageSize = 20;
  String? _searchQuery;
  int? _selectedProductoId; // Para filtrar por producto específico
  int? _selectedTipoProductoId; // Para filtrar por categoría/tipo
  bool _showScrollToTop = false;
  ProductoEstadoFiltro _estadoFiltro = ProductoEstadoFiltro.todos;
  List<Producto> _searchSuggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;
  bool _isSettingTextProgrammatically = false; // Flag para evitar onChanged

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
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadData() {
    final user = ref.read(currentUserProvider);
    final clienteId = user?.clienteId ?? 0;

    // Convertir el filtro de estado a bool para el backend
    bool? activoFilter;
    switch (_estadoFiltro) {
      case ProductoEstadoFiltro.activos:
        activoFilter = true;
        break;
      case ProductoEstadoFiltro.inactivos:
        activoFilter = false;
        break;
      case ProductoEstadoFiltro.todos:
        activoFilter = null;
        break;
    }

    debugPrint('📡 Cargando datos con filtros:');
    debugPrint('   - clienteId: $clienteId');
    debugPrint('   - page: $_currentPage');
    debugPrint('   - search: $_searchQuery');
    debugPrint('   - tipoProductoId: $_selectedTipoProductoId');
    debugPrint('   - productoId: $_selectedProductoId');
    debugPrint('   - activo: $activoFilter');

    if (clienteId > 0) {
      ref.read(productosProvider.notifier).loadProductos(
            clienteId: clienteId,
            pageNumber: _currentPage,
            pageSize: _pageSize,
            search: _searchQuery,
            tipoProductoId: _selectedTipoProductoId,
            productoId: _selectedProductoId,
            activo: activoFilter,
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

    // Convertir el filtro de estado a bool para el backend
    bool? activoFilter;
    switch (_estadoFiltro) {
      case ProductoEstadoFiltro.activos:
        activoFilter = true;
        break;
      case ProductoEstadoFiltro.inactivos:
        activoFilter = false;
        break;
      case ProductoEstadoFiltro.todos:
        activoFilter = null;
        break;
    }

    if (clienteId > 0) {
      ref.read(productosProvider.notifier).clearCache();
      await ref.read(productosProvider.notifier).loadProductos(
            clienteId: clienteId,
            pageNumber: _currentPage,
            pageSize: _pageSize,
            search: _searchQuery,
            tipoProductoId: _selectedTipoProductoId,
            productoId: _selectedProductoId,
            activo: activoFilter,
            forceRefresh: true,
          );
    }
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
          await _onRefresh();
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

  Future<void> _onSearchChanged(String query) async {
    // Ignorar cambios programáticos
    if (_isSettingTextProgrammatically) {
      return;
    }

    // Si el usuario borró todo el texto, limpiar el producto seleccionado
    if (query.isEmpty && _selectedProductoId != null) {
      _clearSearch();
      return;
    }

    // Si ya hay un producto seleccionado, ignorar el onChange
    if (_selectedProductoId != null) {
      return;
    }

    if (query.length >= 3) {
      setState(() {
        _isSearching = true;
        _showSuggestions = true;
      });

      try {
        final user = ref.read(currentUserProvider);
        final clienteId = user?.clienteId ?? 0;

        // Usar el ProductoDatasource del catalogs_providers
        final dioClient = ref.read(dioClientProvider);
        final datasource = ProductoDatasource(dioClient.dio);
        final sugerencias = await datasource.searchProductos(
          clienteId: clienteId,
          search: query,
          pageSize: 10,
        );

        setState(() {
          _searchSuggestions = sugerencias;
          _isSearching = false;
        });
      } catch (e) {
        setState(() {
          _searchSuggestions = [];
          _isSearching = false;
        });
      }
    } else {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
        _isSearching = false;
      });
    }
  }

  void _onProductoSelected(Producto producto) {
    debugPrint('🔍 Producto seleccionado: ${producto.nombre} (ID: ${producto.productoId})');

    // Establecer flag para evitar que onChanged interfiera
    _isSettingTextProgrammatically = true;

    setState(() {
      _selectedProductoId = producto.productoId;
      _searchController.text = producto.nombre;
      _searchSuggestions = []; // Limpiar sugerencias
      _showSuggestions = false;
      _isSearching = false;
      _searchFocusNode.unfocus();
      _currentPage = 1; // Reset a primera página
    });

    // Restablecer flag después de un breve delay
    Future.delayed(Duration(milliseconds: 100), () {
      _isSettingTextProgrammatically = false;
    });

    debugPrint('✅ _selectedProductoId guardado: $_selectedProductoId');
    // Limpiar cache y recargar con el productoId seleccionado
    ref.read(productosProvider.notifier).clearCache();
    _loadData();
  }

  void _clearSearch() {
    // Establecer flag para evitar que onChanged interfiera
    _isSettingTextProgrammatically = true;

    setState(() {
      _searchController.clear();
      _selectedProductoId = null;
      _searchSuggestions = [];
      _showSuggestions = false;
      _currentPage = 1;
    });

    // Restablecer flag después de un breve delay
    Future.delayed(Duration(milliseconds: 100), () {
      _isSettingTextProgrammatically = false;
    });

    // Limpiar cache y recargar sin filtro de producto
    ref.read(productosProvider.notifier).clearCache();
    _loadData();
  }

  String _formatCurrency(double value) {
    // Formato español: punto (.) para miles, coma (,) para decimales
    String valueStr = value.toString();

    // Si es entero, formatear sin decimales
    if (value == value.toInt()) {
      return '\$${NumberFormat('#,###', 'es').format(value.toInt())}';
    }

    // Si tiene decimales, mantenerlos tal cual con coma decimal
    List<String> parts = valueStr.split('.');
    String integerPart = NumberFormat('#,###', 'es').format(int.parse(parts[0]));
    String decimalPart = parts.length > 1 ? parts[1] : '';

    return '\$$integerPart${decimalPart.isNotEmpty ? ',$decimalPart' : ''}';
  }


  @override
  Widget build(BuildContext context) {
    final productosState = ref.watch(productosProvider);
    final user = ref.watch(currentUserProvider);
    final tiposProductoAsync = ref.watch(tiposProductoProvider(
      TiposProductoParams(clienteId: user?.clienteId ?? 0),
    ));

    // Los productos ya vienen filtrados desde el backend
    final productosFiltrados = productosState.productos;

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
              // Barra de búsqueda con autocompletado
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Buscar productos (mín. 3 caracteres)...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearSearch,
                              )
                            : (_isSearching
                                ? Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : null),
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),

                    // Dropdown de sugerencias
                    if (_showSuggestions && _searchSuggestions.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: BoxConstraints(maxHeight: 300.h),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _searchSuggestions.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: AppColors.borderColor,
                          ),
                          itemBuilder: (context, index) {
                            final producto = _searchSuggestions[index];
                            return ListTile(
                              dense: true,
                              title: Text(
                                producto.nombre,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              subtitle: Text(
                                'Cod: ${producto.codExterno ?? "N/A"} - ${_formatCurrency(producto.precio)}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: producto.activo
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : AppColors.grey400.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  producto.activo ? 'Activo' : 'Inactivo',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: producto.activo ? AppColors.success : AppColors.grey400,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              onTap: () => _onProductoSelected(producto),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              // Filtros de estado
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    _FiltroChip(
                      label: 'Todos',
                      isSelected: _estadoFiltro == ProductoEstadoFiltro.todos,
                      onTap: () {
                        debugPrint('🎯 Filtro cambiado a: TODOS');
                        setState(() {
                          _estadoFiltro = ProductoEstadoFiltro.todos;
                          _currentPage = 1;
                        });
                        ref.read(productosProvider.notifier).clearCache();
                        _loadData();
                      },
                    ),
                    SizedBox(width: AppSpacing.sm),
                    _FiltroChip(
                      label: 'Activos',
                      isSelected: _estadoFiltro == ProductoEstadoFiltro.activos,
                      onTap: () {
                        debugPrint('🎯 Filtro cambiado a: ACTIVOS');
                        setState(() {
                          _estadoFiltro = ProductoEstadoFiltro.activos;
                          _currentPage = 1;
                        });
                        ref.read(productosProvider.notifier).clearCache();
                        _loadData();
                      },
                      color: AppColors.success,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    _FiltroChip(
                      label: 'Inactivos',
                      isSelected: _estadoFiltro == ProductoEstadoFiltro.inactivos,
                      onTap: () {
                        debugPrint('🎯 Filtro cambiado a: INACTIVOS');
                        setState(() {
                          _estadoFiltro = ProductoEstadoFiltro.inactivos;
                          _currentPage = 1;
                        });
                        ref.read(productosProvider.notifier).clearCache();
                        _loadData();
                      },
                      color: AppColors.grey400,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sm),

              // Filtro de categoría/tipo de producto
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: tiposProductoAsync.when(
                  data: (tipos) {
                    return DropdownButtonFormField<int?>(
                      value: _selectedTipoProductoId,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon: const Icon(Icons.category_outlined),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'Todas las categorías',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Inter',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        ...tipos.map((tipo) => DropdownMenuItem<int?>(
                              value: tipo.tipoProductoId,
                              child: Text(
                                tipo.nombre,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTipoProductoId = value;
                          _currentPage = 1; // Reset a primera página
                        });
                        ref.read(productosProvider.notifier).clearCache();
                        _loadData();
                      },
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
              SizedBox(height: AppSpacing.md),

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
              else if (productosFiltrados.isEmpty)
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
                    children: productosFiltrados
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

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FiltroChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
