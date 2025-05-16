import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:monsy_weird_package/dio/product_model.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  Future<List<ProductModel>> getData() async {
    final response = await Dio().get('https://fakestoreapi.com/products');

    List<ProductModel> data = [];

    for (var item in response.data) {
      data.add(ProductModel.fromJson(item));
    }
    return data;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 20,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    childAspectRatio: .595,
                    crossAxisSpacing: 10),
                itemBuilder: (context, index) {
                  return FutureBuilder(
                      future: getData(),
                      builder: (context, snapshot) {
                        // data received
                        if (snapshot.hasData) {
                          List? products = snapshot.data;
                          return GestureDetector(
                              onTap: () {},
                              child: shopItemContainer(products, index));
                        }

                        // error trying to get data
                        else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        }

                        // still waiting
                        else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      });
                })));
  }

  Container shopItemContainer(List<dynamic>? products, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey, width: 2)),
      child: Column(
        children: [
          Image.network(
            colorBlendMode: BlendMode.color,
            products?[index].image,
            height: 200,
            width: 200,
            fit: BoxFit.contain,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                SizedBox(
                    height: 40,
                    child: Text(
                      products?[index].title,
                      style: const TextStyle(overflow: TextOverflow.fade),
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Text(
                                '\$',
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic),
                              ),
                              Text(
                                products![index].price.toString(),
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          // Text(
                          //   "Price",
                          //   style: TextStyle(fontStyle: FontStyle.italic,color: colors[1].withOpacity(.8),),
                          // )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
