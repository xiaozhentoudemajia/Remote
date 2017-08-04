//
//  DAAPRequestReply.m
//  yTrack
//
//  Created by Fabrice Dewasmes on 15/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPRequestReply.h"
#import "HexDumpUtility.h"
#import "SessionManager.h"
#import "DAAPResponseerror.h"
#import "DDLog.h"

#ifdef CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif


@implementation DAAPRequestReply

@synthesize delegate;
@synthesize action;


- (void) asyncRequestAndParse:(NSURL *)url withTimeout:(int)timeoutInterval{
	DDLogVerbose(@"DAAPRequestReply async requesting %@",url);
	if(url == nil) 
		url = [NSURL URLWithString:@"error"];
	lastUrl = url;
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
													   timeoutInterval:timeoutInterval];
	[request setValue:@"1" forHTTPHeaderField:@"Viewer-Only-Client"];
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	NSURLConnection *conn =[[NSURLConnection alloc]
							initWithRequest:request delegate:self startImmediately:YES];
    self.connection = conn;
	[conn release];
}

- (void) asyncRequestAndParse:(NSURL *)url{
	[self asyncRequestAndParse:url withTimeout:10];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
	assert(theConnection == self.connection);
	DDLogError(@"AsyncDAAPRequestReply - %@, %d, %@", [error localizedDescription], error.code, error.domain);
	[self.connection cancel];
	self.connection = nil;
	if (error.code == NSURLErrorCannotConnectToHost) {
		if([delegate respondsToSelector:@selector(cantConnect)])
			[delegate cantConnect];
	} else if (error.code == NSURLErrorTimedOut) {
		if([delegate respondsToSelector:@selector(connectionTimedOut)])
			[delegate connectionTimedOut];
	} else if (error.code == NSURLErrorNotConnectedToInternet) {
		if([delegate respondsToSelector:@selector(cantConnect)])
			[delegate cantConnect];
	} else if (error.code == NSURLErrorCannotFindHost) {
		if([delegate respondsToSelector:@selector(cantConnect)])
			[delegate cantConnect];
	} 
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

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response 
// exchange is complete.  We look at the response to check that the HTTP 
// status code is 2xx and that the Content-Type is acceptable.  If these checks 
// fail, we give up on the transfer.
{
#pragma unused(conn)
    
    NSHTTPURLResponse * httpResponse;
	
    assert(conn == self.connection);
	
   
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        DDLogError(@"HTTP error %zd", (ssize_t) httpResponse.statusCode);
    } 
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	assert(theConnection == self.connection);

#ifdef CONFIGURATION_DEBUG
	[HexDumpUtility printHexDumpToConsole:data];
#endif
	
	NSString *command = [DAAPRequestReply parseCommandName:data atPosition:0];
	NSString *clazz = [NSString stringWithFormat:@"DAAPResponse%@",command];
	
	id response = [[NSClassFromString(clazz) alloc] initWithData:data];
	
	NSDate *methodStart = [NSDate date];
	//DDLogError(@"starting parsing : %@",[methodStart description]); 
	[response performSelector:@selector(parse)];
	NSDate *methodFinish = [NSDate date];
	NSTimeInterval parsingTime = [methodFinish timeIntervalSinceDate:methodStart];
	DDLogVerbose(@"the connection %@, parsing time : %f",[connection description], parsingTime);
	
    self.data = nil;
	self.connection = nil;
	/*if (delegate != nil) {
		if([delegate respondsToSelector:@selector(didFinishLoading:)])
			[delegate didFinishLoading:response];
	}*/
	
	if (delegate != nil) {
		if([delegate respondsToSelector:action])
			[delegate performSelector:action withObject:response];
		else if([delegate respondsToSelector:@selector(didFinishLoading:)])
			[delegate didFinishLoading:response];

	}
	
	[response release];
}

+ (DAAPResponse *) onTheFlyRequestAndParseResponse:(NSURL *) url{
	DDLogVerbose(@"---- CALLING SYNC !---");
	NSURLResponse * resp;
	NSError *error;
	NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
														   timeoutInterval:30];
	[urlRequest setValue:@"1" forHTTPHeaderField:@"Viewer-Only-Client"];
	[urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	NSData *dat = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&resp error:&error];
	if (error != nil) {
		//DDLogError(@"onTheFlyRequestAndParseResponse - %@, %d, %@", [error localizedDescription], error.code, error.domain);
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBrokenConnection object:self];
	}
#ifdef CONFIGURATION_DEBUG
	[HexDumpUtility printHexDumpToConsole:dat];
#endif
	
	NSString *command = [self parseCommandName:dat atPosition:0];
	if (command == nil) {
		return [[[DAAPResponseerror alloc] initWithData:dat error:error] autorelease];
	}
	NSString *clazz = [NSString stringWithFormat:@"DAAPResponse%@",command];
	
	
	DAAPResponse *response = [[[NSClassFromString(clazz) alloc] initWithData:dat] autorelease];
	[response performSelector:@selector(parse)];
	return response;
}


+ (DAAPResponse *) onTheFlyRequestAndParseResponse:(NSURL *) url error:(NSError **)error{
	NSURLResponse * resp;
	//NSError *error;
	NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
														   timeoutInterval:30];
	[urlRequest setValue:@"1" forHTTPHeaderField:@"Viewer-Only-Client"];
	[urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	NSData *dat = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&resp error:error];

#ifdef CONFIGURATION_DEBUG
	[HexDumpUtility printHexDumpToConsole:dat];
