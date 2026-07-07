import 'package:flutter/material.dart';

class ProductDetailsDisplay extends StatefulWidget {
  final Map<String, dynamic> foodData;

  const ProductDetailsDisplay({
    super.key,
    required this.foodData,
  });

  @override
  State<ProductDetailsDisplay> createState() => _ProductDetailsDisplayState();
}

class _ProductDetailsDisplayState extends State<ProductDetailsDisplay> {
  bool ingredientsExpanded = false;

  double? _toDouble(dynamic value) {
    if (value == null || value == 'Not available') return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  String _formatValue(dynamic value) {
    if (value == null || value == 'Not available') {
      return 'N/A';
    }
    if (value is num) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  bool _hasIngredients() {
    final ingredients = widget.foodData['ingredients']?.toString().trim();
    return ingredients != null &&
        ingredients.isNotEmpty &&
        ingredients.toLowerCase() != 'not available';
  }

  _HealthIndicatorData _getHealthIndicator() {
    final calories = _toDouble(widget.foodData['calories']);
    final sugar = _toDouble(widget.foodData['sugar']);
    final fats = _toDouble(widget.foodData['fats']);

    final hasUnhealthyValue =
        (calories != null && calories > 400) ||
        (sugar != null && sugar > 22.5) ||
        (fats != null && fats > 17.5);

    if (hasUnhealthyValue) {
      return _HealthIndicatorData(
        label: 'Unhealthy',
        color: Colors.red.shade600,
      );
    }

    final hasKnownValue = calories != null || sugar != null || fats != null;
    final allKnownValuesAreHealthy = hasKnownValue &&
        (calories == null || calories <= 150) &&
        (sugar == null || sugar <= 5) &&
        (fats == null || fats <= 3);

    if (allKnownValuesAreHealthy) {
      return _HealthIndicatorData(
        label: 'Healthy',
        color: Colors.green.shade700,
      );
    }

    return _HealthIndicatorData(
      label: 'Not Bad',
      color: Colors.amber.shade700,
    );
  }

  _DietIndicatorData? _getDietIndicator() {
    final searchableText = [
      widget.foodData['ingredients_analysis_tags'],
      widget.foodData['labels'],
      widget.foodData['categories'],
      widget.foodData['ingredients'],
    ].where((value) => value != null).join(' ').toLowerCase();

    if (searchableText.isEmpty || searchableText == 'not available') {
      return null;
    }

    if (searchableText.contains('en:non-vegetarian')) {
      return _DietIndicatorData(
        label: 'Non-Veg',
        color: Colors.red.shade700,
      );
    }

    if (searchableText.contains('en:vegetarian')) {
      return _DietIndicatorData(
        label: 'Veg',
        color: Colors.green.shade700,
      );
    }

    final nonVegetarianPattern = RegExp(
      r'\b(chicken|beef|pork|mutton|lamb|fish|prawn|shrimp|crab|meat|egg|eggs|gelatin|gelatine|anchovy|tuna|salmon|bacon|ham|non[-\s]?vegetarian|non[-\s]?veg)\b',
    );

    if (nonVegetarianPattern.hasMatch(searchableText)) {
      return _DietIndicatorData(
        label: 'Non-Veg',
        color: Colors.red.shade700,
      );
    }

    return _DietIndicatorData(
      label: 'Veg',
      color: Colors.green.shade700,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final healthIndicator = _getHealthIndicator();
    final dietIndicator = _getDietIndicator();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xff1abc9c),
                  const Color(0xff16a085),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.foodData['name'] ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatusIndicator(data: healthIndicator),
                    ),
                    if (dietIndicator != null) ...[
                      const SizedBox(width: 12),
                      _DietBadge(data: dietIndicator),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Nutrients Grid
          Text(
            'Nutrition Facts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 16),

          // Main Nutrients Grid (2x2)
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _NutrientCard(
                label: 'Calories',
                value: _formatValue(widget.foodData['calories']),
                unit: 'kcal',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
              _NutrientCard(
                label: 'Protein',
                value: _formatValue(widget.foodData['proteins']),
                unit: 'g',
                icon: Icons.fitness_center,
                color: Colors.red,
              ),
              _NutrientCard(
                label: 'Fat',
                value: _formatValue(widget.foodData['fats']),
                unit: 'g',
                icon: Icons.opacity,
                color: Colors.yellow.shade600,
              ),
              _NutrientCard(
                label: 'Carbs',
                value: _formatValue(widget.foodData['carbs']),
                unit: 'g',
                icon: Icons.grain,
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sugar Card (Highlighted)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pink.shade400,
                  Colors.pink.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.cake, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sugar',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatValue(widget.foodData['sugar'])} g',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Collapsible Ingredients Section
          if (_hasIngredients())
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      setState(() {
                        ingredientsExpanded = !ingredientsExpanded;
                      });
                    },
                    title: const Text(
                      'Ingredients',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: AnimatedRotation(
                      turns: ingredientsExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: Colors.grey.shade600,
                        size: 28,
                      ),
                    ),
                  ),
                  if (ingredientsExpanded)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade50,
                      ),
                      child: Text(
                        widget.foodData['ingredients'].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _HealthIndicatorData {
  final String label;
  final Color color;

  const _HealthIndicatorData({
    required this.label,
    required this.color,
  });
}

class _DietIndicatorData {
  final String label;
  final Color color;

  const _DietIndicatorData({
    required this.label,
    required this.color,
  });
}

class _StatusIndicator extends StatelessWidget {
  final _HealthIndicatorData data;

  const _StatusIndicator({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: data.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            data.label,
            style: TextStyle(
              color: data.color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DietBadge extends StatelessWidget {
  final _DietIndicatorData data;

  const _DietBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: data.color, width: 1.5),
                borderRadius: BorderRadius.circular(3),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: data.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              data.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _NutrientCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.grey.shade900 : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon and Label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Value and Unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade900,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
