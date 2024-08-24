import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sit/r.dart';
import 'package:sit/utils/guard_launch.dart';
import 'package:sit/widgets/inapp_webview/page.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  @override
  Widget build(BuildContext context) {
    return InAppWebViewPage(
      initialUri: WebUri.uri(R.forumUri),
      canNavigate: limitOrigin(R.forumUri, onBlock: (uri) async {
        await guardLaunchUrl(context, uri);
      }),
    );
  }
}
