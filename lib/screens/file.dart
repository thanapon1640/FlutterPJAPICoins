import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Coin {
  final String uuid;
  final String name;
  final String description;
  final double price;

  Coin(
      {required this.uuid,
      required this.name,
      required this.description,
      required this.price});

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      uuid: json['uuid'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price']),
    );
  }
}

Future<List<Coin>> fetchCoins() async {
  final response =
      await http.get(Uri.parse('https://api.coinranking.com/v2/coin/'));
  if (response.statusCode == 200) {
    List coins = json.decode(response.body)['data']['coins'];
    return coins.map((coin) => Coin.fromJson(coin)).toList();
  } else {
    throw Exception('Failed to load coins');
  }
}

class CoinDetails extends StatefulWidget {
  @override
  CoinDetailsState createState() => CoinDetailsState();
}

class CoinDetailsState extends State<CoinDetails> {
  late Future<Coin> futureCoin;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Coin>>(
      future: fetchCoins(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final coin = snapshot.data![index];
              return ListTile(
                title: Text(coin.name),
                subtitle: Text(coin.description),
                trailing: Text('\$${coin.price.toStringAsFixed(2)}'),
                onTap: () {
                  // Show Bottom Sheet with coin's uuid data
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price: \$${coin.price.toStringAsFixed(2)}'),
                          // SizedBox(height: 😎,
                          Text('Description: ${coin.description}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
