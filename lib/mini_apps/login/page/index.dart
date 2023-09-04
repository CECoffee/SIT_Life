import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rettulf/rettulf.dart';

import '../init.dart';
import '../using.dart';

class LoginPage extends StatefulWidget {
  final bool isGuarded;

  const LoginPage({super.key, required this.isGuarded});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text field controllers.
  final TextEditingController $account = TextEditingController();
  final TextEditingController $password = TextEditingController();

  final GlobalKey _formKey = GlobalKey<FormState>();

  // State
  bool isPasswordClear = false;
  bool enableLoginButton = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final oaCredential = context.auth.oaCredential;
    if (oaCredential != null) {
      $account.text = oaCredential.account;
      $password.text = oaCredential.password;
    }
    super.didChangeDependencies();
  }

  /// 用户点击登录按钮后
  Future<void> onLogin(BuildContext ctx) async {
    bool formValid = (_formKey.currentState as FormState).validate();
    final account = $account.text;
    final password = $password.text;
    if (!formValid || account.isEmpty || password.isEmpty) {
      await ctx.showTip(
        title: i18n.formatError,
        desc: i18n.validateInputAccountPwdRequest,
        ok: i18n.close,
        serious: true,
      );
      return;
    }

    if (!mounted) return;
    setState(() => enableLoginButton = false);
    final connectionType = await Connectivity().checkConnectivity();
    if (connectionType == ConnectivityResult.none) {
      if (!mounted) return;
      setState(() => enableLoginButton = true);
      await ctx.showTip(
        title: i18n.network.error,
        desc: i18n.network.noAccessTip,
        ok: i18n.close,
        serious: true,
      );
      return;
    }

    try {
      final credential = OACredential(account, password);
      await LoginInit.ssoSession.loginActive(credential);
      final personName = await LoginInit.authServerService.getPersonName();
      if (!mounted) return;
      context.auth.setOaCredential(credential);
      context.auth.setLoginStatus(LoginStatus.validated);
      context.go("/");
    } on CredentialsInvalidException catch (e) {
      if (!mounted) return;
      await ctx.showTip(
        title: i18n.failedWarn,
        desc: e.msg,
        ok: i18n.close,
      );
      return;
    } catch (e, stacktrace) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stacktrace);
      if (!mounted) return;
      await ctx.showTip(
        title: i18n.failedWarn,
        desc: i18n.accountOrPwdIncorrectTip,
        ok: i18n.close,
        serious: true,
      );
    } finally {
      if (mounted) {
        setState(() => enableLoginButton = true);
      }
    }
  }

  Widget buildLoginForm(BuildContext ctx) {
    return Form(
      autovalidateMode: AutovalidateMode.always,
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: $account,
            textInputAction: TextInputAction.next,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            validator: studentIdValidator,
            decoration: InputDecoration(
              labelText: i18n.credential.account,
              hintText: i18n.accountHint,
              icon: const Icon(Icons.person),
            ),
          ),
          TextFormField(
            controller: $password,
            autofocus: true,
            textInputAction: TextInputAction.send,
            contextMenuBuilder: (ctx, state) {
              return AdaptiveTextSelectionToolbar.editableText(
                editableTextState: state,
              );
            },
            autocorrect: false,
            enableSuggestions: false,
            obscureText: !isPasswordClear,
            onFieldSubmitted: (inputted) {
              if (enableLoginButton) {
                onLogin(ctx);
              }
            },
            decoration: InputDecoration(
              labelText: i18n.credential.oaPwd,
              hintText: i18n.oaPwdHint,
              icon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(isPasswordClear ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    isPasswordClear = !isPasswordClear;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoginButton(BuildContext ctx) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          // Online
          onPressed: enableLoginButton && $account.value.text.isNotEmpty
              ? () {
                  // un-focus the text field.
                  FocusScope.of(context).requestFocus(FocusNode());
                  onLogin(ctx);
                }
              : null,
          child: i18n.loginBtn.text().padAll(5),
        ),
        if (!widget.isGuarded)
          ElevatedButton(
            // Offline
            onPressed: () {
              context.auth.setLoginStatus(LoginStatus.offline);
              context.go("/");
            },
            child: i18n.offlineModeBtn.text().padAll(5),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isGuarded ? i18n.loginRequired.text() : null,
        actions: [
          if (!widget.isGuarded)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.push("/settings");
              },
            ),
        ],
      ),
      body: buildBody(),
      //to avoid overflow when keyboard is up.
      bottomNavigationBar: [
        const ForgotPasswordButton(),
      ].wrap(align: WrapAlignment.center).padAll(10),
    );
  }

  Widget buildBody() {
    return [
      widget.isGuarded ? buildOfflineIcon() : buildTitle(),
      Padding(padding: EdgeInsets.only(top: 40.h)),
      // Form field: username and password.
      buildLoginForm(context),
      SizedBox(height: 10.h),
      // Login button.
      buildLoginButton(context),
    ]
        .column(mas: MainAxisSize.min)
        .scrolled(physics: const NeverScrollableScrollPhysics())
        .padH(50.w)
        .center()
        .safeArea();
  }

  Widget buildTitle() {
    return i18n.title.text(
      style: context.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget buildOfflineIcon() {
    return const Icon(
      Icons.person_off_outlined,
      size: 120,
    );
  }

  @override
  void dispose() {
    super.dispose();
    $account.dispose();
    $password.dispose();
  }
}

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(
        i18n.forgotPwdBtn,
        style: const TextStyle(color: Colors.grey),
      ),
      onPressed: () {
        guardLaunchUrlString(context, R.forgotLoginPwdUrl);
      },
    );
  }
}
