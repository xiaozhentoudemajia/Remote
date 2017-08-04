//
//  DAAPResponsemdcl.m
//  yTrack
//
//  Created by Fabrice Dewasmes on 18/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponsemdcl.h"


@implementation DAAPResponsemdcl

@synthesize caia;
@synthesize minm;
@synthesize msma;

- (void) parse{
	[self parse:self.data];
}

- (void)dealloc {
	[self.caia release];
	[self.minm release];
	[self.msma release];
	[super dealloc];
}

@end
