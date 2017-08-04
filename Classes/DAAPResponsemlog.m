//
//  DAAPResponsemlog.m
//  yTrack
//
//  Created by Fabrice Dewasmes on 18/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponsemlog.h"


@implementation DAAPResponsemlog

@synthesize mstt;
@synthesize mlid;

- (void)dealloc {
    [self.mstt release];
    [self.mlid release];
    [super dealloc];
}

@end
