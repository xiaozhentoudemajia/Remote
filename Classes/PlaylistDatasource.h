//
//  PlaylistDatasource.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 29/07/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPRequestReply.h"
#import "ArtistDatasource.h"
#import "TrackCustomCellClass.h"
#import "DAAPDatasource.h"


@interface PlaylistDatasource : DAAPDatasource <UITableViewDataSource, UITableViewDelegate, DAAPRequestDelegate>{
	UINavigationController *navigationController;
	long long containerPersistentId;
}

@property (nonatomic, assign) UINavigationController *navigationController;
@property (nonatomic, assign) long long containerPersistentId;

@end
