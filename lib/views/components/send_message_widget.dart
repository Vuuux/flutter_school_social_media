import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:luanvanflutter/models/user.dart';

class SendMessageWidget extends StatelessWidget {
  final TextEditingController messageTextEditingController;
  final Function sendMessage;
  const SendMessageWidget(
      {Key? key,
      required this.messageTextEditingController,
      required this.sendMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.grey)),
      alignment: Alignment.bottomCenter,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey)),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                controller: messageTextEditingController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration.collapsed(
                    hintText: "Gửi tin nhắn...",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none),
              ),
            ),
            GestureDetector(
              onTap: () {
                sendMessage.call();
                messageTextEditingController.text = "";
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset('assets/images/send.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
