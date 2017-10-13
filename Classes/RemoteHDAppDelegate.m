//
//  RemoteHDAppDelegate.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 19/05/10.
//  fabrice.dewasmes@gmail.com
//  Copyright Fabrice Dewasmes 2010. All rights reserved.
//

#import "RemoteHDAppDelegate.h"
#import "RemoteHDViewController.h"
#import "PreferencesManager.h"
#import "SynthesizeSingleton.h"
#import "DDLog.h"
#import "DDFileLogger.h"
#import "DDTTYLogger.h"
#import "CustomHTTPProtocol.h"

@implementation RemoteHDAppDelegate

@synthesize window;
@synthesize viewController;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.rootViewController = [[UIViewController alloc] init];
    
    static const int ddLogLevel = LOG_LEVEL_VERBOSE;//定义日志级别
    [DDLog addLogger:[DDTTYLogger sharedInstance]];// 初始化DDLog日志输出

    //保持一周的文件日志
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];

    // Override point for customization after app launch
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    
    [NSURLProtocol registerClass:[CustomHTTPProtocol class]];

	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application{
	[[PreferencesManager sharedPreferencesManager] persistPreferences];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
