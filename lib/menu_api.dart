import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

const menuUrl =
    'https://api.github.com/repos/FaisalTabrez/'
    'smart-canteen-pre-ordering-app/contents/assets/menu.json';

List<Food> parseMenu(String text) {
  final rows = jsonDecode(text) as List;
  final foods = rows
      .map((row) => Food(row['id'] as int, row['name'] as String, row['price'] as int))
      .toList();
  if (foods.isEmpty ||
      foods.any((food) => food.name.trim().isEmpty || food.price <= 0) ||
      foods.map((food) => food.id).toSet().length != foods.length) {
    throw const FormatException('Invalid menu');
  }
  return foods;
}

Future<List<Food>> fetchMenu({http.Client? client}) async {
  final connection = client ?? http.Client();
  try {
    final response = await connection
        .get(Uri.parse(menuUrl), headers: {'Accept': 'application/vnd.github.raw+json'})
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw Exception('Menu request failed');
    return parseMenu(utf8.decode(response.bodyBytes));
  } finally {
    connection.close();
  }
}
