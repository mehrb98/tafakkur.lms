import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../models/models.dart';

class AuthController extends ChangeNotifier {
  AuthController(this.api) {
    api.onSessionExpired = () {
      if (!isDemo) _reset();
    };
  }

  final ApiClient api;
  AppUser? user;
  bool isDemo = false;

  bool get isSignedIn => user != null;

  Future<void> signIn(String email, String password, {bool rememberMe = true}) async {
    final body = await api.post('/auth/login', {
      'email': email,
      'password': password,
      'remember_me': rememberMe,
    }) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    api.accessToken = data['access_token'] as String;
    user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    isDemo = false;
    notifyListeners();
  }

  void signInDemo(Role role) {
    const names = {
      Role.admin: ('Dilnoza', 'Karimova'),
      Role.teacher: ('Aziz', 'Rahimov'),
      Role.student: ('Malika', 'Yusupova'),
      Role.parent: ('Sardor', 'Yusupov'),
    };
    final (first, last) = names[role]!;
    user = AppUser(
      id: 'demo-${role.name}',
      email: '${role.name}@demo.tafakkur.uz',
      firstName: first,
      lastName: last,
      role: role,
      emailVerified: true,
    );
    isDemo = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    if (!isDemo) {
      try {
        await api.post('/auth/logout');
      } on Exception {
        // Clear locally even if the server call fails.
      }
    }
    _reset();
  }

  void _reset() {
    api.clear();
    user = null;
    isDemo = false;
    notifyListeners();
  }
}
