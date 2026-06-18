import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/mocks/mock_auth_data.dart';
import 'package:hairspare/models/login_portal.dart';
import 'package:hairspare/models/user.dart';

void main() {
  group('MockAuthData.userForCredentials', () {
    test('1/1 returns spare', () {
      final user = MockAuthData.userForCredentials('1', '1');
      expect(user?.role, UserRole.spare);
    });

    test('2/2 returns shop', () {
      final user = MockAuthData.userForCredentials('2', '2');
      expect(user?.role, UserRole.shop);
    });

    test('3/3 returns admin', () {
      final user = MockAuthData.userForCredentials('3', '3');
      expect(user?.role, UserRole.admin);
    });

    test('4/4 returns spare model', () {
      final user = MockAuthData.userForCredentials('4', '4');
      expect(user?.role, UserRole.spare);
      expect(user?.isModelAccount, isTrue);
    });

    test('invalid credentials return null', () {
      expect(MockAuthData.userForCredentials('3', '1'), isNull);
    });
  });

  group('MockAuthData.userForCredentialsOnPortal', () {
    test('spare portal rejects 2/2', () {
      expect(
        MockAuthData.userForCredentialsOnPortal('2', '2', LoginPortal.spare),
        isNull,
      );
    });

    test('shop portal rejects 1/1', () {
      expect(
        MockAuthData.userForCredentialsOnPortal('1', '1', LoginPortal.shop),
        isNull,
      );
    });

    test('spare portal accepts 1/1 and 3/3', () {
      expect(
        MockAuthData.userForCredentialsOnPortal('1', '1', LoginPortal.spare)?.role,
        UserRole.spare,
      );
      expect(
        MockAuthData.userForCredentialsOnPortal('4', '4', LoginPortal.spare)?.isModelAccount,
        isTrue,
      );
      expect(
        MockAuthData.userForCredentialsOnPortal('3', '3', LoginPortal.spare)?.role,
        UserRole.admin,
      );
    });

    test('shop portal accepts 2/2 and 3/3', () {
      expect(
        MockAuthData.userForCredentialsOnPortal('2', '2', LoginPortal.shop)?.role,
        UserRole.shop,
      );
      expect(
        MockAuthData.userForCredentialsOnPortal('3', '3', LoginPortal.shop)?.role,
        UserRole.admin,
      );
    });
  });

  group('MockAuthData mock token round-trip', () {
    test('admin token restores admin user', () {
      final token = MockAuthData.mockTokenForRole(UserRole.admin);
      final user = MockAuthData.userForMockToken(token);
      expect(user?.role, UserRole.admin);
    });

    test('model token restores model spare user', () {
      final token = MockAuthData.mockTokenForUser(MockAuthData.modelUser());
      final user = MockAuthData.userForMockToken(token);
      expect(user?.role, UserRole.spare);
      expect(user?.isModelAccount, isTrue);
    });
  });
}
