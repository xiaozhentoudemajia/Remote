//
//  DAAPResponseagal.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 11/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"
#import "DAAPResponsemlcl.h"
#import "DAAPResponsemshl.h"

@interface DAAPResponseagal : DAAPResponse {

@private
	NSNumber *mstt;
	NSNumber *muty;
	NSNumber *mtco;
	NSNumber *mrco;
	DAAPResponsemlcl *mlcl;
	DAAPResponsemshl *mshl;
}

@property (nonatomic, retain) NSNumber *mstt;
@property (nonatomic, retain) NSNumber *muty;
@property (nonatomic, retain) NSNumber *mtco;
@property (nonatomic, retain) NSNumber *mrco;
@property (nonatomic, retain, getter=listing) DAAPResponsemlcl *mlcl;
@property (nonatomic, retain, getter=headerList) DAAPResponsemshl *mshl;

@end
