//
//  DAAPResponsecasp.h
//  yTrack
//
//  Created by Fabrice Dewasmes on 18/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"
#import "DAAPResponsemdcl.h"


@interface DAAPResponsecasp : DAAPResponse {
	NSNumber *mstt;
	NSMutableArray *speakers;
}

@property (nonatomic, retain) NSNumber *mstt;
@property (nonatomic, retain) NSMutableArray *speakers;

@end
