//
//  DAAPResponseServerInfo.h
//  yTrack
//
//  Created by Fabrice Dewasmes on 18/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"

@interface DAAPResponsemsrv : DAAPResponse {
	NSNumber *mstt;
	NSNumber *mpro;
	NSNumber *apro;
	NSNumber *aeSV;
	NSNumber *aeFP;
	NSNumber *ated;
	NSNumber *msed;
	NSNumber *msml;
	NSString *ceWM;
	NSNumber *ceVO;
	NSString  *minm;
	NSNumber *mslr;
	NSNumber *mstm;
	NSNumber *msal;
	NSNumber *msas;
	NSNumber *msup;
	NSNumber *mspi;
	NSNumber *msex;
	NSNumber *msbr;
	NSNumber *msqy;
	NSNumber *msix;
	NSNumber *msrs;
	NSNumber *msdc;
	NSNumber *mstc;
	NSNumber *msto;
}

@property (retain, nonatomic) NSNumber  *mstt;
@property (retain, nonatomic) NSNumber  *mpro;
@property (retain, nonatomic) NSNumber  *apro;
@property (retain, nonatomic, setter=setAesv:) NSNumber  *aeSV;
@property (retain, nonatomic, setter=setAefp:) NSNumber  *aeFP;
@property (retain, nonatomic) NSNumber  *ated;
@property (retain, nonatomic) NSNumber  *msed;
@property (retain, nonatomic) NSNumber  *msml;
@property (retain, nonatomic, setter=setCewm:) NSString  *ceWM;
@property (retain, nonatomic, setter=setCevo:) NSNumber  *ceVO;
@property (copy, nonatomic) NSString  *minm;
@property (retain, nonatomic) NSNumber  *mslr;
@property (retain, nonatomic) NSNumber  *mstm;
@property (retain, nonatomic) NSNumber  *msal;
@property (retain, nonatomic) NSNumber  *msas;
@property (retain, nonatomic) NSNumber  *msup;
@property (retain, nonatomic) NSNumber  *mspi;
@property (retain, nonatomic) NSNumber  *msex;
@property (retain, nonatomic) NSNumber  *msbr;
@property (retain, nonatomic) NSNumber  *msqy;
@property (retain, nonatomic) NSNumber  *msix;
@property (retain, nonatomic) NSNumber  *msrs;
@property (retain, nonatomic) NSNumber  *msdc;
@property (retain, nonatomic) NSNumber  *mstc;
@property (retain, nonatomic) NSNumber  *msto;

@end
