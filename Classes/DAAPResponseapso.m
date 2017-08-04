//
//  DAAPResponseapso.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 25/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponseapso.h"
#import "DAAPResponsemlit.h"


@implementation DAAPResponseapso

@synthesize mstt;
@synthesize res;
@synthesize mlcl;
@synthesize mshl;


- (void)dealloc {
	[self.mstt release];
    [self.res release];
	[self.mlcl release];
	[self.mshl release];
    [super dealloc];
}



@end
