//
//  DAAPRequest.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 10/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPRequest.h"
#import "HexDumpUtility.h"
#import "DDLog.h"

#ifdef CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation DAAPRequest
@synthesize data;
@synthesize connection;

- (void) asyncRequest:(NSURL *)url{
	DDLogInfo(@"async requesting %@",url);
	if(url == nil) 
		url = [NSURL URLWithString:@"error"];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
													   timeoutInterval:10];
	[request setValue:@"1" forHTTPHeaderField:@"Viewer-Only-Client"];
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	NSURLConnection *conn =[[NSURLConnection alloc]
							initWithRequest:request delegate:self];
    self.connection = conn;
	[conn release];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
	assert(theConnection == self.connection);
	DDLogInfo(@"AsyncDAAPRequest - %@", [error localizedDescription]);
	[self.connection cancel];
	self.connection = nil;
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
	[HexDumpUtility printHexDumpToConsole:data];
	
    self.data = nil;
	self.connection = nil;
}

//method used to cancel the connection when don't need anymore the AsyncImageView object
- (void)cancelConnection {
	DDLogVerbose(@"CANCEL CONNECTION");
    [self.connection cancel];
    self.connection = nil;
	
	if (self.data!=nil) { 
		self.data = nil; 
	}
}

+ (NSString *) parseCommandName:(NSData *) theData atPosition:(int)position{
	UInt8 *command;
	if ([theData length] < (position + 4)) {
		return nil;
	}
	[theData getBytes:&command range:NSMakeRange(position,4)];
	NSString * str = [[[NSString alloc] initWithBytes:&command length:4 encoding:NSISOLatin1StringEncoding] autorelease];
	return str;
}

+ (NSString *) parseString:(NSData *) theData{
	NSString * str = [[[NSString alloc] initWithBytes:[theData bytes] length:[theData length] encoding:NSUTF8StringEncoding] autorelease];
	//[HexDumpUtility printHexDumpToConsole:theData];
	return str;
}

+ (void) getBytes:(Byte *)buffer fromData:(NSData *)theData length:(int)length{
	//[HexDumpUtility printHexDumpToConsole:data];
	Byte value[length];
	[theData getBytes:&value range:NSMakeRange(0, length)];
	
	for (int i = 0; i < length ; i ++) {
		buffer[i] = value[length - i - 1];
	}
	
}
+ (BOOL) parseBoolean:(NSData *) theData{
	Byte res[1];
	[self getBytes:res fromData:theData length:1];
	NSValue *hop = [NSValue value:res withObjCType:@encode(BOOL)];
	BOOL test;
	[hop getValue:&test];
	/*	if (test) NSLog(@"TRUE");
	 else NSLog(@"FALSE");*/
	return test;
}


+ (short) parseShort:(NSData *) theData{
	Byte res[2];
	[self getBytes:res fromData:theData length:2];
	NSValue *hop = [NSValue value:res withObjCType:@encode(short)];
	short test;
	[hop getValue:&test];
	//	NSLog(@"%d",test);
	return test;
}

+ (long) parseLong:(NSData *) theData {
	Byte res[4];
	[self getBytes:res fromData:theData length:4];
	NSValue *hop = [NSValue value:res withObjCType:@encode(long)];
	long test;
	[hop getValue:&test];
	//	NSLog(@"%d",test);
	return test;
}

+ (long long) parseLongLong:(NSData *)theData{
	Byte res[8];
	[self getBytes:res fromData:theData length:8];
	NSValue *hop = [NSValue value:res withObjCType:@encode(long long)];
	long long test;
	[hop getValue:&test];
	//	NSLog(@"%qX",test);
	return test;
}

+ (int) parseLength:(NSData *) theData atPosition:(int)pos{
	Byte value[4];
	Byte finalValue[4];
	int test;
	int length = 4;
	[theData getBytes:&value range:NSMakeRange(pos, length)];
	
	// we have to revert endianness
	for (int i = 0; i < length ; i ++) {
		finalValue[i] = value[length - i - 1];
	}
	
	NSValue *hop = [NSValue value:&finalValue withObjCType:@encode(int)];
	[hop getValue:&test];
	
	return test;
}

@end
