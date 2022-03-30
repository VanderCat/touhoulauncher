import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final _log = Logger('TouhouGames');

/// Represents a Touhou game.
///
/// There all information about this game: wiki, path, name, etc.
class Game {
  /// Game ID _(same as thcrap)_
  ///
  /// e.g. `th07`
  final String id;

  /// Fancy game name.
  ///
  /// e.g. `Touhou Youyoumu~ Perfect Cherry Blossom`
  String? name;

  /// Text to display below game name.
  ///
  /// Used Primarly to display game name in japanise.
  ///
  /// e.g. `東方妖々夢　～ Perfect Cherry Blossom`
  String? subName;

  /// Path to game executable.
  ///
  /// e.g. `C:\Touhou Project\TH07\th07.exe`
  String path;

  /// URL to article about this game.
  ///
  /// e.g. `https://en.touhouwiki.net/wiki/Perfect_Cherry_Blossom`
  String? wikiUrl;

  String? coverUrl;

  /// Configurator of game ID _(same as thcrap)_
  ///
  /// e.g. `th07_custom`
  String? configId;

  /// Path to configurator of game.
  ///
  /// e.g. `C:\Touhou Project\TH07\th07_custom.exe`
  String? configPath;

  /// Create a Game class
  Game({required this.id, required this.path});

  /// Load the games from thcrap config file
  ///
  /// ```dart
  /// var games = Game.load("C:\\THCRAP")
  /// ```
  static Future<List<Game>> load(String path) async {
    final pref = await SharedPreferences.getInstance();

    _log.info("Loading configs...");

    var gamelist = await File(path + "\\config\\games.js").readAsString();
    Map<String, dynamic> parsedGames = jsonDecode(gamelist);

    var namelist = await File(path + "\\repos\\nmlgc\\script_latin\\stringdefs.js").readAsString();
    Map<String, dynamic> parsedNames = jsonDecode(namelist);


    _log.info("Loading games...");
    List<Game> games = [];

    var client = http.Client();

    for (var id in parsedGames.keys) {
      _log.info("Found $id");
      var path = parsedGames[id];

      if (path == null) {
        path = "err";
        _log.warning("Couldn't get a path!");
      }

      if (id.endsWith('_custom')) {
        var owner = id.replaceAll("_custom", ""); //e.g. th07
        var index = games.indexWhere((g) => g.id == owner); //index of owner
        games[index].configId = id;
        games[index].configPath = path;
        continue;
      }

      var game = Game(id: id, path: path);
      if (parsedNames[id]!=null) {
        var names = parsedNames[id].split(" - ");
        game.name = (names?[1]??[0])??parsedNames[id];
        game.subName = names?[0];
        if (game.name == parsedNames[id])
          game.subName = null;
      }
      else {
        game.name = parsedNames[id];
      }
      if (id.startsWith("th")) {
        game.wikiUrl = "https://en.touhouwiki.net/wiki/${id.toUpperCase()}";
        var imgsaved = pref.getString('img$id');
        if (imgsaved==null) {
          _log.fine("Gathering cover from wiki...");
          try {
            var respraw = await client.get(
              Uri.https(
                'en.touhouwiki.net', 'api.php',
                {
                  'action':'query',
                  'titles':'Image:Th${id.substring(2,id.length)}cover.jpg',
                  'prop'  :'imageinfo',
                  'iiprop':'url',
                  'format':'json'
                }
              ),
            );
            _log.finest(respraw.request?.url);
            var resp = jsonDecode(respraw.body);
            var pages = resp['query']['pages'];
            game.coverUrl = pages[pages.keys.first]['imageinfo'][0]['url'];
            game.coverUrl != null ? pref.setString('img$id', game.coverUrl??"") : null;
          }
          catch (e) {
            _log.warning("An error occured while connecting to the wiki api!");
            _log.warning(e);
          }
        }
        else {
          _log.fine("Using cover url from cache...");
          game.coverUrl = imgsaved;
        }
      }

      games.add(game);
    }
    client.close();
    _log.info("Games loaded!");

    return games;
  }
}
