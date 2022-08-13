class Config {
  _FacePhotoConfig _facePhotoConfig;
  _FacePhotoConfig get facePhotoConfig => _facePhotoConfig;

  Config() : _facePhotoConfig = _FacePhotoConfig();
}

class _FacePhotoConfig {
  int cropSizeW = 500;
}
