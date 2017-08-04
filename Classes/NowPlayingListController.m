//
//  NowPlayingListController.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 03/08/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NowPlayingListController.h"
#import "DAAPResponsemlit.h"
#import "DAAPResponseapso.h"
#import "SessionManager.h"
#import "DAAPResponsecmst.h"
#import "NowPlayingCustomCellViewController.h"


@implementation NowPlayingListController

@synthesize tracks;
@synthesize track;
@synthesize album;
@synthesize artist;
@synthesize albumId;

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
	self.track = CurrentServer.currentTrack;
	self.album = CurrentServer.currentAlbum;
	self.artist = CurrentServer.currentArtist;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_statusUpdate:) name:kNotificationStatusUpdate object:nil];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void) scrollToCurrentlyPlayingTrack{
	int row = -1;
	for (int i = 0; i<[tracks count]; i++) {
		DAAPResponsemlit *t = [tracks objectAtIndex:i];
		if ([t.name isEqualToString:CurrentServer.currentTrack]) {
			row = i;
			break;
		}
	}
	
	if (row >= 0) {
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	}
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


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
    
    static NSString *CellIdentifier = @"NowPlayingCell";
	
	NowPlayingCustomCellViewController *cell = (NowPlayingCustomCellViewController *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed: @"NowPlayingCustomCell" owner: self options: nil] objectAtIndex: 0];
    }
    
    // Configure the cell...
	DAAPResponsemlit * t = (DAAPResponsemlit *)[tracks objectAtIndex:indexPath.row];
	
	cell.trackName.text =  t.name;
	cell.trackNumber.text = [NSString stringWithFormat:@"%d.",indexPath.row+1];
	cell.artistName.text = t.artistName;

	int timeMillis = [t.astm intValue];
	int timeSec = timeMillis / 1000;
	
	int totalDays = timeSec / 86400;
    int totalHours = (timeSec / 3600) - (totalDays * 24);
    int totalMinutes = (timeSec / 60) - (totalDays * 24 * 60) - (totalHours * 60);
    int totalSeconds = timeSec % 60;
	
	cell.trackLength.text = [NSString stringWithFormat:@"%d:%02d",totalMinutes,totalSeconds];
	
	if ([t.name isEqualToString:self.track] && [t.artistName isEqualToString:self.artist] && [t.albumName isEqualToString:self.album]) {
		cell.nowPlaying.hidden = NO;
		cell.trackNumber.hidden = YES;
	} else {
		cell.nowPlaying.hidden = TRUE;
		cell.trackNumber.hidden = NO;
	}
	int res = indexPath.row % 2;
	if (res != 0){
		//cell.backgroundView.backgroundColor = RGBCOLOR(25,25,25);
		cell.backgroundView.backgroundColor = [UIColor clearColor];
		cell.backgroundView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.3];
	} else {
		cell.backgroundView.backgroundColor = [UIColor clearColor];
		cell.backgroundView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3];
	}
    
    return cell;
}


- (void) _statusUpdate:(NSNotification *)notification{
	DAAPResponsecmst *cmst = (DAAPResponsecmst *)[notification.userInfo objectForKey:@"cmst"];
	self.track = cmst.cann;
	self.artist = cmst.cana;
	self.album = cmst.canl;
	
		
	if (cmst.asai && [self.albumId longLongValue] != [cmst.asai longLongValue]){
		[CurrentServer getTracksForAlbum:cmst.asai delegate:self];
		self.albumId = cmst.asai;
	}
		
	[self.tableView reloadData];
}

-(void)didFinishLoading:(DAAPResponse *)response{
	DAAPResponseapso *r = (DAAPResponseapso *)response;
	self.tracks = r.mlcl.list;
	[self.tableView reloadData];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	FDServer *server = CurrentServer;
	[server playSongIndex:indexPath.row inAlbum:server.currentAlbumId];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
	[tracks release];
	[albumId release];
    [super dealloc];
}


@end

