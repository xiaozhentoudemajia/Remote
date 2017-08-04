//
//  DAAPResponsemupd.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 03/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponsemupd.h"


@implementation DAAPResponsemupd
@synthesize musr;
@synthesize mstt;

- (void)dealloc {
	[self.musr release];
	[self.mstt release];
    [super dealloc];
}


@end


