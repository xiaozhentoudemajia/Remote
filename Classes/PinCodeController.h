//
//  PinCodeController.h
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 20/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "DAAPRequestReply.h"

@protocol PincodeDelegate

- (void)didFinishWithPinCode:(NSString *)serviceName guid:(NSString *)guid;

@end

@interface PinCodeController : UIViewController <PairingServerDelegate, UITableViewDataSource,UITableViewDelegate>{
	id<PincodeDelegate> delegate;
	HTTPServer *httpServer;
	IBOutlet UILabel *pinCode1;
	IBOutlet UILabel *pinCode2;
	IBOutlet UILabel *pinCode3;
	IBOutlet UILabel *pinCode4;
	IBOutlet UILabel *pincodeTip;
	IBOutlet UIButton *cancelButton;
	int pin;
	int GUID;
}

@property (nonatomic, assign) id<PincodeDelegate> delegate;

- (IBAction) cancelButtonPressed:(id)sender;

@end
