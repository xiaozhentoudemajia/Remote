//
//  DAAPResponsemlit.m
//  yTrack
//
//  Created by Fabrice Dewasmes on 19/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponsemlit.h"


@implementation DAAPResponsemlit

@synthesize miid;
@synthesize mper;
@synthesize minm;
@synthesize mimc;
@synthesize mctc;
@synthesize meds;
@synthesize abpl;
@synthesize mpco;
@synthesize aeSP;
@synthesize aePS;
@synthesize asai;
@synthesize aeSI;
@synthesize astn;
@synthesize astm;
@synthesize assp;
@synthesize asal;
@synthesize asar;
@synthesize asaa;
@synthesize mshc;
@synthesize mshi;
@synthesize mshn;
@synthesize mcti;

- (void) parse{
	[self parse:self.data];
}

- (void)dealloc {
	[self.miid release];
	[self.mper release];
	[self.mimc release];
	[self.mctc release];
	[self.meds release];
	[self.abpl release];
	[self.mpco release];
	[self.aeSP release];
	[self.aePS release];
	[self.asai release];
	[self.aeSI release];
	[self.astn release];
	[self.astm release];
	[self.assp release];
    [self.minm release];
	[self.asal release];
	[self.asar release];
	[self.asaa release];
	[self.mshc release];
	[self.mshi release];
	[self.mshn release];
	[self.mcti release];
    [super dealloc];
}

@end
