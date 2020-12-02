import 'package:flutter/material.dart';
import 'todo_list_screen.dart';
import '../models/user_modal.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<List<User>> listOfUsers;

  @override
  void initState() {
    super.initState();
    _updateUsers();
  }

  _updateUsers() {
    setState(() {
      listOfUsers = _getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login Screen App'),
        ),
        body: FutureBuilder<List<User>>(
            future: listOfUsers,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return functionBody(snapshot.data);
            }));
  }

  Widget functionBody(List<User> listOfUsers) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: Text(
                  'Book donation app',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                )),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Name',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            FlatButton(
              onPressed: () {
                //forgot password screen
              },
              textColor: Colors.blue,
              child: Text('Forgot Password'),
            ),
            Container(
                height: 50,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: RaisedButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  child: Text('Login'),
                  onPressed: () async {
                    print(nameController.text);
                    print(passwordController.text);
                    User current = new User(
                        username: nameController.text,
                        password: passwordController.text);
                    int logged = validUser(current, listOfUsers);

                    //verificar se está no DB e, se estiver, ir pra home
                    if (logged == 0)
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TodoListScreen()));
                    else if (logged == 1)
                      passwordController.text = "Senha invalida..";
                    else
                      nameController.text = "Usuario nao encontrado..";
                  },
                )),
            Container(
                child: Row(
              children: <Widget>[
                Text('Does not have account?'),
                FlatButton(
                  textColor: Colors.blue,
                  child: Text(
                    'Sign in',
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    //signup screen
                  },
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ))
          ],
        ));
  }

  /// Retorno 0: sucesso
  /// Retorno 1: senha incorreta
  /// Retorno 2: usuario nao encontrado
  int validUser(User current, List<User> listOfUsers) {
    String pw = current.password;
    String user = current.username;

    //chamada da api

    bool found = false;
    bool validPw = false;

    listOfUsers.forEach((element) {
      print(
          element.username + " sendo lido, com senha [${element.password}]\n");
      if (element.username == user) {
        found = true;
        print("Username bateu.\n");
        if (element.password == pw) {
          validPw = true;
          print("senha bateu.\n");
        }
      }
    });

    if (found && validPw) {
      return 0;
    } else if (found && !validPw)
      return 1;
    else
      return 2;
  }

  Future<List<User>> _getUsers() async {
    var response = await http.get(
        "https://my-json-server.typicode.com/diogoneiss/fakeJsonServer/users");
    var rb = response.body;

    // store json data into list
    var list = json.decode(rb) as List;

    // iterate over the list and map each object in list to Img by calling Img.fromJson
    List<User> userList = list.map((i) => User.fromJson(i)).toList();

    return userList;
  }
}
