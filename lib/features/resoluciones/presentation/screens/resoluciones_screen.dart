import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/resolucion_entity.dart';
import '../providers/resoluciones_provider.dart';
import '../widgets/resolucion_form_dialog.dart';

class ResolucionesScreen extends ConsumerStatefulWidget {
  final bool showScaffold;

  const ResolucionesScreen({super.key, this.showScaffold = true});

  @override
  ConsumerState<ResolucionesScreen> createState() => _ResolucionesScreenState();
}

class _ResolucionesScreenState extends ConsumerState<ResolucionesScreen> {
  int _currentPage = 1;
  final int _pageSize = 10;
  bool? _activoFilter;

  // Scroll controller para scroll-to-top
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  late final AppLifecycleListener _lifecycleListener;

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

    // Listener para recargar cuando la app regresa del background
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        debugPrint('App resumed - reloading resoluciones data');
        _refreshData();
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _loadData() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    ref.read(resolucionesProvider.notifier).loadResoluciones(
          clienteId: user.clienteId,
          pageNumber: _currentPage,
          pageSize: _pageSize,
          activo: _activoFilter,
        );
  }

  // Pull-to-refresh: limpia cache y recarga
  Future<void> _refreshData() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Limpiar cache
    await ref.read(resolucionesProvider.notifier).clearCache(user.clienteId);

    // Recargar datos forzando refresh
    await ref.read(resolucionesProvider.notifier).loadResoluciones(
          clienteId: user.clienteId,
          pageNumber: _currentPage,
          pageSize: _pageSize,
          activo: _activoFilter,
          forceRefresh: true,
        );
  }

  // Método público para recargar desde fuera
  void reloadData() {
    _loadData();
  }

  void showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => ResolucionFormDialog(
        onSave: (data) async {
          final user = ref.read(currentUserProvider);
          if (user == null) return;

          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);

          final success = await ref.read(resolucionesProvider.notifier).createResolucion(
                clienteId: user.clienteId,
                prefijo: data['prefijo'],
                numeroDesde: data['numeroDesde'],
                numeroHasta: data['numeroHasta'],
                numeroActual: data['numeroActual'],
                numeroResolucion: data['numeroResolucion'],
                fechaResolucion: data['fechaResolucion'],
                fechaVencimiento: data['fechaVencimiento'],
                activo: data['activo'],
              );

          if (success && mounted) {
            navigator.pop();
            _loadData();
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Resolución creada exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditDialog(ResolucionEntity resolucion) {
    showDialog(
      context: context,
      builder: (context) => ResolucionFormDialog(
        resolucion: resolucion,
        onSave: (data) async {
          final user = ref.read(currentUserProvider);
          if (user == null) return;

          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);

          final success = await ref.read(resolucionesProvider.notifier).updateResolucion(
                resolucionId: resolucion.resolucionId,
                clienteId: user.clienteId,
                prefijo: data['prefijo'],
                numeroHasta: data['numeroHasta'],
                numeroActual: data['numeroActual'],
                fechaVencimiento: data['fechaVencimiento'],
                activo: data['activo'],
              );

          if (success && mounted) {
            navigator.pop();
            _loadData();
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Resolución actualizada exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteDialog(ResolucionEntity resolucion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Resolución'),
        content: Text(
          '¿Está seguro de eliminar la resolución ${resolucion.prefijo} - ${resolucion.numeroResolucion}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = ref.read(currentUserProvider);
              if (user == null) return;

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              navigator.pop();

              final success = await ref.read(resolucionesProvider.notifier).deleteResolucion(
                    resolucionId: resolucion.resolucionId,
                    clienteId: user.clienteId,
                  );

              if (success && mounted) {
                _loadData();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Resolución eliminada exitosamente'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolucionesState = ref.watch(resolucionesProvider);
    final data = resolucionesState.data;

    final bodyContent = Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
          // Header con filtro y botón de agregar (solo cuando no hay scaffold)
          if (!widget.showScaffold)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.borderColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Filtro de activo
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: DropdownButton<bool?>(
                      value: _activoFilter,
                      hint: Text(
                        'Estado',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      underline: const SizedBox(),
                      isDense: true,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            'Todas',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: true,
                          child: Text(
                            'Activas',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text(
                            'Inactivas',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _activoFilter = value;
                          _currentPage = 1;
                        });
                        _loadData();
                      },
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: showCreateDialog,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Nueva Resolución'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Lista de resoluciones o estados (loading/error/empty)
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: resolucionesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : resolucionesState.error != null && data == null
                    ? Center(
                        child: Text(
                          resolucionesState.error!,
                          style: TextStyle(
                            color: AppColors.danger,
                            fontFamily: 'Inter',
                          ),
                        ),
                      )
                    : data == null || data.resoluciones.isEmpty
                        ? Center(
                            child: Text(
                              'No hay resoluciones',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              Column(
                                children: data.resoluciones.map((resolucion) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                                    child: _ResolucionCard(
                                      resolucion: resolucion,
                                      onEdit: () => _showEditDialog(resolucion),
                                      onDelete: () => _showDeleteDialog(resolucion),
                                    ),
                                  );
                                }).toList(),
                              ),
                              // Indicador de loading para paginación (no bloquea UI)
                              if (resolucionesState.isLoadingMore)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(AppSpacing.sm),
                                    color: AppColors.primary.withValues(alpha: 0.9),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16.w,
                                          height: 16.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                          ),
                                        ),
                                        SizedBox(width: AppSpacing.sm),
                                        Text(
                                          'Cargando...',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
          ),

          // Paginación rediseñada
          if (data?.pagination != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón Anterior
                  TextButton.icon(
                    onPressed: data!.pagination!.hasPrevious
                        ? () {
                            setState(() => _currentPage--);
                            _loadData();
                          }
                        : null,
                    icon: Icon(Icons.chevron_left, size: 20.sp),
                    label: Text(
                      'Anterior',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),

                  // Información de página
                  Text(
                    'Página $_currentPage de ${data.pagination!.totalPages}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),

                  // Botón Siguiente
                  TextButton.icon(
                    onPressed: data.pagination!.hasNext
                        ? () {
                            setState(() => _currentPage++);
                            _loadData();
                          }
                        : null,
                    label: Text(
                      'Siguiente',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Inter',
                      ),
                    ),
                    icon: Icon(Icons.chevron_right, size: 20.sp),
                  ),
                ],
              ),
            ),

          // Espaciado adicional al final para que el botón flotante no cubra contenido
          SizedBox(height: 80.h),
                ],
              ),
            ),
          ),

          // Botón flotante scroll-to-top
          if (_showScrollToTop)
            Positioned(
              bottom: 16.h,
              right: 16.w,
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(28.r),
                elevation: 4,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28.r),
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
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );

    if (!widget.showScaffold) {
      return bodyContent;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resoluciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showCreateDialog,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: bodyContent,
    );
  }
}

