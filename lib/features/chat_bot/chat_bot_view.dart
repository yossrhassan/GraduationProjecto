import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../core/utils/assets.dart';

class ChatPage extends StatelessWidget {
  static String id = 'ChatPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetsData.logo,
              height: 50,
            ),
            Text('Chat')
          ],
        ),
      ),
      body: Column(
        children: [
          // 🎨 RENDERING MANAGEMENT INTERFACE - This should be visible!
          Container(
            color: Colors.green,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle invite friends button press
                  },
                  child: Text('INVITE FRIENDS'),
                ),
                TextButton(
                  onPressed: () {
                    // Handle share match button press
                  },
                  child: Text('SHARE MATCH'),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle leave match button press
            },
            child: Text('LEAVE MATCH'),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: 0, // No items to display
              itemBuilder: (context, index) {
                return Container(); // Empty container since no items
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.send,
                    color: kPrimaryColor,
                  ),
                  hintText: 'send message',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: kPrimaryColor))),
            ),
          )
        ],
      ),
    );
  }
}
