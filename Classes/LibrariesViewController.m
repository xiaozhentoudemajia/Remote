    //
//  LibrariesViewController.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 20/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "LibrariesViewController.h"
#import "PreferencesManager.h"
#import "SessionManager.h"
#import "DAAPRequestReply.h"
#import "HexDumpUtility.h"
#import "DAAPResponsemdcl.h"
#import "RemoteSpeaker.h"
#import "DAAPResponsecasp.h"
#import "DDLog.h"
#import <netinet/in.h>
#import <sys/socket.h>
#include <arpa/inet.h>

#ifdef CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

#define kProgressIndicatorSize 20.0
#define kLocalizedEdit     NSLocalizedString(@"Edit","Modifier")
#define kLocalizedDone    NSLocalizedString(@"Done","OK")


@interface LibrariesViewController()
@property (nonatomic, retain, readwrite) NSArray* speakers;
@property (nonatomic, retain, readwrite) NSNetServiceBrowser* netServiceBrowser;
@property (nonatomic, retain, readwrite) NSNetService* currentResolve;
@property (nonatomic, retain, readwrite) NSTimer* timer;
@property (nonatomic, assign, readwrite) BOOL needsActivityIndicator;
@property (nonatomic, copy, readwrite) NSString *currentlyPairingServiceName;
@property (nonatomic, copy, readwrite) NSString *selectedServiceName;
@property (nonatomic, copy, readwrite) NSString *currentGUID;
@property (nonatomic, retain, readwrite) NSMutableArray *availableServices;

- (void)stopCurrentResolve;
- (void)didChangeSpeakerValue:(id)sender;
- (void)didChangeVolumeControl:(id)sender;
- (BOOL) _hasRemoteSpeakers;
@end

@implementation LibrariesViewController

@synthesize delegate;
@synthesize table;

@synthesize currentResolve = _currentResolve;
@synthesize netServiceBrowser = _netServiceBrowser;
@synthesize speakers = _speakers;
@synthesize needsActivityIndicator = _needsActivityIndicator;
@dynamic timer;
@synthesize currentlyPairingServiceName = _currentServiceName;
@synthesize selectedServiceName = _selectedServiceName;
@synthesize currentGUID = _currentGUID;
@synthesize availableServices = _availableServices;

- (NSTimer *)timer {
	return _timer;
}

// When this is called, invalidate the existing timer before releasing it.
- (void)setTimer:(NSTimer *)newTimer {
	[_timer invalidate];
	[newTimer retain];
	[_timer release];
	_timer = newTimer;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.*/
- (void)viewDidLoad {
    [super viewDidLoad];
	DDLogVerbose(@"Library view did load");
	self.availableServices = [[NSMutableArray alloc] init];
	editButton.possibleTitles = [NSSet setWithObjects:kLocalizedEdit, kLocalizedDone, nil];
	editButton.title = kLocalizedEdit;
}

- (void)viewWillAppear:(BOOL)animated{
	DDLogVerbose(@"Library view did appear");
//	self.currentGUID = nil;
	
	if (![CurrentServer connected]) {
		if (self.speakers != nil) {
			self.speakers = nil;
		}
	}
	if ([[[SessionManager sharedSessionManager] getServers] count] > 0) {
		[self searchForServicesOfType:@"_touch-able._tcp" inDomain:@"local"];
		[CurrentServer getSpeakers:self];
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if ([self _hasRemoteSpeakers]){
		return 3;
	}
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return [[[SessionManager sharedSessionManager] getServers] count] + 1;
			break;
		case 1:
			if ([self _hasRemoteSpeakers]) { 
				return [self.speakers count];
			} else {
				return 1;
			}
			break;
		case 2:
			return 1;
			break;
		default:
			return 0;
	}		
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"LibraryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	if (indexPath.section == 1) {
		if ([self _hasRemoteSpeakers]){
			RemoteSpeaker * sp = (RemoteSpeaker *)[self.speakers objectAtIndex:indexPath.row];
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
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[sw release];
		} 
    } else if (indexPath.section == 0) {
		if (indexPath.row == [[[SessionManager sharedSessionManager] getServers] count]){
			cell.textLabel.text = NSLocalizedString(@"addLibrary",@"Ajouter une bibliothèque");
			if (cell.accessoryView) {
				cell.accessoryView = nil;
			}
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else {
			// Set up the text for the cell
			FDServer *server = [[[SessionManager sharedSessionManager] getServers] objectAtIndex:indexPath.row];
			
			NSData *obj = [server.TXT objectForKey:@"CtlN"];
			NSString * libraryName = [DAAPRequestReply parseString:obj];
			NSString *serviceName = server.servicename;
			
			cell.textLabel.text = libraryName;
			// by default library names are greyed
			cell.textLabel.textColor = [UIColor grayColor];
			
			// unless it has been found during the service discovery
			if ([self.availableServices indexOfObject:serviceName] != NSNotFound) {
				cell.textLabel.textColor = [UIColor blackColor];
			}
			
			
			cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
			
			// Note that the underlying array could have changed, and we want to show the activity indicator on the correct cell
			if (self.needsActivityIndicator && [self.selectedServiceName isEqualToString:serviceName]) {
				if (!cell.accessoryView) {
					CGRect frame = CGRectMake(0.0, 0.0, kProgressIndicatorSize, kProgressIndicatorSize);
					UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithFrame:frame];
					[spinner startAnimating];
					spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
					[spinner sizeToFit];
					spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
												UIViewAutoresizingFlexibleRightMargin |
												UIViewAutoresizingFlexibleTopMargin |
												UIViewAutoresizingFlexibleBottomMargin);
					cell.accessoryView = spinner;
					[spinner release];
				}
			} else if (cell.accessoryView) {
				cell.accessoryView = nil;
			}		
			// is we are currently connected to a server add a checkmark
			FDServer *currentServer = CurrentServer;
			if ([serviceName isEqualToString:currentServer.servicename]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
				cell.textLabel.textColor = [UIColor blackColor];
			}
			
		}
	}
	
	if ((indexPath.section == 1 && ![self _hasRemoteSpeakers]) || indexPath.section == 2) {
		cell.textLabel.text = NSLocalizedString(@"volumeControl",@"Contrôle du volume");
		UISwitch *sw = [[UISwitch alloc] init];
		if ([[PreferencesManager sharedPreferencesManager] volumeControl]) {
			sw.on = YES;
		} else {
			sw.on = NO;
		}
		//sw.tag = 10+indexPath.row;
		[sw addTarget:self action:@selector(didChangeVolumeControl:) forControlEvents:UIControlEventValueChanged];
		cell.accessoryView = sw;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[sw release];
	}
    
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
//	[self.table reloadData];
}

