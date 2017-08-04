//
//  DAAPResponsecasp.m
//  yTrack
//
//  Created by Fabrice Dewasmes on 18/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponsecasp.h"
#import "RemoteSpeaker.h"


@implementation DAAPResponsecasp

@synthesize mstt;
@synthesize speakers;

- (void) setMdcl:(DAAPResponsemdcl *)mdcl{
	if (speakers == nil) {
		NSMutableArray *temp = [[NSMutableArray alloc] init];
		self.speakers = temp;
		[temp release];
	}
	RemoteSpeaker *sp = [[RemoteSpeaker alloc] init];
	sp.speakerName = mdcl.name;
	if ([mdcl.caia shortValue] == 1) {
		sp.on = YES;
	} else {
		sp.on = NO;
	}
	sp.spId = mdcl.msma;
	[self.speakers addObject:sp];
	[sp release];
}

- (void)dealloc {
    [self.mstt release];
	[self.speakers release];
    [super dealloc];
}

@end
