//
//  DAAPResponsemshl.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 09/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponsemshl.h"
#import "DAAPResponsemlit.h"

@implementation DAAPResponsemshl

@synthesize indexList;

- (void) setMlit:(DAAPResponsemlit *)mlit{
	if (indexList == nil) {
		NSMutableArray *temp = [[NSMutableArray alloc] init];
		self.indexList = temp;
		[temp release];
	}
	[self.indexList addObject:mlit];
}

- (void) parse{
	[self parse:self.data];
}

- (void)dealloc {
	[self.indexList release];
    [super dealloc];
}


@end
