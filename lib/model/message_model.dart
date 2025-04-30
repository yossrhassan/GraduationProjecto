import 'package:graduation_project/constants.dart';

<<<<<<< HEAD
class Message {
  final String message;
  final String id;
  Message(this.message, this.id);
=======

class Message {
  final String message;
  final String id;
  Message(this.message,this.id);
>>>>>>> my-local-version

  factory Message.fromjson(jsondata) {
    return Message(jsondata[kMessage], jsondata['id']);
  }
}
