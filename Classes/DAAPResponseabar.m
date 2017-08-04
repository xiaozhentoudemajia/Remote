//
//  DAAPResponseabar.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 23/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponseabar.h"


@implementation DAAPResponseabar

@synthesize mstt;
@synthesize list;

- (void) setMlit:(NSString *)mlit{
	if (list == nil) {
		NSMutableArray *temp = [[NSMutableArray alloc] init];
		self.list = temp;
		[temp release];
	}
	[self.list addObject:mlit];
}


/*
 here we have to override the isBranch method just to tell 
 that mlit is not a branch but a leaf
 */
- (BOOL) isBranch:(NSString *)command{
	if ([command isEqualToString:@"cmst"]) {
		return YES;
	} else if ([command isEqualToString:@"mlog"]) {
		return YES;
	} else if ([command isEqualToString:@"agal"]) {
		return YES;
	} else if ([command isEqualToString:@"mlcl"]) {
		return YES;
	} else if ([command isEqualToString:@"mshl"]) {
		return YES;
	} else if ([command isEqualToString:@"abro"]) {
		return YES;
	} else if ([command isEqualToString:@"abar"]) {
		return YES;
	} else if ([command isEqualToString:@"apso"]) {
		return YES;
	} else if ([command isEqualToString:@"caci"]) {
		return YES;
	} else if ([command isEqualToString:@"avdb"]) {
		return YES;
	} else if ([command isEqualToString:@"cmgt"]) {
		return YES;
	} else if ([command isEqualToString:@"aply"]) {
		return YES;
	} else if ([command isEqualToString:@"adbs"]) {
		return YES;
	} else if ([command isEqualToString:@"msrv"]) {
		return YES;
	} else if ([command isEqualToString:@"casp"]) {
		return YES;
	} else if ([command isEqualToString:@"mdcl"]) {
		return YES;
	} else if ([command isEqualToString:@"mccr"]) {
		return YES;
	} else if ([command isEqualToString:@"glmc"]) {
		return YES;
	} 
	return NO;
	//return [branches evaluateWithObject:command];
}

- (BOOL) isString:(NSString *)command{
	if ([command isEqualToString:@"mlit"]) {
		return YES;
	} 
	return NO;
}


- (void) parse{
	[self parse:self.data];
}

- (void)dealloc {
	[self.mstt release];
	[self.list release];
    [super dealloc];
}

@end
