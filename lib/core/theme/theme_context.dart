import 'package:flutter/material.dart';

import 'kiseki_tokens.dart';

/// Удобный доступ к семантическим токенам: `context.tokens.primary`.
extension KisekiThemeContext on BuildContext {
  KisekiTokens get tokens => Theme.of(this).extension<KisekiTokens>()!;
}
