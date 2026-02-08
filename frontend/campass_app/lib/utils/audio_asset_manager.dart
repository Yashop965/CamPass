import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioAssetManager {
  static final AudioAssetManager _instance = AudioAssetManager._internal();

  factory AudioAssetManager() {
    return _instance;
  }

  AudioAssetManager._internal();

  /// List of audio files and their asset paths
  static const Map<String, String> audioAssets = {
    'sos_alarm': 'assets/sounds/sos_alarm.mp3',
    'geofence_alert': 'assets/sounds/geofence_alert.mp3',
    'pass_approved': 'assets/sounds/pass_approved.mp3',
    'pass_rejected': 'assets/sounds/pass_rejected.mp3',
    'notification': 'assets/sounds/notification.mp3',
  };

  /// List of required audio files
  static const List<String> requiredAudioFiles = [
    'sos_alarm',
    'geofence_alert',
    'notification',
  ];

  /// Copy audio assets to app documents directory
  Future<void> initializeAudioAssets() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final soundsDir = Directory('${documentsDir.path}/sounds');

      if (!await soundsDir.exists()) {
        await soundsDir.create(recursive: true);
      }

      // Copy required audio files
      for (final audioName in requiredAudioFiles) {
        final assetPath = audioAssets[audioName];
        if (assetPath == null) continue;

        final fileName = assetPath.split('/').last;
        final targetFile = File('${soundsDir.path}/$fileName');

        if (!await targetFile.exists()) {
          final data = await rootBundle.load(assetPath);
          await targetFile.writeAsBytes(data.buffer.asUint8List());
          print('Audio file copied: $fileName');
        }
      }

      print('Audio assets initialized');
    } catch (e) {
      print('Error initializing audio assets: $e');
    }
  }

  /// Get audio file path
  Future<String?> getAudioPath(String audioName) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final assetPath = audioAssets[audioName];
      if (assetPath == null) return null;

      final fileName = assetPath.split('/').last;
      final filePath = '${documentsDir.path}/sounds/$fileName';

      if (await File(filePath).exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      print('Error getting audio path: $e');
      return null;
    }
  }

  /// Get all available audio files
  Future<Map<String, String>> getAvailableAudioFiles() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final soundsDir = Directory('${documentsDir.path}/sounds');

      final result = <String, String>{};

      if (await soundsDir.exists()) {
        final files = soundsDir.listSync();
        for (final file in files) {
          if (file is File) {
            final fileName = file.path.split('/').last;
            final audioName = fileName.replaceAll('.mp3', '');
            result[audioName] = file.path;
          }
        }
      }

      return result;
    } catch (e) {
      print('Error getting audio files: $e');
      return {};
    }
  }

  /// Check if required audio files exist
  Future<bool> hasRequiredAudioFiles() async {
    try {
      for (final audioName in requiredAudioFiles) {
        final path = await getAudioPath(audioName);
        if (path == null) {
          print('Missing audio file: $audioName');
          return false;
        }
      }
      return true;
    } catch (e) {
      print('Error checking audio files: $e');
      return false;
    }
  }
}
