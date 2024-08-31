import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mimir/backend/user/entity/verify.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/login/page/index.dart';
import 'package:mimir/login/widgets/forgot_pwd.dart';
import 'package:mimir/utils/save.dart';
import 'package:mimir/widgets/markdown.dart';
import 'package:rettulf/rettulf.dart';

import '../../init.dart';
import '../entity/user.dart';

class MimirSignInPage extends ConsumerStatefulWidget {
  const MimirSignInPage({super.key});

  @override
  ConsumerState createState() => _MimirSignInPageState();
}

class _MimirSignInPageState extends ConsumerState<MimirSignInPage> {
  MimirAuthMethods? authMethods;
  var school = SchoolCode.sit;

  @override
  void initState() {
    super.initState();
    fetchAuthMethods();
  }

  Future<void> fetchAuthMethods() async {
    setState(() {
      this.authMethods = null;
    });
    final authMethods = await BackendInit.auth.fetchAuthMethods(school: school);
    setState(() {
      this.authMethods = authMethods;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PromptDiscardBeforeQuitScope(
      changed: true,
      child: buildBody(),
    );
  }

  Widget buildBody() {
    if (context.isPortrait) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 90,
          title: buildSchoolSelector(),
        ),
        body: [
          [
            buildHeader(),
            buildAuthMethods(),
          ].column(maa: MainAxisAlignment.spaceEvenly),
          const Divider(),
          AnimatedSwitcher(
            duration: Durations.medium2,
            child: buildLoginForm(),
          ).padAll(12),
        ].listview(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: [
          [
            buildHeader(),
            buildSchoolSelector(),
            buildAuthMethods(),
          ].column(caa: CrossAxisAlignment.center, maa: MainAxisAlignment.spaceEvenly),
          const VerticalDivider(),
          AnimatedSwitcher(
            duration: Durations.medium2,
            child: buildLoginForm(),
          ).padAll(8),
        ].row(),
      );
    }
  }

  Widget buildHeader() {
    return "Sign-in SIT Life"
        .text(
          style: context.textTheme.displaySmall,
          textAlign: TextAlign.center,
        )
        .padSymmetric(v: 20);
  }

  Widget buildAuthMethods() {
    final authMethods = this.authMethods;
    return AnimatedSwitcher(
      duration: Durations.medium2,
      child: authMethods != null ? buildAuthSegments(authMethods) : const CircularProgressIndicator.adaptive(),
    );
  }

  Widget buildLoginForm() {
    if (authMethods == null) {
      return const CircularProgressIndicator.adaptive().center();
    }
    return SchoolIdSignInForm(
      school: school,
    );
  }

  Widget buildAuthSegments(MimirAuthMethods methods) {
    return SegmentedButton(
      segments: [
        if (methods.schoolId != null)
          ButtonSegment(
            label: "School ID".text(),
            value: "school-id",
            enabled: methods.schoolId == true,
          ),
        ButtonSegment(
          label: "Phone".text(),
          value: "phone-number",
          enabled: false,
        ),
      ],
      selected: const {"school-id"},
      onSelectionChanged: (newSelection) {},
    );
  }

  Widget buildPhoneNumber() {
    return FilledButton(
      onPressed: () {},
      child: "Phone Number".text(),
    );
  }

  Widget buildSchoolSelector() {
    return DropdownMenu<SchoolCode>(
      label: "School".text(),
      initialSelection: school,
      onSelected: (newSelection) {
        final selected = newSelection ?? SchoolCode.sit;
        if (school != selected) {
          setState(() {
            school = selected;
          });
          fetchAuthMethods();
        }
      },
      dropdownMenuEntries: SchoolCode.values
          .map((school) => DropdownMenuEntry<SchoolCode>(
                value: school,
                label: school.l10n(),
              ))
          .toList(),
    );
  }
}

class SchoolIdSignInForm extends ConsumerStatefulWidget {
  final SchoolCode school;

  const SchoolIdSignInForm({
    super.key,
    required this.school,
  });

  @override
  ConsumerState createState() => _SchoolIdSignInFormState();
}

enum _SignInStatus {
  none,
  notFound,
  existing,
}

class _SchoolIdSignInFormState extends ConsumerState<SchoolIdSignInForm> {
  final $password = TextEditingController();
  var schoolId = "";
  bool isPasswordClear = false;
  bool isLoggingIn = false;
  bool accepted = false;
  var status = _SignInStatus.none;
  final $schoolIdForm = GlobalKey<FormState>();
  var checkingExisting = false;

  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  @override
  void dispose() {
    $password.dispose();
    super.dispose();
  }

