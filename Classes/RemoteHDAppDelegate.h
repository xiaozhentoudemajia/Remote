//
//  RemoteHDAppDelegate.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 19/05/10.
//  fabrice.dewasmes@gmail.com
//  Copyright Fabrice Dewasmes 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDLog.h"

#ifdef CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif


@class RemoteHDViewController;

@interface RemoteHDAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RemoteHDViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RemoteHDViewController *viewController;


@end

