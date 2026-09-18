import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bluerum/app/providers.dart';
import 'package:bluerum/shared/models/site.dart';
import 'package:bluerum/shared/widgets/filters/instance_site_panel.dart';
import 'package:bluerum/shared/widgets/filters/option_picker_bottom_sheet.dart';

class HomeFilterBottomSheet extends ConsumerStatefulWidget {
  final String initialSort;
  final String initialType;
  final GetSiteResponse? cachedSiteResponse;
  final ValueChanged<GetSiteResponse>? onSiteResponseLoaded;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<String> onTypeChanged;

  const HomeFilterBottomSheet({
    super.key,
    required this.initialSort,
    required this.initialType,
    this.cachedSiteResponse,
    this.onSiteResponseLoaded,
    required this.onSortChanged,
    required this.onTypeChanged,
  });

  @override
  ConsumerState<HomeFilterBottomSheet> createState() =>
      _HomeFilterBottomSheetState();
}

class _HomeFilterBottomSheetState extends ConsumerState<HomeFilterBottomSheet> {
  late String _selectedSort;
  late String _selectedType;

  static const _sortOptions = [
    'Active',
    'Hot',
    'Controversial',
    'Scaled',
    'New',
    'Old',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialSort;
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight =
        mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom -
        16;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: mediaQuery.padding.bottom > 0 ? mediaQuery.padding.bottom : 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: InstanceSitePanel(
              cachedSiteResponse: widget.cachedSiteResponse,
              onSiteResponseLoaded: widget.onSiteResponseLoaded,
            ),
          ),
          _FilterNavTile(
            icon: MingCuteIcons.mgc_filter_line,
            title: 'Sort posts',
            value: _selectedSort,
            onTap: () {
              Navigator.of(context).pop();
              _showSortSelector(context);
            },
          ),
          _FilterNavTile(
            icon: MingCuteIcons.mgc_globe_line,
            title: 'Feed type',
            value: _selectedType,
            onTap: () {
              Navigator.of(context).pop();
              _showFeedTypeSelector(context);
            },
          ),
        ],
      ),
    );
  }

  void _showSortSelector(BuildContext context) {
    showOptionPickerBottomSheet(
      context: context,
      title: 'Sort posts',
      options: _sortOptions,
      selected: _selectedSort,
      onSelected: widget.onSortChanged,
    );
  }

  void _showFeedTypeSelector(BuildContext context) {
    final isLoggedIn = ref.read(authRepositoryProvider).isLoggedIn;
    final typeOptions = ['All', 'Local', if (isLoggedIn) 'Subscribed'];
    showOptionPickerBottomSheet(
      context: context,
      title: 'Feed type',
      options: typeOptions,
      selected: _selectedType,
      onSelected: widget.onTypeChanged,
      footer: isLoggedIn
          ? null
          : const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Log in to use Subscribed',
                  style: TextStyle(fontSize: 12, color: Color(0xFF525252)),
                ),
              ),
            ),
    );
  }
}

class _FilterNavTile extends StatelessWidget {
  const _FilterNavTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Icon(icon, color: const Color(0xFF000000)),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Color(0xFF000000),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF525252),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            MingCuteIcons.mgc_right_line,
            size: 16,
            color: Color(0xFF525252),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
