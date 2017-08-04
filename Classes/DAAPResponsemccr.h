//
//  DAAPResponsemccr.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 25/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"

@interface DAAPResponsemccr : DAAPResponse {
	NSNumber *mstt;
	NSArray *tags;
}

@property (nonatomic, retain) NSNumber *mstt;
@property (nonatomic, retain) NSArray *tags;

@end
