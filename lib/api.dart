import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:io';

//? For this app, the only [Category] endpoint we retreive from an API is Currency.
//? If we had more, we could keep a list of [Categories] here
const apiCategory = {
  'name': 'Currency',
  'route': 'currency',
};

//? The REST API retreives unit conversions for [Categories] that change.
//? For example, the currency exchange rate, stock prices, the height of the
//? tides change often.
//? We have set up an API that retreives a list of currencies and their current
//? exchange rate (mock data).
//? GET /currency: get a list of currencies.
//? GET /currency/convert: get conversion from one currency amount to another

class Api {
//? We use  the 'dart:io' Httpclient.
//? We specify the rtpe here for readibility. Since we're defining a final
//? field, the type is determined at initilization.

  final HttpClient _httpClient = HttpClient();

//? The API endpoint we want to hit.
//? This API doesnot have a key but often, APIs do require authentication
  final String _url = 'flutter.udacity.com';

//? Gets all the units and conversion rates for a given category.
//? The 'category' parameter is the name of the [Category] from which to
//? retreive units. We pass this into the query parameter in the API call.
//
//? Returns a list. Returns null on Error.
  Future<List> getUnits(String category) async {
    final uri = Uri.https(_url, '/$category');
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['units'] == null) {
      print('Error Retreiving Units.');
      return null;
    }
    return jsonResponse['units'];
  }

//? Given two units, converts from one another.
//? Returns a double, which is the converted amount. Returns null on error.
  Future<double> convert(
      String category, String amount, String fromUnit, String toUnit) async {
    final uri = Uri.https(_url, '/$category/convert',
        {'amount': amount, 'from': fromUnit, 'to': toUnit});
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['status'] == null) {
      print('Error retreiving conversion.');
      return null;
    } else if (jsonResponse['status'] == 'error') {
      print(jsonResponse['message']);
      return null;
    }
    return jsonResponse['conversion'].toDouble();
  }

//? Fetches and decodes a JSON object represented as a Dart [Map].
//
//? Returns null if the API server is down, or the response is not JSON.
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final httpRequest = await _httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.ok) {
        return null;
      }
      //? The response is sent as a Stream of bytes that we need to convert to a
      //? 'String'
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      //? Finally, the String is parsed into JSON Object.
      return json.decode(responseBody);
    } on Exception catch (e) {
      print('Error $e');
      return null;
    }
  }
}
