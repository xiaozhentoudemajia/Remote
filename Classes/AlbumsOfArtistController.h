//
//  AlbumsOfArtistController.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 11/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAAPResponseagal.h"
#import "AsyncImageLoader.h"

@interface AlbumsOfArtistController : UITableViewController <AsyncImageLoaderDelegate>{
	DAAPResponseagal *agal;
	@private
	NSMutableDictionary *artworks;
	NSMutableDictionary *cellId;
	NSMutableDictionary *loaders;
}

@property (nonatomic, retain) DAAPResponseagal *agal;



@end
