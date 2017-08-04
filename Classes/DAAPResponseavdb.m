//
//  DAAPResponseavdb.m
//  yTrack
//
//  Created by Fabrice Dewasmes on 19/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponseavdb.h"
#import "DAAPResponsemlit.h"


@implementation DAAPResponseavdb

@synthesize mstt;
@synthesize muty;
@synthesize mtco;
@synthesize mrco;
@synthesize mlcl;

- (void)dealloc {
    [self.mstt release];
	[self.muty release];
	[self.mtco release];
	[self.mrco release];
	[self.mlcl release];
    [super dealloc];
}


@end
