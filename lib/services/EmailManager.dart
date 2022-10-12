
import 'package:mrdqa_tool/models/Config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'ConfigManager.dart';

class EmailManager {

  final ConfigManager configManager;

  EmailManager({@required this.configManager});

  Future<void> sendEmail(String subject, String body, List<String> recipients, List<String> attachments) async {

    final Email email = new Email(subject: subject, body: body, recipients: recipients, attachmentPaths: attachments, isHTML: false,);
    String platformResponse;

    Future<Config> config = configManager.getConfig();

    config.then((data) async {
      try {
        await FlutterEmailSender.send(email);
        platformResponse = 'success';
      } catch (error) {
        platformResponse = error.toString();
      }
    });
  }
}