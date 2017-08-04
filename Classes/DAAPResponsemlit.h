//
//  DAAPResponsemlit.h
//  yTrack
//
//  Created by Fabrice Dewasmes on 19/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"

@interface DAAPResponsemlit : DAAPResponse {
@private
	NSNumber *miid;
	NSNumber *mper;
	NSString *minm;
	NSNumber *mimc;
	NSNumber *mctc;
	NSNumber *meds;
	NSNumber *abpl;
	NSNumber *mpco;
	NSNumber *aeSP;
	NSNumber *aePS;
	NSNumber *asai;
	NSNumber *aeSI;
	NSNumber *astn;
	NSNumber *astm;
	NSNumber *assp;
	NSString *asal;
	NSString *asar;
	NSString *asaa;
	NSString *mshc;
	NSNumber *mshi;
	NSNumber *mshn;
	NSNumber *mcti;
	int index;
}

@property (nonatomic, retain) NSNumber *miid;
@property (nonatomic, retain, getter=persistentId) NSNumber *mper;
@property (nonatomic, copy, getter=name) NSString *minm;
@property (nonatomic, retain) NSNumber *mimc;
@property (nonatomic, retain) NSNumber *mctc;
@property (nonatomic, retain) NSNumber *meds;
@property (nonatomic, retain) NSNumber *abpl;
@property (nonatomic, retain) NSNumber *mpco;
@property (nonatomic, retain, setter=setAesp:) NSNumber *aeSP;
@property (nonatomic, retain, setter=setAeps:) NSNumber *aePS;
@property (nonatomic, retain) NSNumber *asai;
@property (nonatomic, retain, setter=setAesi:) NSNumber *aeSI;
@property (nonatomic, retain, getter=songTrackNumber) NSNumber *astn;
@property (nonatomic, retain) NSNumber *astm;
@property (nonatomic, retain) NSNumber *assp;
@property (nonatomic, copy, getter=albumName) NSString *asal;
@property (nonatomic, copy, getter=artistName) NSString *asar;
@property (nonatomic, copy, getter=songAlbumArtist) NSString *asaa;
@property (nonatomic, copy) NSString *mshc;
@property (nonatomic, retain) NSNumber *mshi;
@property (nonatomic, retain) NSNumber *mshn;
@property (nonatomic, retain) NSNumber *mcti;

@end
