import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelKey: 'basic',
            channelName: 'Notifications',
            channelDescription: 'Target Extension test notifications'
        )
      ]
  );
  runApp(const MyApp());
}

Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  // Navigate into pages, avoiding to open the notification details page over another details page already opened
  MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
          (route) => (route.settings.name != '/notification-page') || route.isFirst,
      arguments: receivedAction);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) =>
                MyHomePage(title: 'Flutter Demo Home Page')
            );

          case '/notification-page':
            return MaterialPageRoute(builder: (context) {
              final ReceivedAction receivedAction = settings
                  .arguments as ReceivedAction;
              return MyNotificationPage(receivedAction: receivedAction);
            });

          default:
            assert(false, 'Page ${settings.name} not found');
            return null;
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  initState(){
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod);
  }

  void _incrementCounter() async {
    bool notificationsAreAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!notificationsAreAllowed){
      notificationsAreAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    if (notificationsAreAllowed) {
      AwesomeNotifications()
          .createNotification(
          content: NotificationContent(
              id: -1,
              channelKey: 'basic',
              title: 'This is a nice notification!',
              body: 'This is a very cool notification! Take a look!',
              notificationLayout: NotificationLayout
                  .BigPicture,
              bigPicture: 'asset://assets/images/balloon.jpeg'
          )
      );

      setState(() {
        _counter++;
      });
    }
    else {
      print('notifications are not allowed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You already created all these notifications:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Create new notification',
        child: const Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class MyNotificationPage extends StatelessWidget {
  final ReceivedAction receivedAction;

  const MyNotificationPage({
    required this.receivedAction,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * .25,
            flexibleSpace: FlexibleSpaceBar(
              background: Image(
                  fit: BoxFit.cover,
                  image: receivedAction.bigPictureImage!
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(receivedAction.title ?? '', style: TextStyle(fontSize: 26)),
                SizedBox(height: 20),
                Text(receivedAction.body ?? '', style: TextStyle(fontSize: 14)),
                SizedBox(height: 20),
                Container(
                  color: Colors.grey.shade200,
                  padding: EdgeInsets.all(20),
                  child: Text(receivedAction.toString(), style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}

