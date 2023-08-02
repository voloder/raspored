import 'package:flutter/material.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:localstorage/localstorage.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:flex_color_picker/flex_color_picker.dart';

void main() {
  runApp(MyApp());
}

T castOrFallback<T>(dynamic x, T fallback) => x is T ? x : fallback;

class AppBuilder extends StatefulWidget {
  final Function(BuildContext) builder;

  const AppBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  AppBuilderState createState() => AppBuilderState();

  static AppBuilderState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppBuilderState>();
  }
}

class AppBuilderState extends State<AppBuilder> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  void rebuild() {
    setState(() {});
  }
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final LocalStorage _storage = LocalStorage('raspored.json');
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _storage.ready,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return AppBuilder(builder: (context) {
            Color color = Color(
                castOrFallback(_storage.getItem("color"), Colors.teal.value));
            return MaterialApp(
                title: 'Raspored Časova',
                themeMode: _storage.getItem("darktheme") ?? false
                    ? ThemeMode.dark
                    : ThemeMode.light,
                darkTheme: ThemeData(
                  scaffoldBackgroundColor: Colors.grey[900],
                  brightness: Brightness.dark,
                  primaryColor: color,
                  appBarTheme: AppBarTheme(color: color),
                  backgroundColor: Colors.white,
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                      unselectedItemColor: Colors.grey[400],
                      selectedItemColor: Colors.white),
                  textTheme: const TextTheme(
                    headline4: TextStyle(color: Colors.white),
                  ),
                ),
                theme: ThemeData(
                  brightness: Brightness.light,
                  primaryColor: color,
                  appBarTheme: AppBarTheme(color: color),
                  backgroundColor: Colors.black,
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                      unselectedItemColor: Colors.grey[600],
                      selectedItemColor: Colors.black),
                  textTheme: const TextTheme(
                    headline4: TextStyle(color: Colors.black),
                  ),
                ),
                home: Material(
                  child:
                      MyHomePage(title: 'Raspored Časova', storage: _storage),
                ));
          });
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.storage})
      : super(key: key);

  final String title;
  final LocalStorage storage;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textFieldController = TextEditingController();

  String valueText = "";
  final PageController controller = PageController();
  int _selectedIndex = 0;
  late List<String> values;
  late List<String> list;
  @override
  Widget build(BuildContext context) {
    values = (widget.storage.getItem('raspored') ?? List.filled(36, ""))
        .cast<String>();

    list = (widget.storage.getItem('predmeti') ?? <String>[""]).cast<String>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Raspored Časova'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.grading),
              tooltip: 'Ocjene',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Screen2(storage: widget.storage)),
                );
              },
            ),
          ],
        ),
        drawer: SizedBox(
            width: 200,
            child: Drawer(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: const Text('Raspored Časova'),
                  ),
                  ListTile(
                    title: const Text('Ocjene'),
                    trailing: const Icon(Icons.grading),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Screen2(storage: widget.storage)),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Postavke'),
                    trailing: const Icon(Icons.settings),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Postavke(storage: widget.storage)),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Predmeti'),
                    trailing: const Icon(Icons.subject),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Predmeti(storage: widget.storage)),
                      );
                    },
                  ),
                ],
              ),
            )),
        bottomNavigationBar:
            MediaQuery.of(context).orientation == Orientation.portrait
                ? BottomNavigationBar(
                    items: <BottomNavigationBarItem>[
                          const BottomNavigationBarItem(
                            icon: Icon(Icons.calendar_view_week),
                            label: 'Sedmično',
                          )
                        ] +
                        List.generate(5, (index) {
                          return BottomNavigationBarItem(
                            icon: Icon(DateTime.now().weekday == index + 1
                                ? Icons.calendar_today_outlined
                                : Icons.calendar_today),
                            label: [
                              "Ponedjeljak",
                              "Utorak",
                              "Srijeda",
                              "Četvrtak",
                              "Petak"
                            ][index],
                          );
                        }),
                    currentIndex: _selectedIndex,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                        controller.animateToPage(index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease);
                      });
                    })
                : null,
        body: Container(
            /*decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),*/
            child: PageView(
          controller: controller,
          children: <Widget>[
                Column(mainAxisAlignment: MainAxisAlignment.start, children: <
                    Widget>[
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? Container(
                          margin: const EdgeInsets.only(top: 30.0, bottom: 30),
                          child: Text("Sedmični raspored",
                              style: Theme.of(context).textTheme.headline4))
                      : const SizedBox.shrink(),
                  GridView.count(
                    // Create a grid with 2 columns. If you change the scrollDirection to
                    // horizontal, this produces 2 rows.
                    shrinkWrap: true,
                    crossAxisCount: 6,
                    childAspectRatio: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 1.5
                        : 3.5,
                    // Generate 100 widgets that display their index in the List.
                    children: List.generate(48, (index) {
                      return Container(
                          padding: const EdgeInsets.all(1),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.75),
                                //borderRadius: BorderRadius.circular(1),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Builder(builder: (BuildContext context) {
                                if (index < 6) {
                                  return Center(
                                      child: Text(
                                    [
                                      "",
                                      "PON",
                                      "UTO",
                                      "SRI",
                                      "ČET",
                                      "PET"
                                    ][index],
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .apply(
                                          color: Colors.white,
                                          fontWeightDelta: 1,
                                          fontSizeFactor: 1.1,
                                        ),
                                  ));
                                }
                                if (index % 6 == 0) {
                                  return Center(
                                      child: Text(
                                    index ~/ 7 == 0
                                        ? "P"
                                        : (index ~/ 7).toString() + ".",
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .apply(
                                          color: Colors.white,
                                          fontWeightDelta: 1,
                                          fontSizeFactor: 1.1,
                                        ),
                                  ));
                                }
                                return DropdownButton<String>(
                                  borderRadius: BorderRadius.circular(10),
                                  dropdownColor: Colors.black.withOpacity(0.5),
                                  isExpanded: true,
                                  value:
                                      values[((index - 7) - (index - 7) ~/ 6)],
                                  icon: const SizedBox.shrink(),
                                  elevation: 16,
                                  underline: const SizedBox(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      values[((index - 7) - (index - 7) ~/ 6)] =
                                          value!;
                                      widget.storage
                                          .setItem('raspored', values);
                                    });
                                  },
                                  items: (list).map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Center(
                                              child: Text(
                                            value,
                                            textAlign: TextAlign.center,
                                            style: DefaultTextStyle.of(context)
                                                .style
                                                .apply(
                                                  color: Colors.white,
                                                  fontSizeFactor: 0.8,
                                                ),
                                          )),
                                        );
                                      }).toList() +
                                      [
                                        DropdownMenuItem<String>(
                                          value: null,
                                          onTap: () {
                                            //Navigator.pop(context);
                                            Future<void>.delayed(
                                                const Duration(
                                                    milliseconds: 50),
                                                () => _dodajPredmet(context,
                                                    index - 7, values, list));
                                          },
                                          child: Center(
                                              child: Text(
                                            "Dodaj predmet",
                                            textAlign: TextAlign.center,
                                            style: DefaultTextStyle.of(context)
                                                .style
                                                .apply(
                                                  color: Colors.white,
                                                  fontSizeFactor: 0.8,
                                                ),
                                          )),
                                        )
                                      ],
                                );
                              })));
                    }),
                  )
                ])
              ] +
              List.generate(5, (day) {
                return Column(children: <Widget>[
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? Container(
                          margin: const EdgeInsets.only(top: 30.0, bottom: 30),
                          child: Text(
                              [
                                "Ponedjeljak",
                                "Utorak",
                                "Srijeda",
                                "Četvrtak",
                                "Petak"
                              ][day],
                              style: Theme.of(context).textTheme.headline4))
                      : const SizedBox.shrink(),
                  ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (BuildContext context, int index) =>
                          (MediaQuery.of(context).orientation ==
                                  Orientation.portrait)
                              ? const Divider()
                              : const Divider(height: 5),
                      itemCount: 7,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (BuildContext context, int index) {
                        return Row(children: <Widget>[
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              margin: const EdgeInsets.only(right: 10),
                              child: Container(
                                width: 45,
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        (MediaQuery.of(context).orientation ==
                                                Orientation.portrait)
                                            ? 8
                                            : 1),
                                child: Center(
                                    child: Text(
                                  index == 0 ? "P" : (index).toString() + ".",
                                  style:
                                      DefaultTextStyle.of(context).style.apply(
                                            fontSizeFactor: 1.6,
                                            color: Colors.white,
                                          ),
                                )),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.1)),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              )),
                          Expanded(
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: (MediaQuery.of(context)
                                                    .orientation ==
                                                Orientation.portrait)
                                            ? 8
                                            : 1),
                                    child: Center(
                                        child: Text(
                                      values[index * 5 + day],
                                      style: DefaultTextStyle.of(context)
                                          .style
                                          .apply(
                                            fontSizeFactor: 1.6,
                                            color: Colors.white,
                                          ),
                                    )),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.1)),
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.75),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  )))
                        ]);
                      }),
                ]);
              }),
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        )));
  }

  Future<void> _dodajPredmet(
      BuildContext context, int index, List values, List list) async {
    _textFieldController.text = "";
    String? _error;
    print("ass");
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              title: const Text('Dodaj novi premet'),
              content: TextField(
                onChanged: (value) {},
                controller: _textFieldController,
                decoration: InputDecoration(
                    hintText: "Naziv predmeta", errorText: _error),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    setState(() {
                      String value = _textFieldController.text;

                      if (value == "") {
                        _error = "Unesi ime predmeta";
                      } else if (list.contains(value)) {
                        _error = "Taj predmet već postoji";
                      } else {
                        list.add(value);
                        values[(index - index ~/ 6)] = value;
                        widget.storage.setItem('raspored', values);
                        widget.storage.setItem('predmeti', list);
                        Navigator.pop(context, 'OK');
                      }
                    });
                  },
                ),
              ],
            );
          });
        });
  }
}

