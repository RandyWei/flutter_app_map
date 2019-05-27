#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#include "FLTMapView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    
    NSString* pluginKey = NSStringFromClass([self class]);
    if (![self hasPlugin:pluginKey]) {
        NSObject<FlutterPluginRegistrar>* registrar = [self registrarForPlugin:pluginKey];
        
        FLTMapViewFactory* viewFactory = [[FLTMapViewFactory alloc]initWithMessenger:registrar.messenger];
        [registrar registerViewFactory:viewFactory withId:@"plugin.bughub.dev/amap_view"];
    }
    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end

