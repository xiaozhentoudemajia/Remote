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

    // add device list view
    // 初始化
    self.devicelist=[[DeviceList alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    // 设置数据源
    self.devicelist.textLabel_MArray=[[NSMutableArray alloc] initWithObjects:@"9924F359312A63C4_diningroom_ACA-0184",@"B6EF21A6E863DC73", nil];

    NSMutableArray *images  = [NSMutableArray array];
    for(NSInteger index = 0;index<[self.devicelist.textLabel_MArray count];index++){
        UIImage *image      = [UIImage imageNamed:@"settings"];
        [images addObject:image];
    }
    self.devicelist.images_MArray     = [[NSMutableArray alloc] initWithArray:images];
    self.devicelist.delegate = self;
    self.devicelist.dataSource = self;
    // 添加到当前View
    [self.view addSubview:self.devicelist];
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
    NSLog(@"www serviceName=%@, guidStr=%@", serviceName, guidStr);
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

#pragma mark delegate
// tableView每个分区的行数，可以为各个分区设置不同的行数，根据section的值判断即可
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"_textLabel_MArray conut=%lu",(unsigned long)[self.devicelist.textLabel_MArray count]);
    return [self.devicelist.textLabel_MArray count];
}

// 实现每一行Cell的内容，tableView重用机制
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 为其定义一个标识符，在重用机制中，标识符非常重要，这是系统用来匹配table各行cell的判断标准，在以后的学习中会体会到
    static NSString *cellIdentifier = @"cellIdentifier";
    // 从缓存队列中取出复用的cell
    UITableViewCell *cell           = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    // 如果队列中cell为空，即无复用的cell，则对其进行初始化
    if (cell==nil) {
        // 初始化
        cell                    = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        // 定义其辅助样式
        cell.accessoryType      = UITableViewCellAccessoryNone;
    }

    // 设置cell上文本内容
    cell.textLabel.text         = [self.devicelist.textLabel_MArray objectAtIndex:indexPath.row];
    cell.imageView.image        = [self.devicelist.images_MArray objectAtIndex:indexPath.row];

    return cell;
}

// tableView分区数量，默认为1，可为其设置为多个分区
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// tableView页眉的值，同理，可为不同的分区设置不同的页眉，也可不写此方法
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"页眉";
}

// 页脚
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"页脚";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK",nil];
    alert.title = @"链接";
    [alert show];//显示对话框
    [self.delegate didFinishWithPinCode:@"9924F359312A63C4_diningroom_ACA-0184" guid:@"192.168.137.83"];
    
}

@end
