import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../services/global_overlay_manager.dart';

class AppLifecycleObserver with WidgetsBindingObserver {
  static final AppLifecycleObserver _instance = AppLifecycleObserver._internal();
  factory AppLifecycleObserver() => _instance;
  AppLifecycleObserver._internal();

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GlobalOverlayManager().dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App is back in foreground
        debugPrint('App resumed - overlay should continue running');
        break;
      case AppLifecycleState.paused:
        // App is paused but overlay should stay active
        debugPrint('App paused - overlay continues in background');
        break;
      case AppLifecycleState.inactive:
        // App is inactive but overlay should stay active  
        debugPrint('App inactive - overlay continues in background');
        break;
      case AppLifecycleState.detached:
        // App is detached, clean up overlay
        debugPrint('App detached - disposing overlay');
        GlobalOverlayManager().dispose();
        break;
      case AppLifecycleState.hidden:
        // App is hidden but overlay should stay active
        debugPrint('App hidden - overlay continues in background');
        break;
    }
  }
}