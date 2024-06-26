import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sit/credentials/entity/credential.dart';
import 'package:sit/credentials/init.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/utils/error.dart';

import '../init.dart';
import '../i18n.dart';
import '../widgets/item.dart';

// TODO: Send email
class EduEmailInboxPage extends ConsumerStatefulWidget {
  const EduEmailInboxPage({super.key});

  @override
  ConsumerState<EduEmailInboxPage> createState() => _EduEmailInboxPageState();
}

class _EduEmailInboxPageState extends ConsumerState<EduEmailInboxPage> {
  List<MimeMessage>? messages;

  @override
  initState() {
    super.initState();
    final credentials = ref.read(CredentialsInit.storage.$eduEmailCredentials);
    if (credentials != null) {
      refresh(credentials);
    }
  }

  Future<void> refresh(Credentials credentials) async {
    if (!mounted) return;
    try {
      await EduEmailInit.service.login(credentials);
    } catch (error, stackTrace) {
      handleRequestError(error, stackTrace);
      CredentialsInit.storage.eduEmailCredentials = null;
      return;
    }
    try {
      final result = await EduEmailInit.service.getInboxMessage(30);
      final messages = result.messages;
      // The more recent the time, the smaller the index in the list.
      messages.sort((a, b) {
        return a.decodeDate()!.isAfter(b.decodeDate()!) ? -1 : 1;
      });
      if (!mounted) return;
      setState(() {
        this.messages = messages;
      });
    } catch (error, stackTrace) {
      handleRequestError(error, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final credentials = ref.watch(CredentialsInit.storage.$eduEmailCredentials);
    final messages = this.messages;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: i18n.inbox.title.text(),
            bottom: credentials != null && messages == null
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(4),
                    child: LinearProgressIndicator(),
                  )
                : null,
          ),
          if (messages != null)
            SliverList.builder(
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                return EmailItem(messages[i]);
              },
            )
        ],
      ),
    );
  }
}
