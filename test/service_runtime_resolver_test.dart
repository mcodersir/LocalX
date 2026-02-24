import 'package:flutter_test/flutter_test.dart';
import 'package:localx/core/services/service_runtime.dart';

void main() {
  test('resolver provides docker fallback for redis', () {
    final plan = ServiceRuntimeResolver.resolve('redis', 6380);
    expect(plan.native.command, isNotEmpty);
    expect(plan.dockerFallback, isNotNull);
    expect(plan.dockerFallback!.image, contains('redis'));
  });

  test('resolver returns native plan for websocket', () {
    final plan = ServiceRuntimeResolver.resolve('websocket', 6001);
    expect(plan.native.command, isNotEmpty);
  });
}
