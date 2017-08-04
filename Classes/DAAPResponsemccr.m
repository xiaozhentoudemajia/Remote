//
//  DAAPResponsemccr.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 25/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponsemccr.h"


@implementation DAAPResponsemccr

@synthesize mstt;
@synthesize tags;

- (void)dealloc {
	[self.mstt release];
    [self.tags release];
    [super dealloc];
}

@end
