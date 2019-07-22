import 'package:draggable_floating_button/draggable_floating_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '雀魂 Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.blue),
      home: HomePage(),
    );
  }
}

class Boolean {
  Boolean({this.value});
  bool value;
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences preferences;
  WebViewController webViewController;
  TextEditingController hostController;
  TextEditingController pathController;
  TextEditingController portController;

  Boolean isHttpsController;
  String get url =>
      'http${isHttpsController.value ? 's' : ''}://${hostController.text}:${portController.text}${pathController.text}';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sp) {
      preferences = sp;
      String host = sp.getString('host') ?? 'majsoul.union-game.com';
      String path = sp.getString('path') ?? '/0/';
      String port = sp.getString('port') ?? '80';
      bool isHttps = sp.getBool('isHttps') ?? true;

      hostController = TextEditingController(text: host);
      pathController = TextEditingController(text: path);
      portController = TextEditingController(text: port);
      isHttpsController = Boolean(value: isHttps);
      setState(() {
        if (webViewController != null) webViewController.loadUrl(url);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Center(
              child: WebView(
                initialUrl: '',
                javascriptMode: JavascriptMode.unrestricted,
                debuggingEnabled: true,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  if (portController != null) webViewController.loadUrl(url);
                },
              ),
            ),
            DraggableFloatingActionButton(
              offset: Offset(0, 150),
              mini: true,
              child: Icon(
                Icons.settings,
                size: 24,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return SettingDialog(
                      preferences: preferences,
                      hostController: hostController,
                      pathController: pathController,
                      portController: portController,
                      isHttpsController: isHttpsController,
                      webViewController: webViewController,
                    );
                  },
                );
              },
              appContext: context,
            )
          ],
        ),
      ),
    );
  }
}

class SettingDialog extends StatefulWidget {
  SettingDialog(
      {this.preferences,
      this.webViewController,
      this.hostController,
      this.pathController,
      this.portController,
      this.isHttpsController});

  final SharedPreferences preferences;
  final WebViewController webViewController;
  final TextEditingController hostController;
  final TextEditingController pathController;
  final TextEditingController portController;
  final Boolean isHttpsController;

  @override
  _SettingDialogState createState() => _SettingDialogState();
}

class _SettingDialogState extends State<SettingDialog> {
  String get url =>
      'http${widget.isHttpsController.value ? 's' : ''}://${widget.hostController.text}:${widget.portController.text}${widget.pathController.text}';

  saveSettings() {
    widget.preferences.setString('host', widget.hostController.text);
    widget.preferences.setString('path', widget.pathController.text);
    widget.preferences.setString('port', widget.portController.text);
    widget.preferences.setBool('isHttps', widget.isHttpsController.value);
    setState(() {
      widget.webViewController.loadUrl(url);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('修改服务器设置'),
      children: <Widget>[
        SimpleDialogOption(
          child: TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.near_me),
              labelText: '域名',
            ),
            controller: widget.hostController,
          ),
        ),
        SimpleDialogOption(
          child: TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.router),
              labelText: '路径',
            ),
            controller: widget.pathController,
          ),
        ),
        SimpleDialogOption(
          child: TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.format_list_numbered),
              labelText: '端口',
            ),
            inputFormatters: [WhitelistingTextInputFormatter(RegExp('[0-9]'))],
            controller: widget.portController,
          ),
        ),
        SimpleDialogOption(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Switch(
                      value: widget.isHttpsController.value,
                      onChanged: (to) {
                        setState(() {
                          widget.isHttpsController.value = to;
                        });
                      },
                    ),
                    Text('https'),
                  ],
                ),
                SimpleDialogOption(
                  child: Center(
                    child: Text('保存'),
                  ),
                  onPressed: saveSettings,
                )
              ],
            ),
          ),
        ),
        SimpleDialogOption(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                child: Text('国服预设配置'),
                onPressed: () {
                  widget.hostController.text = 'majsoul.union-game.com';
                  widget.pathController.text = '/0/';
                  widget.portController.text = '443';
                  widget.isHttpsController.value = true;
                  saveSettings();
                },
              ),
              FlatButton(
                child: Text('雀魂 Plus 预设配置'),
                onPressed: () {
                  widget.hostController.text = 'localhost';
                  widget.pathController.text = '/';
                  widget.portController.text = '8887';
                  widget.isHttpsController.value = true;
                  saveSettings();
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
