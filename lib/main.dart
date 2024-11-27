import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pancake Receipts',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Pancake receipts'),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<String, Map<String, dynamic>> receipts = {
    'Classic Pancakes': {
      'image': 'assets/images/pic1.jpg',
      'calories': 227,
      'steps': [
        'Mix flour, baking powder, salt, and sugar in a bowl',
        'In another bowl, whisk together milk, eggs, and melted butter',
        'Combine wet and dry ingredients, mix until smooth',
        'Heat a pan over medium heat',
        'Pour 1/4 cup of batter for each pancake',
        'Cook until bubbles form, then flip and cook other side'
      ],
    },
    'Chocolate Chip Pancakes': {
      'image': 'assets/images/pic2.jpg',
      'calories': 250,
      'steps': [
        'Prepare classic pancake batter',
        'Fold in chocolate chips',
        'Mix flour, baking powder, salt, and sugar in a bowl',
        'In another bowl, whisk together milk, eggs, and melted butter',
        'Combine wet and dry ingredients, mix until smooth',
        'Heat a pan over medium heat',
        'Pour 1/4 cup of batter for each pancake',
        'Cook until bubbles form, then flip and cook other side'
      ],
    },
    'Blueberry Pancakes': {
      'image': 'assets/images/pic3.jpg',
      'calories': 300,
      'steps': [
        'Prepare classic pancake batter',
        'Gently fold in fresh blueberries',
        'Mix flour, baking powder, salt, and sugar in a bowl',
        'In another bowl, whisk together milk, eggs, and melted butter',
        'Combine wet and dry ingredients, mix until smooth',
        'Heat a pan over medium heat',
        'Pour 1/4 cup of batter for each pancake',
        'Cook until bubbles form, then flip and cook other side'
      ],
    },
    'Banana Pancakes': {
      'image': 'assets/images/pic4.jpg',
      'calories': 223,
      'steps': [
        'Mash ripe bananas and add to classic pancake batter',
        'Optionally add cinnamon for extra flavor',
        'Mix flour, baking powder, salt, and sugar in a bowl',
        'In another bowl, whisk together milk, eggs, and melted butter',
        'Combine wet and dry ingredients, mix until smooth',
        'Heat a pan over medium heat',
        'Pour 1/4 cup of batter for each pancake',
        'Cook until bubbles form, then flip and cook other side'
      ],
    },
  };

  String weatherInfo = 'Loading weather...';
  Timer? _timer;
  ScrollController _scrollController = ScrollController();//scrolling weather information

  @override
  void initState() {
    super.initState();
    fetchWeather();
    _timer = Timer.periodic(Duration(minutes: 10), (Timer t) => fetchWeather());
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(0.0);
      }
    });

    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        double newScrollOffset = _scrollController.offset + 1;
        if (newScrollOffset >= _scrollController.position.maxScrollExtent) {
          newScrollOffset = 0;
        }
        _scrollController.jumpTo(newScrollOffset);
      }
    });
  }

  Future<void> fetchWeather() async {
    final response = await http.get(Uri.parse('https://data.weather.gov.hk/weatherAPI/opendata/weather.php?dataType=rhrread&lang=en'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final temperature = data['temperature']['data'][0]['value'];
      final humidity = data['humidity']['data'][0]['value'];
      final warnings = data['warningMessage'] ?? '';

      setState(() {
        weatherInfo = 'Temperature: $temperature°C, Humidity: $humidity%';
        if (warnings.isNotEmpty) {
          weatherInfo += ' | Warnings: $warnings';
        }
      });
    } else {
      setState(() {
        weatherInfo = 'Failed to load weather data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue,
            height: 40,
            child: ListView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              children: [
                Row(
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width),
                    Text(
                      weatherInfo,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: receipts.entries.map((entry) {
                  String pancakeType = entry.key;
                  String imagePath = entry.value['image'] as String;
                  return GestureDetector(
                    onTap: () => _showReceipts(context, pancakeType),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            height: 150,
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              pancakeType,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReceipts(BuildContext context, String pancakeType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptsScreen(
          title: pancakeType,
          imagePath: receipts[pancakeType]!['image'] as String,
          calories: receipts[pancakeType]!['calories'] as int,
          steps: receipts[pancakeType]!['steps'] as List<String>,
        ),
      ),
    );
  }
}

class ReceiptsScreen extends StatelessWidget {
  final String title;
  final String imagePath;
  final int calories;
  final List<String> steps;

  ReceiptsScreen({
    required this.title,
    required this.imagePath,
    required this.calories,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              imagePath,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Receipt Steps',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Calories: $calories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
            ),
            for (int i = 0; i < steps.length; i++)
              ListTile(
                leading: CircleAvatar(
                  child: Text('${i + 1}'),
                ),
                title: Text(steps[i]),
              ),
          ],
        ),
      ),
    );
  }
}