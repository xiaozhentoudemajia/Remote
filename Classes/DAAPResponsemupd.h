//
//  DAAPResponsemupd.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 03/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"

@interface DAAPResponsemupd : DAAPResponse {
	NSNumber *mstt;
	NSNumber *musr;
}

@property (nonatomic, retain) NSNumber *musr;
@property (nonatomic, retain) NSNumber *mstt;

@end
