import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;

import 'Models/user.dart';

// 🔹 AUTO ID GENERATOR
String generateUserId() {
  DateTime now = DateTime.now();
  return "${now.year}"
      "${now.month.toString().padLeft(2, '0')}"
      "${now.day.toString().padLeft(2, '0')}"
      "${now.hour.toString().padLeft(2, '0')}"
      "${now.minute.toString().padLeft(2, '0')}"
      "${now.second.toString().padLeft(2, '0')}"
      "${now.millisecond.toString().padLeft(3, '0')}";
}

void main() async {
  final router = Router();

  // JSON file
  File database = File("${Directory.current.path}/data.json");

  // Read JSON
  String jsonString = await database.readAsString();
  Map<String, dynamic> dartObject = jsonDecode(jsonString);

  List<User> data = (dartObject["Users"] as List)
      .map((e) => User.fromJson(e))
      .toList();

       //  ===== GET (all user) ===== 
  router.get("/", (Request req) {
    return Response.ok(
      jsonEncode(data.map((e) => e.toJson()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  });

           //  ===== POST (add user) ===== 
  router.post("/addUser", (Request req) async {
    var body = await req.readAsString();
    var obj = jsonDecode(body);

    obj["UserId"] = generateUserId();
    print("Generated ID: ${obj["UserId"]}");

    data.add(User.fromJson(obj));

    Map records = {"Users": data.map((e) => e.toJson()).toList()};

    await database.writeAsString(jsonEncode(records));

    return Response.ok(
      jsonEncode(obj),
      headers: {'Content-Type': 'application/json'},
    );
  });
 
           //  ===== PUT (update user) ===== 

  router.put("/updateUser/<UserEmail>", (Request res) async {
    String? email = res.params["UserEmail"];
    int index = data.indexWhere((item) => item.UserEmail == email);

    if (index == -1) {
      return Response.notFound(
         jsonEncode({"message": "User exist nahi karta"}),
          headers: {'Content-Type': 'application/json'},
      );
    }

     // Existing user
  User oldUser = data[index];

  // Read body
  var body = await res.readAsString();
  var obj = jsonDecode(body);

  // Partial update
  User updatedUser = User(
    UserId: oldUser.UserId, //change nahi hoga
    UserName: obj["UserName"] ?? oldUser.UserName,
    UserEmail: obj["UserEmail"] ?? oldUser.UserEmail,
    UserPassword: obj["UserPassword"] ?? oldUser.UserPassword,
    UserAge: obj["UserAge"] ?? oldUser.UserAge,
  );

  data[index] = updatedUser;

  Map records = {
    "Users": data.map((e) => e.toJson()).toList()
  };

  await database.writeAsString(jsonEncode(records));

  return Response.ok(
    jsonEncode(updatedUser.toJson()),
    headers: {'Content-Type': 'application/json'},
  );
});
 
    //  ===== DELETE (delete user) =====   
  router.delete("/deleteUser/<UserId>", (Request req) async {
  String id = req.params["UserId"]!;

  int index = data.indexWhere((u) => u.UserId == id);

 if (index == -1) {
    return Response.notFound(
      jsonEncode({"message": "User exist nahi karta"}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  //  Remove user
  User deletedUser = data.removeAt(index);

  // Rewrite JSON file
  Map records = {
    "Users": data.map((e) => e.toJson()).toList()
  };

  await database.writeAsString(jsonEncode(records));

  return Response.ok(
    jsonEncode({
      "message": "User successfully deleted",
      "deletedUser": deletedUser.toJson()
    }),
    headers: {'Content-Type': 'application/json'},
  );
});

  final server = await io.serve(router, "localhost", 9001);
  print("Server running on http://localhost:9001");
}
