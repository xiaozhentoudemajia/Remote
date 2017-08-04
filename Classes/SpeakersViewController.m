//
//  SpeakersViewController.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 20/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "SpeakersViewController.h"
#import "RemoteSpeaker.h"
#import "DAAPResponsecasp.h"

@implementation SpeakersViewController
@synthesize speakers;


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
	FDServer *server = CurrentServer;
	[server getSpeakers:self];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	FDServer *server = CurrentServer;
	[server getSpeakers:self];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
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
    return [self.speakers count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SpeakerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	RemoteSpeaker *sp = (RemoteSpeaker *)[self.speakers objectAtIndex:indexPath.row];
	cell.textLabel.text = sp.speakerName;
	UISwitch *sw = [[UISwitch alloc] init];
	if (sp.on) {
		sw.on = YES;
	} else {
		sw.on = NO;
	}
	sw.tag = 10+indexPath.row;
	[sw addTarget:self action:@selector(didChangeSpeakerValue:) forControlEvents:UIControlEventValueChanged];
	cell.accessoryView = sw;
	[sw release];
    
    return cell;
}

- (void)didChangeSpeakerValue:(id)sender{
	NSMutableArray *spList = [[NSMutableArray alloc] init];
	for (RemoteSpeaker *sp in self.speakers){
		if (sp.on) {
			[spList addObject:sp.spId];
		}
	}
	UISwitch *sw = (UISwitch *)sender;
	int rowNum = sw.tag - 10;
	NSNumber * num = [[self.speakers objectAtIndex:rowNum] spId];
	if (sw.on) {
		[spList addObject:num];
	}
	else {
		[spList removeObjectIdenticalTo:num];
	}
	[CurrentServer setSpeakers:spList];
	[CurrentServer getSpeakers:self];
	//[self.tableView reloadData];
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
}


// get speaker list
-(void)didFinishLoading:(DAAPResponse *)response{
	//BOOL shouldAnimate = ((self.speakers == nil) && (self.speakers.count < 2));
	DAAPResponsecasp *casp = (DAAPResponsecasp *)response;
	
	self.speakers = casp.speakers;
	/*if (shouldAnimate){
	 [self.tableView beginUpdates];
	 [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
	 [self.tableView endUpdates];
	 } else {*/
	[self.tableView reloadData];
	//}
	
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
	[self.speakers release];
    [super dealloc];
}


@end

