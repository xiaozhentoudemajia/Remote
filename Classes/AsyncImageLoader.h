//
//  AsyncImageLoader.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 13/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AsyncImageLoaderDelegate <NSObject>
-(void)didFinishLoading:(UIImage *)image forAlbumId:(NSNumber *)albumId;
@end

@interface AsyncImageLoader : NSObject {
	NSURLConnection* connection;
    NSMutableData* data;
	NSNumber *albumId;
	UIImage *image;
	id <AsyncImageLoaderDelegate> delegate;
}

@property (nonatomic, assign) id <AsyncImageLoaderDelegate> delegate;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSNumber *albumId;
@property (nonatomic, retain) UIImage *image;

- (void)loadImageFromURL:(NSURL*)url withId:(NSNumber *)theAlbumId;
- (void)cancelConnection;

@end
