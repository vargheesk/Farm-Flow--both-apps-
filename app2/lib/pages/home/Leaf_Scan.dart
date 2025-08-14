import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:io';

class Leaf_Scan extends StatefulWidget {
  const Leaf_Scan({super.key});

  @override
  _Leaf_ScanState createState() => _Leaf_ScanState();
}

class _Leaf_ScanState extends State<Leaf_Scan> {
  final Gemini _gemini = Gemini.instance;
  File? _image;
  String? _result;
  double _accuracy = 0.0;
  String _prevention = '';
  String _cure = '';
  String _plantInfo = '';
  final _imagePicker = ImagePicker();
  late Interpreter _interpreter;
  late Interpreter _leafDetector; // New interpreter for leaf detection
  int noOfClassses = 89;
  List<String> _labels = [];
  // Define a threshold for disease classification confidence
  final double _diseaseConfidenceThreshold = 50.0;

  @override
  void initState() {
    super.initState();
    loadModels();
  }

  @override
  void dispose() {
    _interpreter.close();
    _leafDetector.close();
    super.dispose();
  }

  Future<void> loadModels() async {
    try {
      // Load plant disease model and labels
      String labelsData = await DefaultAssetBundle.of(context)
          .loadString('assets/efficientnet_v2-labels.txt');
      _labels = labelsData
          .split('\n')
          .map((e) => e.split(' ').sublist(1).join(' '))
          .toList();

      _interpreter =
          await Interpreter.fromAsset('assets/efficientnet_v2.tflite');

      // Load leaf detection model
      _leafDetector =
          await Interpreter.fromAsset('assets/leafornonleaf.tflite');

      setState(() {});
    } catch (e) {
      print('Error loading models: $e');
    }
  }

