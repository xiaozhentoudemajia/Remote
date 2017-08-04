//
//  PreferencesManager.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 23/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "PreferencesManager.h"
#import "SynthesizeSingleton.h"
#import "DDLog.h"

#ifdef CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@implementation PreferencesManager

@synthesize preferences;
@synthesize prefPath;


SYNTHESIZE_SINGLETON_FOR_CLASS(PreferencesManager)

- (BOOL)writeApplicationData:(NSData *)data toFile:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if (!documentsDirectory) {
        DDLogError(@"Documents directory not found!");
        return NO;
    }
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    return ([data writeToFile:appFile atomically:YES]);
}

- (BOOL)writeApplicationPlist:(id)plist toFile:(NSString *)fileName {
    NSString *error;
    NSData *pData = [NSPropertyListSerialization dataFromPropertyList:plist format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
    if (!pData) {
        DDLogError(@"%@", error);
        return NO;
    }
    return ([self writeApplicationData:pData toFile:(NSString *)fileName]);
}

- (void) checkAndMigrate{
	if ([self.preferences objectForKey:kPrefVersion] == nil) {
		
		NSMutableArray *servers = [self.preferences objectForKey:kPrefLibrarykey];
		if (servers != nil){
			for (int i = 0; i<[servers count];i++) {
				[[servers objectAtIndex:i] removeObjectForKey:kLibraryHostKey];
				[[servers objectAtIndex:i] removeObjectForKey:kLibraryPortKey];
				[[servers objectAtIndex:i] setObject:@"local" forKey:kLibraryDomainKey];
				[[servers objectAtIndex:i] setObject:@"_touch-able._tcp" forKey:kLibraryTypeKey];
			}
		}
		[self saveViewState:kPrefLastSelectedSegControlArtist withKey:kPrefLastSelectedSegControl];
		[self setVolumeControl:YES];
		[self.preferences setObject:@"1.1" forKey:kPrefVersion];
	}
	
}

- (void) loadPreferencesFromFile{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSString * prefDocPath = [documentsPath stringByAppendingString:@"/prefs.plist"];
	if (self.preferences != nil) {
		[self.preferences release];
	}
	NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithContentsOfFile:prefDocPath];
	self.preferences = temp; 
	if (self.preferences == nil) {
		NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
		self.preferences = temp;
		[temp release];
	}
	
	self.prefPath = prefDocPath;
	
	[self checkAndMigrate];
}

- (void) persistPreferences{
	[self writeApplicationPlist:self.preferences toFile:@"prefs.plist"];
}

- (NSArray *) getAllStoredServers {
	if ([self.preferences objectForKey:kPrefLibrarykey] == nil){
		NSMutableArray *servers = [[NSMutableArray alloc] init];
		[self.preferences setObject:servers forKey:kPrefLibrarykey];
		[servers release];
	}
	NSMutableArray *servers = [[NSMutableArray alloc] init];
	for (NSDictionary *server in [self.preferences objectForKey:kPrefLibrarykey]) {
		FDServer *newServer = [[FDServer alloc] initWithDictionary:server];
		[servers addObject:newServer];
		[newServer release];
	}
	NSArray *immutableArray= [NSArray arrayWithArray:servers];
	[servers release];
	return immutableArray;
	
}
- (FDServer *) lastUsedServer{
	NSDictionary *dict = [self.preferences objectForKey:kPrefLastUsedLibrary];
	FDServer *server = [[[FDServer alloc] initWithDictionary:dict] autorelease];
	return server;
}

- (void) setLastUsedServer:(FDServer *)server{
	[self.preferences setObject:[server getAsDictionary] forKey:kPrefLastUsedLibrary];
	[self persistPreferences];
}

- (void) addServer:(FDServer *) newServer{
	NSMutableArray *servers = [self.preferences objectForKey:kPrefLibrarykey];
	if (servers == nil){
		NSMutableArray *newServers = [[NSMutableArray alloc] init];
		[self.preferences setObject:newServers forKey:kPrefLibrarykey];
		[newServers release];
	}
	servers = [self.preferences objectForKey:kPrefLibrarykey];
	
	int foundIndex = -1;
	for (int i = 0; i<[servers count];i++) {
		NSString *serverServiceName = [[servers objectAtIndex:i] objectForKey:kLibraryServicenameKey];
		NSString *newserverServiceName = newServer.servicename;
		if ([newserverServiceName isEqualToString:serverServiceName]) {
			foundIndex = i;
			break;
		}
	}
	if (foundIndex >=0) {
		[servers removeObjectAtIndex:foundIndex];
	} 
	
	[servers addObject:[newServer getAsDictionary]];
	[self.preferences setObject:[newServer getAsDictionary] forKey:kPrefLastUsedLibrary];
	[self persistPreferences];
}

- (void) deleteServerAtIndex:(int)index{
	NSMutableArray *servers = [self.preferences objectForKey:kPrefLibrarykey];
	NSString *serverServiceName = [[servers objectAtIndex:index] objectForKey:kLibraryServicenameKey];
	[servers removeObjectAtIndex:index];
	
	// clear last used library from prefs file if deleted library is the last used one
	NSDictionary * currentServer = [self.preferences objectForKey:kPrefLastUsedLibrary];
	if ([[currentServer objectForKey:kLibraryServicenameKey] isEqualToString:serverServiceName]) {
		[self.preferences removeObjectForKey:kPrefLastUsedLibrary];
	}
	[self persistPreferences];
}

- (void) saveViewState:(NSString *)state withKey:(NSString *)key{
	[self.preferences setObject:state forKey:key];
}

- (void) setVolumeControl:(BOOL)volumeControlEnabled{
	[self.preferences setObject:[NSNumber numberWithBool:volumeControlEnabled] forKey:kPrefVolumeControlEnabled];
}

- (BOOL) volumeControl{
	NSNumber *volumeControlEnabled = (NSNumber *)[self.preferences objectForKey:kPrefVolumeControlEnabled];
	if (volumeControlEnabled == nil) {
		[self setVolumeControl:YES];
		return YES;
	}
	return [volumeControlEnabled boolValue];
}

- (NSString *) getViewStateForKey:(NSString *)key{
	return [self.preferences objectForKey:key];
}

- (void)dealloc {
    [self.preferences release];
    [super dealloc];
}


@end
