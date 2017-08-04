//
//  DAAPResponsecmst.m
//  yTrack
//
//  Created by Fabrice Dewasmes on 19/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponsecmst.h"


@implementation DAAPResponsecmst
@synthesize mstt;
@synthesize cmsr;
@synthesize caps;
@synthesize cash;
@synthesize carp;
@synthesize cavc;
@synthesize caas;
@synthesize caar;
@synthesize canp;
@synthesize cann;
@synthesize cana;
@synthesize canl;
@synthesize cang;
@synthesize asai;
@synthesize cmmk;
@synthesize ceGS;
@synthesize cant;
@synthesize cast;

- (void)dealloc {
	[self.mstt release];
	[self.cmsr release];
	[self.caps release];
	[self.cash release];
	[self.carp release];
	[self.cavc release];
	[self.caas release];
	[self.caar release];
	[self.canp release];
	[self.cann release];
	[self.cana release];
	[self.canl release];
    [self.cang release];
	[self.asai release];
	[self.cmmk release];
	[self.ceGS release];
	[self.cant release];
	[self.cast release];
    [super dealloc];
}

@end
