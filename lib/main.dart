import 'package:flutter/material.dart';
import 'package:touhou_launcher/touhou_game.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_size/window_size.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touhou_launcher/settings.dart';
import 'package:touhou_launcher/theme.dart';

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
      useInheritedMediaQuery: true,
      title: 'Touhou Launcher',
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const TouhouLauncher(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/settings': (context) => const Settings(),
      },
      theme: NewMDDarkTheme.theme,
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
      ),
      // body is the majority of the screen.
      body: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [GameList()]
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add', // used by assistive technologies
        child: const Icon(Icons.settings),
        onPressed: () {
          Navigator.pushNamed(context, '/settings');
        },
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
        ),
          TextButton.icon(
            onPressed: game.configId != null ? () {
              Logger.root.fine("Launching ${game.configId} with ${pref.getString('preset')} preset.");
              Process.start("${pref.getString('thcrap')}\\thcrap_loader.exe \"${pref.getString('preset')}.js\" ${game.configId}",[]);
            } : null, 
            icon: const Icon(Icons.settings, size: 16),
            label: const Text("Settings"),
          ),
        ElevatedButton.icon(
          onPressed: () {
            Logger.root.fine("Launching ${game.id} with ${pref.getString('preset')} preset.");
            Process.start("${pref.getString('thcrap')}\\thcrap_loader.exe \"${pref.getString('preset')}.js\" ${game.id}",[]);
          },
          icon: const Icon(Icons.play_arrow, size: 16),
          label: const Text("PLAY"),
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
        Settings.thcrapPath(context, pref, initialization);
      }
    });
    return isLoading ? 
       const Center(child: CircularProgressIndicator()) :
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