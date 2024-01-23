import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();

  static void thcrapPath(context, pref, callback) {
    var path = "";
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (contex) {
          return AlertDialog (
            title: const Text("Path to THCRAP"),
            content: TextField(
              decoration: const InputDecoration(
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
                    callback();
                    Navigator.of(context).pop();
                  }
                },
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
                      callback();
                      Navigator.of(context).pop();
                    }
                  });
                },
              ),
            ]
          );
        });
  }
}

class _SettingsState extends State<Settings> {
  bool isLoading = true;
  SharedPreferences? _pref;

  void loadPref() async {
    isLoading = true;
      _pref ??= await SharedPreferences.getInstance();
    setState((){
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPref();
  }

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : SettingsList(
        applicationType: ApplicationType.material,
        platform: DevicePlatform.web,
        sections: [
          SettingsSection(
            title: Text('Common'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.extension),
                title: Text('Path to Touhou Community Reliant Automatic Patcher'),
                value: Text(_pref?.getString("thcrap")??"None"),
                onPressed: (ctx) {
                  Settings.thcrapPath(ctx, _pref, loadPref);
                },
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.view_list),
                title: Text('Select Patch'),
                value: Text('Currently Selected: ${_pref?.getString("preset")??"Error"}'),
                onPressed: (ctx) {
                  showDialog(
                    context: context, 
                    builder: (ctx) {
                      return AlertDialog(
                        title: Text("Select patch"),
                        content: ListView(
                          children: [
                            
                          ],
                        ),
                      );
                    }
                  );
                }
              ),
            ],
          ),
        ],
      ),
    );
  }
}