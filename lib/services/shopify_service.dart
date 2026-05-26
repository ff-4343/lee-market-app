import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ShopifyService {
  static const String _storeUrl =
      'https://f61e20-88.myshopify.com/api/2024-01/graphql.json';
  static const String _storefrontToken = '54710e221c946a7f98e4ec4ca2df3029';

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'X-Shopify-Storefront-Access-Token': _storefrontToken,
  };

  static Future<Map<String, dynamic>> _query(String query,
      [Map<String, dynamic>? variables]) async {
    final body = json.encode({
      'query': query,
      if (variables != null) 'variables': variables,
    });

    final response = await http.post(
      Uri.parse(_storeUrl),
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['errors'] != null) {
        throw Exception('GraphQL errors: ${data['errors']}');
      }
      return data['data'] ?? {};
    } else {
      throw Exception(
          'HTTP error ${response.statusCode}: ${response.body}');
    }
  }

  static const String _productFields = '''
    id
    title
    description
    handle
    vendor
    productType
    tags
    images(first: 5) {
      edges {
        node {
          url
          altText
        }
      }
    }
    variants(first: 10) {
      edges {
        node {
          id
          title
          availableForSale
          quantityAvailable
          priceV2 {
            amount
            currencyCode
          }
        }
      }
    }
  ''';

  static Future<List<Product>> fetchProducts({
    int limit = 20,
    String? cursor,
    String? collectionHandle,
  }) async {
    String queryStr;

    if (collectionHandle != null) {
      queryStr = '''
        query GetCollectionProducts(\$handle: String!, \$limit: Int!, \$cursor: String) {
          collection(handle: \$handle) {
            products(first: \$limit, after: \$cursor) {
              edges {
                node { $_productFields }
              }
            }
          }
        }
      ''';
      final data = await _query(queryStr, {
        'handle': collectionHandle,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      });
      final edges = data['collection']?['products']?['edges'] as List? ?? [];
      return edges
          .map((e) => Product.fromJson(e['node'] as Map<String, dynamic>))
          .toList();
    } else {
      queryStr = '''
        query GetProducts(\$limit: Int!, \$cursor: String) {
          products(first: \$limit, after: \$cursor) {
            edges {
              node { $_productFields }
            }
          }
        }
      ''';
      final data = await _query(queryStr, {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      });
      final edges = data['products']?['edges'] as List? ?? [];
      return edges
          .map((e) => Product.fromJson(e['node'] as Map<String, dynamic>))
          .toList();
    }
  }

  static Future<Product?> fetchProductByHandle(String handle) async {
    const queryStr = '''
      query GetProduct(\$handle: String!) {
        product(handle: \$handle) {
          $_productFields
        }
      }
    ''';
    final data = await _query(queryStr, {'handle': handle});
    final node = data['product'];
    if (node == null) return null;
    return Product.fromJson(node as Map<String, dynamic>);
  }

  static Future<List<Product>> searchProducts(String query,
      {int limit = 20}) async {
    const queryStr = '''
      query SearchProducts(\$query: String!, \$limit: Int!) {
        products(first: \$limit, query: \$query) {
          edges {
            node { $_productFields }
          }
        }
      }
    ''';
    final data =
        await _query(queryStr, {'query': query, 'limit': limit});
    final edges = data['products']?['edges'] as List? ?? [];
    return edges
        .map((e) => Product.fromJson(e['node'] as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Collection>> fetchCollections({int limit = 20}) async {
    const queryStr = '''
      query GetCollections(\$limit: Int!) {
        collections(first: \$limit) {
          edges {
            node {
              id
              title
              handle
              description
              image {
                url
              }
            }
          }
        }
      }
    ''';
    final data = await _query(queryStr, {'limit': limit});
    final edges = data['collections']?['edges'] as List? ?? [];
    return edges
        .map((e) => Collection.fromJson(e['node'] as Map<String, dynamic>))
        .toList();
  }

  static Future<String?> createCheckout(
      List<Map<String, dynamic>> lineItems) async {
    const queryStr = '''
      mutation CheckoutCreate(\$lineItems: [CheckoutLineItemInput!]!) {
        checkoutCreate(input: { lineItems: \$lineItems }) {
          checkout {
            id
            webUrl
          }
          checkoutUserErrors {
            message
          }
        }
      }
    ''';
    final data = await _query(queryStr, {'lineItems': lineItems});
    final errors =
        data['checkoutCreate']?['checkoutUserErrors'] as List? ?? [];
    if (errors.isNotEmpty) {
      throw Exception(errors.map((e) => e['message']).join(', '));
    }
    return data['checkoutCreate']?['checkout']?['webUrl'] as String?;
  }
}
