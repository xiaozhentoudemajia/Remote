//
//  TracksDatasource.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 24/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPRequestReply.h"
#import "ArtistDatasource.h"
#import "TrackCustomCellClass.h"
#import "DAAPDatasource.h"


@interface TracksDatasource : DAAPDatasource <UITableViewDataSource, UITableViewDelegate, DAAPRequestDelegate>{
	UINavigationController *navigationController;
}

@property (nonatomic, assign) UINavigationController *navigationController;

@end
