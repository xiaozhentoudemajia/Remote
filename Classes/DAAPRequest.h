//
//  DAAPRequest.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 10/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DAAPRequest : NSObject {
	NSURLConnection* connection;
    NSMutableData* data;
}


@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSURLConnection *connection;

- (void) asyncRequest:(NSURL *)url;
- (void) cancelConnection;

+ (NSString *) parseCommandName:(NSData *) data atPosition:(int)position;
+ (NSString *) parseString:(NSData *) data;
+ (BOOL) parseBoolean:(NSData *) theData;
+ (short) parseShort:(NSData *) theData;
+ (long) parseLong:(NSData *) theData;
+ (long long) parseLongLong:(NSData *)theData;
+ (int) parseLength:(NSData *) theData atPosition:(int)pos;

@end
