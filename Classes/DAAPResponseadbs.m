//
//  DAAPResponseadbs.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 23/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponseadbs.h"
#import "DAAPResponsemlit.h"


@implementation DAAPResponseadbs
@synthesize mstt;
@synthesize muty;
@synthesize mtco;
@synthesize mrco;
@synthesize res;



- (void)dealloc {
	[self.mstt release];
    [self.muty release];
	[self.mtco release];
	[self.mrco release];
	[self.res release];
    [super dealloc];
}

@end
