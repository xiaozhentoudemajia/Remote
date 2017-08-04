    //
//  PinCodeController.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 20/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "PinCodeController.h"


@implementation PinCodeController

@synthesize delegate;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	pincodeTip.text = NSLocalizedString(@"pincodeTip",@"Pour ajouter une bibliothèque iTunes, ouvrez iTunes puis sélectionnez votre iPad dans la liste d'appareils.");
	[cancelButton setTitle:NSLocalizedString(@"cancelButton",@"Annuler") forState:UIControlStateNormal];
	[cancelButton setTitle:NSLocalizedString(@"cancelButton",@"Annuler") forState:UIControlStateHighlighted];
	
	GUID = arc4random() % ((unsigned)RAND_MAX + 1);
	NSString * randomPairCode = [NSString stringWithFormat:@"%08X%08X",GUID,GUID];

	UIDevice *device = [UIDevice currentDevice];
	 NSDictionary *dicton = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: device.name,@"10000",device.model,@"Remote",@"1",randomPairCode,nil] forKeys:[NSArray arrayWithObjects:@"DvNm",@"RemV",@"DvTy",@"RemN",@"txtvers",@"Pair",nil]];
	 if (httpServer == nil) {
	 httpServer = [HTTPServer new];
	 [httpServer setType:@"_touch-remote._tcp."];
	 [httpServer setName:@"0000000000000000000000000000000000000006"];
	 [httpServer setPort:1024];
	 [httpServer setConnectionClass:[MyHTTPConnection class]];
	 [httpServer setTXTRecordDictionary:dicton];
		 httpServer.pairingDelegate = self;
	 }
	 
	 NSError *error;
	 if(![httpServer start:&error])
	 {
	 NSLog(@"Error starting HTTP Server: %@", error);
	 }
	
}

- (void)viewWillAppear:(BOOL)animated{
	pin = arc4random() % (10000);
	NSString *pinStr = [NSString stringWithFormat:@"%04d",pin];
	pinCode1.text = [pinStr substringToIndex:1];
	pinCode2.text = [pinStr substringWithRange:NSMakeRange(1, 1)];
	pinCode3.text = [pinStr substringWithRange:NSMakeRange(2, 1)];
	pinCode4.text = [pinStr substringWithRange:NSMakeRange(3, 1)];
}

- (void) tryClosingServer:(NSTimer *)theTimer{
	if ([httpServer numberOfHTTPConnections] == 0) {
		[httpServer stop];
		[theTimer invalidate];
	}
}

#pragma mark -
#pragma mark PairingServerDelegate methods

- (int) obtainPinCode{
	return pin;
}

- (int) obtainGUID{
	return GUID;
}

- (void) pairedSuccessfully:(NSString *)serviceName {
	NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(tryClosingServer:) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	NSString * guidStr = [NSString stringWithFormat:@"%08X%08X",GUID,GUID];
	[delegate didFinishWithPinCode:serviceName guid:guidStr];
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (IBAction) cancelButtonPressed:(id)sender{
	[httpServer stop];
	[delegate didFinishWithPinCode:nil guid:nil];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
