//
//  DAAPRequestReply.h
//  yTrack
//
//  Created by Fabrice Dewasmes on 15/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAAPResponse.h"
#import "DAAPRequest.h"

#define kRequestContentCodes @"http://%@:%@/content-codes"
#define kRequestLogin @"http://%@:%@/login?pairing-guid=0x%@"
#define kRequestLogout @"http://%@:%@/logout?session-id=%d"
#define kRequestServerInfo @"http://%@:%@/server-info"
#define kRequestDatabases @"http://%@:%@/databases?session-id=%d"
#define kRequestControl @"http://%@:%@/crtl-int"
#define kRequestPlayStatusUpdate @"^http://%@:%@/ctrl-int/[[:digit:]]+/playstatusUpdate$revision-number=%d&session-id=%d"
#define kRequestPropertyVolume @"http://%@:%@/ctrl-int/1/getproperty?properties=dmcp.volume&session-id=%d"
#define kRequestChangePropertyVolume @"http://%@:%@/ctrl-int/1/setproperty?dmcp.volume=%d&session-id=%d"
#define kRequestShoutcast @"http://%@:%@/ctrl-int/1/setproperty?shoutcast-url=%@&com.apple.itunes.extended-media-kind=1&session-id=%d"
#define kRequestWifiConfig @"http://%@:%@/wificfg?ssid=%@&password=%@"
#define kRequestChangePropertyShuffle @"http://%@:%@/ctrl-int/1/setproperty?dacp.shufflestate=%d&session-id=%d"
#define kRequestChangePropertyRepeat @"http://%@:%@/ctrl-int/1/setproperty?dacp.repeatstate=%d&session-id=%d"
#define kRequestPlayLists @"http://%@:%@/databases/%d/containers?session-id=%d&meta=dmap.itemname,dmap.itemcount,dmap.itemid,dmap.persistentid,daap.baseplaylist,com.apple.itunes.special-playlist,com.apple.itunes.smart-playlist,com.apple.itunes.saved-genius,dmap.parentcontainerid,dmap.editcommandssupported,com.apple.itunes.jukeboxcurrent,daap.songcontentdescription"
#define kRequestGetSpeakers @"http://%@:%@/ctrl-int/1/getspeakers?session-id=%d"
#define kRequestTracksForAlbum @"http://%@:%@/databases/%d/containers/%d/items?session-id=%d&meta=dmap.itemname,dmap.itemid,daap.songartist,daap.songalbumid,daap.songalbum,daap.songartist,dmap.containeritemid,daap.songuserrating,daap.songtime,daap.songstoptime,daap.songtracknumber&type=music&sort=album&query='daap.songalbumid:%qi'"
#define kRequestUpdate @"http://%@:%@/update?session-id=%d&revision-number=%d"
#define kRequestSetSpeakers @"http://%@:%@/ctrl-int/1/setspeakers?speaker-id=%@&session-id=%d"
#define kRequestAllTracks @"http://%@:%@/databases/%d/containers/%d/items?session-id=%d&meta=dmap.itemname,dmap.itemid,daap.songartist,daap.songalbum,dmap.containeritemid,daap.songtime&type=music&sort=name&include-sort-headers=1&query=('com.apple.itunes.mediakind:1','com.apple.itunes.mediakind:32')"
#define kRequestAllBooks @"http://%@:%@/databases/%d/groups?session-id=%d&meta=dmap.itemname,dmap.itemid,dmap.persistentid,daap.songartist,daap.songalbum,daap.songtime&type=music&group-type=albums&sort=album&include-sort-headers=1&query='com.apple.itunes.mediakind:8'"
#define kRequestAllPodcasts @"http://%@:%@/databases/%d/groups?session-id=%d&meta=dmap.itemname,dmap.itemid,dmap.persistentid,daap.songartist,daap.songalbum&type=music&group-type=albums&sort=album&include-sort-headers=1&query=(('com.apple.itunes.mediakind:4','com.apple.itunes.mediakind:36','com.apple.itunes.mediakind:6')+'daap.songalbum!:')"
#define kRequestPlayPodcast2 @"http://%@:%@/ctrl-int/1/cue?command=play&query=(('com.apple.itunes.mediakind:4','com.apple.itunes.mediakind:36','com.apple.itunes.mediakind:6')+'daap.songalbumid:%qi')&index=%d&sort=releasedate&invert-sort-order=1&session-id=%d"
#define kRequestPlayBook2 @"http://%@:%@/ctrl-int/1/cue?command=play&query=('com.apple.itunes.mediakind:8'+'daap.songalbumid:%qi')&index=%d&sort=releasedate&invert-sort-order=1&session-id=%d"
#define kRequestPodcastTracks @"http://%@:%@/databases/%d/containers/%d/items?session-id=%d&meta=dmap.itemname,dmap.itemid,daap.songartist,daap.songalbumid,dmap.containeritemid,com.apple.itunes.has-video,daap.songtime,daap.songhasbeenplayed,daap.songdatereleased,daap.sortartist,daap.songcontentdescription,daap.songalbum&type=music&sort=releasedate&invert-sort-order=1&query=(('com.apple.itunes.mediakind:4','com.apple.itunes.mediakind:36','com.apple.itunes.mediakind:6')+'daap.songalbumid:%@')"
#define kRequestBookTracks @"http://%@:%@/databases/%d/containers/%d/items?session-id=%d&meta=dmap.itemname,dmap.itemid,daap.songartist,daap.songalbumid,dmap.containeritemid,com.apple.itunes.has-video,daap.songtime,daap.songhasbeenplayed,daap.songdatereleased,daap.sortartist,daap.songcontentdescription,daap.songalbum&type=music&sort=releasedate&invert-sort-order=1&query=('com.apple.itunes.mediakind:8'+'daap.songalbumid:%@')"
#define kRequestPlaySongInLibrary @"http://%@:%@/ctrl-int/1/cue?command=play&query=('com.apple.itunes.mediakind:1','com.apple.itunes.mediakind:32')&index=%d&sort=name&session-id=%d"
#define kRequestPlaySongInPlaylist @"http://%@:%@/ctrl-int/1/playspec?database-spec='dmap.persistentid:0x%qX'&container-spec='dmap.persistentid:0x%qX'&container-item-spec='dmap.containeritemid:0x%X'&session-id=%d"
#define kRequestPlayPodcast @"http://%@:%@/ctrl-int/1/playspec?database-spec='dmap.persistentid:0x%qX'&container-spec='dmap.persistentid:0x%qX'&item-spec='dmap.itemid:0x%X'&session-id=%d"
#define kRequestPlayBookInLibrary @"http://%@:%@/ctrl-int/1/cue?command=play&index=%d&sort=name&session-id=%d"
#define kRequestStopPlaying @"http://%@:%@/ctrl-int/1/cue?command=clear&session-id=%d"
#define kRequestNowPlayingArtwork @"http://%@:%@/ctrl-int/1/nowplayingartwork?mw=130&mh=130&session-id=%d"
#define kRequestNowPlayingArtworkBig @"http://%@:%@/ctrl-int/1/nowplayingartwork?mw=768&mh=768&session-id=%d"
#define kRequestPlayPause @"http://%@:%@/ctrl-int/1/playpause?session-id=%d"
#define kRequestPlayNextItem @"http://%@:%@/ctrl-int/1/nextitem?session-id=%d"
#define kRequestPlayPreviousItem @"http://%@:%@/ctrl-int/1/previtem?session-id=%d"
#define kRequestArtists @"http://%@:%@/databases/%d/browse/artists?session-id=%d&include-sort-headers=1&filter=('com.apple.itunes.mediakind:1','com.apple.itunes.mediakind:32')+'daap.songartist!:'"
#define kRequestAlbumsForArtist @"http://%@:%@/databases/%d/groups?session-id=%d&meta=dmap.itemname,dmap.itemid,dmap.persistentid,daap.songartist&type=music&group-type=albums&sort=album&include-sort-headers=1&query=(('com.apple.itunes.mediakind:1','com.apple.itunes.mediakind:32')+'daap.songartist:%@'+'daap.songalbum!:')"
#define kRequestAllAlbums @"http://%@:%@/databases/%d/groups?session-id=%d&meta=dmap.itemname,dmap.itemid,dmap.persistentid,daap.songartist&type=music&group-type=albums&sort=album&include-sort-headers=1&query=(('com.apple.itunes.mediakind:1','com.apple.itunes.mediakind:32')+'daap.songalbum!:')"
#define kRequestAllTracksForArtist @"http://%@:%@/databases/%d/containers/%d/items?session-id=%d&meta=dmap.itemname,dmap.itemid,daap.songartist,daap.songalbum,dmap.containeritemid,daap.songtime&type=music&sort=album&query=(('com.apple.itunes.mediakind:1','com.apple.itunes.mediakind:32')+'daap.songartist:%@')"
#define kRequestAlbumArtwork @"http://%@:%@/databases/%d/groups/%d/extra_data/artwork?session-id=%d&mw=%d&mh=%d&group-type=albums"
#define kRequestTrackArtwork @"http://%@:%@/databases/%d/items/%d/extra_data/artwork?session-id=%d&mw=%d&mh=%d"
#define kRequestPlayTracksInAlbum @"http://%@:%@/ctrl-int/1/cue?command=play&query=(('com.apple.itunes.mediakind:1','com.apple.itunes.mediakind:32')+'daap.songalbumid:%qi')&index=%d&sort=album&session-id=%d"
#define kRequestPlayAllTracksForArtist @"http://%@:%@/ctrl-int/1/cue?command=play&query=(('com.apple.itunes.mediakind:1','com.apple.itunes.mediakind:32')+'daap.songartist:%@')&index=%d&sort=album&session-id=%d"
#define kRequestSetPlayingTime @"http://%@:%@/ctrl-int/1/setproperty?dacp.playingtime=%d&session-id=%d"
#define kRequestTracksForPlaylist @"http://%@:%@/databases/%d/containers/%d/items?session-id=%d&meta=dmap.itemname,dmap.itemid,daap.songartist,daap.songalbum,dmap.containeritemid,daap.songtime&query=('com.apple.itunes.mediakind:1','com.apple.itunes.mediakind:32')"
#define kRequestGenres @"http://%@:%@/databases/%d/browse/genres?session-id=%d&include-sort-headers=1&filter=('com.apple.itunes.mediakind:1','com.apple.itunes.mediakind:32')+'daap.songgenre!:'"


@protocol DAAPRequestDelegate <NSObject>

-(void)didFinishLoading:(DAAPResponse *)response;
@optional
- (void) connectionTimedOut;
- (void) cantConnect;
@end


@interface DAAPRequestReply : DAAPRequest {

	id <DAAPRequestDelegate> delegate;
	SEL action;
	NSURL *lastUrl;
}

@property (nonatomic, assign) id <DAAPRequestDelegate> delegate;
@property (nonatomic, assign) SEL action;

// kept just in case but not used for now
+ (DAAPResponse *) searchAndParseResponse:(NSURL *) url;
+ (void) parseSearchResponse:(NSData *) data handle:(int)handle resp:(NSMutableDictionary *)dict;

// those should removed
+ (BOOL) request:(NSURL *) url ;
+ (DAAPResponse *) onTheFlyRequestAndParseResponse:(NSURL *) url;
+ (DAAPResponse *) onTheFlyRequestAndParseResponse:(NSURL *) url error:(NSError **)error;
+ (UIImage *) imageFromUrl:(NSURL *) url ;

- (void) asyncRequestAndParse:(NSURL *)url;
- (void) asyncRequestAndParse:(NSURL *)url withTimeout:(int)timeoutInterval;





@end
