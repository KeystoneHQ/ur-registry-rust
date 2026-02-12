#import "UrRegistryFlutterPlugin.h"
#if __has_include(<ur_registry_flutter/ur_registry_flutter-Swift.h>)
#import <ur_registry_flutter/ur_registry_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ur_registry_flutter-Swift.h"
#endif

@implementation UrRegistryFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftUrRegistryFlutterPlugin registerWithRegistrar:registrar];
}
@end
