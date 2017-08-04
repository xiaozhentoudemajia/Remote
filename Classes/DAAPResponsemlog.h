//
//  DAAPResponsemlog.h
//  yTrack
//
//  Created by Fabrice Dewasmes on 18/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"


@interface DAAPResponsemlog : DAAPResponse {
	NSNumber *mstt;
	NSNumber *mlid;

}

@property (nonatomic,retain) NSNumber *mstt;
@property (nonatomic,retain) NSNumber *mlid;

@end
