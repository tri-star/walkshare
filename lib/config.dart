class Config {
  final _FacePhotoConfig _facePhotoConfig;
  _FacePhotoConfig get facePhotoConfig => _facePhotoConfig;

  final String _firebaseProjectId;
  String get firebaseProjectId => _firebaseProjectId;

  final String _firebaseRegion;
  String get firebaseRegion => _firebaseRegion;

  Config()
      : _facePhotoConfig = _FacePhotoConfig(),
        _firebaseProjectId = const String.fromEnvironment('projectId'),
        _firebaseRegion = const String.fromEnvironment('region');
}

class _FacePhotoConfig {
  int cropSizeW = 500;
}
