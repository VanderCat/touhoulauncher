# Touhou Launcher

**A Touhou games launcher!**

Utilizes lost potential [thcrap](https://github.com/thpatch/thcrap) has. In other words it uses a game library thcrap provides, and a list of pathes. It allows us to make a front end and not use a *fucking tons of .lnk files*. (cmon nobody likes that system)

And yeah. THCRAP is mandatory. At least for now.

Change active preset in `%AppData%\com.example\touhou_launcher\shared_preferences.json` **!! TEMPORARY DECISION !!**

## TODO:
- A lot of refactoring of bad design choices
- Settings
- Changing patches in launcher and not in cfg files hidden in depths of system
- A lot of testing
- Drag'n'Drop will add games
- Make THCRAP optional (idk y u will want this but whatever)
- In-Launcher patch management

Yeah... thats A LOT

## building
```
flutter pub get
flutter build windows
```

## Post Scrpitum

idk i made it in about 3 days lmao
