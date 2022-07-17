import 'package:flutter_login_facebook/flutter_login_facebook.dart';

class AuthService {
  static Future<dynamic> facebookLogin() async {
    final fb = FacebookLogin();
    Map<String, dynamic> userDetails = {};
    String error;

    final res = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

    switch (res.status) {
      case FacebookLoginStatus.success:
        final FacebookAccessToken accessToken = res.accessToken;
        print('Access token: ${accessToken.token}');

        final profile = await fb.getUserProfile();
        print('Hello, ${profile.name}! You ID: ${profile.userId}');
        userDetails.putIfAbsent('name', () => profile.name.toString());

        final imageUrl = await fb.getProfileImageUrl(width: 100);
        print('Your profile image: $imageUrl');
        userDetails.putIfAbsent('image', () => imageUrl.toString());

        final email = await fb.getUserEmail();

        if (email != null) {
          print('And your email is $email');
          userDetails.putIfAbsent('email', () => email.toString());
        }
        break;
      case FacebookLoginStatus.cancel:
        break;
      case FacebookLoginStatus.error:
        print('Error while log in: ${res.error}');
        error = res.error.developerMessage;
        break;
    }

    return userDetails ?? error;
  }
}
