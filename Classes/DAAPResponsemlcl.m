//
//  DAAPResponsemlcl.m
//  yTrack
//
//  Created by Fabrice Dewasmes on 19/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponsemlcl.h"
#import "HexDumpUtility.h"
#import "DAAPResponsemlit.h"


@implementation DAAPResponsemlcl

@synthesize list;

- (void) setMlit:(DAAPResponsemlit *)mlit{
	if (list == nil) {
		NSMutableArray *temp = [[NSMutableArray alloc] init];
		self.list = temp;
		[temp release];
	}
	[self.list addObject:mlit];
}

- (void) parse{
	[self parse:self.data];
}

- (void)dealloc {
    [self.list release];
    [super dealloc];
}

@end