/// Card individual para cada resolución
class _ResolucionCard extends StatelessWidget {
  final ResolucionEntity resolucion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ResolucionCard({
    required this.resolucion,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isVencida = resolucion.isVencida;
    final isCercaLimite = resolucion.isCercaLimite;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            resolucion.prefijo,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          if (!resolucion.activo)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.grey300.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                'INACTIVA',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          if (isVencida)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                'VENCIDA',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          if (isCercaLimite && !isVencida)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                'CERCA LÍMITE',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Resolución: ${resolucion.numeroResolucion}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rango: ${resolucion.rangoNumeros}',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Actual: ${resolucion.numeroActual}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Vence: ${_formatDate(resolucion.fechaVencimiento)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isVencida ? AppColors.danger : AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Creada: ${_formatDate(resolucion.fechaResolucion)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // Barra de progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: resolucion.progreso,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCercaLimite ? AppColors.warning : AppColors.success,
                ),
                minHeight: 6.h,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Progreso: ${(resolucion.progreso * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.edit, size: 16.sp),
                  label: const Text('Editar'),
                  onPressed: onEdit,
                ),
                SizedBox(width: 8.w),
                TextButton.icon(
                  icon: Icon(Icons.delete, size: 16.sp),
                  label: const Text('Eliminar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
