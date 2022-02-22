import 'dart:convert';

import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zefyrka/zefyrka.dart';
import 'setting.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ZefyrController? _controller;
  final FocusNode _focusNode = FocusNode();

  Settings? _settings;

  void _handleSettingsLoaded(Settings value) {
    print('here');
    setState(() {
      _settings = value;
      _loadFromAssets();
    });
  }

  @override
  void initState() {
    super.initState();
    Settings.load().then(_handleSettingsLoaded);
  }

  Future<void> _loadFromAssets() async {
    try {
      final result = await rootBundle.loadString('assets/welcome.note');
      final doc = NotusDocument.fromJson(jsonDecode(result));
      setState(() {
        _controller = ZefyrController(doc);
      });
    } catch (error) {
      final doc = NotusDocument()..insert(0, 'Empty asset');
      setState(() {
        _controller = ZefyrController(doc);
      });
    }
  }

  Future<void> _save() async {
    final fs = LocalFileSystem();
    final file = fs.directory(_settings!.assetsPath).childFile('welcome.note');
    final data = jsonEncode(_controller!.document);
    await file.writeAsString(data);
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null || _controller == null) {
      return const Scaffold(body: Center(child: Text('Loading...')));
    }

    return SettingsProvider(
        settings: _settings,
        child: Column(
          children: [
            ZefyrToolbar.basic(controller: _controller!),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: ZefyrEditor(
                  controller: _controller!,
                  focusNode: _focusNode,
                  autofocus: true,
                  // readOnly: true,
                  // padding: EdgeInsets.only(left: 16, right: 16),
                  onLaunchUrl: _launchUrl,
                ),
              ),
            ),
          ],
        ));
  }

  void _showSettings() async {
    final result = await showSettingsDialog(context, _settings);
    if (mounted && result != null) {
      setState(() {
        _settings = result;
      });
    }
  }

  void _launchUrl(String url) async {
    final result = await canLaunch(url);
    if (result) {
      await launch(url);
    }
  }
}
