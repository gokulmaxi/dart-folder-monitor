import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

void main() {
  final folderPath = '/home/gokul/Pictures';
  final stateFilePath = 'state.json';

  final previousState = _readStateFile(stateFilePath);

  final currentState = _getFolderState(folderPath);

  final newFiles = _getNewFiles(previousState, currentState);

  _writeStateFile(stateFilePath, currentState);

  // Process the new files
  for (var file in newFiles) {
    print('New file added: ${path.basename(file)}');
  }
}

Map<String, String> _getFolderState(String folderPath) {
  final folder = Directory(folderPath);
  final state = <String, String>{};

  if (folder.existsSync()) {
    final files = folder.listSync(recursive: false);

    for (var file in files) {
      if (file is File) {
        state[file.path] = file.lastModifiedSync().toString();
      }
    }
  }

  return state;
}

List<String> _getNewFiles(
    Map<String, String> previousState, Map<String, String> currentState) {
  final newFiles = <String>[];

  for (var filePath in currentState.keys) {
    if (!previousState.containsKey(filePath) ||
        previousState[filePath] != currentState[filePath]) {
      newFiles.add(filePath);
    }
  }

  return newFiles;
}

Map<String, String> _readStateFile(String stateFilePath) {
  final stateFile = File(stateFilePath);
  final stateContent =
      stateFile.existsSync() ? stateFile.readAsStringSync() : '{}';
  final Map<String, dynamic> rawData = json.decode(stateContent);
  return Map<String, String>.from(rawData);
}

void _writeStateFile(String stateFilePath, Map<String, String> state) {
  final stateFile = File(stateFilePath);
  final stateContent = json.encode(state);
  stateFile.writeAsStringSync(stateContent);
}
