//
//  RemoteSpeaker.m
//  yTrack
//
//  Created by Fabrice Dewasmes on 18/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "RemoteSpeaker.h"


@implementation RemoteSpeaker
@synthesize speakerName;
@synthesize on;
@synthesize spId;

- (void) dealloc {
	[self.speakerName release];
	[self.spId release];
	[super dealloc];
}

@end
