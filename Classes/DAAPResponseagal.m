//
//  DAAPResponseagal.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 11/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponseagal.h"


@implementation DAAPResponseagal
@synthesize mstt;
@synthesize muty;
@synthesize mtco;
@synthesize mrco;
@synthesize mlcl;
@synthesize mshl;

- (void)dealloc {
	[self.mstt release];
	[self.muty release];
	[self.mtco release];
	[self.mrco release];
    [self.mlcl release];
	[self.mshl release];
    [super dealloc];
}

@end
