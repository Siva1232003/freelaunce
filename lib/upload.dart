import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
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
  String selectedBinding = "Chart Binding";
  int numberOfCopies = 1;

  String? _radioValue = 'Single Side';
  String? _staplePin = 'Yes';

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
        String fileExtension = path.extension(file.path).toLowerCase();
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

  void _showFile(XFile file) {
    // Placeholder function to view the file; implement file display logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing file: ${file.name}')),
    );
  }

  void _saveAndProceed() {
    // Placeholder function to handle save and proceed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved! Proceeding to next step...')),
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
                        Expanded(
                          child: Tooltip(
                            message: file.name,
                            child: Text(
                              file.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _showFile(file),
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
                          selectedBinding = '';
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
                    Text('Binding Type', style: TextStyle(fontSize: 18, color: Color.fromRGBO(0, 0, 0, 0))),
                    DropdownButtonFormField<String>(
                      value: selectedBinding.isNotEmpty ? selectedBinding : null,
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
                      decoration: InputDecoration(
                        fillColor: Colors.transparent, // Make the background transparent
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFCFF008), width: 2.0), // Border color when focused
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFCFF008), width: 2.0), // Border color when enabled
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFCFF008), width: 2.0), // Default border color
                        ),
                      ),
                    ),
                    if (selectedBinding.isNotEmpty)
                      Column(
                        children: [
                          SizedBox(height: 10),
                          Text('Select Color', style: TextStyle(fontSize: 18, color: Colors.white)),
                          Wrap(
                            spacing: 8.0,
                            children: ['Blue', 'Green', 'Yellow', 'Orange'].map((color) {
                              return ChoiceChip(
                                label: Text(color),
                                selected: selectedColor == color,
                                onSelected: (bool selected) {
                                  setState(() {
                                    selectedColor = color;
                                  });
                                },
                                selectedColor: Color(0xFFCFF008),
                                backgroundColor: Colors.grey,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                  ],
                ),
              Divider(color: Colors.white),
              // Text('Number of Copies', style: TextStyle(fontSize: 18, color: Colors.white)),
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
              Divider(color: Colors.white),
              ElevatedButton(
  onPressed: _saveAndProceed,
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFCFF008), // Use backgroundColor instead of primary
  ),
  child: Text('Save and Proceed'),
),

            ],
          ),
        ),
      ),
    );
  }
}
