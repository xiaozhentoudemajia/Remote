//
//  DAAPResponsemdcl.h
//  yTrack
//
//  Created by Fabrice Dewasmes on 18/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"

@interface DAAPResponsemdcl : DAAPResponse {
	NSNumber *caia;
	NSString *minm;
	NSNumber *msma;
}

@property (nonatomic, retain) NSNumber *caia;
@property (nonatomic, copy, getter=name) NSString *minm;
@property (nonatomic, retain) NSNumber *msma;

@end
