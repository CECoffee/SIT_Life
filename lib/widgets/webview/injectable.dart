import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mimir/util/logger.dart';
import 'package:mimir/util/url_launcher.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../unsupported_platform_launch.dart';

typedef JavaScriptMessageCallback = void Function(JavaScriptMessage msg);

enum InjectionPhrase {
  onPageStarted,
  onPageFinished,
}

class Injection {
  /// js注入的url匹配规则
  bool Function(String url) matcher;

  /// 若为空，则表示不注入
  String? js;

  /// 异步js字符串，若为空，则表示不注入
  Future<String?>? asyncJs;

  /// js注入时机
  InjectionPhrase phrase;

  Injection({
    required this.matcher,
    this.js,
    this.asyncJs,
    this.phrase = InjectionPhrase.onPageFinished,
  });
}

class InjectableWebView extends StatefulWidget {
  final String initialUrl;
  final WebViewController? controller;

  /// js注入规则，判定某个url需要注入何种js代码
  final List<Injection>? injections;

  /// hooks
  final void Function(String url)? onPageStarted;
  final void Function(String url)? onPageFinished;
  final void Function(int progress)? onProgress;

  /// 注入cookies
  final List<WebViewCookie> initialCookies;

  /// 自定义 UA
  final String? userAgent;

  final JavaScriptMode mode;

  /// 暴露dart回调到js接口
  final Map<String, JavaScriptMessageCallback>? javaScriptChannels;

  /// 如果不支持webview，是否显示浏览器打开按钮
  final bool showLaunchButtonIfUnsupported;

  const InjectableWebView({
    Key? key,
    required this.initialUrl,
    this.controller,
    this.mode = JavaScriptMode.unrestricted,
    this.injections,
    this.onPageStarted,
    this.onPageFinished,
    this.onProgress,
    this.userAgent,
    this.initialCookies = const <WebViewCookie>[],
    this.javaScriptChannels,
    this.showLaunchButtonIfUnsupported = true,
  }) : super(key: key);

  @override
  State<InjectableWebView> createState() => _InjectableWebViewState();
}

class _InjectableWebViewState extends State<InjectableWebView> {
  late WebViewController controller;
  late WebViewCookieManager cookieManager;

  @override
  void initState() {
    super.initState();
    controller =(widget.controller ?? WebViewController())
      ..setJavaScriptMode(widget.mode)
      ..setUserAgent(widget.userAgent)
      ..setNavigationDelegate(NavigationDelegate(
        onWebResourceError: onResourceError,
        onPageStarted: (String url) async {
          Log.info('"$url" starts loading.');
          await Future.wait(filterMatchedRule(url, InjectionPhrase.onPageStarted).map(injectJs));
          widget.onPageStarted?.call(url);
        },
        onPageFinished: (String url) async {
          Log.info('"$url" loaded.');
          await Future.wait(filterMatchedRule(url, InjectionPhrase.onPageFinished).map(injectJs));
          widget.onPageFinished?.call(url);
        },
        onProgress: widget.onProgress,
      ));
    final channels = widget.javaScriptChannels;
    if (channels != null) {
      for (final entry in channels.entries) {
        controller.addJavaScriptChannel(entry.key, onMessageReceived: entry.value);
      }
    }
    for (final cookie in widget.initialCookies) {
      cookieManager.setCookie(cookie);
    }
    controller.loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    if (UniversalPlatform.isDesktop) {
      return UnsupportedPlatformUrlLauncher(
        widget.initialUrl,
        showLaunchButton: widget.showLaunchButtonIfUnsupported,
      );
    } else {
      return WebViewWidget(
        controller: controller,
      );
    }
  }

  /// 获取该url匹配的所有注入项
  Iterable<Injection> filterMatchedRule(String url, InjectionPhrase phrase) sync* {
    final rules = widget.injections;
    if (rules != null) {
      for (final rule in rules) {
        if (rule.matcher(url) && rule.phrase == phrase) {
          yield rule;
        }
      }
    }
  }

  /// 根据当前url筛选所有符合条件的js脚本，执行js注入
  Future<void> injectJs(Injection injection) async {
    var injected = false;
    // 同步获取js代码
    if (injection.js != null) {
      injected = true;
      await controller.runJavaScript(injection.js!);
    }
    // 异步获取js代码
    if (injection.asyncJs != null) {
      injected = true;
      String? js = await injection.asyncJs;
      if (js != null) {
        await controller.runJavaScript(js);
      }
    }
    if (injected) {
      Log.info('JavaScript code was injected.');
    }
  }

  void onResourceError(WebResourceError error) {
    if (error.description.startsWith('http')) {
      launchUrlInBrowser(error.description);
      controller.goBack();
    }
  }
}