- (void) didChangeVolumeControl:(id)sender{
	UISwitch *sw = (UISwitch *)sender;
	[[PreferencesManager sharedPreferencesManager] setVolumeControl:sw.on];
	
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (section == 0) {
		return NSLocalizedString(@"iTunesLibraries",@"Bibliothèques de musique");
	} else  if (section == 1) {
		if ([self _hasRemoteSpeakers]){
			return NSLocalizedString(@"remoteSpeakers",@"Haut parleurs");
		}
		else{
			return NSLocalizedString(@"Options",@"Options");
		}
	} else {
		return NSLocalizedString(@"Options",@"Options");
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1 || indexPath.section == 2) {
		return NO;
	} else if (indexPath.section == 0) {
		if (indexPath.row == [[[SessionManager sharedSessionManager] getServers] count]){
			return NO;
		} else {
			return YES;
		}

	}
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	 if (editingStyle == UITableViewCellEditingStyleDelete) {
		 FDServer *server = [[[SessionManager sharedSessionManager] getServers] objectAtIndex:indexPath.row];
		 [[SessionManager sharedSessionManager] deleteServerWithPairingGUID:server.pairingGUID];
		 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
	 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
		 // Do nothing
	 }  
	if ([[[SessionManager sharedSessionManager] getServers] count] == 0) {
		doneButton.enabled = YES;
		editButton.title = kLocalizedEdit;
		editButton.style = UIBarButtonItemStyleBordered;
		[self.table setEditing:NO animated:YES];
	}

}

