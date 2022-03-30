import 'package:flutter/material.dart';
import 'package:touhou_launcher/touhou_game.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_size/window_size.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

late List <Game> games;

late final SharedPreferences pref;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("Touhou Launcher Alpha");
    setWindowMinSize(Size(395, 395));
  }

  pref = await SharedPreferences.getInstance();

  pref.getString('preset') == null ? pref.setString('preset', "en") : null;

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.time.hour}:${record.time.minute}:${record.time.second} [${record.level.name}] ${record.message}');
  });
  //games = await Game.load(thcrap);
  runApp(
    MaterialApp(
      title: 'Touhou Launcher',
      home: const TouhouLauncher(),
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch(accentColor: Colors.purpleAccent, brightness: Brightness.dark)
      ),
    ),
  );
}

class TouhouLauncher extends StatelessWidget {
  const TouhouLauncher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for
    // the major Material Components.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Touhou Launcher'),
        backgroundColor: const Color(0xAA272727),
      ),
      backgroundColor: const Color(0xAA121212),
      // body is the majority of the screen.
      body: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [GameList()]
      ),
      floatingActionButton: const FloatingActionButton(
        tooltip: 'Add', // used by assistive technologies
        child: Icon(Icons.settings),
        onPressed: null,
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  const GameCard({Key? key, required this.game}) : super(key: key);

  final Game game;

  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for
    // the major Material Components.
    return SizedBox(
      width: double.infinity,
      height: 128,
      child: Card(
        color: Color(0xAA1b1b1b),
        child: Container(
          margin: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: game.coverUrl??"http://via.placeholder.com/96x96",
                width: 96,
                height: 96,
                fit: BoxFit.fitHeight,
                filterQuality: FilterQuality.medium,
                progressIndicatorBuilder: (context, url, downloadProgress) => 
                  CircularProgressIndicator(
                    value: downloadProgress.progress,
                    color: Theme.of(context).colorScheme.secondary
                    ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Flexible(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        game.name??game.id,
                        style: Theme.of(context).textTheme.headline5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        game.subName??"Error",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GameControls(game: game),
                      ],
                    )
                  ],
                ),
              ),
            ]
          ),
        ),
      ),
  );
  }
}

class GameControls extends StatelessWidget {
  const GameControls({ Key? key, required this.game}) : super(key: key);

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: () async {
            if (await canLaunch(game.wikiUrl ??= "")) {
              await launch(game.wikiUrl ??= "");
            }
          }, 
          icon: const Icon(Icons.help_outline, size: 16),
          label: const Text("Wiki"),
          style: TextButton.styleFrom(
            primary: Theme.of(context).colorScheme.secondary,
          ),
        ),
          TextButton.icon(
            onPressed: game.configId != null ? () {
              Logger.root.fine("Launching ${game.configId} with ${pref.getString('preset')} preset.");
              Process.start("${pref.getString('thcrap')}\\thcrap_loader.exe \"${pref.getString('preset')}.js\" ${game.configId}",[]);
            } : null, 
            icon: const Icon(Icons.settings, size: 16),
            label: const Text("Settings"),
            style: TextButton.styleFrom(
              primary: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ElevatedButton.icon(
          onPressed: () {
            Logger.root.fine("Launching ${game.id} with ${pref.getString('preset')} preset.");
            Process.start("${pref.getString('thcrap')}\\thcrap_loader.exe \"${pref.getString('preset')}.js\" ${game.id}",[]);
          },
          icon: const Icon(Icons.play_arrow, size: 16),
          label: const Text("PLAY"),
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).colorScheme.secondary,
          ),
        )
      ],
    );
  }
}

class GameList extends StatefulWidget {
  const GameList({ Key? key }) : super(key: key);

  @override
  State<GameList> createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  bool isLoading = true;
  String? thcrap;

  Future<void> initialization() async {
    isLoading = true;
    thcrap = pref.getString('thcrap');
    if ((thcrap != null) && (thcrap != "")) {
      games = await Game.load(thcrap??"");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // Call the fetch data method
    super.initState();
    initialization();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero,(){
      if (isLoading && (thcrap == null || thcrap == "")) {
        var path = "";
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (contex) {
          return AlertDialog (
            title: const Text("Please provide path to THCRAP"),
            content: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
                hintText: 'C:\\THCRAP\\thcrap.exe',
              ),
              onChanged: (txt) => path = txt,
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  if (path.endsWith("thcrap.exe")) {
                    pref.setString('thcrap', path.replaceAll("thcrap.exe", ""));
                    initialization();
                    Navigator.of(context).pop();
                  }
                },
                style: TextButton.styleFrom(
                  primary: Theme.of(context).colorScheme.secondary,
                ),
              ),
              TextButton(
                child: const Text('Pick'),
                onPressed: () {
                  FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ["exe"]
                  ).then((result) {
                    if (result != null) {
                      pref.setString('thcrap', result.files.single.path?.replaceAll("thcrap.exe", "")??"");
                      initialization();
                      Navigator.of(context).pop();
                    }
                  });
                },
                style: TextButton.styleFrom(
                  primary: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
            backgroundColor: Color.fromARGB(255, 55, 55, 55),
          );
        });
      }
    });
    return isLoading ? 
       Center(child: CircularProgressIndicator(
         color: Theme.of(context).colorScheme.secondary,
       )) :
       Expanded(
          child: 
            ListView.builder(
              itemCount:games.length ,
              itemBuilder: (context, index) {
                return GameCard(game: games[index],);
              }
            )
        );
    }
}