//
//  MasterViewController.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 19/05/10.
//  fabrice.dewasmes@gmail.com
//  Copyright Fabrice Dewasmes 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAAPRequestReply.h"
#import "DetailViewController.h"
#import "ShoutcastController.h"
#import "WifiConfigController.h"

@protocol MasterViewDelegate

- (void)didSelectPlaylist;
- (void)didSelectLibrary;
- (void)didSelectBooksOrPodcasts;
- (void)didSelectShoutCast;
- (void)didSelectWifiConfig;

@end


@interface MasterViewController : UITableViewController {
	NSArray *results;
	IBOutlet DetailViewController *detailViewController;
	id<MasterViewDelegate> delegate;
	BOOL initialState;
    ShoutcastController *shoutcastController;
    WifiConfigController *wifiConfigController;
};

@property (nonatomic, retain) NSArray *results;
@property (nonatomic, assign) id<MasterViewDelegate> delegate;

- (void) didChangeLibrary;

@end
