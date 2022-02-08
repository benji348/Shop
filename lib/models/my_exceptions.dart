class MyHttpExecptions implements Exception {
  final String message;

  MyHttpExecptions(this.message);
  @override
  String toString() {
    return message;
  }
}
