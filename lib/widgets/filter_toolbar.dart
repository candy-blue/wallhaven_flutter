import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallpaper_provider.dart';
import '../models/search_params.dart';
import '../l10n/app_localizations.dart';

class FilterToolbar extends StatefulWidget {
  const FilterToolbar({super.key});

  @override
  State<FilterToolbar> createState() => _FilterToolbarState();
}

class _FilterToolbarState extends State<FilterToolbar> {
  late SearchParams _tempParams;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _syncParams();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ideally we only sync if we are not dirty, or if the provider updated from elsewhere.
    // For simplicity, if we are not dirty, we keep syncing.
    if (!_isDirty) {
      _syncParams();
    }
  }

  void _syncParams() {
    final provider = context.read<WallpaperProvider>();
    _tempParams = provider.params.clone();
  }

  void _apply() {
    context.read<WallpaperProvider>().updateSearchParams(_tempParams);
    setState(() {
      _isDirty = false;
    });
  }

  void _updateState(VoidCallback fn) {
    setState(() {
      fn();
      _isDirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            // Purity
            _buildButtonGroup([
              _buildPurityButton(l10n.sfw, 0, const Color(0xFF429842)),
              _buildPurityButton(l10n.sketchy, 1, const Color(0xFFC4A000)),
              _buildPurityButton(l10n.nsfw, 2, const Color(0xFFCC3333)),
            ]),

            const SizedBox(width: 8),

            // Resolution Dropdown
            _buildResolutionDropdown(l10n),

            const SizedBox(width: 8),

            // Ratios Dropdown (Using PopupMenuButton with custom layout)
            _buildRatioDropdown(l10n),

            const SizedBox(width: 8),

            // Color Dropdown
            _buildColorDropdown(l10n),

            const SizedBox(width: 8),

            // Sorting Dropdown
            _buildStandardDropdown(
              label: _getSortingLabel(l10n, _tempParams.sorting),
              value: _tempParams.sorting,
              items: ['date_added', 'relevance', 'random', 'views', 'favorites', 'toplist', 'hot'],
              itemLabels: {
                'date_added': l10n.dateAdded,
                'relevance': l10n.relevance,
                'random': l10n.random,
                'views': l10n.views,
                'favorites': l10n.favorites,
                'toplist': l10n.toplist,
                'hot': l10n.hot,
              },
              onChanged: (val) {
                if (val != null) _updateState(() => _tempParams.sorting = val);
              },
            ),

            // Order Toggle (Arrow)
            IconButton(
              icon: Icon(_tempParams.order == 'desc' ? Icons.arrow_downward : Icons.arrow_upward),
              onPressed: () {
                _updateState(() {
                  _tempParams.order = _tempParams.order == 'desc' ? 'asc' : 'desc';
                });
              },
              tooltip: l10n.order,
              constraints: const BoxConstraints(minWidth: 36),
            ),

            // Toplist Range (Only if Toplist)
            if (_tempParams.sorting == 'toplist') ...[
              const SizedBox(width: 8),
              _buildStandardDropdown(
                label: _tempParams.topRange,
                value: _tempParams.topRange,
                items: ['1d', '3d', '1w', '1M', '3M', '6M', '1y'],
                itemLabels: {
                  '1d': l10n.lastDay,
                  '3d': l10n.last3Days,
                  '1w': l10n.lastWeek,
                  '1M': l10n.lastMonth,
                  '3M': l10n.last3Months,
                  '6M': l10n.last6Months,
                  '1y': l10n.lastYear,
                },
                onChanged: (val) {
                   if (val != null) _updateState(() => _tempParams.topRange = val);
                },
              ),
            ],

            const SizedBox(width: 16),

            // Refresh / Apply Button
            Container(
              decoration: BoxDecoration(
                color: _isDirty ? theme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _isDirty ? theme.primaryColor : Colors.grey),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh),
                color: _isDirty ? Colors.white : theme.iconTheme.color,
                onPressed: _apply,
                tooltip: l10n.apply,
              ),
            ),
          ],
        ),
          );
        },
      ),
    );
  }

  Widget _buildStandardDropdown({
    required String label,
    required String? value,
    required List<String> items,
    Map<String, String>? itemLabels,
    required ValueChanged<String?> onChanged,
    IconData? icon,
    String? activeLabel,
    bool isMultiSelect = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: PopupMenuButton<String>(
        initialValue: value,
        tooltip: label,
        offset: const Offset(0, 40),
        itemBuilder: (context) => items.map((item) {
          final itemLabel = itemLabels?[item] ?? item;
          final isSelected = isMultiSelect && value != null && value.split(',').contains(item);
          return PopupMenuItem(
            value: item,
            child: Row(
              children: [
                if (isMultiSelect)
                  Icon(
                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 18,
                  )
                else
                  const SizedBox.shrink(),
                if (isMultiSelect) const SizedBox(width: 8),
                Expanded(child: Text(itemLabel)),
              ],
            ),
          );
        }).toList(),
        onSelected: isMultiSelect ? (_) {} : onChanged,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 4)],
              Text(activeLabel ?? (itemLabels?[value] ?? label)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  String _getSortingLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'date_added': return l10n.dateAdded;
      case 'relevance': return l10n.relevance;
      case 'random': return l10n.random;
      case 'views': return l10n.views;
      case 'favorites': return l10n.favorites;
      case 'toplist': return l10n.toplist;
      case 'hot': return l10n.hot;
      default: return key;
    }
  }

  Widget _buildButtonGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildResolutionDropdown(AppLocalizations l10n) {
    // Common resolutions
    final resolutions = [
      '1920x1080', '2560x1440', '3840x2160', '2560x1080', '3440x1440',
      '3840x1600', '1280x720', '1600x900', '1920x1200', '2560x1600',
      '3840x2400', '1280x960', '1600x1200', '1920x1440', '2560x1920',
      '3840x2880', '1280x1024', '1600x1280', '1920x1536', '2560x2048',
      '3840x3072'
    ];
    
    final activeLabel = _tempParams.resolutions != null && _tempParams.resolutions!.isNotEmpty
        ? (_tempParams.resolutions!.split(',').length > 1 
            ? '${_tempParams.resolutions!.split(',').length} selected'
            : _tempParams.resolutions)
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: PopupMenuButton<String>(
        tooltip: l10n.resolution,
        offset: const Offset(0, 40),
        itemBuilder: (context) => resolutions.map((item) {
          final current = _tempParams.resolutions?.split(',').where((e) => e.isNotEmpty).toSet() ?? <String>{};
          final isSelected = current.contains(item);
          return PopupMenuItem(
            value: item,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(item),
              ],
            ),
          );
        }).toList(),
        onSelected: (val) {
          _updateState(() {
            // Toggle resolution
            final current = _tempParams.resolutions?.split(',').where((e) => e.isNotEmpty).toSet() ?? <String>{};
            if (current.contains(val)) {
              current.remove(val);
            } else {
              current.add(val);
            }
            _tempParams.resolutions = current.isEmpty ? null : current.join(',');
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.aspect_ratio, size: 16),
              const SizedBox(width: 4),
              Text(activeLabel ?? l10n.resolution),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurityButton(String label, int index, Color activeColor) {
    // Purity string might be shorter if not all options available, but usually 3 chars '100'
    // Default to '0' if out of bounds
    final isSelected = index < _tempParams.purity.length && _tempParams.purity[index] == '1';
    
    return InkWell(
      onTap: () {
        _updateState(() {
          // Ensure string is long enough
          var current = _tempParams.purity;
          while (current.length <= index) {
            current += '0';
          }
          final chars = current.split('');
          chars[index] = isSelected ? '0' : '1';
          _tempParams.purity = chars.join('');
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8) ?? Colors.grey[400],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Active background: if activeColor provided, use it (for Purity). 
    // Otherwise use dark grey/primary (for Categories).
    Color? bgColor;
    Color textColor;

    if (isSelected) {
      bgColor = activeColor ?? (isDark ? Colors.grey[700] : Colors.grey[400]);
      textColor = activeColor != null ? Colors.white : (isDark ? Colors.white : Colors.black);
    } else {
      bgColor = Colors.transparent;
      textColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          // Add border right separator if needed, but Group container has border
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRatioDropdown(AppLocalizations l10n) {
    // Custom Ratio Grid using PopupMenuButton
    final activeLabel = _tempParams.ratios != null && _tempParams.ratios!.isNotEmpty
        ? (_tempParams.ratios!.split(',').length > 1 ? 'Multi' : _tempParams.ratios)
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          popupMenuTheme: PopupMenuThemeData(
            color: const Color(0xFF1F1F1F), // Dark background for the menu
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            enableFeedback: true,
          ),
        ),
        child: PopupMenuButton<String>(
          tooltip: l10n.ratios,
          offset: const Offset(0, 40),
          constraints: const BoxConstraints(minWidth: 520, maxWidth: 520), // Wider for grid
          itemBuilder: (context) {
            return [
              PopupMenuItem<String>(
                enabled: false, // Not clickable as a whole, items inside handle taps
                padding: EdgeInsets.zero,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return _buildRatioGridContent(setState);
                  },
                ),
              ),
            ];
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.aspect_ratio, size: 16),
                const SizedBox(width: 4),
                Text(activeLabel ?? l10n.ratios),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatioGridContent(StateSetter setState) {
    final currentRatios = _tempParams.ratios?.split(',').where((e) => e.isNotEmpty).toSet() ?? {};
    final activeColor = Theme.of(context).primaryColor;

    Widget buildRatioButton(String ratio) {
      final isSelected = currentRatios.contains(ratio);
      return InkWell(
        onTap: () {
          _updateState(() {
            setState(() {
              if (isSelected) {
                currentRatios.remove(ratio);
              } else {
                currentRatios.add(ratio);
              }
              _tempParams.ratios = currentRatios.join(',');
            });
          });
        },
        child: Container(
          width: 80,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey[800] : const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              if (isSelected) BoxShadow(color: activeColor.withOpacity(0.5), blurRadius: 2, spreadRadius: 0),
            ],
            border: Border.all(
              color: isSelected ? activeColor : Colors.black,
              width: 1,
            ),
          ),
          child: Text(
            ratio.replaceAll('x', '×'),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[400],
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    Widget buildGroupHeader(String title, VoidCallback onSelectAll) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            // Only show select all for Wide/Portrait
            if (title == "Wide" || title == "Portrait")
              InkWell(
                onTap: () {
                  _updateState(() {
                    setState(() {
                      onSelectAll();
                      _tempParams.ratios = currentRatios.join(',');
                    });
                  });
                },
                child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: const Color(0xFF333333),
                     borderRadius: BorderRadius.circular(2),
                   ),
                   child: Text("All $title", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      width: 520,
      color: const Color(0xFF1F1F1F),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Column 1: Wide (16x9, 16x10)
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     buildGroupHeader("Wide", () => currentRatios.addAll(['16x9', '16x10'])),
                     Wrap(spacing: 4, runSpacing: 4, children: [
                       buildRatioButton('16x9'),
                       buildRatioButton('16x10'),
                     ]),
                   ],
                 ),
               ),
               const SizedBox(width: 16),
               // Column 2: Ultrawide
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     buildGroupHeader("Ultrawide", () {}), // No select all in ref image
                     Wrap(spacing: 4, runSpacing: 4, children: [
                       buildRatioButton('21x9'),
                       buildRatioButton('32x9'),
                       buildRatioButton('48x9'),
                     ]),
                   ],
                 ),
               ),
               const SizedBox(width: 16),
               // Column 3: Portrait
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     buildGroupHeader("Portrait", () => currentRatios.addAll(['9x16', '10x16', '9x18'])),
                     Wrap(spacing: 4, runSpacing: 4, children: [
                       buildRatioButton('9x16'),
                       buildRatioButton('10x16'),
                       buildRatioButton('9x18'),
                     ]),
                   ],
                 ),
               ),
               const SizedBox(width: 16),
               // Column 4: Square
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     buildGroupHeader("Square", () {}),
                     Wrap(spacing: 4, runSpacing: 4, children: [
                       buildRatioButton('1x1'),
                       buildRatioButton('3x2'),
                       buildRatioButton('4x3'),
                       buildRatioButton('5x4'),
                     ]),
                   ],
                 ),
               ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildColorDropdown(AppLocalizations l10n) {
    // Custom Color Grid using PopupMenuButton
    final hasColor = _tempParams.colors != null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          popupMenuTheme: PopupMenuThemeData(
            color: const Color(0xFF222222), // Dark grey background
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        child: PopupMenuButton<String>(
          tooltip: l10n.colors,
          offset: const Offset(0, 40),
          constraints: const BoxConstraints(minWidth: 340, maxWidth: 340),
          itemBuilder: (context) {
            return [
              PopupMenuItem<String>(
                enabled: false,
                padding: EdgeInsets.zero,
                child: StatefulBuilder(
                   builder: (context, setState) => _buildColorGridContent(setState),
                ),
              ),
            ];
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasColor)
                   Container(
                     width: 14, height: 14, 
                     decoration: BoxDecoration(
                       color: Color(int.parse('0xFF${_tempParams.colors}')),
                       border: Border.all(color: Colors.grey),
                     ),
                   )
                else
                   const Icon(Icons.palette, size: 16),
                const SizedBox(width: 4),
                Text(hasColor ? "" : l10n.colors),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorGridContent(StateSetter setState) {
    final colors = [
      "660000", "990000", "cc0000", "cc3333", "ea4c88", "993399", 
      "663399", "333399", "0066cc", "0099cc", "66cccc", "77cc33", 
      "669900", "336600", "666600", "999900", "cccc33", "ffff00", 
      "ffcc33", "ff9900", "ff6600", "cc6633", "996633", "663300", 
      "000000", "999999", "cccccc", "ffffff", "424153"
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      width: 340,
      color: const Color(0xFF222222),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          // Reset block
          InkWell(
            onTap: () {
              _updateState(() {
                 setState(() => _tempParams.colors = null);
              });
              Navigator.pop(context);
            },
            child: Container(
              width: 48,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Icon(Icons.block, size: 16, color: Colors.white70),
            ),
          ),
          ...colors.map((c) {
             final isSelected = _tempParams.colors == c;
             return InkWell(
              onTap: () {
                _updateState(() {
                   setState(() => _tempParams.colors = c);
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 48,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(int.parse('0xFF$c')),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: isSelected 
                    ? const Center(child: Icon(Icons.check, color: Colors.white, size: 16))
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}
