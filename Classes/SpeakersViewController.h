//
//  SpeakersViewController.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 20/06/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDServer.h"
#import "SessionManager.h"

@interface SpeakersViewController : UITableViewController <DAAPRequestDelegate>{
	@private
	NSArray *speakers;
}

@property (nonatomic, retain) NSArray *speakers;

- (void)didChangeSpeakerValue:(id)sender;
@end
