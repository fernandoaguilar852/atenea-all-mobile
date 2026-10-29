import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme_config.dart';
import '../../../../shared/widgets/app_drawer.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/resolucion_entity.dart';
import '../../providers/resoluciones_provider.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    ref.read(resolucionesProvider.notifier).loadResoluciones(
          clienteId: user.clienteId,
          pageNumber: _currentPage,
          pageSize: _pageSize,
        );
  }

  void _showCreateDialog() {
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

    final bodyContent = Column(
        children: [
          // Header con botón de agregar (solo cuando no hay scaffold)
          if (!widget.showScaffold)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.grey300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showCreateDialog,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Nueva Resolución'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    ),
                  ),
                ],
              ),
            ),
          // Lista de resoluciones
          Expanded(
            child: resolucionesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : resolucionesState.error != null
                    ? Center(
                        child: Text(
                          resolucionesState.error!,
                          style: TextStyle(color: AppColors.danger),
                        ),
                      )
                    : data == null || data.resoluciones.isEmpty
                        ? const Center(child: Text('No hay resoluciones'))
                        : ListView.separated(
                            padding: EdgeInsets.all(16.w),
                            itemCount: data.resoluciones.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final resolucion = data.resoluciones[index];
                              return _ResolucionCard(
                                resolucion: resolucion,
                                onEdit: () => _showEditDialog(resolucion),
                                onDelete: () => _showDeleteDialog(resolucion),
                              );
                            },
                          ),
          ),

          // Paginación
          if (data?.pagination != null)
            Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Página $_currentPage de ${data!.pagination!.totalPages}',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: data.pagination!.hasPrevious
                            ? () {
                                setState(() => _currentPage--);
                                _loadData();
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: data.pagination!.hasNext
                            ? () {
                                setState(() => _currentPage++);
                                _loadData();
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
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
            onPressed: _showCreateDialog,
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

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12.w),
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
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (!resolucion.activo)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.grey300,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'INACTIVA',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          if (isVencida)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'VENCIDA',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (isCercaLimite && !isVencida)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'CERCA LÍMITE',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Resolución: ${resolucion.numeroResolucion}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
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