  Widget buildBody() {
    final widgets = [
      [
        [
          buildSchoolId().expanded(),
          if (status == _SignInStatus.none)
            checkingExisting
                ? const CircularProgressIndicator.adaptive()
                : IconButton.filledTonal(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: schoolId.isEmpty
                        ? null
                        : () async {
                            await checkExisting(schoolId);
                          },
                  ),
        ].row(),
        if (status != _SignInStatus.none) buildPassword(),
      ].column(),
      if (status != _SignInStatus.none)
        MimirSchoolIdDisclaimerCard(
          accepted: accepted,
          onAccepted: (value) {
            setState(() {
              accepted = value;
            });
          },
        ),
      if (status == _SignInStatus.existing) buildSignIn(),
      if (status == _SignInStatus.notFound) buildSignUp(),
      // if (status != MimirSchoolIdSignInStatus.none)
      //   "Don't have a SIT Life account?\n It will automatically sign-up for you.".text(),
      const ForgotPasswordButton(url: "https://www.mysit.life"),
    ];
    return widgets.map((w) => w.padV(8)).toList().column(
          maa: MainAxisAlignment.spaceEvenly,
        );
    return ListView.separated(
      itemCount: widgets.length,
      itemBuilder: (ctx, i) => widgets[i],
      separatorBuilder: (ctx, i) => const SizedBox(height: 8),
    );
  }

  Future<void> checkExisting(String schoolId) async {
    if ($schoolIdForm.currentState?.validate() != true) {
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      checkingExisting = true;
    });
    final existing = await BackendInit.auth.checkExistingBySchoolId(
      school: widget.school,
      schoolId: schoolId,
    );
    setState(() {
      status = existing ? _SignInStatus.existing : _SignInStatus.notFound;
      checkingExisting = false;
    });
  }

  Widget buildForgotPassword() {
    return PlatformTextButton(
      onPressed: () {},
      child: "Forgot password?".text(),
    );
  }

  Widget buildSchoolId() {
    return Form(
      key: $schoolIdForm,
      child: TextFormField(
        autofillHints: const [AutofillHints.username],
        textInputAction: TextInputAction.next,
        autocorrect: false,
        // readOnly: isLoggingIn,
        enableSuggestions: false,
        validator: (account) => studentIdValidator(account, () => i18n.invalidAccountFormat),
        decoration: InputDecoration(
          labelText: "School ID",
          hintText: "Student ID/Worker ID",
          icon: Icon(context.icons.person),
        ),
        onChanged: (text) async {
          setState(() {
            schoolId = text;
            status = _SignInStatus.none;
          });
        },
        onFieldSubmitted: (text) async {
          await checkExisting(text);
        },
      ),
    );
  }

  Widget buildPassword() {
    return TextFormField(
      controller: $password,
      keyboardType: isPasswordClear ? TextInputType.visiblePassword : null,
      autofillHints: const [AutofillHints.password],
      textInputAction: TextInputAction.send,
      readOnly: isLoggingIn,
      contextMenuBuilder: (ctx, state) {
        return AdaptiveTextSelectionToolbar.editableText(
          editableTextState: state,
        );
      },
      autocorrect: false,
      enableSuggestions: false,
      obscureText: !isPasswordClear,
      onFieldSubmitted: (inputted) async {},
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "School password",
        icon: Icon(context.icons.lock),
        suffixIcon: PlatformIconButton(
          icon: Icon(isPasswordClear ? context.icons.eyeSolid : context.icons.eyeSlashSolid),
          onPressed: () {
            setState(() {
              isPasswordClear = !isPasswordClear;
            });
          },
        ),
      ),
    );
  }

  Widget buildSignIn() {
    return FilledButton.icon(
      onPressed: () {},
      icon: Icon(Icons.login),
      label: "Sign in".text(),
    );
  }

  Widget buildSignUp() {
    return FilledButton.icon(
      onPressed: () {},
      icon: Icon(Icons.create),
      label: "Sign up".text(),
    );
  }
}

class MimirSchoolIdDisclaimerCard extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onAccepted;

  const MimirSchoolIdDisclaimerCard({
    super.key,
    required this.accepted,
    required this.onAccepted,
  });

  @override
  Widget build(BuildContext context) {
    final md = """
## Disclaimer
We prioritize your data security.
Your School ID and password are used for verification and are immediately discarded after confirming your identity.

Please read the [Privacy Policy](https://www.mysit.life/privacy-policy) and [Term of Service](https://www.mysit.life/tos) before.
""";
    return [
      FeaturedMarkdownWidget(data: md),
      CheckboxListTile.adaptive(
        title: "I've read and accepted".text(),
        value: accepted,
        onChanged: (value) {
          if (value != null) {
            onAccepted(value);
          }
        },
      ),
    ].column(caa: CrossAxisAlignment.stretch).padAll(12).inOutlinedCard();
  }
}
