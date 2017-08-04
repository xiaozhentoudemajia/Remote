//
//  PodcastsDatasource.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 01/08/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "PodcastsBooksDatasource.h"
#import "SessionManager.h"
#import "DAAPResponsemlit.h"
#import "PodcastTracksDatasource.h"
#import "BooksAndPodcastsCustomCellView.h"

@implementation PodcastsBooksDatasource

@synthesize navigationController;
@synthesize containerPersistentId;
@synthesize itemType;

- (id) init{
	if ((self = [super init])) {
		artworks = [[NSMutableDictionary alloc] init];
		cellId = [[NSMutableDictionary alloc] init];
		loaders = [[NSMutableDictionary alloc] init];	
    }
    return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.indexList count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	long res = [[(DAAPResponsemlit *)[self.indexList objectAtIndex:section] mshn] longValue];
	
	return res;
}

-(void)didFinishLoading:(UIImage *)image forAlbumId:(NSNumber *)albumId{
	if (image == nil) {
		return;
	}
	[artworks setObject:image forKey:albumId];
	[loaders removeObjectForKey:albumId];
	//NSLog(@"got image for row : %d",[(NSIndexPath *)[cellId objectForKey:albumId] row]);
	[self.delegate updateImage:image forIndexPath:[cellId objectForKey:albumId]];
}

- (UIImage *) artworkForAlbum:(NSNumber *)albumId{
	if ([artworks objectForKey:albumId] == nil) {
		AsyncImageLoader *loader = [CurrentServer getArtwork:albumId size:90 delegate:self forAlbum:YES];
		UIImage *defaultImage = [UIImage imageNamed:@"defaultAlbumArtwork.png"];
		[artworks setObject:defaultImage forKey:albumId];
		[loaders setObject:loader forKey:albumId];
		return defaultImage;
	} else {
		return [artworks objectForKey:albumId];
	}
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSMutableArray *chars = [[[NSMutableArray alloc] init] autorelease];
	for (DAAPResponsemlit *mlit in self.indexList) {
		[chars addObject:[mlit mshc]];
	}
	return chars;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	NSInteger count = 0;
	for(DAAPResponsemlit *mlit in self.indexList)
	{
		if([mlit.mshc isEqualToString:title])
			return count;
		count ++;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [(DAAPResponsemlit *)[self.indexList objectAtIndex:section] mshc];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"PodcastsCell";
    
	BooksAndPodcastsCustomCellView *cell = (BooksAndPodcastsCustomCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed: @"BooksAndPodcastsCell" owner: self options: nil] objectAtIndex: 0];
    }
    
	long offset = [[(DAAPResponsemlit *)[self.indexList objectAtIndex:indexPath.section] mshi] longValue];
	DAAPResponsemlit *track = [self.list objectAtIndex:(offset + indexPath.row)];
	
	cell.trackName.text = track.name;
	cell.artistName.text = track.songAlbumArtist;
	int res = indexPath.row % 2;
	if (res != 0){
		cell.backgroundView.backgroundColor = cellColoredBackground;
	} else {
		cell.backgroundView.backgroundColor = [UIColor whiteColor];
	}
	
	cell.imageView.image = [self artworkForAlbum:track.miid];
	
	if ([cellId objectForKey:track.miid] == nil) {
		[cellId setObject:indexPath forKey:track.miid];
	}
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	long offset = [[(DAAPResponsemlit *)[self.indexList objectAtIndex:indexPath.section] mshi] longValue];
	DAAPResponsemlit *song = (DAAPResponsemlit *)[self.list objectAtIndex:(offset + indexPath.row)];
	
	//NSLog(@"%@-%qi-%qi",song.name,[song.persistentId longLongValue],containerPersistentId);
	
	DAAPResponseapso * resp;
	if (self.itemType == kItemTypePodcast) {
		resp = [CurrentServer getTracksForPodcast:[NSString stringWithFormat:@"%qi",[song.persistentId longLongValue]]];
	} else {
		resp = [CurrentServer getTracksForBook:[NSString stringWithFormat:@"%qi",[song.persistentId longLongValue]]];
	}

	
	PodcastsTracksDatasource * c = [[PodcastsTracksDatasource alloc] init];
	c.itemType = self.itemType;
	c.list = resp.listing.list;
	c.containerPersistentId = containerPersistentId ;
	c.currentPodcastGroupId = song.miid;
	//c.albumName = [(DAAPResponsemlit *)[self.list objectAtIndex:i] name];
	//[c setTitle:[(DAAPResponsemlit *)[self.list objectAtIndex:i] name]];
	[self.navigationController pushViewController:c animated:YES];
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	[c release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 90;
}

// Used to update nowPlaying in the table
- (void) statusUpdate:(NSNotification *)notification{
	/*DAAPResponsecmst *cmst = (DAAPResponsecmst *)[notification.userInfo objectForKey:@"cmst"];
	self.currentTrack = cmst.cann;
	self.currentArtist = cmst.cana;
	self.currentAlbum = cmst.canl;*/
	
	[self.delegate refreshTableView];
}

- (void) didFinishLoading:(DAAPResponse *)response{
	[super didFinishLoading:response];
	self.list = [[(DAAPResponseapso *)response listing] list];
	self.indexList = [[(DAAPResponseapso *)response headerList] indexList];
	
	[self.delegate refreshTableView];
	[self.delegate didFinishLoading];
}

- (void) cleanJobs{
	NSEnumerator *enumerator = [loaders objectEnumerator];
	id value;
	
	while ((value = [enumerator nextObject])) {
		[(AsyncImageLoader *)value cancelConnection];
	}
}

- (void)dealloc {
	[self cleanJobs];
	[artworks release];
	[cellId release];
	[loaders release];
    [super dealloc];
}

@end
