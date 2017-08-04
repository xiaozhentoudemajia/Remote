//
//  TracksForAlbumController.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 11/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "TracksForAlbumController.h"
#import "DAAPResponsemlit.h"




@implementation TracksForAlbumController
@synthesize tracks;
@synthesize shouldPlayAllTracks;
@synthesize albumName;

#pragma mark -
#pragma mark Initialization

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if ((self = [super initWithStyle:style])) {
 }
 return self;
 }
 */


#pragma mark -
#pragma mark View lifecycle


 - (void)viewDidLoad {
 [super viewDidLoad];
 
 // Uncomment the following line to preserve selection between presentations.
 self.clearsSelectionOnViewWillAppear = NO;
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusUpdate:) name:kNotificationStatusUpdate object:nil];

 }
 


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [tracks count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"DetailedTrack";
    
	DetailedTrackCustomCellClass *cell = (DetailedTrackCustomCellClass *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed: @"DetailedTrackCustomCellView" owner: self options: nil] objectAtIndex: 0];
    }
    
    // Configure the cell...
	DAAPResponsemlit *mlit = (DAAPResponsemlit *)[self.tracks objectAtIndex:indexPath.row];
    cell.trackName.text = mlit.name;
	int timeMillis = [mlit.astm intValue];
	int timeSec = timeMillis / 1000;
	
	int totalDays = timeSec / 86400;
    int totalHours = (timeSec / 3600) - (totalDays * 24);
    int totalMinutes = (timeSec / 60) - (totalDays * 24 * 60) - (totalHours * 60);
    int totalSeconds = timeSec % 60;

	cell.trackLength.text = [NSString stringWithFormat:@"%d:%02d",totalMinutes,totalSeconds];
	cell.trackNumber.text = [NSString stringWithFormat:@"%d.",indexPath.row+1];
	if ([cell.trackName.text isEqualToString:CurrentServer.currentTrack] && [mlit.artistName isEqualToString:CurrentServer.currentArtist]){
		if (self.shouldPlayAllTracks) {
			cell.nowPlaying = YES;
		} else {
			if ([self.title isEqualToString:CurrentServer.currentAlbum]) {
				cell.nowPlaying = YES;
			} else {
				cell.nowPlaying = NO;
			}

		}

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
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	DAAPResponsemlit *mlit = (DAAPResponsemlit *)[self.tracks objectAtIndex:indexPath.row];
	if (self.shouldPlayAllTracks) {
		[CurrentServer playAllTracksForArtist:mlit.artistName index:indexPath.row];
	} else {
		[CurrentServer playSongIndex:indexPath.row inAlbum:mlit.asai];
	}
	
}

// Used to update nowPlaying in the table
- (void) statusUpdate:(NSNotification *)notification{
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[self.tracks release];
	[self.albumName release];
    [super dealloc];
}


@end
