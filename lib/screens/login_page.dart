import 'package:badiup/colors.dart';
import 'package:badiup/screens/admin_home_page.dart';
import 'package:badiup/screens/customer_home_page.dart';
import 'package:badiup/sign_in.dart';
import 'package:badiup/test_keys.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loginInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loginInProgress
          ? LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(paletteForegroundColor),
              backgroundColor: paletteLightGreyColor,
            )
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(decoration: _buildBackgroundDecoration(context)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 100),
                    _buildBadiUpLogo(),
                    SizedBox(height: 32),
                    _buildLoginButton(context),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildBadiUpLogo() {
    return Container(
      height: 77,
      width: 249,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/badiup_logo.png'),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration(BuildContext context) {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/login_background.jpg'),
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return RaisedButton(
      key: Key(makeTestKeyString(TKUsers.user, TKScreens.login, "loginButton")),
      onPressed: () => _doLogin(context),
      color: paletteBlackColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      highlightElevation: 100,
      child: _buildLoginButtonInternal(),
    );
  }

  void _doLogin(BuildContext context) async {
    setState(() {
      _loginInProgress = true;
    });

    var result = await signInWithGoogle();

    if (result != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return currentSignedInUser.isAdmin()
                ? AdminHomePage(title: 'BADI UP')
                : CustomerHomePage(title: 'BADI UP');
          },
        ),
      );
    }

    setState(() {
      _loginInProgress = false;
    });
  }

  Widget _buildLoginButtonInternal() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image(
            image: AssetImage("assets/google_logo.png"),
            height: 20,
          ),
          Container(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              'Google でログイン',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: paletteLightGreyColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
