// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:js' as js;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Flutter Demo', home: HomePage());
  }
}

/// [Widget] displaying the home page consisting of an image the the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  /// A controller for an editable text field that allows the user to input a URL.
  ///
  /// This controller can be used to retrieve the current value of the text field,
  /// listen for changes to the text field, and manipulate the text field's value.
  final TextEditingController _urlController = TextEditingController(
      text: kDebugMode ? 'https://picsum.photos/id/237/200/300' : null);

  /// A nullable string that holds the URL of an image.
  String? imageUrl;

  /// An optional [OverlayEntry] that can be used to display an overlay
  /// on top of the current widget tree. This can be used for displaying
  /// custom tooltips, popups, or other floating elements.
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _createImageElement();
  }

  /// Creates an image element.
  ///
  /// This method is responsible for creating an image element
  /// and performing any necessary setup or configuration.
  void _createImageElement() {
    // Ensure registration before usage
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'image-element',
      (int viewId) {
        final img = html.ImageElement()
          ..src = imageUrl
          ..style.position = "absolute"
          ..style.left = "50%"
          ..style.top = "50%"
          ..style.transform = "translate(-50%, -50%)"
          ..onDoubleClick.listen((event) {
            _setFullscreen();
          });
        return img;
      },
    );
  }

  /// Sets the application to fullscreen mode.
  ///
  /// This method configures the application to run in fullscreen,
  /// hiding the status bar and navigation bar for an immersive experience.
  _setFullscreen() {
    js.context.callMethod("toggleFullScreen");
  }

  /// Displays an image.
  ///
  /// This method is responsible for handling the logic to display an image
  /// within the application. The specific implementation details should be
  /// provided within the method body.
  void _displayImage() {
    setState(() {
      imageUrl = _urlController.text;
    });
  }

  @override

  /// Called whenever the widget configuration changes.
  ///
  /// This method is called when the widget is rebuilt with a new configuration
  /// that is different from the previous configuration. It provides the previous
  /// widget instance as an argument, allowing you to compare the old and new
  /// configurations and perform any necessary updates.
  ///
  /// Override this method to handle changes in the widget's configuration.
  ///
  /// - Parameter oldWidget: The previous instance of the widget before the update.
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (imageUrl != null) {
      final imgElement =
          html.document.getElementById("image-element") as html.ImageElement?;
      if (imgElement != null) {
        imgElement.src = imageUrl!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: imageUrl != null
                      ? const HtmlElementView(
                          viewType: 'image-element',
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(hintText: 'Image URL'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _displayImage,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                    child: Icon(Icons.arrow_forward),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _toggleMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Toggles the visibility of the menu in the given [context].
  ///
  /// This function is typically used to show or hide a menu
  /// when a user interacts with a specific UI element.
  ///
  /// [context] is the BuildContext in which the menu should be toggled.
  void _toggleMenu(BuildContext context) {
    if (_overlayEntry == null) {
      _showMenu(context);
    } else {
      _removeMenu();
    }
  }

  /// Creates a menu item widget with the given text and onTap callback.
  ///
  /// The [text] parameter specifies the text to be displayed on the menu item.
  /// The [onTap] parameter is a callback function that is triggered when the menu item is tapped.
  ///
  /// Returns a [Widget] representing the menu item.
  Widget _menuItem(String text, VoidCallback onTap) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 5),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  /// Displays a menu in the given context.
  ///
  /// This function shows a menu in the provided [BuildContext].
  ///
  /// [context] - The context in which to show the menu.
  void _showMenu(BuildContext context) {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Dim Background with BackdropFilter (Dimming effect)
          GestureDetector(
            onTap: _removeMenu,
            child: Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Menu Positioned Above FAB
          Positioned(
            bottom: 80,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _menuItem("Enter fullscreen", () => _setFullscreen()),
                const SizedBox(height: 10),
                _menuItem("Exit fullscreen", () => _setFullscreen()),
              ],
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  /// Removes the menu from the UI.
  ///
  /// This method is responsible for removing the menu widget from the
  /// user interface. It performs necessary cleanup and state updates
  /// to ensure the menu is properly removed.
  void _removeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
