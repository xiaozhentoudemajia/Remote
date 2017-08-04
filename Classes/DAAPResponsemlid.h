//
//  DAAPResponsemlid.h
//  yTrack
//
//  Created by Fabrice Dewasmes on 19/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"


@interface DAAPResponsemlid : NSObject {
	NSNumber *miid;
	NSNumber *mper;
	NSString *minm;
	NSNumber *mimc;
	NSNumber *mctc;
	NSNumber *meds;
}

@property (nonatomic, retain) NSNumber *miid;
@property (nonatomic, retain) NSNumber *mper;
@property (nonatomic, copy) NSString *minm;
@property (nonatomic, retain) NSNumber *mimc;
@property (nonatomic, retain) NSNumber *mctc;
@property (nonatomic, retain) NSNumber *meds;

@end
