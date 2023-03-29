import 'package:parkassist/boundary/calculator_interface.dart';
import 'package:parkassist/control/pricing_controller.dart';
import 'package:flutter/material.dart';
import 'package:parkassist/control/carParkController.dart';
import 'package:parkassist/control/favouritesController.dart';
import 'package:parkassist/entity/carParkList.dart';
import 'package:parkassist/entity/favouritesEntity.dart';
import 'package:parkassist/entity/pricing.dart';

///Interface to display information on the selected car park
class InfoInterface extends StatefulWidget {
  final String carParkID;
  const InfoInterface({super.key, required this.carParkID});

  @override
  State<InfoInterface> createState() => _InfoInterfaceState();
}

class _InfoInterfaceState extends State<InfoInterface> {
  late CarPark carpark;
  bool inFav = false;
  String status = 'loading';

  @override
  void initState() {
    //uses getCarparkByID() to get carpark object
    carpark = CarParkController.getCarparkByID(widget.carParkID);
    print(carpark);
    fetchFavStatus(carpark, inFav);
    super.initState();
  }

  ///Get favourite status from favourites controller
  void fetchFavStatus(CarPark carpark, bool setFav) async {
    bool temp = await FavouritesController.inFavourites(carpark);
    print("carpark in fav: $temp");
    setState(() {
      inFav = temp;
      status = 'ready';
    });
  }

  ///Change favourite status
  void favStatusChange(bool setFav) {
    setState(() {
      inFav = setFav;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<List<CarPark>> favList = FavouritesEntity.fetchFavouritesList();
    if (status == 'ready') {
      return Scaffold(
        //carpark development name as appbar
        appBar: AppBar(
          title: Text('${carpark.development}'),
          backgroundColor: Colors.green,
          //favorites button. please add navigation
          actions: [
            IconButton(
                icon: inFav ? const Icon(Icons.star) : const Icon(Icons.star_border),
                onPressed: () {
                  favList.then((value) {
                    if (!inFav) {
                      FavouritesController.addToFavourites(value, carpark);
                      favStatusChange(true);
                    } else {
                      FavouritesController.removeFromFavourites(value, carpark);
                      favStatusChange(false);
                    }
                  });
                })
          ],
        ),
        body: Column(
          children: [
            //available lots text
            Container(
              color: Colors.grey.shade400,
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: RichText(
                  text: TextSpan(
                      text: 'Available Lots: ',
                      style: const TextStyle(color: Colors.black),
                      children: <TextSpan>[
                    TextSpan(
                        text: '${carpark.availableLots}',
                        style: const TextStyle(color: Colors.blue))
                  ])),
            ),
            Expanded(
                child: FutureBuilder<Records>(
              future:
                  //use carpark object with getPricingStrings to get pricing string. person doing calculatorcontroller can replace
                  PricingController().getPricingStrings(carpark),
              builder: (context, pricing) {
                if (pricing.hasData) {
                  var children2 = <Widget>[
                    //hdb pricing text
                    if (pricing.data!.weekdaysRate1 != null && pricing.data!.category == 'HDB')
                      Wrap(children: [
                        Container(
                          height: 50,
                          color: Colors.grey.shade700,
                          child: const Center(
                            child: Text('Parking Rates',
                                style: TextStyle(
                                  color: Colors.white,
                                )),
                          ),
                        ),
                        Container(
                          height: 50,
                          color: Colors.grey.shade400,
                          child: Center(child: Text('${pricing.data!.weekdaysRate1}')),
                        ),
                        if (pricing.data!.weekdaysRate2 != null)
                          Container(
                            height: 50,
                            color: Colors.grey.shade400,
                            child: Center(child: Text('${pricing.data!.weekdaysRate2}')),
                          ),
                        Container(
                          height: 50,
                        ),
                      ]),
                    //weekday pricing text
                    if (pricing.data!.weekdaysRate1 != null && pricing.data!.category != 'HDB')
                      Wrap(children: [
                        Container(
                          height: 50,
                          color: Colors.grey.shade700,
                          child: const Center(
                              child: Text('Weekday Rate',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ))),
                        ),
                        Container(
                          height: 50,
                          color: Colors.grey.shade400,
                          child: Center(child: Text('${pricing.data!.weekdaysRate1}')),
                        ),
                        if (pricing.data!.weekdaysRate2 != null)
                          Container(
                            height: 50,
                            color: Colors.grey.shade400,
                            child: Center(child: Text('${pricing.data!.weekdaysRate2}')),
                          ),
                        Container(
                          height: 50,
                        ),
                      ]),
                    //saturday pricing text
                    if (pricing.data!.saturdayRate != null)
                      Wrap(children: [
                        Container(
                          height: 50,
                          color: Colors.grey.shade700,
                          child: const Center(
                              child: Text('Saturday Rate',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ))),
                        ),
                        Container(
                          height: 50,
                          color: Colors.grey.shade400,
                          child: Center(child: Text('${pricing.data!.saturdayRate}')),
                        ),
                        Container(
                          height: 50,
                        ),
                      ]),
                    //sunday pricing text
                    if (pricing.data!.sundayPublicholidayRate != null)
                      Wrap(children: [
                        Container(
                          height: 50,
                          color: Colors.grey.shade700,
                          child: const Center(
                              child: Text('Sunday & Public Holidays Rate',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ))),
                        ),
                        Container(
                          height: 50,
                          color: Colors.grey.shade400,
                          child: Center(child: Text('${pricing.data!.sundayPublicholidayRate}')),
                        ),
                        Container(
                          height: 50,
                        ),
                      ]),
                  ];
                  return ListView(
                    padding: const EdgeInsets.all(8),
                    children: children2,
                  );
                } else if (pricing.hasError) {
                  return Text('${pricing.error}');
                }
                //when pricing info still loading/ doesnt load:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )),
            //calculator button. please add navigation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const CalculatorInterface()));
                  },
                  child: const Text('Parking Fee Calculator')),
            ),
          ],
        ),
      );
    } else {
      //when carpark info loading:
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
