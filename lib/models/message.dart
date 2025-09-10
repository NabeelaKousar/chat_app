enum MsgType { text, image }

class Message {
  final String fromId;
  final String toId;
  final String msg;
  final MsgType type;
  final String sent;
  final String read;

  Message({
    required this.fromId,
    required this.toId,
    required this.msg,
    required this.type,
    required this.sent,
    required this.read,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      fromId: json['fromId'] ?? '',
      toId: json['toId'] ?? '',
      msg: json['msg'] ?? '',
      type: json['type'] == 'image' ? MsgType.image : MsgType.text,
      sent: json['sent'] ?? '',
      read: json['read'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromId': fromId,
      'toId': toId,   // ✅ spelling fix
      'msg': msg,
      'type': type.name,
      'sent': sent,
      'read': read,
    };
  }
}