#endif

	NSString *command = [self parseCommandName:dat atPosition:0];
	if (command == nil) {
		return [[[DAAPResponseerror alloc] initWithData:dat] autorelease];
	}
	NSString *clazz = [NSString stringWithFormat:@"DAAPResponse%@",command];
	
	
	DAAPResponse *response = [[[NSClassFromString(clazz) alloc] initWithData:dat] autorelease];
	[response performSelector:@selector(parse)];
	return response;
}

+ (UIImage *) imageFromUrl:(NSURL *) url {
	NSURLResponse * resp;
	NSError *error;
	NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
	[urlRequest setValue:@"1" forHTTPHeaderField:@"Viewer-Only-Client"];
	[urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	DDLogVerbose(@"sync requesting image from %@",url);
	NSData *dat = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&resp error:&error];
	DDLogVerbose(@"END requesting image from %@",url);
	
	UIImage * image = [[[UIImage alloc] initWithData:dat] autorelease];
	return image;
}


+ (BOOL) request:(NSURL *) url {
	DDLogInfo(@"sync requesting one way %@",url);
	NSURLResponse * resp;
	NSError *error;
	NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
	[urlRequest setValue:@"1" forHTTPHeaderField:@"Viewer-Only-Client"];
	[urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&resp error:&error];

	NSHTTPURLResponse * httpResponse;
    httpResponse = (NSHTTPURLResponse *) resp;
	
	if ((httpResponse.statusCode / 100) != 2) {
        DDLogError(@"HTTP error %zd", (ssize_t) httpResponse.statusCode);
		return NO;
    }
	if (error != nil) {
//		DDLogError(@"AsyncDAAPRequestReply - %@, %d, %@", [error localizedDescription], error.code, error.domain);
		return NO;
	}
	return YES;
}

+ (void) parseSearchResponse:(NSData *) theData handle:(int)handle resp:(NSMutableDictionary *)dict{
	//DAAPResponse *response = [dict lastObject];
	int progress = 0;
	while (handle > 0) {
		NSString *command = [self parseCommandName:theData atPosition:progress];
		
		int length = [self parseLength:theData atPosition:progress+4];
		DDLogVerbose(@"command (%d) : %@",length,command);
		
		handle -= 8 + length;
		NSPredicate *branches = [NSPredicate
								 predicateWithFormat:@"SELF MATCHES %@", @"cmst|mlog|agal|mlcl|mshl|abro|abar|apso|caci|avdb|cmgt|aply|adbs|msrv|casp|mdcl"];
		
		
		NSPredicate *strings = [NSPredicate
								predicateWithFormat:@"SELF MATCHES %@", @"minm|cann|cana|cang|canl|asaa|asal|asar|ceWM|asdt|msts|mcna|ascm|asfm"];
		
		if ([command isEqualToString:@"mlit"]) {
			NSData *block = [theData subdataWithRange:NSMakeRange(progress+8, length)];
			NSString *str = [self parseString:block];
			NSString *cmdKey = [NSString stringWithFormat:@"%@[%06d]",command,progress];
			if (str != nil)
				[dict setObject:str forKey:cmdKey];
			else {
#ifdef CONFIGURATION_DEBUG
				[HexDumpUtility printHexDumpToConsole:block];
#endif
			}

		}
		else if ([branches evaluateWithObject:(NSString *)command] == YES) {
			NSData *block = [theData subdataWithRange:NSMakeRange(progress+8, length)];
			NSMutableDictionary *subDict = [[NSMutableDictionary alloc] init];
			if ([dict objectForKey:command] != nil) {
				NSString *cmdKey = [NSString stringWithFormat:@"%@[%06d]",command,progress];
				[dict setObject:subDict forKey:cmdKey];
			}else
				[dict setObject:subDict forKey:command];
			[self parseSearchResponse:block handle:length resp:subDict];
			
		} else if([strings evaluateWithObject:(NSString *)command] == YES){
			NSData *block = [theData subdataWithRange:NSMakeRange(progress+8, length)];
			NSString *str = [self parseString:block];
			if (str != nil)
				[dict setObject:str forKey:command];
		} else if (length == 1 || length == 2 || length == 4 || length == 8) {
			int pos = progress + 8;
			NSData * val = [theData subdataWithRange:NSMakeRange(pos, length)];
			
			switch (length) {
				case 1:
					[dict setObject:[NSNumber numberWithBool:[self parseBoolean:val]] forKey:command];
					break;
				case 2:
					[dict setObject:[NSNumber numberWithShort:[self parseShort:val]] forKey:command];
					break;
				case 4:
					[dict setObject:[NSNumber numberWithLong:[self parseLong:val]] forKey:command];
					break;
				case 8:
					[dict setObject:[NSNumber numberWithLongLong:[self parseLongLong:val]] forKey:command];
					break;
					
				default:
					break;
			}
		} 
		progress += 8 + length;
	}
}

+ (DAAPResponse *) searchAndParseResponse:(NSURL *) url {
	NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease]; 
	NSURLResponse * resp;
	NSError *error;
	NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
	[urlRequest setValue:@"1" forHTTPHeaderField:@"Viewer-Only-Client"];
	[urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	NSData *dat = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&resp error:&error];
#ifdef CONFIGURATION_DEBUG
	[HexDumpUtility printHexDumpToConsole:dat];
#endif
	[self parseSearchResponse:dat handle:[dat length] resp:dict];
	NSDictionary * retValue = [NSDictionary dictionaryWithDictionary:dict];
	NSString *clazz;
	for (id key in retValue) {
		clazz = [NSString stringWithFormat:@"DAAPResponse%@",key];
	}
	DAAPResponse *response = (DAAPResponse *)[[[NSClassFromString(clazz) alloc] init] autorelease];
	//[response didFinishRawParsing:retValue];
	return response;
}

- (void)dealloc {
    [connection cancel];
    [connection release];
    [data release];
    [super dealloc];
}


@end
