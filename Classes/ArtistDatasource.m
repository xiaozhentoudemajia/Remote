//
//  ArtistDelegate.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 11/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "ArtistDatasource.h"
#import "SessionManager.h"
#import "DAAPResponsemlit.h"
#import "AlbumsOfArtistController.h"
#import "TracksForAlbumController.h"
#import "DAAPResponseabro.h"


@implementation ArtistDatasource
@synthesize navigationController;


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.indexList count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	long res = [[(DAAPResponsemlit *)[self.indexList objectAtIndex:section] mshn] longValue];
	
	return res;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *CellIdentifier = @"CellArtist";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	long offset = [[(DAAPResponsemlit *)[self.indexList objectAtIndex:indexPath.section] mshi] longValue];
	NSString *artist = [self.list objectAtIndex:(offset + indexPath.row)];
	
//	NSString *artist = [self.list objectAtIndex:indexPath.row];
	
	cell.textLabel.text = artist;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	DAAPResponsemlit *mlit = (DAAPResponsemlit *)[self.indexList objectAtIndex:indexPath.section];
	long offset = [mlit.mshi longValue];
	long i = offset + indexPath.row;
	NSString *artist = [self.list objectAtIndex:i];
	DAAPResponseagal * resp = [CurrentServer getAlbumsForArtist:artist];
	
	if ([resp.listing.list count] == 0) {
		// No named album for that artist
		//TODO use header view to place a 'all tracks' in case some tracks are in an album and others don't
		DAAPResponseapso * resp2 = [CurrentServer getAllTracksForArtist:artist];
		TracksForAlbumController * c = [[TracksForAlbumController alloc] init];
		c.tracks = resp2.listing.list;
		[self.navigationController setNavigationBarHidden:NO animated:NO];
		[c setTitle:NSLocalizedString(@"TracksDefaultName",@"Pistes")];
		c.shouldPlayAllTracks = YES;
		[self.navigationController pushViewController:c animated:YES];
		[c release];
		
	} else if ([resp.listing.list count] == 1) {
		NSNumber *albumId = [(DAAPResponsemlit *)[resp.listing.list objectAtIndex:0] persistentId];
		DAAPResponseapso * resp = [CurrentServer getTracksForAlbum:albumId];
		TracksForAlbumController * c = [[TracksForAlbumController alloc] init];
		c.tracks = resp.listing.list;
		c.shouldPlayAllTracks = NO;
		[self.navigationController setNavigationBarHidden:NO animated:NO];
		[c setTitle:[(DAAPResponsemlit *)[resp.listing.list objectAtIndex:0] albumName]];
		c.albumName = [(DAAPResponsemlit *)[resp.listing.list objectAtIndex:0] name];
		[self.navigationController pushViewController:c animated:YES];
		[c release];
	}
	
	else {
		AlbumsOfArtistController * c = [[AlbumsOfArtistController alloc] init];
		c.agal = resp;
		[self.navigationController setNavigationBarHidden:NO animated:NO];
		[c setTitle:@"Albums"];
		[self.navigationController pushViewController:c animated:YES];
		[c release];
	}
}

- (void) didFinishLoading:(DAAPResponse *)response{
	[super didFinishLoading:response];
	DAAPResponseabro * resp = (DAAPResponseabro *)response;

	self.list = resp.abar.list;
	self.indexList = resp.headerList.indexList;
	
	[self.delegate refreshTableView];
	[self.delegate didFinishLoading];
}

- (void)dealloc {
    [super dealloc];
}

@end
