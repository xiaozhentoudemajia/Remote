//
//  AsyncImageLoader.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 13/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "AsyncImageLoader.h"
#import "DDLog.h"

#ifdef CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation AsyncImageLoader
@synthesize delegate;
@synthesize data;
@synthesize connection;
@synthesize albumId;
@synthesize image;

- (void)loadImageFromURL:(NSURL*)url withId:(NSNumber *)theAlbumId;  {
	if(url == nil) 
		url = [NSURL URLWithString:@"error"];
	self.albumId = theAlbumId;
    if (self.connection!=nil) { [self cancelConnection];}
    if (self.data!=nil) { self.data = nil; }
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:60.0];
	[request setValue:@"1" forHTTPHeaderField:@"Viewer-Only-Client"];
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	NSURLConnection *conn =[[NSURLConnection alloc]
							initWithRequest:request delegate:self];
    self.connection = conn;
	[conn release];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
	assert(theConnection == self.connection);
	DDLogError(@"AsyncImageView - %@", [error localizedDescription]);
}

- (void)connection:(NSURLConnection *)theConnection
	didReceiveData:(NSData *)incrementalData {
	assert(theConnection == self.connection);
    if (self.data==nil) {
		NSMutableData *temp = [[NSMutableData alloc] initWithCapacity:2048];
		self.data = temp;
		[temp release];
	}
    [self.data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	assert(theConnection == self.connection);
    self.connection=nil;
	
		
	UIImage * img = [[UIImage alloc] initWithData:self.data];
	self.image = img;
	[img release];
    self.data = nil;
	
	if([delegate respondsToSelector:@selector(didFinishLoading:forAlbumId:)])
		[delegate didFinishLoading:self.image forAlbumId:self.albumId];
}

//method used to cancel the connection when don't need anymore the AsyncImageView object
- (void)cancelConnection {
	[self.connection cancel];
	self.connection = nil;
}

- (void)dealloc {
    [self.connection cancel];
    [self.connection release];
    [self.data release];
	[self.albumId release];
	[self.image release];
    [super dealloc];
}


@end
