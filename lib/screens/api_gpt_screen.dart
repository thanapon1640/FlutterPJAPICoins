import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Coin {
  final String symbol;
  final String name;
  final String iconUrl;
  final String price;
  final String change;
  final String uuid;
  final int rank;
  final String coinrankingUrl;

  Coin({
    required this.price,
    required this.name,
    required this.symbol,
    required this.iconUrl,
    required this.change,
    required this.uuid,
    required this.rank,
    required this.coinrankingUrl,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      name: json['name'],
      change: json['change'],
      symbol: json['symbol'],
      iconUrl: json['iconUrl'],
      price: json['price'],
      uuid: json['uuid'],
      rank: json['rank'],
      coinrankingUrl: json['coinrankingUrl'],
    );
  }
}

Future<List<Coin>> fetchCoins() async {
  final response =
      await http.get(Uri.parse('https://api.coinranking.com/v2/coins'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body)['data']['coins'];
    List<Coin> coins = data.map((coin) => Coin.fromJson(coin)).toList();
    return coins;
  } else {
    throw Exception('Failed to load coins');
  }
}

class CoinsPage extends StatefulWidget {
  const CoinsPage({super.key});

  @override
  CoinsPageState createState() => CoinsPageState();
}

class CoinsPageState extends State<CoinsPage> {
  late Future<List<Coin>> futureCoins;

  @override
  void initState() {
    super.initState();
    futureCoins = fetchCoins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitcoin API Tracking'),
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder<List<Coin>>(
          future: futureCoins,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  // Coin coin = snapshot.data![index];

                  return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                      child: Card(
                        elevation: 3,
                        child: ListTile(
                          leading: Image.network(snapshot.data![index].iconUrl,
                              width: 30.0,
                              height: 30.0,
                              errorBuilder: (context, error, stacktrace) =>
                                  SvgPicture.network(
                                    snapshot.data![index].iconUrl,
                                    width: 30.0,
                                    height: 30.0,
                                  )),
                          title: Text(snapshot.data![index].name),
                          subtitle: Text(snapshot.data![index].symbol),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('\$ ${snapshot.data![index].price}'),
                              Text('${snapshot.data![index].change}'),
                            ],
                          ),
                          dense: false,
                          onTap: () => showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${snapshot.data![index].symbol}',
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Rank :  ${snapshot.data![index].rank}',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    Center(
                                      child: CircleAvatar(
                                        radius: 110,
                                        child: Image.network(
                                            snapshot.data![index].iconUrl,
                                            width: 140.0,
                                            height: 140.0,
                                            errorBuilder: (context, error,
                                                    stacktrace) =>
                                                SvgPicture.network(
                                                  snapshot.data![index].iconUrl,
                                                  width: 140.0,
                                                  height: 140.0,
                                                )),
                                      ),
                                    ),
                                    Spacer(),
                                    ElevatedButton(
                                      child: Center(
                                        child: new Text(
                                          'Show more detail',
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        Uri _url = Uri.parse(
                                            '${snapshot.data![index].coinrankingUrl}');
                                        await launchUrl(_url);
                                      },
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                      ));
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
