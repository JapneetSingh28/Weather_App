import 'package:flutter/material.dart';
import './ui/klimatic.dart';

void main(){
  runApp(
      new MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather App',
        home: new Klimatic(),
      )
  );
}