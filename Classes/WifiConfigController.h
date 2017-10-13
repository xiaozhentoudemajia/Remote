//
//  WifiConfig.h
//  AcaRemote
//
//  Created by ALI_MAC on 2017/10/13.
//

#import <UIKit/UIKit.h>

@protocol WifiConfigDelegate

- (void)didFinishWifiConfig;
- (void)didSetWifiConfig:(NSString *)ssid pwd:(NSString *)pwd;

@end

@interface WifiConfigController : UIViewController {
    id<WifiConfigDelegate> delegate;
    IBOutlet UITextField *ssid;
    IBOutlet UITextField *password;
}

@property (nonatomic, assign) id<WifiConfigDelegate> delegate;

- (IBAction)ssidText:(id)sender;
- (IBAction)passwordText:(id)sender;
- (IBAction)enterWifiConfig:(id)sender;
- (IBAction)exitWifiConfig:(id)sender;
@end
