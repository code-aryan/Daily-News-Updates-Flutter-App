import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newsappflutter/InfoNews.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:newsappflutter/countries.dart';

var cName;
var country;
var catagory;
var find_news;

GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

toggleDrawer() async {
  if (_scaffoldKey.currentState.isDrawerOpen) {
    _scaffoldKey.currentState.openEndDrawer();
  } else {
    _scaffoldKey.currentState.openDrawer();
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isSwitched = false;
  var news;

  int currentLength = 0;
  List<int> data = [];
  int increment = 0;
  bool isLoading = false;

  @override
  void initState() {
    getNews();
    super.initState();
  }

  getNewsChannel(channel) async {
    var url =
        "https://newsapi.org/v2/top-headlines?sources=$channel&apiKey=58b98b48d2c74d9c94dd5dc296ccf7b6";

    http.Response res = await http.get(url);
    var json = jsonDecode(res.body)['totalResults'] == 0
        ? "notFound"
        : jsonDecode(res.body)['articles'];
    setState(() {
      news = json;
    });
  }

  getNews() async {
    var url;
    if (country == null) {
      if (catagory == null) {
        url =
            "https://newsapi.org/v2/top-headlines?country=in&apiKey=58b98b48d2c74d9c94dd5dc296ccf7b6";
      } else {
        url =
            "https://newsapi.org/v2/top-headlines?country=in&category=$catagory&apiKey=58b98b48d2c74d9c94dd5dc296ccf7b6";
      }
    } else {
      if (catagory == null) {
        url =
            "https://newsapi.org/v2/top-headlines?country=$country&apiKey=58b98b48d2c74d9c94dd5dc296ccf7b6";
      } else {
        url =
            "https://newsapi.org/v2/top-headlines?country=$country&category=$catagory&apiKey=58b98b48d2c74d9c94dd5dc296ccf7b6";
      }
    }
    print(url);
    http.Response res = await http.get(url);

    var json = jsonDecode(res.body)['articles'];
    setState(() {
      news = json;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News',
      theme: isSwitched ? ThemeData.light() : ThemeData.dark(),
      home: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 60),
            children: <Widget>[
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    country != null ? Center(child: Text("Showing News from $cName",textAlign: TextAlign.center)) : Container(),
                    SizedBox(
                      height: 10,
                    ),
                    catagory != null
                        ? Center(child: Text("News category is ${catagory}"))
                        : Container(),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(hintText: "Find Keyword"),
                          onChanged: (val) {
                            setState(() {
                              find_news = val;
                            });
                          },
                        ),
                      ),
                    ),
                    FlatButton(
                      child: Text("Find"),
                      onPressed: () async {
                        http.Response res = await http.get(
                            "https://newsapi.org/v2/top-headlines?q=$find_news&apiKey=58b98b48d2c74d9c94dd5dc296ccf7b6");

                        var json = jsonDecode(res.body)['totalResults'] == 0
                            ? "notFound"
                            : jsonDecode(res.body)['articles'];
                        setState(() {
                          news = json;
                        });

                        toggleDrawer();
                      },
                    ),
                  ],
                ),
              ),
              ExpansionTile(
                title: Text("Select Country"),
                children: <Widget>[
                  for (int i = 0; i < listOfCountry.length; i++)
                    DropDownList(
                      call: () {
                        country = listOfCountry[i]['code'];
                        cName = listOfCountry[i]['name'].toUpperCase();
                        getNews();
                        toggleDrawer();
                      },
                      name: listOfCountry[i]['name'].toUpperCase(),
                    ),
                ],
              ),
              ExpansionTile(
                title: Text("Select Catagory"),
                children: [
                  for (int i = 0; i < listOfCatagory.length; i++)
                    DropDownList(
                      call: () {
                        catagory = listOfCatagory[i]['code'];
                        getNews();
                        toggleDrawer();
                      },
                      name: listOfCatagory[i]['name'].toUpperCase(),
                    ),
                ],
              ),
              ExpansionTile(
                title: Text("Select News Channel"),
                children: [
                  for (int i = 0; i < listOfNewsChannel.length; i++)
                    DropDownList(
                      call: () {
                        getNewsChannel(listOfNewsChannel[i]['code']);
                        toggleDrawer();
                      },
                      name: listOfNewsChannel[i]['name'].toUpperCase(),
                    ),
                ],
              ),
            ],
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: Text("Daily News "),
          actions: [
            IconButton(
              onPressed: () {
                country = null;
                catagory = null;
                find_news = null;
                cName = null;
                getNews();
              },
              icon: Icon(Icons.refresh),
            ),
            Switch(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                });
              },
              activeTrackColor: Colors.blueGrey,
              activeColor: Colors.white,
            ),
          ],
        ),
        body: news == null
            ? Center(child: CircularProgressIndicator())
            : news == "notFound"
                ? Center(
                    child: Image.network(
                        "https://www.estrategiaswebcolombia.com/nuevo/wp-content/uploads/09/404-735x465.png"),
                  )
                : ListView.builder(
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Artical_News(
                                NewsUrl: news[index]['url'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30)),
                          child: Column(
                            children: [
                              Stack(children: [
                                news[index]['urlToImage'] == null
                                    ? Container()
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) => Container(
                                              child:
                                                  CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                          imageUrl: news[index]['urlToImage'],
                                        ),
                                      ),
                                Positioned(
                                  bottom: 10,
                                  right: 20,
                                  child: Text(
                                    "${news[index]['source']['name']}",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ]),
                              SizedBox(height: 15),
                              Text(
                                "${news[index]['title']}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20,fontStyle: FontStyle.italic),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: news.length,
                  ),
      ),
    );
  }
}

class DropDownList extends StatelessWidget {
  final String name;
  final Function call;

  const DropDownList({Key key, this.name, this.call}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ListTile(
        title: Text(name),
      ),
      onTap: call,
    );
  }
}
