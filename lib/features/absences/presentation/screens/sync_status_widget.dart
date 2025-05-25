import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/absence_providers.dart';

class SyncStatusWidget extends ConsumerWidget {
  final String status;
  final double size;

  const SyncStatusWidget({
    super.key,
    required this.status,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSynced = status == 'synced';
    final backgroundColor = isSynced ? Colors.green : Colors.orange;
    final icon = isSynced ? Icons.cloud_done : Icons.cloud_off;
    final text = isSynced ? 'Synchronisé' : 'Hors ligne';

    return InkWell(
      onTap: isSynced 
          ? null 
          : () async {
              try {
                final syncUseCase = ref.read(syncAbsencesUseCaseProvider);
                await syncUseCase();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Synchronisation réussie'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Rafraîchir les données
                ref.invalidate(studentAbsencesProvider);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur de synchronisation: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: size,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontSize: size,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 