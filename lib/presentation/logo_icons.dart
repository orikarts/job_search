import 'package:flutter/material.dart';

IconData iconForLogo(String key) => switch (key) {
      'phone' => Icons.phone_android,
      'design' => Icons.brush,
      'server' => Icons.dns,
      'bug' => Icons.bug_report,
      'team' => Icons.groups,
      _ => Icons.work_outline,
    };