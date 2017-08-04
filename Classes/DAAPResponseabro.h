//
//  DAAPResponseabro.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 23/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"
#import "DAAPResponseabar.h"
#import "DAAPResponsemshl.h"

@interface DAAPResponseabro : DAAPResponse {
	
	NSNumber *mstt;
	NSNumber *muty;
	NSNumber *mtco;
	NSNumber *mrco;
	DAAPResponseabar *abar;
	DAAPResponsemshl *mshl;
}

@property (nonatomic, retain) NSNumber *mstt;
@property (nonatomic, retain) NSNumber *muty;
@property (nonatomic, retain) NSNumber *mtco;
@property (nonatomic, retain) NSNumber *mrco;
@property (nonatomic, retain) DAAPResponseabar *abar;
@property (nonatomic, retain, getter=headerList) DAAPResponsemshl *mshl;

@end
