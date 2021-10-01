


import 'dart:convert';

import 'package:auth0_flutter_web/auth0_flutter_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import 'authObject.dart';
const AUTH0_DOMAIN = 'nemcrunchers.auth0.com';
const AUTH0_CLIENT_ID = 'Gxd73MGuYFuKwMnLAbvd8OlKKx5JBfwW';

const AUTH0_REDIRECT_URI = 'com.auth0.flutterdemo://login-callback';
const AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';


final FlutterAppAuth appAuth = FlutterAppAuth();
final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

class NavDrawer extends StatelessWidget {

  AuthObject auth = AuthObject.empty();
  

  @override
  Widget build(BuildContext context) {
    this.auth = Provider.of<AuthObject>(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 4.0),
                shape: BoxShape.circle,
                image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(auth.picture ?? ''),
                ),
            ),
          ),
          ListTile(
            leading: Icon((auth.isAuthenticated)?Icons.logout:Icons.login),
            title: Text((auth.isAuthenticated)?'Logout':'Login'),
            onTap: () {
                if(auth.isAuthenticated){
                    this.logoutAction();
                }else{
                    this.loginAction();
                }
                Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> parseIdToken(String idToken) {
    final parts = idToken.split(r'.');
    assert(parts.length == 3);

    return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
  }
  Future<Map<String, dynamic>> getUserDetails(String accessToken) async {
    final url = 'https://$AUTH0_DOMAIN/userinfo';
    final response = await get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }
  Future<void> loginAction() async {
    
    try {
      if(kIsWeb){
        Auth0 auth0 = await createAuth0Client(
          Auth0ClientOptions(
            domain: '$AUTH0_DOMAIN',
            client_id: '$AUTH0_CLIENT_ID',
          )
        );
        await auth0.loginWithPopup();
        Map<String, dynamic> user = (await auth0.getUser() ?? const {});
        Map<String, dynamic> tokenclaims = (await auth0.getIdTokenClaims() ?? const {});
        this.auth.updateAuthObject(tokenclaims['picture'], tokenclaims['name'], tokenclaims['__raw']);
      }else{
        final AuthorizationTokenResponse result =
          await appAuth.authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              AUTH0_CLIENT_ID,
              AUTH0_REDIRECT_URI,
              issuer: 'https://$AUTH0_DOMAIN',
              scopes: ['openid', 'profile', 'offline_access'],
              // promptValues: ['login']
            ),
          );

        final idToken = parseIdToken(result.idToken);
        final profile = await getUserDetails(result.accessToken);
        await secureStorage.write(
            key: 'refresh_token', value: result.refreshToken);
        await secureStorage.write(
            key: 'id_token', value: result.idToken);
        this.auth.updateAuthObject(profile['picture'], idToken['name'], result.idToken);
      }
      


    } catch (e, s) {
      print('login error: $e - stack: $s');
    }
  }
  void logoutAction() async {
    if(kIsWeb){
      Auth0 auth0 = await createAuth0Client(
        Auth0ClientOptions(
          domain: '$AUTH0_DOMAIN',
          client_id: '$AUTH0_CLIENT_ID',
        )
      );
      auth0.logout(
        options: LogoutOptions(
          returnTo: Uri.base.toString()
        ));
    }else{
      await secureStorage.delete(key: 'refresh_token');
    }
    this.auth.clearAuthObject();
  }
}