class Screen2 extends StatefulWidget {
  const Screen2({Key? key, required this.storage}) : super(key: key);
  final LocalStorage storage;

  @override
  State<StatefulWidget> createState() {
    return Screen2State();
  }
}

class Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    List predmeti = castOrFallback(widget.storage.getItem('predmeti'), []);
    var ocjene = widget.storage.getItem('ocjene');

    if (predmeti.length <= 1) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Ocjene'),
          ),
          body: const Center(child: Text("Nema predmeta")));
    }

    ocjene ??= <String, List<int>>{};
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ocjene'),
        ),
        body: Column(
          children: [
            Container(
                margin: const EdgeInsets.all(5),
                child: const Text(
                  "Dodirnite ocjenu da je izbrišete",
                )),
            ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(height: 1),
                itemCount: predmeti.length - 1,
                itemBuilder: (BuildContext context, int index) {
                  index += 1;
                  return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                              Container(
                                  padding: const EdgeInsets.only(
                                      top: 12.0, bottom: 12, left: 12),
                                  child: Text(
                                    predmeti[index],
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .apply(
                                          fontSizeFactor: 1.4,
                                        ),
                                  )),
                              SizedBox(
                                  height: 30,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: (ocjene[predmeti[index]] ?? [])
                                          .length,
                                      itemBuilder:
                                          (BuildContext context, int i) {
                                        return MaterialButton(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          minWidth: 25,
                                          onPressed: () {
                                            setState(() {
                                              ocjene[predmeti[index]]
                                                  .removeAt(i);
                                              widget.storage
                                                  .setItem("ocjene", ocjene);
                                            });
                                          },
                                          textColor: Colors.white,
                                          color: [
                                            Colors.red,
                                            Colors.amber,
                                            Colors.green,
                                            Colors.blue,
                                            Colors.purple
                                          ][ocjene[predmeti[index]][i] - 1],
                                          child: Text(ocjene[predmeti[index]][i]
                                              .toString()),
                                          //padding: EdgeInsets.all(1),
                                          shape: const CircleBorder(),
                                        );
                                      })),
                            ])),
                        SizedBox(
                            width: 60,
                            child: Column(children: <Widget>[
                              SizedBox(
                                  width: 60,
                                  child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton(
                                        isExpanded: true,
                                        underline: const SizedBox(),
                                        items: [1, 2, 3, 4, 5].map((int items) {
                                          return DropdownMenuItem(
                                            alignment: Alignment.centerRight,
                                            value: items,
                                            child: CircleAvatar(
                                              backgroundColor: [
                                                Colors.red,
                                                Colors.amber,
                                                Colors.green,
                                                Colors.blue,
                                                Colors.purple
                                              ][items - 1],
                                              child: Center(
                                                child: Text(
                                                  items.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (int? newValue) {
                                          setState(() {
                                            ocjene[predmeti[index]] ??= <int>[];
                                            ocjene[predmeti[index]] += [
                                              newValue
                                            ];
                                            widget.storage
                                                .setItem("ocjene", ocjene);
                                          });
                                        },
                                        icon: DecoratedBox(
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 40,
                                            )),
                                      ))),
                              ((ocjene[predmeti[index]] ?? []).length > 0
                                  ? Text((ocjene[predmeti[index]]
                                              .fold(0, (p, c) => p + c) /
                                          ocjene[predmeti[index]].length)
                                      .toStringAsFixed(2))
                                  : const Text("")),
                            ])),
                      ]);
                })
          ],
        ));
  }
}

