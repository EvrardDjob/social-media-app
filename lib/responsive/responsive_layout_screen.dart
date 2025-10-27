import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/provider/user_provider.dart';
import 'package:social_media_app/utils/global_variables.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;
  const ResponsiveLayout({super.key, required this.webScreenLayout, required this.mobileScreenLayout});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {

  @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async{
    //Accède au UserProvider (votre magasin d'état pour l'utilisateur). L'argument listen: false est crucial car il indique au widget de ne pas se reconstruire si les données du Provider changent.
    UserProvider _userProvider=Provider.of(context,listen: false);
    await _userProvider.refreshUser();
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints){
        if(constraints.maxWidth > webScreenSize){
          return widget.webScreenLayout;
        } else{
          return widget.mobileScreenLayout;
        }
      }
    );
  }
}