import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> traineeData;

  @override
  void initState() {
    super.initState();
    traineeData = getData();
  }

  Future<List<Map<String, dynamic>>> getData() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('trainees')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Trainees')),
      child: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: traineeData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong!'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No trainees found'));
            }

            var trainees = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: trainees.length,
              itemBuilder: (context, index) {
                return TraineeCard(trainee: trainees[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class TraineeCard extends StatelessWidget {
  final Map<String, dynamic> trainee;

  const TraineeCard({super.key, required this.trainee});

  String get name => trainee['name'] ?? 'No name';

  String get email => trainee['email'] ?? 'No email';

  String get expectations => trainee['expectations'] ?? '';

  String get github => trainee['github'] ?? '';

  String get linkedIn => trainee['linkedIn'] ?? '';

  String get phone => trainee['phone'] ?? '';

  Future<void> openLink(String url) async {
    if (url.isEmpty) return;

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    await launchUrl(Uri.parse(url));
  }

  Future<void> makeCall(String phone) async {
    if (phone.isEmpty) return;

    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  void showExpectations(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoPopupSurface(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expectations',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navTitleTextStyle,
                    ),
                    const SizedBox(height: 16),
                    Text(expectations),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            email,
            style: const TextStyle(
              color: CupertinoColors.secondaryLabel,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 12),

          if (expectations.isNotEmpty) ...[
            Text(expectations, maxLines: 3, overflow: TextOverflow.ellipsis),

            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => showExpectations(context),
              child: const Text('See more...'),
            ),
          ],

          const SizedBox(height: 8),

          Row(
            children: [
              if (github.isNotEmpty)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => openLink(github),
                  child: const FaIcon(FontAwesomeIcons.github, size: 24),
                ),

              if (linkedIn.isNotEmpty)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => openLink(linkedIn),
                  child: const FaIcon(
                    FontAwesomeIcons.linkedin,
                    size: 24,
                    color: CupertinoColors.systemBlue,
                  ),
                ),

              if (phone.isNotEmpty)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => makeCall(phone),
                  child: const Icon(
                    CupertinoIcons.phone_fill,
                    size: 24,
                    color: CupertinoColors.systemGreen,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}