//
//  DAAPResponseerror.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 20/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "DAAPResponseerror.h"


@implementation DAAPResponseerror

@synthesize error;

- (id) initWithData:(NSData *)theData error:(NSError *)err{
	if ((self = [super initWithData:theData])) {
        error = err;
		[error retain];
    }
    return self;
}

- (void)dealloc {
	[error release];
    [super dealloc];
}


@end
