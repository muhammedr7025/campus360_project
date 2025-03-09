import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAssistant extends StatefulWidget {
  final VoidCallback onTurnLightOn;
  final VoidCallback onTurnLightOff;
  final VoidCallback onTurnFanOn;
  final VoidCallback onTurnFanOff;

  const VoiceAssistant({
    Key? key,
    required this.onTurnLightOn,
    required this.onTurnLightOff,
    required this.onTurnFanOn,
    required this.onTurnFanOff,
  }) : super(key: key);

  @override
  _VoiceAssistantState createState() => _VoiceAssistantState();
}

class _VoiceAssistantState extends State<VoiceAssistant> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      print("Speech available: $available");
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          final recognized = result.recognizedWords;
          print("Recognized words: $recognized");
          setState(() {
            _recognizedText = recognized;
          });
          _processCommand(recognized);
        });
      } else {
        setState(() => _isListening = false);
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _processCommand(String command) {
    // Normalize the command.
    final cmd = command.toLowerCase().trim();
    print("Processing command: $cmd");

    // Check for various phrases.
    if (cmd.contains("light on") ||
        cmd.contains("turn light on") ||
        cmd.contains("switch light on")) {
      print("Command matched: Light ON");
      widget.onTurnLightOn();
    } else if (cmd.contains("light off") ||
        cmd.contains("turn light off") ||
        cmd.contains("switch light off")) {
      print("Command matched: Light OFF");
      widget.onTurnLightOff();
    } else if (cmd.contains("fan on") ||
        cmd.contains("turn fan on") ||
        cmd.contains("switch fan on")) {
      print("Command matched: Fan ON");
      widget.onTurnFanOn();
    } else if (cmd.contains("fan off") ||
        cmd.contains("turn fan off") ||
        cmd.contains("switch fan off")) {
      print("Command matched: Fan OFF");
      widget.onTurnFanOff();
    } else {
      print("No matching command found for: $cmd");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: _toggleListening,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
        const SizedBox(height: 8),
        Text("Heard: $_recognizedText"),
      ],
    );
  }
}
