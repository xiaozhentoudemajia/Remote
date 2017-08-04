//
//  DAAPResponsecmgt.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 03/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponsecmgt.h"


@implementation DAAPResponsecmgt

@synthesize mstt;
@synthesize cmvo;

- (void)dealloc {
	[self.mstt release];
    [self.cmvo release];
    [super dealloc];
}

@end
