import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(AQIMonitorApp());
}

class AQIMonitorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, // ใช้ Material 3
        colorScheme: ColorScheme.light(
          primary: Colors.blue[700]!, // สีหลัก
          secondary: Colors.blue[400]!, // สีรอง
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto', color: Colors.white),  // เปลี่ยนจาก bodyText1 เป็น bodyLarge
        ),
      ),
      home: AirQualityScreen(),
    );
  }
}

class AirQualityScreen extends StatefulWidget {
  @override
  _AirQualityScreenState createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AirQualityScreen> {
  String city = "Loading...";
  int aqi = 0;
  double temperature = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAirQuality();
    Timer.periodic(Duration(minutes: 5), (timer) {
      fetchAirQuality();
    });
  }

  Future<void> fetchAirQuality() async {
    final url =
        Uri.parse("https://api.waqi.info/feed/here/?token=6cd4fe92cc98ff29768a279f2d04658cf120df14");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == "ok") {
          setState(() {
            city = data['data']['city']['name'];
            aqi = data['data']['aqi'];
            temperature = data['data']['iaqi']['t']['v'].toDouble();
            isLoading = false;
          });
        } else {
          setState(() {
            city = "Error fetching data";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          city = "Error fetching data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        city = "Unable to fetch data";
        isLoading = false;
      });
    }
  }

  Color getAqiColor(int aqi) {
    if (aqi <= 50) return Colors.blue;
    if (aqi <= 100) return Colors.lightBlue;
    if (aqi <= 150) return Colors.lightBlueAccent;
    if (aqi <= 200) return Colors.blueAccent;
    if (aqi <= 300) return Colors.deepPurpleAccent;
    return Colors.indigo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50], // Light blue background
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.air, color: Colors.white),
            SizedBox(width: 10),
            Text("Air Quality Index (AQI)",
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ],
        ),
        backgroundColor: Colors.blue[700], // Dark blue AppBar
        elevation: 0,
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      city,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              "$aqi",
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                color: getAqiColor(aqi),
                              ),
                            ),
                            Text(
                              aqi > 150 ? "Unhealthy" : "Good",
                              style: TextStyle(
                                fontSize: 22,
                                color: getAqiColor(aqi),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      "Temperature: ${temperature.toStringAsFixed(1)}°C",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
  onPressed: fetchAirQuality,
  child: Text("Refresh"),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue[700], // กำหนดสีพื้นหลังของปุ่ม
    foregroundColor: Colors.white, // กำหนดสีข้อความบนปุ่ม
    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    textStyle: TextStyle(fontSize: 18),
  ),
),
                  ],
                ),
              ),
      ),
    );
  }
}
