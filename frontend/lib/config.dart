/// Configuration for backend server connection
/// 
/// IMPORTANT: When connecting via USB cable, ensure the smartphone and computer are on the same network
/// Update serverIp if your machine's IP address changes
/// Command to find your IP: ifconfig | grep "inet " | grep -v 127.0.0.1
library;

class Config {
  static const bool useLocalBackend = false;

  // Backend server configuration
  static const String serverIp = '192.168.1.5'; // Update this with your machine's IP
  static const int serverPort = 5000;
  static const String serverUrl = 'http://$serverIp:$serverPort';
  
  // API Endpoints
  static const String barcodeEndpoint = '$serverUrl/barcode';
  static const List<String> openFoodFactsHosts = [
    'world.openfoodfacts.org',
    'in.openfoodfacts.org',
    'us.openfoodfacts.org',
  ];
  static final String openFoodFactsFields = [
    'status',
    'product_name',
    'generic_name',
    'nutriments',
    'ingredients_text',
    'ingredients_text_en',
    'ingredients_text_with_allergens',
    'ingredients_text_with_allergens_en',
    'ingredients',
    'labels',
    'labels_tags',
    'categories',
    'categories_tags',
    'ingredients_analysis_tags',
  ].join(',');

  /// Get the barcode endpoint with query parameter
  static String getBarcodeUrl(String barcode) {
    return '$barcodeEndpoint?barcode=$barcode';
  }

  /// Fallback mobile data endpoint for OpenFoodFacts
  static List<String> getOpenFoodFactsUrls(String barcode) {
    return openFoodFactsHosts
        .map(
          (host) =>
              'https://$host/api/v2/product/$barcode.json?fields=$openFoodFactsFields',
        )
        .toList();
  }
}