// If necessary, sets up state to show an activity indicator to let the user know that a resolve is occuring.
- (void)showWaiting:(NSTimer*)timer {
	if (timer == self.timer) {
		self.needsActivityIndicator = YES;
		NSIndexPath *indexPath = (NSIndexPath *)timer.userInfo;
		[self.table reloadRowsAtIndexPaths:[NSArray	arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
		// Deselect the row since the activity indicator shows the user something is happening.
		[self.table deselectRowAtIndexPath:indexPath animated:YES];
		
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.currentResolve stop];
	if (indexPath.section == 0) {
		// user selected add library
		if (indexPath.row == [[[SessionManager sharedSessionManager] getServers] count]) {
			[self.netServiceBrowser stop];
			PinCodeController *pincodeController = [[PinCodeController alloc] initWithNibName:@"PinCodeController" bundle:nil];
			pincodeController.modalPresentationStyle = UIModalPresentationFullScreen;
			pincodeController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
			pincodeController.delegate = self;
			[self presentModalViewController:pincodeController animated:YES];
		} 
		// user selected a previously paired library, try to resolve service in case the host has changed
		else {
			FDServer *selectedServer = [[[SessionManager sharedSessionManager] getServers] objectAtIndex:indexPath.row];
			
			if (!selectedServer.connected) {
				selectedServer.delegate = self;
				[CurrentServer logout];
				[selectedServer open];
				self.selectedServiceName = selectedServer.servicename;
				self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(showWaiting:) userInfo:indexPath repeats:NO];
			}			
		}
	}
}

#pragma mark -
#pragma mark actions
- (IBAction) doneButtonPressed:(id)sender{
	[delegate didFinishEditingLibraries];
}

- (IBAction) editButtonPressed:(id)sender{
	if ([[[SessionManager sharedSessionManager] getServers] count] == 0) {
		doneButton.enabled = YES;
		editButton.title = kLocalizedEdit;
		editButton.style = UIBarButtonItemStyleBordered;
		[self.table setEditing:NO animated:NO];
		return;
	}
	if (!self.table.editing){
		editButton.title = kLocalizedDone;
		editButton.style = UIBarButtonItemStyleDone;
		doneButton.enabled = NO;
		[self.table setEditing:YES animated:YES];
	} else {
		doneButton.enabled = YES;
		editButton.title = kLocalizedEdit;
		editButton.style = UIBarButtonItemStyleBordered;
		[self.table setEditing:NO animated:YES];
	}

}

- (void)didFinishWithPinCode:(NSString *)serviceName guid:(NSString *)guid{
	[self dismissModalViewControllerAnimated:YES];
	self.currentlyPairingServiceName = serviceName;
	self.currentGUID = guid;
	[self searchForServicesOfType:@"_touch-able._tcp" inDomain:@"local"];
};
	 
// Creates an NSNetServiceBrowser that searches for services of a particular type in a particular domain.
// If a service is currently being resolved, stop resolving it and stop the service browser from
// discovering other services.
- (BOOL)searchForServicesOfType:(NSString *)type inDomain:(NSString *)domain {
	
	[self stopCurrentResolve];
	[self.netServiceBrowser stop];
	
	DDLogVerbose(@"starting services search");
	
	NSNetServiceBrowser *aNetServiceBrowser = [[NSNetServiceBrowser alloc] init];
	if(!aNetServiceBrowser) {
		// The NSNetServiceBrowser couldn't be allocated and initialized.
		return NO;
	}
	
	aNetServiceBrowser.delegate = self;
	self.netServiceBrowser = aNetServiceBrowser;
	[aNetServiceBrowser release];
	[self.netServiceBrowser searchForServicesOfType:type inDomain:domain];
	
	[self.table reloadData];
	return YES;
}
	 
- (void)stopCurrentResolve {
	DDLogVerbose(@"stopping current resolve");
	self.needsActivityIndicator = NO;
	self.timer = nil;
	
	[self.currentResolve stop];
	self.currentResolve = nil;
}


#pragma mark -
#pragma mark NSNetService callbacks

- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveService:(NSNetService*)service moreComing:(BOOL)moreComing {
	DDLogVerbose(@"a service disappeared : %@",service.name);
	// If a service went away, stop resolving it if it's currently being resolved,
	// remove it from the list and update the table view if no more events are queued.
	if (self.currentResolve && [service isEqual:self.currentResolve]) {
		[self stopCurrentResolve];
	}
	if ([self.availableServices indexOfObject:service.name] != NSNotFound) {
		[self.availableServices removeObject:service.name];
	}
	if (!moreComing) {
		[self.table reloadData];
	}
}	


- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing {
	DDLogVerbose(@"Found a service : %@",service.name);
	if ([service.name isEqualToString:self.currentlyPairingServiceName]) {
		DDLogVerbose(@"it's the server we've just paired with, resolving it...");
		self.currentResolve = service;
		[self.currentResolve setDelegate:self];
		self.currentlyPairingServiceName = nil;
		
		// Attempt to resolve the service. A value of 0.0 sets an unlimited time to resolve it. The user can
		// choose to cancel the resolve by selecting another service in the table view.
		[self.currentResolve resolveWithTimeout:20.0];
	} else {
		DDLogVerbose(@"This is either a previously paired service or a new one, just keep it for later use");
		if ([self.availableServices indexOfObject:service.name] == NSNotFound) {
			[self.availableServices addObject:service.name];
		}
	}

	
	if (!moreComing) {
		[self.table reloadData];
	}
}	


// This should never be called, since we resolve with a timeout of 0.0, which means indefinite
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	DDLogError(@"service did not resolve");
	[self stopCurrentResolve];
	[self.table reloadData];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
	assert(service == self.currentResolve);
	DDLogVerbose(@"service %@ address resolved",service.name);
	
	[service retain];
	[self stopCurrentResolve];

	if (![service.name isEqualToString:[CurrentServer servicename]]) {
		DDLogVerbose(@"We were already connected to that server, logout and refresh server definition");
		[CurrentServer logout];
		FDServer *server = [[FDServer alloc] initWithNetService:service pairingGUID:self.currentGUID];
		FDServer * serv = [[SessionManager sharedSessionManager] foundNewServer:server];
		serv.delegate = self;
		[serv open];
		[server release];
	}
	
	[service release];
	[self.table reloadData];
}

- (void) didFinishResolvingServerWithSuccess:(BOOL)success{
	self.needsActivityIndicator = NO;
	self.timer = nil;
	[self.table reloadData];
}

- (void) didOpenServer:(FDServer *)server {
	[(FDServer *)server getSpeakers:self];
	[self.table reloadData];
}

// get speaker list
-(void)didFinishLoading:(DAAPResponse *)response{
	DAAPResponsecasp *casp = (DAAPResponsecasp *)response;
	
	self.speakers = casp.speakers;
	[self.table reloadData];
}

- (BOOL) _hasRemoteSpeakers{
	return (self.speakers != nil) && ([self.speakers count] > 1);
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidDisappear:animated];
}


- (void)dealloc {
    [super dealloc];
}


@end
