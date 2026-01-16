import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallpaper_provider.dart';
import '../models/search_params.dart';
import '../l10n/app_localizations.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late SearchParams _tempParams;
  bool _initialized = false;

  // Color Palette
  final List<String> _colors = [
    "660000", "990000", "cc0000", "cc3333", "ea4c88", "993399", 
    "663399", "333399", "0066cc", "0099cc", "66cccc", "77cc33", 
    "669900", "336600", "666600", "999900", "cccc33", "ffff00", 
    "ffcc33", "ff9900", "ff6600", "cc6633", "996633", "663300", 
    "000000", "999999", "cccccc", "ffffff", "424153"
  ];

  // Ratio Groups
  final Map<String, List<String>> _ratioGroups = {
    'Wide': ['16x9', '16x10'],
    'Ultrawide': ['21x9', '32x9', '48x9'],
    'Portrait': ['9x16', '10x16', '9x18'],
    'Square': ['1x1', '3x2', '4x3', '5x4'],
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // Clone existing params to local state
      final provider = Provider.of<WallpaperProvider>(context, listen: false);
      _tempParams = provider.params.clone();
      _initialized = true;
    }
  }

  void _applyFilters() {
    final provider = Provider.of<WallpaperProvider>(context, listen: false);
    provider.updateSearchParams(_tempParams);
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _tempParams = SearchParams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings), // Reusing 'Settings' or use a new title 'Filters'
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: Text(l10n.reset, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(l10n.categories),
            _buildCategories(l10n),
            const SizedBox(height: 16),
            
            _buildSectionTitle(l10n.purity),
            _buildPurity(l10n),
            const SizedBox(height: 16),

            _buildSectionTitle(l10n.sorting),
            _buildSorting(l10n),
            
            if (_tempParams.sorting == 'toplist') ...[
               const SizedBox(height: 16),
               _buildSectionTitle(l10n.topRange),
               _buildTopRange(l10n),
            ],

            const SizedBox(height: 16),
            _buildSectionTitle(l10n.order),
            _buildOrder(l10n),
            
            const SizedBox(height: 16),
            _buildSectionTitle(l10n.ratios),
            _buildRatios(),
            
            const SizedBox(height: 16),
            _buildSectionTitle(l10n.colors),
            _buildColors(),
            
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _applyFilters,
        label: Text(l10n.apply),
        icon: const Icon(Icons.check),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCategories(AppLocalizations l10n) {
    final cats = _tempParams.categories;
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        FilterChip(
          label: Text(l10n.general),
          selected: cats[0] == '1',
          onSelected: (val) {
            setState(() {
              final newCats = '${val ? '1' : '0'}${cats[1]}${cats[2]}';
              _tempParams.categories = newCats;
            });
          },
        ),
        FilterChip(
          label: Text(l10n.anime),
          selected: cats[1] == '1',
          onSelected: (val) {
             setState(() {
              final newCats = '${cats[0]}${val ? '1' : '0'}${cats[2]}';
              _tempParams.categories = newCats;
            });
          },
        ),
        FilterChip(
          label: Text(l10n.people),
          selected: cats[2] == '1',
          onSelected: (val) {
             setState(() {
              final newCats = '${cats[0]}${cats[1]}${val ? '1' : '0'}';
              _tempParams.categories = newCats;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPurity(AppLocalizations l10n) {
    final purity = _tempParams.purity;
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        FilterChip(
          label: Text(l10n.sfw),
          selected: purity[0] == '1',
          onSelected: (val) {
             setState(() {
              final newPurity = '${val ? '1' : '0'}${purity[1]}${purity.length > 2 ? purity[2] : '0'}';
              _tempParams.purity = newPurity;
            });
          },
        ),
        FilterChip(
          label: Text(l10n.sketchy),
          selected: purity[1] == '1',
          onSelected: (val) {
             setState(() {
              final newPurity = '${purity[0]}${val ? '1' : '0'}${purity.length > 2 ? purity[2] : '0'}';
              _tempParams.purity = newPurity;
            });
          },
        ),
        FilterChip(
          label: Text(l10n.nsfw),
          selected: purity.length > 2 && purity[2] == '1',
          onSelected: (val) {
             setState(() {
              final newPurity = '${purity[0]}${purity[1]}${val ? '1' : '0'}';
              _tempParams.purity = newPurity;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSorting(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      children: [
        _buildSortChip('date_added', l10n.dateAdded),
        _buildSortChip('relevance', l10n.relevance),
        _buildSortChip('random', l10n.random),
        _buildSortChip('views', l10n.views),
        _buildSortChip('favorites', l10n.favorites),
        _buildSortChip('toplist', l10n.toplist),
        _buildSortChip('hot', l10n.hot),
      ],
    );
  }

  Widget _buildSortChip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _tempParams.sorting == value,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _tempParams.sorting = value;
          });
        }
      },
    );
  }

  Widget _buildTopRange(AppLocalizations l10n) {
    final Map<String, String> ranges = {
      '1d': l10n.lastDay,
      '3d': l10n.last3Days,
      '1w': l10n.lastWeek,
      '1M': l10n.lastMonth,
      '3M': l10n.last3Months,
      '6M': l10n.last6Months,
      '1y': l10n.lastYear,
    };

    return DropdownButton<String>(
      value: _tempParams.topRange,
      isExpanded: true,
      items: ranges.entries.map((e) {
        return DropdownMenuItem(value: e.key, child: Text(e.value));
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _tempParams.topRange = val;
          });
        }
      },
    );
  }

  Widget _buildOrder(AppLocalizations l10n) {
    return Row(
      children: [
        ChoiceChip(
          label: Text(l10n.desc),
          selected: _tempParams.order == 'desc',
          onSelected: (val) {
            if (val) setState(() => _tempParams.order = 'desc');
          },
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: Text(l10n.asc),
          selected: _tempParams.order == 'asc',
          onSelected: (val) {
            if (val) setState(() => _tempParams.order = 'asc');
          },
        ),
      ],
    );
  }

  Widget _buildRatios() {
    final currentRatios = _tempParams.ratios?.split(',').where((e) => e.isNotEmpty).toSet() ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _ratioGroups.entries.map((entry) {
        final groupName = entry.key;
        final ratios = entry.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(groupName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Select all in group
                    setState(() {
                      if (ratios.every((r) => currentRatios.contains(r))) {
                         // Deselect all
                         currentRatios.removeAll(ratios);
                      } else {
                        // Select all
                        currentRatios.addAll(ratios);
                      }
                      _tempParams.ratios = currentRatios.join(',');
                    });
                  },
                  child: const Text('All', style: TextStyle(fontSize: 12)),
                )
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ratios.map((ratio) {
                final isSelected = currentRatios.contains(ratio);
                return FilterChip(
                  label: Text(ratio.replaceAll('x', '×')),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        currentRatios.add(ratio);
                      } else {
                        currentRatios.remove(ratio);
                      }
                      _tempParams.ratios = currentRatios.join(',');
                    });
                  },
                );
              }).toList(),
            ),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildColors() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // "None" option
        GestureDetector(
          onTap: () {
            setState(() {
              _tempParams.colors = null;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: _tempParams.colors == null ? Colors.blue : Colors.grey,
                width: _tempParams.colors == null ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.block, color: Colors.grey),
          ),
        ),
        ..._colors.map((colorHex) {
          final isSelected = _tempParams.colors == colorHex;
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                   _tempParams.colors = null;
                } else {
                   _tempParams.colors = colorHex;
                }
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(int.parse('0xFF$colorHex')),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected 
                  ? Icon(Icons.check, color: _isLightColor(colorHex) ? Colors.black : Colors.white)
                  : null,
            ),
          );
        }),
      ],
    );
  }

  bool _isLightColor(String hex) {
    final r = int.parse(hex.substring(0, 2), radix: 16);
    final g = int.parse(hex.substring(2, 4), radix: 16);
    final b = int.parse(hex.substring(4, 6), radix: 16);
    // YIQ equation
    return ((r * 299) + (g * 587) + (b * 114)) / 1000 >= 128;
  }
}
