//
//  PreferencesManager.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 23/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDServer.h"

#define kPrefLibrarykey @"libraries"
#define kPrefLastUsedLibrary @"lastUsedLib"
#define kPrefLastSelectedSegControl @"segControl"

#define kPrefLastSelectedSegControlTrack @"track"
#define kPrefLastSelectedSegControlArtist @"artist"
#define kPrefLastSelectedSegControlAlbum @"album"
#define kPrefVolumeControlEnabled @"volumeControl"

#define kPrefVersion @"version"

@interface PreferencesManager : NSObject {
	NSMutableDictionary *preferences;
	NSString *prefPath;
	
}

@property (nonatomic, retain) NSMutableDictionary *preferences;
@property (nonatomic, copy) NSString *prefPath;


+ (id) sharedPreferencesManager;

- (void) loadPreferencesFromFile;
- (NSArray *) getAllStoredServers;
- (FDServer *) lastUsedServer;
- (void) persistPreferences;
- (void) addServer:(FDServer *) newServer;
- (void) deleteServerAtIndex:(int)index;
- (void) setVolumeControl:(BOOL)volumeControlEnabled;
- (BOOL) volumeControl;
- (void) saveViewState:(NSString *)state withKey:(NSString *)key;
- (NSString *) getViewStateForKey:(NSString *)key;
- (void) checkAndMigrate;


@end
