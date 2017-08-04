//
//  ArtistDelegate.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 11/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPDatasource.h"
#import "DAAPRequestReply.h"


@interface ArtistDatasource : DAAPDatasource <UITableViewDataSource, UITableViewDelegate, DAAPRequestDelegate>{

	UINavigationController *navigationController;
}

@property (nonatomic, assign) UINavigationController *navigationController;

@end
