import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:natura_app/screens/direccion_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:natura_app/helpers/api_helper.dart';
import 'package:natura_app/models/response.dart';
import 'package:natura_app/models/token.dart';
import 'package:natura_app/models/user.dart';
import 'package:natura_app/screens/login_screen.dart';
import 'package:natura_app/screens/user_screen.dart';

class HomeScreen extends StatefulWidget {
  final Token token;

  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showLoader = false;
  late User _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = widget.token.user;
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfcbb04),
      // appBar: AppBar(
      //   title: Text('Natura App'),
      // ),
      body: _getBody(),
      // drawer: _getMenu(),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on),
                  SizedBox(
                    width: 20,
                  ),
                  Text('Editar Perfil'),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return Color(0xFFfc6c0c);
                }),
              ),
              onPressed: () => _editUser(),
            ),
            ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  SizedBox(
                    width: 20,
                  ),
                  Text('Salir'),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return Color(0xFFe4540c);
                }),
              ),
              onPressed: () => _logOut(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _getBody() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/logo.png'),
              width: 250,
            ),
            SizedBox(
              height: 40,
            ),
            ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: _user.imageFullPath,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  height: 200,
                  width: 200,
                  placeholder: (context, url) => Image(
                    image: AssetImage('assets/loading.gif'),
                    fit: BoxFit.cover,
                    height: 200,
                    width: 200,
                  ),
                )),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                'Bienvenido/a ${_user.fullName}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  // Widget _getMenu() {
  //   return Drawer(
  //     child: ListView(
  //       padding: EdgeInsets.zero,
  //       children: <Widget>[
  //         DrawerHeader(child: Image(image: AssetImage('assets/logo.png'))),
  //         ListTile(
  //           leading: Icon(Icons.location_on),
  //           title: Text('Direcciones'),
  //           onTap: () {
  //             Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => DireccionScreen(
  //                           token: widget.token,
  //                           user: widget.token.user,
  //                         )));
  //           },
  //         ),
  //         Divider(
  //           color: Colors.black,
  //           height: 2,
  //         ),
  //         ListTile(
  //           leading: Icon(Icons.face),
  //           title: Text('Editar perfil'),
  //           onTap: () async {
  //             String? result = await Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => UserScreen(
  //                           token: widget.token,
  //                           user: _user,
  //                           myProfile: true,
  //                         )));
  //             if (result == 'yes') {
  //               _getUser();
  //             }
  //           },
  //         ),
  //         ListTile(
  //           leading: Icon(Icons.logout),
  //           title: Text('Cerrar Sesión'),
  //           onTap: () {
  //             _logOut();
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemembered', false);
    await prefs.setString('userBody', '');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  Future<Null> _getUser() async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verifica que estés conectado a Internet',
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    Response response = await ApiHelper.getUser(widget.token, _user.id);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }
    setState(() {
      _user = response.result;
    });
  }

  _editUser() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserScreen(
                  token: widget.token,
                  user: _user,
                  myProfile: true,
                )));
    if (result == 'yes') {
      _getUser();
    }
  }
}