class Postavke extends StatefulWidget {
  const Postavke({Key? key, required this.storage}) : super(key: key);
  final LocalStorage storage;
  // etc
  @override
  State<StatefulWidget> createState() {
    return PostavkeState();
  }
}

class PostavkeState extends State<Postavke> {
  @override
  Widget build(BuildContext context) {
    bool darktheme = widget.storage.getItem("darktheme") ?? false;
    Color pickerColor =
        Color(widget.storage.getItem("color") ?? Colors.teal.value);

    return Scaffold(
      appBar: AppBar(title: const Text("Postavke")),
      body: SettingsList(
        lightTheme:
            const SettingsThemeData(settingsListBackground: Colors.white),
        darkTheme: SettingsThemeData(settingsListBackground: Colors.grey[900]),
        sections: [
          SettingsSection(
            title: const Text('Izgled'),
            tiles: <AbstractSettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    darktheme = value;
                    widget.storage.setItem("darktheme", darktheme);
                    AppBuilder.of(context)?.rebuild();
                  });
                },
                initialValue: darktheme,
                leading: const Icon(Icons.dark_mode),
                title: const Text('Tamna tema'),
              ),
              CustomSettingsTile(
                  child: ColorPicker(
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.accent: false,
                },
                enableShadesSelection: false,
                color: pickerColor,
                onColorChanged: (Color color) {
                  setState(() {
                    pickerColor = color;
                    widget.storage.setItem("color", pickerColor.value);
                    AppBuilder.of(context)?.rebuild();
                  });
                },
              ))
            ],
          ),
        ],
      ),
    );
  }
}

