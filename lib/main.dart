import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'app.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int index = 2;
  String search = '';
  late InAppWebViewController inAppWebViewController;
  late PullToRefreshController pullToRefreshController;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (Platform.isAndroid) {
          await inAppWebViewController.reload();
        } else if (Platform.isIOS) {
          Uri? url = await inAppWebViewController.getUrl();

          inAppWebViewController.loadUrl(
            urlRequest: URLRequest(url: url),
          );
        }
      },
      options: PullToRefreshOptions(color: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'OTT PLATFORM',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: (search == "")
          ? SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://wallpapercave.com/wp/wp2817752.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 5 / 6,
                  ),
                  itemCount: Val.website.length,
                  itemBuilder: (context, i) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          search = Val.website[i]['site'];
                          textEditingController.text = search;
                          Val.history.add(Val.website[i]['site']);
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Image.network(Val.website[i]['img']),
                          ),
                          Text(
                            Val.website[i]['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          : SafeArea(
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: Uri.parse('https://www.google.com/search?q=$search'),
                ),
                onWebViewCreated: (val) {
                  setState(() {
                    inAppWebViewController = val;
                  });
                },
                pullToRefreshController: pullToRefreshController,
                onLoadStop: (context, uri) {
                  pullToRefreshController.endRefreshing();
                },
              ),
            ),
      backgroundColor: Colors.white,
      bottomSheet: Container(
        height: 50,
        width: width,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: CupertinoSearchTextField(
          controller: textEditingController,
          onSuffixTap: () {
            setState(() {
              search = "";
              textEditingController.clear();
            });
          },
          onSubmitted: (val) async {
            search = val;
            textEditingController.text = search;
            inAppWebViewController.loadUrl(
              urlRequest: URLRequest(
                url: Uri.parse('https://www.google.com/search?q=$search'),
              ),
            );
            Val.history.add('https://www.google.com/search?q=$search');
          },
        ),
      ),
      floatingActionButton: (search != '')
          ? Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: FloatingActionButton(
                child: const Icon(Icons.bookmark),
                onPressed: () {
                  setState(() {
                    Val.bookmark.add('https://www.google.com/search?q=$search');

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("BookMark Added Sucesfully"),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  });
                },
              ),
            )
          : Container(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 5,
        onTap: (val) async {
          setState(() {
            index = val;
          });

          if (index == 0) {
            if (await inAppWebViewController.canGoBack()) {
              await inAppWebViewController.goBack();

              Uri? uri = await inAppWebViewController.getUrl();

              textEditingController.text = uri.toString();
            }
          } else if (index == 1) {
            if (await inAppWebViewController.canGoForward()) {
              await inAppWebViewController.goForward();
              Uri? uri = await inAppWebViewController.getUrl();
              textEditingController.text = uri.toString();
            }
          } else if (index == 2) {
            search = "";
            textEditingController.clear();
          } else if (index == 3) {
            showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(50))),
              context: context,
              builder: (context) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  expand: false,
                  builder: (context, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child:
                              Text("History", style: TextStyle(fontSize: 22)),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: Val.history.map((e) {
                                return TextButton(
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      search = e;
                                      Navigator.pop(context);
                                      inAppWebViewController.loadUrl(
                                        urlRequest: URLRequest(
                                          url: Uri.parse(e),
                                        ),
                                      );
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          } else {
            showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(50))),
              context: context,
              builder: (context) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  expand: false,
                  builder: (context, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child:
                              Text("BookMark", style: TextStyle(fontSize: 22)),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: Val.bookmark.map((e) {
                                return TextButton(
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      search = e;
                                      Navigator.pop(context);
                                      inAppWebViewController.loadUrl(
                                        urlRequest: URLRequest(
                                          url: Uri.parse(e),
                                        ),
                                      );
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back_sharp),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_forward_sharp),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_rounded),
            label: '',
          ),
        ],
      ),
    );
  }
}
