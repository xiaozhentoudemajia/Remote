//
//  TracksForAlbumController.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 11/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionManager.h"
#import "DetailedTrackCustomCellClass.h"


@interface TracksForAlbumController : UITableViewController {
	NSArray *tracks;
	BOOL shouldPlayAllTracks;
	NSString *albumName;
}

@property (nonatomic, retain) NSArray *tracks;
@property (nonatomic) BOOL shouldPlayAllTracks;
@property (nonatomic, copy) NSString *albumName;


@end
