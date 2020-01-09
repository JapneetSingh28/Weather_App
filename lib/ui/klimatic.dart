import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../util/utils.dart' as util;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => new _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {

  String _cityEntered;


  Future<bool> _onBackPressed() {
    return showDialog(context: context,
        builder: (context) =>AlertDialog(
          title: Text("Do you really want to exit?",style: TextStyle(fontFamily: 'OpenSansRegular' ,fontSize: 18.5),),
          actions: <Widget>[
            FlatButton(
              child: Text("No",style:TextStyle(color: Colors.orange),),
              onPressed: ()=>Navigator.pop(context,false),
            ),
            FlatButton(
              child: Text("Yes",style: TextStyle(color: Colors.red),),
              onPressed: ()=>Navigator.pop(context,true),
            ),
          ],
        ));
  }

  Future _goToNextScreen(BuildContext context) async {
    Map results = await Navigator
        .of(context)
        .push(new MaterialPageRoute<Map>(builder: (BuildContext context) { //change to Map instead of dynamic for this to work
      return new ChangeCity();
    }));

    if ( results != null && results.containsKey('enter')) {
      _cityEntered = results['enter'];
//      debugPrint("From First screen" + results['enter'].toString());
    }
  }
@override
  void initState() {
    super.initState();
  }
  void showStuff() async {
    Map data = await getWeather(util.appId, util.defaultCity);
  }

  Map content;

  @override
  Widget build(BuildContext context) {
//    print("${content['main']['temp'].toString()}" ?? "Null");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      appBar:   AppBar(
        title:   Text('Weather App'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
            IconButton(
              icon:   Icon(Icons.menu),
              onPressed: () {
                _goToNextScreen(context);
              })
        ],
      ),
      body:  WillPopScope(
        onWillPop: _onBackPressed,
        child: Stack(
          children: <Widget>[
              Center(
                 child:   Image.asset(
                'images/umbrella.png',
                width: 490.0,
                height: 1200.0,
                fit: BoxFit.fill,
              ),
            ),
              Container(
              alignment: Alignment.topRight,
              margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
                child:   Text(
                '${_cityEntered == null ? util.defaultCity : _cityEntered}',
                style: cityStyle(),
              ),
            ),

              Container(
              alignment: Alignment.center,
              child:   Image.asset('images/light_rain.png'),
            ),
            updateTempWidget(_cityEntered)

            //Container which will have our weather data
//            Container(
//            //margin: const EdgeInsets.fromLTRB(30.0, 310.0, 0.0, 0.0),
//
//            child: ,
//          )
          ],
        ),
      ),
    );
  }

  Future<Map> getWeather(String appId, String city) async {
    String apiUrl =
        'http://api.openweathermap.org/data/2.5/weather?q=$city&appid='
        '${util.appId}&units=metric';

    http.Response response = await http.get(apiUrl);

    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return   FutureBuilder(
        future: getWeather(util.appId, city == null ? util.defaultCity : city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          //where we get all of the json data, we setup widgets etc.
          if (snapshot.hasData) {
            Map content = snapshot.data;
            if (content.containsKey("main")){
               return Container(
              margin: const EdgeInsets.fromLTRB(30.0, 250.0, 0.0, 0.0),
              child:   Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    ListTile(
                    title:   Text(
                      content['main']['temp'].toString() +"°C"??"Not Ava.",
                      style: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontSize: 49.9,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                    subtitle:   ListTile(
                      title:   Text(
                        "Humidity: ${content['main']['humidity'].toString()}\n"
                            "Min: ${content['main']['temp_min'].toString()} °C\n"
                            "Max: ${content['main']['temp_max'].toString()} °C " ?? "Not Ava.",
                        style: extraData(),

                      ),
                    ),
                  )
                ],
              ),
            );}else{
              return Container(
                margin: const EdgeInsets.fromLTRB(30.0, 250.0, 0.0, 0.0),
                child:   Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
                      title:   Text(
                        "Currently Unavailable",
                        style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontSize: 30.9,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      subtitle:   ListTile(
                        title:   Text(
                          "Humidity: Currently Unavailable\n"
                              "Min: Currently Unavailable\n"
                              "Max: Currently Unavailable",
                          style: extraData(),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
          } else {
            return  Container();
          }
        });
  }
}

class ChangeCity extends StatefulWidget {

  @override
  _ChangeCityState createState() => _ChangeCityState();
}

class _ChangeCityState extends State<ChangeCity> {
  var _cityFieldController =   TextEditingController();

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      appBar:   AppBar(
        backgroundColor: Colors.red,
        title:   Text('Change City'),
        centerTitle: true,
      ),
      body:   Stack(
        children: <Widget>[
            Center(
            child: Image.asset(
              'images/white_snow.png',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),

            ListView(
            children: <Widget>[
                ListTile(
                  title: TextField(
                    onSubmitted: (val){ _cityFieldController.text= (val ?? "Delhi");},
                    textCapitalization: TextCapitalization.words,
//                    onChanged: (val){ _cityFieldController.text=val;},
                  decoration:   InputDecoration(
                    labelText: 'Enter City',
                    hintText: 'For example: Delhi....',
                  ),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
                ListTile(
                  title: FlatButton(
                    onPressed: () {
                      if(_cityFieldController.text != "" )
                      Navigator.pop(context, {
                        'enter': _cityFieldController.text
                      });
                    },
                    textColor: Colors.white70,
                    color: Colors.redAccent,
                    child:   Text('Get Weather')),
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ListTile(
              title: Text("Japneet Singh",style: TextStyle(fontSize: 16),),
              subtitle: Text("Flutter Developer",style: TextStyle(fontSize: 14,),),
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle cityStyle() {
  return   TextStyle(
      color: Colors.white, fontSize: 22.9, fontStyle: FontStyle.italic);
}

TextStyle extraData() {
  return   TextStyle(
      color: Colors.white70,
      fontStyle: FontStyle.normal,
      fontSize: 17.0);

}
TextStyle tempStyle() {
  return   TextStyle(
      color: Colors.white,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontSize: 49.9);
}
