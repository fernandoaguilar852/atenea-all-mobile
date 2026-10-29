import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/notificacion_entity.dart';
import '../providers/notificaciones_provider.dart';

class NotificacionesDrawer extends ConsumerStatefulWidget {
  final int clienteId;

  const NotificacionesDrawer({
    super.key,
    required this.clienteId,
  });

  @override
  ConsumerState<NotificacionesDrawer> createState() =>
      _NotificacionesDrawerState();
}

class _NotificacionesDrawerState extends ConsumerState<NotificacionesDrawer> {
  @override
  void initState() {
    super.initState();
    // Cargar notificaciones pendientes al abrir el drawer
    Future.microtask(() {
      ref
          .read(notificacionesProvider(widget.clienteId).notifier)
          .fetchPendientes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificacionesProvider(widget.clienteId));
    final notifier = ref.read(notificacionesProvider(widget.clienteId).notifier);

    return Drawer(
      child: Column(
        children: [
          // Header del drawer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 48.0,
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notificaciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.totalElement} pendientes',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Lista de notificaciones
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Error al cargar notificaciones',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => notifier.fetchPendientes(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : state.notificaciones.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_none,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay notificaciones pendientes',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => notifier.fetchPendientes(),
                            child: ListView.separated(
                              itemCount: state.notificaciones.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final notificacion =
                                    state.notificaciones[index];
                                return _NotificacionItem(
                                  notificacion: notificacion,
                                  onMarcarLeida: () async {
                                    await notifier.marcarComoLeida(
                                        notificacion.notificacionId);
                                  },
                                  onArchivar: () async {
                                    await notifier
                                        .archivar(notificacion.notificacionId);
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _NotificacionItem extends StatelessWidget {
  final NotificacionEntity notificacion;
  final VoidCallback onMarcarLeida;
  final VoidCallback onArchivar;

  const _NotificacionItem({
    required this.notificacion,
    required this.onMarcarLeida,
    required this.onArchivar,
  });

  Color _getPrioridadColor(String prioridad) {
    switch (prioridad) {
      case 'CRITICA':
        return Colors.red;
      case 'ALTA':
        return Colors.orange;
      case 'MEDIA':
        return Colors.yellow[700]!;
      case 'BAJA':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'RESOLUCION_VENCIMIENTO':
        return Icons.event_busy;
      case 'NUMERACION_BAJA':
        return Icons.format_list_numbered;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con prioridad e icono
          Row(
            children: [
              // Indicador de prioridad
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _getPrioridadColor(notificacion.prioridad),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Icono del tipo
              Icon(
                _getTipoIcon(notificacion.tipo),
                color: _getPrioridadColor(notificacion.prioridad),
                size: 24,
              ),
              const SizedBox(width: 12),
              // Título y prioridad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notificacion.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getPrioridadColor(notificacion.prioridad)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        notificacion.prioridad,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getPrioridadColor(notificacion.prioridad),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Mensaje
          Text(
            notificacion.mensaje,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          // Metadata (si existe)
          if (notificacion.metadata != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notificacion.metadata!['dias_restantes'] != null)
                    Text(
                      'Días restantes: ${notificacion.metadata!['dias_restantes']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  if (notificacion.metadata!['numeros_disponibles'] != null)
                    Text(
                      'Números disponibles: ${notificacion.metadata!['numeros_disponibles']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  if (notificacion.metadata!['prefijo'] != null)
                    Text(
                      'Prefijo: ${notificacion.metadata!['prefijo']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Fecha
          Text(
            dateFormat.format(notificacion.createdAt),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),
          // Acciones
          Row(
            children: [
              TextButton.icon(
                onPressed: onMarcarLeida,
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Marcar leída', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onArchivar,
                icon: const Icon(Icons.archive_outlined, size: 16),
                label: const Text('Archivar', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