class Predmeti extends StatefulWidget {
  const Predmeti({Key? key, required this.storage}) : super(key: key);
  final LocalStorage storage;
  // etc
  @override
  State<StatefulWidget> createState() {
    return PredmetiState();
  }
}

class PredmetiState extends State<Predmeti> {
  @override
  Widget build(BuildContext context) {
    List predmeti = castOrFallback(widget.storage.getItem('predmeti'), []);

    if (predmeti.length <= 1) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Predmeti'),
          ),
          body: const Center(child: Text("Nema predmeta")));
    }

    //predmeti = List.from(predmeti).cast<String>();
    //predmeti.removeLast();
    //predmeti.removeAt(0);

    return Scaffold(
        appBar: AppBar(title: const Text("Predmeti")),
        body: ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(height: 2),
            itemCount: predmeti.length - 1,
            itemBuilder: (BuildContext context, int index) {
              index += 1;
              return Row(children: <Widget>[
                Expanded(
                    child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        margin: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          predmeti[index],
                          style: DefaultTextStyle.of(context).style.apply(
                                fontSizeFactor: 1.4,
                              ),
                        ))),
                ElevatedButton(
                  onPressed: () {
                    String removed = predmeti[index];
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          title: const Text("Ukloniti predmet?"),
                          content: Text(
                              "Da li ste sigurni da želite ukloniti predmet " +
                                  removed +
                                  "?"),
                          actions: [
                            TextButton(
                                child: const Text("NE"),
                                onPressed: () => Navigator.pop(context, false)),
                            TextButton(
                                child: const Text("DA"),
                                onPressed: () => Navigator.pop(context, true))
                          ],
                        );
                      },
                    ).then((val) {
                      if (val) {
                        List raspored = castOrFallback(
                            widget.storage.getItem('raspored'), []);

                        for (int i = 0; i < raspored.length; i++) {
                          if (raspored[i] == predmeti[index]) {
                            raspored[i] = "";
                          }
                        }
                        predmeti.removeAt(index);
                        print(raspored);
                        widget.storage.setItem('raspored', raspored);

                        AppBuilder.of(context)?.rebuild();
                      }
                    });
                  },
                  child: const Icon(Icons.remove, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),

                    primary: Colors.red,
                    // <-- Splash color
                  ),
                )
              ]);
            }));
  }
}