  // Function to check if image contains a leaf
  Future<bool> isLeafImage(File image) async {
    try {
      img.Image? imageInput = img.decodeImage(image.readAsBytesSync());
      if (imageInput == null) return false;

      img.Image resizedImg =
          img.copyResize(imageInput, width: 224, height: 224);

      var inputArray = List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            var pixel = resizedImg.getPixel(x, y);
            return [
              (pixel.r.toDouble() - 127.5) / 127.5,
              (pixel.g.toDouble() - 127.5) / 127.5,
              (pixel.b.toDouble() - 127.5) / 127.5,
            ];
          },
        ),
      );

      // Output will have 2 classes: [leaf, non-leaf]
      var outputArray = List.filled(2, 0.0).reshape([1, 2]);
      _leafDetector.run([inputArray], outputArray);

      // Class 0 is leaf, class 1 is non-leaf
      return outputArray[0][0] > outputArray[0][1];
    } catch (e) {
      print('Error detecting leaf: $e');
      return false;
    }
  }

  // Function to show the "Not a Leaf" dialog
  void _showNotLeafDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Leaf Detected'),
          content: const Text(
              'We couldn\'t detect a leaf in this. Please upload an image that clearly shows a plant leaf.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 5,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to show the "Leaf not in dataset" dialog
  void _showLeafNotInDatasetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leaf Not Recognized'),
          content: const Text(
              'Could not find the leaf in the dataset and its condition. This leaf may not be part of our training data.'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 5,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatBoldText(String text) {
    return text;
  }

  Future<void> getPlantInfo(String plant) async {
    try {
      var infoResponse = await _gemini.text(
        '''Provide detailed information about the $plant, including its botanical characteristics, uses, and interesting facts.
      Keep the response informative and concise.''',
      );

      setState(() {
        _plantInfo = _formatBoldText(
            infoResponse?.output ?? 'Unable to get plant information');
      });
    } catch (e) {
      print('Error fetching plant info: $e');
      setState(() {
        _plantInfo = 'Error fetching plant information';
      });
    }
  }

  Future<void> getPreventionAndCure(String disease) async {
    try {
      if (!disease.toLowerCase().contains('healthy')) {
        var preventionResponse = await _gemini.text(
          '''Given the plant disease "$disease", provide prevention methods in 3-4 concise bullet points.
          Keep the response short and practical.''',
        );

        var cureResponse = await _gemini.text(
          '''Given the plant disease "$disease", provide treatment/cure methods in 3-4 concise bullet points.
          Keep the response short and practical.''',
        );

        setState(() {
          _prevention = _formatBoldText(preventionResponse?.output ??
              'Unable to get prevention information');
          _cure = _formatBoldText(
              cureResponse?.output ?? 'Unable to get cure information');
        });
      } else {
        await getPlantInfo(disease.split('-')[0]);
      }
    } catch (e) {
      print('Error loading model: $e');
      setState(() {
        _prevention = 'Error fetching prevention information';
        _cure = 'Error fetching cure information';
      });
    }
  }

  Future<void> classifyImage(File image) async {
    try {
      // First check if the image contains a leaf
      bool containsLeaf = await isLeafImage(image);

      if (!containsLeaf) {
        // If not a leaf, show dialog and reset the state
        _showNotLeafDialog();
        setState(() {
          _result = null;
          _accuracy = 0.0;
          _prevention = '';
          _cure = '';
          _plantInfo = '';
        });
        return;
      }

      img.Image? imageInput = img.decodeImage(image.readAsBytesSync());
      if (imageInput == null) return;

      img.Image resizedImg =
          img.copyResize(imageInput, width: 224, height: 224);

      var inputArray = List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            var pixel = resizedImg.getPixel(x, y);
            return [
              (pixel.r.toDouble() - 127.5) / 127.5,
              (pixel.g.toDouble() - 127.5) / 127.5,
              (pixel.b.toDouble() - 127.5) / 127.5,
            ];
          },
        ),
      );

      var outputArray =
          List.filled(noOfClassses, 0.0).reshape([1, noOfClassses]);
      _interpreter.run([inputArray], outputArray);

      var maxIndex = 0;
      var maxValue = outputArray[0][0];
      for (var i = 1; i < outputArray[0].length; i++) {
        if (outputArray[0][i] > maxValue) {
          maxValue = outputArray[0][i];
          maxIndex = i;
        }
      }

      // Calculate accuracy percentage from the confidence value
      double accuracyPercent = maxValue * 100;

      // Check if the confidence is below the threshold
      if (accuracyPercent < _diseaseConfidenceThreshold) {
        // If below threshold, show leaf not in dataset dialog
        _showLeafNotInDatasetDialog();
        setState(() {
          _result = null;
          _accuracy = 0.0;
          _prevention = '';
          _cure = '';
          _plantInfo = '';
        });
        return;
      }

      setState(() {
        _result = _labels[maxIndex];
        _accuracy = accuracyPercent;
        _prevention = '';
        _cure = '';
        _plantInfo = '';
      });

      await getPreventionAndCure(_result!);
    } catch (e) {
      print('Error classifying image: $e');
      setState(() {
        _result = 'Error classifying image';
        _accuracy = 0.0;
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _image = File(image.path);
        _prevention = '';
        _cure = '';
        _plantInfo = '';
      });

      await classifyImage(_image!);
    } catch (e) {
      print("Error picking image: $e");
      setState(() {});
    }
  }

  Widget _buildInfoContainer({
    required String title,
    required String content,
    Color backgroundColor = const Color.fromARGB(255, 251, 255, 252),
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 16.0, fontFamily: "Arial"),
              strong: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: CircularProgressIndicator(
                      value: _accuracy / 100,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _accuracy > 80
                            ? Colors.green
                            : _accuracy > 60
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "${_accuracy.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Detection Confidence",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _accuracy > 80
                      ? "High confidence in this result"
                      : _accuracy > 60
                          ? "Moderate confidence in this result"
                          : "Low confidence - consider retaking the photo",
                  style: TextStyle(
                    color: _accuracy > 80
                        ? Colors.green
                        : _accuracy > 60
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 170, 191, 163),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_image == null)
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 26, 103, 30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file,
                                color: Colors.white,
                                size: 50,
                              ),
                              Text(
                                'UPLOAD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (_result != null) ...[
                      Row(
                        children: [
                          const Text(
                            'Plant        : ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_result?.split('-')[0] ?? 'No plant detected'),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            'Condition : ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_result?.split('-')[1].replaceAll('_', ' ') ??
                              'Unknown'),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          onPressed: () => pickImage(ImageSource.camera),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            backgroundColor:
                                const Color.fromARGB(255, 26, 103, 30),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                          onPressed: () => pickImage(ImageSource.gallery),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            backgroundColor:
                                const Color.fromARGB(255, 26, 103, 30),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Display accuracy indicator if we have a result
              if (_result != null && _accuracy > 0) _buildAccuracyIndicator(),

              // Conditional rendering based on plant condition
              if (_result != null) ...[
                const SizedBox(height: 20),

                // Show prevention and cure for diseased plants
                if (_prevention.isNotEmpty && _cure.isNotEmpty) ...[
                  _buildInfoContainer(
                    title: 'Prevention:',
                    content: _prevention,
                  ),
                  _buildInfoContainer(
                    title: 'Cure:',
                    content: _cure,
                  ),
                ],

                // Show plant info for healthy plants
                if (_plantInfo.isNotEmpty)
                  _buildInfoContainer(
                    title: 'Plant Information:',
                    content: _plantInfo,
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
