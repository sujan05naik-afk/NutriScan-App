class BarcodeService {
  static const List<Map<String, dynamic>> _products = [
    {
      'barcodes': ['balaji crunchex', 'crunchex', '8906010501570'],
      'name': 'Balaji Crunchex',
      'calories': 545.0,
      'sugar': 3.8,
      'proteins': 7.5,
      'fats': 30.7,
      'carbs': 55.0,
      'labels': 'Vegetarian',
      'categories': 'Snack, namkeen, extruded snack',
      'ingredients_analysis_tags': ['en:vegetarian'],
      'ingredients':
          'Potato (84%), Edible Vegetable Oil (Contains One or More of the followings: Palmolein, Groundnut), Seasoning As Flavouring & Seasoning Agent (Sugar, Maltodextrin, Edible Common Salt, Spices & Condiments (Chilli 0.5%), Pepper ), Dehydrated Vegetable Powder (Onion, Garlic, Tomato), Black Salt, Acidity Regulator (INS 330,INS 296,INS 334), Milk Solids (0.1%), Hydrolyzed Vegetable Protein (SOYA), Anticaking Agent (INS 551), Flavour Enhancer (INS 627, INS 631), Flavour (Natural & Nature Identical Flavouring Substances), Paprika extract (INS 160C), Stabilizer (INS 340), Emulsifier (INS 470)].',
    },
    {
      'barcodes': [
        'chocos',
        'kelloggs chocos',
        'kellogg chocos',
        '8901499008275',
      ],
      'name': 'Kellogg\'s Chocos',
      'calories': 371.0,
      'sugar': 26.5,
      'proteins': 8.3,
      'fats': 2.3,
      'carbs': 82.4,
      'labels': 'Vegetarian',
      'categories': 'Breakfast cereal',
      'ingredients_analysis_tags': ['en:vegetarian'],
      'ingredients':
          'Multigrain Flour Mix(69.4%), {Wheat flour (Atta) (53.7%), Corn Meal (7.9%), Rice Flour (6.3%), Sorghum (Jowar) Flour (1.5%)}, Sugar, Cocoa Solids (2.7%), Minerals, Iodized Salt, Cereal Extract, Colours (INS 150a, INS 150d), Flavours {Nature Identical (Vanilla) & Artificial (Cream)}, Edible Vegetable Oil (Palmolein), Vitamins, Antioxidant (INS 307b).',
    },
    {
      'barcodes': [
        'parle g',
        'parle-g',
        'parle g biscuit',
        '8901719134845',
        '8901014004843',
      ],
      'name': 'Parle-G Original Gluco Biscuits',
      'calories': 448.0,
      'sugar': 25.5,
      'proteins': 7.0,
      'fats': 11.8,
      'carbs': 78.4,
      'labels': 'Vegetarian',
      'categories': 'Biscuits',
      'ingredients_analysis_tags': ['en:vegetarian'],
      'ingredients':
          'Refined Wheat flour (Maida) (70%), Sugar, Refined Palm Oil, Invert Sugar Syrup [Sugar, Citric Acid], Iodized Salt, Raising Agents [503(ii), 500(ii)], Milk Solids, Artificial (Vanilla) Flavouring Substances, Emulsifier of Vegetable Origin[472e], And Flour Treatment Agent [1101(ii)] (D-Glucose, Levulose).',
    },
    {
      'barcodes': [
        'haldiram sev murmura',
        'haldiram sev murmura namkeen',
        'sev murmura',
        '8904004401554',
        '8906095262021',
      ],
      'name': 'Haldiram Sev Murmura',
      'calories': 535.0,
      'sugar': 2.51,
      'proteins': 8.4,
      'fats': 30.2,
      'carbs': 57.34,
      'labels': 'Vegetarian',
      'categories': 'Namkeen, puffed rice snack',
      'ingredients_analysis_tags': ['en:vegetarian'],
      'ingredients':
          'Puffed Rice (50%), Edible Vegetable Oil (Palmolein, Cotton Seed, Corn, Sunflower, Rice Bran), Bengal Gram Flour (Besan), Iodized Salt, Red Chilli, Garlic, Dried Onion Powder, Dried Garlic Powder, Lemon Powder, Cheese Powder, Yeast Extract, Acidity Regulator (INS 330), Colour (INS 160c), Flavour Enhancer (INS 627, INS 631) & Asafoetida.',
    },
    {
      'barcodes': ['7 up', '7up', 'seven up', '8902080704057', '8902080002283'],
      'name': '7UP Lemon Lime Drink',
      'calories': 44.0,
      'sugar': 11.0,
      'proteins': 0.0,
      'fats': 0.0,
      'carbs': 11.0,
      'labels': 'Vegetarian',
      'categories': 'Carbonated soft drink',
      'ingredients_analysis_tags': ['en:vegetarian'],
      'ingredients':
          'Carbonated water, sugar, acidity regulator, lemon and lime flavouring substances, preservative and permitted stabilisers.',
    },
  ];

  static String _normalizeLookupKey(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '').trim();
  }

  static Future<Map<String, dynamic>> fetchProductData(String barcode) async {
    final lookupKey = _normalizeLookupKey(barcode);

    for (final product in _products) {
      final aliases = product['barcodes'] as List<String>;
      final matchesProduct = aliases.any(
        (alias) => _normalizeLookupKey(alias) == lookupKey,
      );

      if (matchesProduct) {
        return Map<String, dynamic>.from(product)..remove('barcodes');
      }
    }

    throw Exception('Product not found in local database. Try Other Products.');
  }
}
