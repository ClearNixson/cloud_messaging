import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('Background message ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText;
  List<Map<String, String>> notificationHistory = [];
  
  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("messaging");
    messaging.getToken().then((value) {
      print(value);
    });
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received in foreground");
      print(message.notification?.body);
      addToHistory(message);
      showSimpleDialog(message);
    });
    
    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
      handleMessageNavigation(message);
    });
  }

  void addToHistory(RemoteMessage message) {
    setState(() {
      notificationHistory.insert(0, {
        'title': message.notification?.title ?? 'No title',
        'body': message.notification?.body ?? 'No body',
        'time': DateTime.now().toString(),
      });
    });
  }

  void showSimpleDialog(RemoteMessage message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message.notification?.title ?? 'Notification'),
          content: Text(message.notification?.body ?? ''),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  void handleMessageNavigation(RemoteMessage message) {
    // You can implement navigation logic here based on message data
    print('Message data: ${message.data}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Firebase Messaging Demo"),
            SizedBox(height: 20),
            Text("Received Notifications:"),
            Expanded(
              child: ListView.builder(
                itemCount: notificationHistory.length,
                itemBuilder: (context, index) {
                  final notification = notificationHistory[index];
                  return ListTile(
                    title: Text(notification['title']!),
                    subtitle: Text(notification['body']!),
                    trailing: Text(notification['time']!.substring(11, 16)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}