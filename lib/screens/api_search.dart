import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _coins = [];

  void _searchCoins(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://api.coinranking.com/v2/search-suggestions?query=$query'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _coins = data['data']['coins'];
      });
    } else {
      print('Failed to load coins');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Coins'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.manage_search_rounded),
                  onPressed: () => _searchCoins(_controller.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _coins.length,
              itemBuilder: (context, index) {
                final coin = _coins[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: new BorderRadius.circular(30.0),
                    child: Image.network(
                      coin['iconUrl'],
                      fit: BoxFit.cover,
                      height: 40.0,
                      width: 40.0,
                      errorBuilder: (context, error, stackTrace) => ClipRRect(
                        child: SvgPicture.network(
                          coin['iconUrl'],
                          fit: BoxFit.cover,
                          height: 40.0,
                          width: 40.0,
                        ),
                      ),
                    ),
                  ),
                  title: Text(coin['name']),
                  subtitle: Text(coin['symbol']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
