import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class Home extends StatefulWidget {
  static const routeName = '/';

  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  // กำนหดตัวแปรข้อมูล products
  late Future<List<Product>> products;
  // ตัว ScrollController สำหรับจัดการการ scroll ใน ListView
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    products = fetchProduct();
  }

  Future<void> _refresh() async {
    setState(() {
      products = fetchProduct();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: FutureBuilder<List<Product>>(
          // ชนิดของข้อมูล
          future: products, // ข้อมูล Future
          builder: (context, snapshot) {
            // มีข้อมูล และต้องเป็น done ถึงจะแสดงข้อมูล ถ้าไม่ใช่ ก็แสดงตัว loading
            if (snapshot.hasData) {
              bool _visible =
                  false; // กำหนดสถานะการแสดง หรือมองเห็น เป็นไม่แสดง
              if (snapshot.connectionState == ConnectionState.waiting) {
                // เมื่อกำลังรอข้อมูล
                _visible = true; // เปลี่ยนสถานะเป็นแสดง
              }
              if (_scrollController.hasClients) {
                //เช็คว่ามีตัว widget ที่ scroll ได้หรือไม่ ถ้ามี
                // เลื่อน scroll มาด้านบนสุด
                _scrollController.animateTo(0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn);
              }
              return Column(
                children: [
                  Visibility(
                    child: const LinearProgressIndicator(),
                    visible: _visible,
                  ),
                  Container(
                    // สร้างส่วน header ของลิสรายการ
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(100),
                    ),
                    child: Row(
                      children: [
                        Text(
                            'Total ${snapshot.data!.length} items'), // แสดงจำนวนรายการ
                      ],
                    ),
                  ),
                  Expanded(
                    // ส่วนของลิสรายการ
                    child: snapshot.data!.isNotEmpty // กำหนดเงื่อนไขตรงนี้
                        ? RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.separated(
                              // กรณีมีรายการ แสดงปกติ
                              controller:
                                  _scrollController, // กำนหนด controller ที่จะใช้งานร่วม
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                Product product = snapshot.data![index];

                                Widget card; // สร้างเป็นตัวแปร
                                card = Card(
                                    margin: const EdgeInsets.all(
                                        5.0), // การเยื้องขอบ
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: Image.network(
                                            product.image,
                                            width: 100.0,
                                          ),
                                          title: Text(product.title),
                                          subtitle: Text(
                                              'Price: \$ ${product.price}'),
                                          trailing: Icon(Icons.more_vert),
                                          onTap: () {},
                                        ),
                                      ],
                                    ));
                                return card;
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const SizedBox(),
                            ),
                          )
                        : const Center(
                            child: Text('No items')), // กรณีไม่มีรายการ
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              // กรณี error
              return Text('${snapshot.error}');
            }
            // กรณีสถานะเป็น waiting ยังไม่มีข้อมูล แสดงตัว loading
            return const RefreshProgressIndicator();
          },
        ),
      ),
    );
  }
}

// สรัางฟังก์ชั่นดึงข้อมูล คืนค่ากลับมาเป็นข้อมูล Future ประเภท List ของ Product
Future<List<Product>> fetchProduct() async {
  // ทำการดึงข้อมูลจาก server ตาม url ที่กำหนด
  String url = 'https://fakestoreapi.com/products';
  final response = await http.get(Uri.parse(url));

  // เมื่อมีข้อมูลกลับมา
  if (response.statusCode == 200) {
    // ส่งข้อมูลที่เป็น JSON String data ไปทำการแปลง เป็นข้อมูล List<Product
    // โดยใช้คำสั่ง compute ทำงานเบื้องหลัง เรียกใช้ฟังก์ชั่นชื่อ parseProducts
    // ส่งข้อมูล JSON String data ผ่านตัวแปร response.body
    return compute(parseProducts, response.body);
  } else {
    // กรณี error
    throw Exception('Failed to load product');
  }
}

// ฟังก์ชั่นแปลงข้อมูล JSON String data เป็น เป็นข้อมูล List<Product>
List<Product> parseProducts(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Product>((json) => Product.fromJson(json)).toList();
}
