//
//  DAAPResponseabro.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 23/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponseabro.h"


@implementation DAAPResponseabro
@synthesize mstt;
@synthesize muty;
@synthesize mtco;
@synthesize mrco;
@synthesize abar;
@synthesize mshl;

- (void)dealloc {
	[self.mstt release];
	[self.muty release];
	[self.mtco release];
	[self.mrco release];
    [self.abar release];
    [self.mshl release];
    [super dealloc];
}
@end
