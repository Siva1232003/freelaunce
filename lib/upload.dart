import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Upload extends StatefulWidget {
  final String selectedColor;

  Upload({required this.selectedColor});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _fileList = [];
  String selectedColor = "Black and White";
  String selectedBinding = "Chart Binding";  // Make sure this is initialized properly
  int numberOfCopies = 1;

  String? _radioValue = 'Single Side';
  String? _staplePin = 'No';

  Color chosenColor = Color(0xFFCFF008);

  @override
  void initState() {
    super.initState();
    selectedColor = widget.selectedColor;
  }

  Future<void> _pickFiles() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      List<XFile> validFiles = [];
      for (var file in pickedFiles) {
        String fileExtension = extension(file.path).toLowerCase();
        if (['.jpg', '.jpeg', '.png', '.pdf'].contains(fileExtension)) {
          validFiles.add(file);
        }
      }
      setState(() {
        _fileList = validFiles;
      });
    }
  }

  void _showColorPicker(BuildContext scaffoldContext) {
    showDialog(
      context: scaffoldContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: chosenColor,
              onColorChanged: (Color color) {
                setState(() {
                  chosenColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(scaffoldContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFCFF008)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickFiles,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: _fileList == null || _fileList!.isEmpty
                        ? Text('Click here to browse files (Images/PDFs only)', style: TextStyle(color: Colors.white))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Files Selected', style: TextStyle(color: Colors.white)),
                              Text('${_fileList?.length} file(s)', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_fileList != null)
                Column(
                  children: _fileList!.map((file) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(file.name, style: TextStyle(color: Colors.white)),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                backgroundColor: Color(0xFFCFF008),
                              ),
                              child: Text(
                                'View',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Color(0xFFCFF008)),
                              onPressed: () {
                                setState(() {
                                  _fileList?.remove(file);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                ),
              Divider(color: Colors.white),
              Text('Print Side', style: TextStyle(fontSize: 18, color: Colors.white)),
              Row(
                children: [
                  Radio<String>(
                    value: 'Single Side',
                    groupValue: _radioValue,
                    onChanged: (String? value) {
                      setState(() {
                        _radioValue = value;
                      });
                    },
                    activeColor: Color(0xFFCFF008),
                  ),
                  Text('Single Side', style: TextStyle(color: Colors.white)),
                  Radio<String>(
                    value: 'Double Side',
                    groupValue: _radioValue,
                    onChanged: (String? value) {
                      setState(() {
                        _radioValue = value;
                      });
                    },
                    activeColor: Color(0xFFCFF008),
                  ),
                  Text('Double Side', style: TextStyle(color: Colors.white)),
                ],
              ),
              Divider(color: Colors.white),
              Text('Staple Pin', style: TextStyle(fontSize: 18, color: Colors.white)),
              Row(
                children: [
                  Radio<String>(
                    value: 'Yes',
                    groupValue: _staplePin,
                    onChanged: (String? value) {
                      setState(() {
                        _staplePin = value;
                        if (_staplePin == 'Yes') {
                          selectedBinding = '';  // Clear if staple pin is yes
                        }
                      });
                    },
                    activeColor: Color(0xFFCFF008),
                  ),
                  Text('Yes', style: TextStyle(color: Colors.white)),
                  Radio<String>(
                    value: 'No',
                    groupValue: _staplePin,
                    onChanged: (String? value) {
                      setState(() {
                        _staplePin = value;
                      });
                    },
                    activeColor: Color(0xFFCFF008),
                  ),
                  Text('No', style: TextStyle(color: Colors.white)),
                ],
              ),
              Divider(color: Colors.white),
              if (_staplePin == 'No')
                Column(
                  children: [
                    Text('Binding Type', style: TextStyle(fontSize: 18, color: Colors.white)),
                    DropdownButton<String>(
                      value: selectedBinding.isNotEmpty ? selectedBinding : null, // Handle initial value
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBinding = newValue!;
                        });
                      },
                      items: <String>['Chart Binding', 'Box Binding']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Number of Copies: ', style: TextStyle(color: Colors.white)),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        if (numberOfCopies > 1) {
                          numberOfCopies--;
                        }
                      });
                    },
                  ),
                  Text('$numberOfCopies', style: TextStyle(color: Colors.white)),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        numberOfCopies++;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle the 'Save & Proceed' functionality here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFCFF008),
                ),
                child: Text('Save & Proceed'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
