


import 'package:flutter/material.dart';

class NavDrawer extends StatelessWidget {

  final loginAction;
  final logoutAction;
  final auth;
  
  const NavDrawer(this.loginAction, this.logoutAction, this.auth);
  @override
  Widget build(BuildContext context) {
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

}