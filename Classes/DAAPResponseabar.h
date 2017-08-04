//
//  DAAPResponseabar.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 23/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"
#import "DAAPResponsemlit.h"

@interface DAAPResponseabar : DAAPResponse {
	NSNumber *mstt;
	NSMutableArray *list;
}

@property (nonatomic, retain) NSMutableArray *list;
@property (nonatomic, retain) NSNumber *mstt;

@end
