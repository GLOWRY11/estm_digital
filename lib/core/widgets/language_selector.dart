import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_localizations.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isFrench = currentLocale.languageCode == 'fr';
    
    return PopupMenuButton<String>(
      tooltip: isFrench ? 'Changer la langue' : 'Change language',
      icon: Icon(
        Icons.language,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : null,
      ),
      onSelected: (String languageCode) {
        ref.read(localeProvider.notifier).state = Locale(languageCode);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'fr',
          child: Row(
            children: [
              if (isFrench) const Icon(Icons.check, size: 18),
              const SizedBox(width: 10),
              const Text('Français'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              if (!isFrench) const Icon(Icons.check, size: 18),
              const SizedBox(width: 10),
              const Text('English'),
            ],
          ),
        ),
      ],
    );
  }
} 