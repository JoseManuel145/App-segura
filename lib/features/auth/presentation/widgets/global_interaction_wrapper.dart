import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/security/session_manager.dart';

class GlobalInteractionWrapper extends StatelessWidget {
  final Widget child;

  const GlobalInteractionWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // listen: false porque solo queremos llamar a registerActivity, no reconstruir ante cambios
    final session = Provider.of<SessionManager>(context, listen: false);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => session.registerActivity(),
      onPointerMove: (_) => session.registerActivity(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          session.registerActivity();
          return false;
        },
        child: Focus(
          autofocus: true,
          onKeyEvent: (_, __) {
            session.registerActivity();
            return KeyEventResult.ignored;
          },
          child: child,
        ),
      ),
    );
  }
}
