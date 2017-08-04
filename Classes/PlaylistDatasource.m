//
//  PlaylistDatasource.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 29/07/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "PlaylistDatasource.h"
#import "SessionManager.h"
#import "DAAPResponseadbs.h"
#import "DAAPResponsemlit.h"
#import "DAAPResponsemlog.h"
#import "DAAPResponseabro.h"
#import "DAAPResponseavdb.h"

@implementation PlaylistDatasource

@synthesize navigationController;
@synthesize containerPersistentId;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	int sectionCount = [self.list count]/10;
	if ([self.list count]%10 > 0) return sectionCount+1;
	else return sectionCount;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == [self.list count]/10 ) {
		return [self.list count]%10;
	}
	else return 10;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	NSMutableArray *chars = [[[NSMutableArray alloc] init] autorelease];
	int i = 0;
	int sectionCount = [self.list count]/10;
	int j = 0;
	if ([self.list count]%10 > 0) j = sectionCount+1;
	else j = sectionCount;
	while (i<j) {
		[chars addObject:[NSString stringWithFormat:@"•",i++]];
	}
	return chars;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"TrackCell";
    
	TrackCustomCellClass *cell = (TrackCustomCellClass *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed: @"TrackCustomCell" owner: self options: nil] objectAtIndex: 0];
    }
 	
	int index = 0;
	if (indexPath.section > [self.list count]/10 ) {
		index =  ((int)[self.list count]/10)*10 + indexPath.row;
	} else {
		index = indexPath.section*10 + indexPath.row;
	}

	DAAPResponsemlit *track = [self.list objectAtIndex:(indexPath.section*10 + indexPath.row)];
	
	cell.trackName.text = track.name;
	NSString *album = track.asal;
	NSString *artist = track.artistName;
	cell.artistName.text = artist;
	cell.albumName.text = album;
	
	int timeMillis = [track.astm intValue];
	int timeSec = timeMillis / 1000;
	
	int totalDays = timeSec / 86400;
    int totalHours = (timeSec / 3600) - (totalDays * 24);
    int totalMinutes = (timeSec / 60) - (totalDays * 24 * 60) - (totalHours * 60);
    int totalSeconds = timeSec % 60;
	
	cell.trackLength.text = [NSString stringWithFormat:@"%d:%02d",totalMinutes,totalSeconds];
	
	if ([cell.trackName.text isEqualToString:CurrentServer.currentTrack] && [cell.artistName.text isEqualToString:CurrentServer.currentArtist] && [cell.albumName.text isEqualToString:CurrentServer.currentAlbum]) {
		cell.nowPlaying = YES;
	} else {
		cell.nowPlaying = NO;
	}
	int res = indexPath.row % 2;
	if (res != 0){
		cell.background.backgroundColor = cellColoredBackground;
	} else {
		cell.background.backgroundColor = [UIColor whiteColor];
	}
	
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int index = 0;
	if (indexPath.section > [self.list count]/10 ) {
		index =  ((int)[self.list count]/10)*10 + indexPath.row;
	} else {
		index = indexPath.section*10 + indexPath.row;
	}
	DAAPResponsemlit *song = (DAAPResponsemlit *)[self.list objectAtIndex:index];
	[CurrentServer playSongInPlaylist:containerPersistentId song:[song.mcti longValue]];
}

- (void) didFinishLoading:(DAAPResponse *)response{
	[super didFinishLoading:response];
	self.list = [[(DAAPResponseapso *)response listing] list];
	
	[self.delegate refreshTableView];
	[self.delegate didFinishLoading];
	self.needsRefresh = YES;
}

- (void) dealloc{
	[super dealloc];
}


@end
