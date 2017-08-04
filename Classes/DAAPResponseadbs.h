//
//  DAAPResponseadbs.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 23/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"


@interface DAAPResponseadbs  : DAAPResponse {
	NSNumber *mstt;
	NSNumber *muty;
	NSNumber *mtco;
	NSNumber *mrco;
	NSArray *res;

}

@property (nonatomic, retain) NSNumber *mstt;
@property (nonatomic, retain) NSNumber *muty;
@property (nonatomic, retain) NSNumber *mtco;
@property (nonatomic, retain) NSNumber *mrco;
@property (nonatomic, retain) NSArray *res;

@end
