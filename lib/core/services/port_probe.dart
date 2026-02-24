import 'dart:io';

class PortProbe {
  static Future<bool> isAvailable(int port, {String address = '127.0.0.1'}) async {
    try {
      final socket = await ServerSocket.bind(address, port);
      await socket.close();
      return true;
    } on SocketException {
      return false;
    }
  }

  static Future<int> findAvailablePort(
    int preferred, {
    int maxAttempts = 20,
    int step = 1,
  }) async {
    var port = preferred;
    for (var i = 0; i < maxAttempts; i++) {
      if (await isAvailable(port)) return port;
      port += step;
    }
    return preferred;
  }
}
