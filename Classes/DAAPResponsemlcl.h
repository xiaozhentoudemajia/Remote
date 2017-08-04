//
//  DAAPResponsemlcl.h
//  yTrack
//
//  Created by Fabrice Dewasmes on 19/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"


@interface DAAPResponsemlcl : DAAPResponse {
	NSMutableArray *list;
}

@property (nonatomic, retain) NSMutableArray *list;

@end
