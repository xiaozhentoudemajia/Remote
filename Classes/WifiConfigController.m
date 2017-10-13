//
//  WifiConfig.m
//  AcaRemote
//
//  Created by ALI_MAC on 2017/10/13.
//

#import "WifiConfigController.h"

@interface WifiConfigController ()

@end

@implementation WifiConfigController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)ssidText:(id)sender {
}

- (IBAction)passwordText:(id)sender {
}

- (IBAction)enterWifiConfig:(id)sender {
    [delegate didSetWifiConfig:ssid.text pwd:password.text];
}

- (IBAction)exitWifiConfig:(id)sender {
    [delegate didFinishWifiConfig];
}

- (void)dealloc {
    [ssid release];
    [password release];
    [super dealloc];
}
@end
