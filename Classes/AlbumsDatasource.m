//
//  AlbumsDatasource.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 19/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "AlbumsDatasource.h"
#import "DAAPResponsemlit.h"
#import "DAAPResponseapso.h"
#import "TracksForAlbumController.h"
#import "SessionManager.h"
#import "UIImage+Resize.h"


@implementation AlbumsDatasource
@synthesize navigationController;

- (id) init{
	if ((self = [super init])) {
		artworks = [[NSMutableDictionary alloc] init];
		cellId = [[NSMutableDictionary alloc] init];
		loaders = [[NSMutableDictionary alloc] init];		
    }
    return self;
}


#pragma mark -
#pragma mark Table view data source

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
	//return arrayOfCharacters;
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

-(void)didFinishLoading:(UIImage *)image forAlbumId:(NSNumber *)albumId{
	if (image == nil) {
		return;
	}
	
	UIImage *temp = [image resizedImage:CGSizeMake(55, 55) interpolationQuality:kCGInterpolationDefault];
	//NSLog(@"got image for row : %d, w: %f, h: %f",[(NSIndexPath *)[cellId objectForKey:albumId] row], temp.size.width, temp.size.height);
	[artworks setObject:temp forKey:albumId];
	[loaders removeObjectForKey:albumId];
	[self.delegate  updateImage:temp forIndexPath:[cellId objectForKey:albumId]];
}

- (UIImage *) artworkForAlbum:(NSNumber *)albumId{
	if ([artworks objectForKey:albumId] == nil) {
		AsyncImageLoader *loader = [CurrentServer getArtwork:albumId delegate:self forAlbum:YES];
		UIImage *defaultImage = [UIImage imageNamed:@"defaultAlbumArtwork.png"];
		[artworks setObject:defaultImage forKey:albumId];
		[loaders setObject:loader forKey:albumId];
		return defaultImage;
	} else {
		return [artworks objectForKey:albumId];
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AlbumCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	long offset = [[(DAAPResponsemlit *)[self.indexList objectAtIndex:indexPath.section] mshi] longValue];
	DAAPResponsemlit *mlit = (DAAPResponsemlit *)[self.list objectAtIndex:(offset + indexPath.row)];
	
    cell.textLabel.text = mlit.name;
	cell.imageView.image = [self artworkForAlbum:mlit.miid];
	if ([cellId objectForKey:mlit.miid] == nil) {
		[cellId setObject:indexPath forKey:mlit.miid];
	}
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DAAPResponsemlit *mlit = (DAAPResponsemlit *)[self.indexList objectAtIndex:indexPath.section];
	long offset = [mlit.mshi longValue];
	long i = offset + indexPath.row;
	NSNumber *albumId = [(DAAPResponsemlit *)[self.list objectAtIndex:i] persistentId];
	
	DAAPResponseapso * resp = [CurrentServer getTracksForAlbum:albumId];
	TracksForAlbumController * c = [[TracksForAlbumController alloc] init];
	c.tracks = resp.listing.list;
	c.albumName = [(DAAPResponsemlit *)[self.list objectAtIndex:i] name];
	[c setTitle:[(DAAPResponsemlit *)[self.list objectAtIndex:i] name]];
	[self.navigationController pushViewController:c animated:YES];
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	[c release];
}

- (void) didFinishLoading:(DAAPResponse *)response{
	[super didFinishLoading:response];
	self.list = [[(DAAPResponseagal *)response listing] list];
	self.indexList = [[(DAAPResponseagal *)response headerList] indexList];
	
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
