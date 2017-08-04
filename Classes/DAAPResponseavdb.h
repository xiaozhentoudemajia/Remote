//
//  DAAPResponseavdb.h
//  yTrack
//
//  Created by Fabrice Dewasmes on 19/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"
#import "DAAPResponsemlcl.h"


@interface DAAPResponseavdb : DAAPResponse {
	NSNumber *mstt;
	NSNumber *muty;
	NSNumber *mtco;
	NSNumber *mrco;
	DAAPResponsemlcl *mlcl;
}

@property (nonatomic, retain) NSNumber *mstt;
@property (nonatomic, retain) NSNumber *muty;
@property (nonatomic, retain) NSNumber *mtco;
@property (nonatomic, retain) NSNumber *mrco;
@property (nonatomic, retain, getter=listing) DAAPResponsemlcl *mlcl;

@end
