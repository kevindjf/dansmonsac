import 'package:flutter_test/flutter_test.dart';
import 'package:onboarding/src/models/command/pack_time_command.dart';

void main() {
  group('PackTimeCommand', () {
    test('creates command with correct hour and minute', () {
      final command = PackTimeCommand(14, 30);

      expect(command.hour, 14);
      expect(command.minute, 30);
    });

    test('creates command with edge case values', () {
      final morningCommand = PackTimeCommand(0, 0);
      expect(morningCommand.hour, 0);
      expect(morningCommand.minute, 0);

      final eveningCommand = PackTimeCommand(23, 59);
      expect(eveningCommand.hour, 23);
      expect(eveningCommand.minute, 59);
    });
  });
}
