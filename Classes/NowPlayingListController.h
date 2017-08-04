//
//  NowPlayingListController.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 03/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAAPRequestReply.h"

@interface NowPlayingListController : UITableViewController <DAAPRequestDelegate>{
	NSArray *tracks;
	NSString *track;
	NSString *album;
	NSString *artist;
	NSNumber *albumId;
}

@property (nonatomic, retain) NSArray *tracks;
@property (nonatomic, copy) NSString *track;
@property (nonatomic, copy) NSString *album;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, retain) NSNumber *albumId;

- (void) scrollToCurrentlyPlayingTrack;

@end
