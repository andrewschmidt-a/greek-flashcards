import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:auth0_flutter_web/auth0_flutter_web.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
//import 'package:page_transition/page_transition.dart';

import 'authObject.dart';
import 'question.dart';
import 'nav-drawer.dart';
import 'flashcard.dart';
import 'quiz_brain.dart';
import 'scorekeeper.dart';
//import 'Constants.dart';

/// -----------------------------------
///           Auth0 Variables
/// -----------------------------------

const AUTH0_DOMAIN = 'nemcrunchers.auth0.com';
const AUTH0_CLIENT_ID = 'Gxd73MGuYFuKwMnLAbvd8OlKKx5JBfwW';

const AUTH0_REDIRECT_URI = 'com.auth0.flutterdemo://login-callback';
const AUTH0_ISSUER = 'https://$AUTH0_DOMAIN';


final FlutterAppAuth appAuth = FlutterAppAuth();
final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

QuizBrain quizBrain = QuizBrain();
ScoreKeeper scoreKeeper = ScoreKeeper();

late Auth0 auth0;

void main() async {
  auth0 = await createAuth0Client(
    Auth0ClientOptions(
      domain: '$AUTH0_DOMAIN',
      client_id: '$AUTH0_CLIENT_ID',
    )
  );
  runApp(StudyApp());
}

class StudyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Greek Flashcardss',
      theme: ThemeData.light(),
      initialRoute: 'defaultpage',
      routes: <String, WidgetBuilder>{
        'defaultpage': (BuildContext context) => new DefaultPage(),
        'flashscreen': (BuildContext context) => new FlashScreen(quizBrain, scoreKeeper)
      },
    );
  }
}


class DefaultPage extends StatefulWidget {
  @override
  _DefaultPageState createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  bool loading = true;
  bool isBusy = false;
  bool isLoggedIn = false;
  String errorMessage = "";
  AuthObject auth = AuthObject.empty();
  loadAsset(filename) async {
    print('Loading');
    List<List<dynamic>> data = [];
    Response res = await get(
      "https://greek.nemcrunchers.dev/.netlify/functions/content",
      headers: {'Authorization': 'Bearer '+this.auth.token},
    );
    print('Converting');
    List<List<dynamic>> csvTable = jsonDecode(res.body)[filename];
    print('Starting');

    data = csvTable;
    List<Question> questionBank = [];
    for (var i = 0; i < data.length; i++) {
      print('Adding ' + data[i][0]);
      questionBank.add(Question(data[i][0], data[i][1]));
    }
    quizBrain.setQuestions(questionBank);
    print('Finished');
  }

  @override
  Widget build(BuildContext context) {
    var spacecrafts = ["Chapter 1", "Chapter 2"];
    var myGridView = new GridView.builder(
      itemCount: spacecrafts.length,
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (BuildContext context, int index) {
        return new GestureDetector(
          child: new Card(
            elevation: 5.0,
            child: new Container(
              alignment: Alignment.centerLeft,
              margin: new EdgeInsets.only(top: 10.0, bottom: 10.0,left: 10.0),
              child: new Text(spacecrafts[index]),
            ),
          ),
          onTap: () {
            loadAsset(spacecrafts[index].replaceAll(" ", ""));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FlashScreen(quizBrain, scoreKeeper)),
            );
          },
        );
      },
    );

    return new Scaffold(
      drawer: NavDrawer(this.loginAction, this.logoutAction, this.auth),
      appBar: new AppBar(
          title: new Text("Greek Study Cards")
      ),
      body: myGridView,
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
    setState(() {
      isBusy = true;
      errorMessage = '';
    });

    try {
      if(kIsWeb){

        await auth0.loginWithPopup();
        String token = await auth0.getTokenSilently();
        Map<String, dynamic> user = (await auth0.getUser() ?? const {});
        Map<String, dynamic> tokenclaims = (await auth0.getIdTokenClaims() ?? const {});
        print(tokenclaims);
        setState(() {
          isBusy = false;
          isLoggedIn = true;
          auth = AuthObject(tokenclaims['picture'], tokenclaims['name'], tokenclaims['__raw']);
        });
        print(token);
        // await secureStorage.write(
        //     key: 'id_token', value: token);
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
        setState(() {
          isBusy = false;
          isLoggedIn = true;
          auth = AuthObject(profile['picture'], idToken['name'], result.idToken);
        });
      }
      


    } catch (e, s) {
      print('login error: $e - stack: $s');

      setState(() {
        isBusy = false;
        isLoggedIn = false;
        errorMessage = e.toString();
      });
    }
  }
  void logoutAction() async {
    if(kIsWeb){
      auth0.logout(
        options: LogoutOptions(
          returnTo: Uri.base.toString()
        ));
    }else{
      await secureStorage.delete(key: 'refresh_token');
    }
    setState(() {
      isLoggedIn = false;
      isBusy = false;
      auth = AuthObject.empty();
    });
  }
}
