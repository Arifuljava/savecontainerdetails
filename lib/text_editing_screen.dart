import 'package:flutter/material.dart';


import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';



class TextEdititngScreen extends StatefulWidget {
  @override
  _TextEdititngScreenState createState() => _TextEdititngScreenState();
}

class _TextEdititngScreenState extends State<TextEdititngScreen> {

  Uint8List? imageData;
  GlobalKey globalKey = GlobalKey();
  static const platform =
  MethodChannel('com.github.Arifuljava:GrozziieBlutoothSDk:v1.0.1');


  late TextEditingController _textEditingController;
  late bool _isBold;
  late bool _isItalic;
  bool? _isUnderline;
  late TextAlign _alignment;
  late Color _textColor;
  late double _fontSize;


  late double textFieldX;
  late double textFieldY;
  late double textFieldWidth;
  late double textFieldHeight;
  late String _currentText;
  double minTextFieldWidth = 40.0;

  List<String> undoStack = [];
  List<String> redoStack = [];


  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _isBold = false;
    _isItalic = false;
    _isUnderline = false;
    _alignment = TextAlign.left;
    _textColor = Colors.black;
    _fontSize = 14.0;
    textFieldX = 0.0;
    textFieldY = 0.0;
    textFieldWidth = 200.0;
    textFieldHeight = 50.0;
    _currentText = '';
  }

  void _toggleBold() {
    setState(() {
      final previousText = _textEditingController.text;
      _isBold = !_isBold;
      undoStack.add(previousText);
      _applyChanges();
    });
  }

  void _toggleUnderline() {
    setState(() {
      final previousText = _textEditingController.text;
      _isUnderline = !_isUnderline!;
      undoStack.add(previousText);
      _applyChanges();
    });
  }

  void _toggleItalic() {
    setState(() {
      final previousText = _textEditingController.text;
      _isItalic = !_isItalic;
      undoStack.add(previousText);
      _applyChanges();
    });
  }

  void _changeAlignment(TextAlign alignment) {
    setState(() {
      final previousText = _textEditingController.text;
      _alignment = alignment;
      undoStack.add(previousText);
      _applyChanges();
    });
  }

  void _changeFontSize(double fontSize) {
    setState(() {
      final previousText = _textEditingController.text;
      _fontSize = fontSize;
      undoStack.add(previousText);
      _applyChanges();
    });
  }

  void _changeTextColor(Color color) {
    setState(() {
      final previousText = _textEditingController.text;
      _textColor = color;
      undoStack.add(previousText);
      _applyChanges();
    });
  }

  void _undoChanges() {
    if (undoStack.isNotEmpty) {
      setState(() {
        redoStack.add(_currentText);
        _currentText = undoStack.removeLast();
        _applyChanges();
      });
    }
  }

  void _redoChanges() {
    if (redoStack.isNotEmpty) {
      setState(() {
        undoStack.add(_currentText);
        _currentText = redoStack.removeLast();
        _applyChanges();
      });
    }
  }

  void _applyChanges() {
    _textEditingController.value = TextEditingValue(
      text: _currentText,
      selection: TextSelection.collapsed(offset: _currentText.length),
    );
    _updateTextFieldSize();
  }

  void _updateTextFieldSize() {
    final textSpan = TextSpan(
      text: _currentText,
      style: TextStyle(
        fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
        decoration: _isUnderline! ? TextDecoration.underline : null,
        fontSize: _fontSize,
        color: _textColor,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: textFieldWidth);

    final textWidth = textPainter.size.width;
    final textHeight = textPainter.size.height;

    // Calculate the number of lines required based on the available width
    final availableWidth = textFieldWidth - 16.0; // Adjust for padding
    final lines = (textWidth / availableWidth).ceil();

    // Ensure a minimum height for the TextField
    final minHeight = _fontSize + 12.0; // Minimum height based on font size

    setState(() {
      textFieldHeight =
          (textHeight * lines + 16.0).clamp(minHeight, double.infinity);
    });
  }

  void _handleResizeGesture(DragUpdateDetails details) {
    setState(() {
      final newWidth = textFieldWidth + details.delta.dx;
      const minWidth = 50.0; // Set the minimum width for the TextField
      if (newWidth >= minWidth) {
        textFieldWidth = newWidth;
      } else {
        textFieldWidth =
            minWidth; // Set the TextField width to the minimum value
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double containerHeight = 300;
    const double containerWidth = 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TextField Example'),
      ),
      body: Column(
        children: [
          _buildTextFieldController(containerHeight, containerWidth, context),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: _buildTextFieldStyle(),
            ),
          ),
          SizedBox(height: 20),

        ],
      ),
    );
  }

  Column _buildTextFieldStyle() {
    return Column(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _toggleBold,
                    icon: Icon(
                      _isBold ? Icons.format_bold : Icons.format_bold,
                      color: _isBold ? Colors.black : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleItalic,
                    icon: Icon(
                      _isItalic
                          ? Icons.format_italic
                          : Icons.format_italic,
                      color: _isItalic ? Colors.black : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleUnderline,
                    icon: Icon(
                      _isUnderline!
                          ? Icons.format_underline
                          : Icons.format_underline,
                      color:
                      _isUnderline! ? Colors.black : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _changeAlignment(TextAlign.left),
                    icon: Icon(
                      Icons.format_align_left,
                      color: _alignment == TextAlign.left
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _changeAlignment(TextAlign.center),
                    icon: Icon(
                      Icons.format_align_center,
                      color: _alignment == TextAlign.center
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        _changeAlignment(TextAlign.right),
                    icon: Icon(
                      Icons.format_align_right,
                      color: _alignment == TextAlign.right
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                  /* IconButton(
                    onPressed: _undoChanges,
                    icon: const Icon(Icons.undo),
                  ),
                  IconButton(
                    onPressed: _redoChanges,
                    icon: const Icon(Icons.redo),
                  ),*/
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Slider(
                value: _fontSize,
                min: 14.0,
                max: 30.0,
                divisions: 18,
                label: _fontSize.round().toString(),
                onChanged: (value) => _changeFontSize(value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildColorPickerButton(Colors.black),
                  _buildColorPickerButton(Colors.red),
                  _buildColorPickerButton(Colors.green),
                  _buildColorPickerButton(Colors.blue),
                ],
              ),
            ),

            ElevatedButton(onPressed: (){
              print('print Clicked');
            }, child: Text('print'))
          ],
        ),
      ],
    );
  }

  Column _buildTextFieldController(double containerHeight, double containerWidth, BuildContext context) {
    return Column(
      children: [
        RepaintBoundary(
          key: globalKey,
          child: Container(
            height: containerHeight,
            width: containerWidth,
            color: Colors.white,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: (_) {
                  // Dismiss the keyboard when the user interacts with the screen
                  FocusScope.of(context).unfocus();
                },
                onPanUpdate: (details) {
                  setState(() {
                    textFieldX += details.delta.dx;
                    textFieldY += details.delta.dy;
                  });
                },
                child: Stack(
                  children: [
                    Container(
                      child: Positioned(
                        left: textFieldX.clamp(
                          0,
                          containerWidth -
                              (textFieldWidth > 0 ? textFieldWidth : 0),
                        ),
                        top: textFieldY,
                        child: SizedBox(
                          width: textFieldWidth > 0
                              ? textFieldWidth
                              : double.infinity,
                          height: textFieldHeight > 0
                              ? textFieldHeight
                              : double.infinity,
                          child: Stack(
                            children: [
                              TextFormField(
                                controller: _textEditingController,
                                onChanged: (value) {
                                  setState(() {
                                    _currentText = value;
                                    _updateTextFieldSize();
                                  });
                                },
                                style: TextStyle(
                                  fontWeight: _isBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontStyle: _isItalic
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  decoration: _isUnderline!
                                      ? TextDecoration.underline
                                      : null,
                                  fontSize: _fontSize,
                                  color: _textColor,
                                ),
                                textAlign: _alignment,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                  EdgeInsets.zero, // Remove the padding
                                ),
                              ),
                              Positioned(
                                right: -32,
                                bottom: -32 + textFieldHeight - _fontSize - 2,
                                child: GestureDetector(
                                  onPanUpdate: _handleResizeGesture,
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    /*decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),*/
                                    child: const Icon(
                                      Icons.touch_app,
                                      size: 35,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPickerButton(Color color) {
    return GestureDetector(
      onTap: () => _changeTextColor(color),
      child: Container(
        margin: const EdgeInsets.all(4.0),
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _textColor == color ? Colors.grey : Colors.transparent,
            width: 5.0,
          ),
        ),
      ),
    );
  }


  void printContent() async {
    final image = await convertWidgetToImage();

    if (image != null) {
      final imageData = await convertImageToData(image);
      if (imageData != null) {
        setState(() {
          this.imageData = imageData;
        });
        await sendBitmapToJava(imageData);
      }
    }
  }

  Future<ui.Image?> convertWidgetToImage() async {
    try {
      RenderRepaintBoundary boundary =
      globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      return image;
    } catch (e) {
      print('Error capturing container convert to bitmap: $e');
      return null;
    }
  }

  Future<Uint8List?> convertImageToData(ui.Image image) async {
    try {
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error converting image to data: $e');
      return null;
    }
  }

  Future<void> sendBitmapToJava(Uint8List bitmapData) async {
    try {
      final byteBuffer = bitmapData.buffer;
      final byteList = byteBuffer.asUint8List();
      await platform.invokeMethod('receiveBitmap', {'bitmapData': byteList});
      print('Bitmap data sent to Java');
    } catch (e) {
      print('Error sending bitmap data to Java: $e');
    }
  }
}