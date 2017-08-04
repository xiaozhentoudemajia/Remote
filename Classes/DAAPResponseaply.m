//
//  DAAPResponseaply.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 23/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponseaply.h"
#import "DAAPResponsemlit.h"


@implementation DAAPResponseaply

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
