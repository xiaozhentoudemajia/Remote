    //
//  PinCodeController.m
//  RemoteHD
//
//  Created by Fabrice Dewasmes on 20/05/10.
//  Copyright 2010 Fabrice Dewasmes. All rights reserved.
//

#import "PinCodeController.h"
#import "DDLog.h"
#import <arpa/inet.h>

#ifdef CONFIGURATION_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_WARN;
#endif

@interface PinCodeController ()
// 客户端主要使用的是iOS SDK里的NSNetServiceBrowser
@property(strong,nonatomic)NSNetServiceBrowser *serverBrowser;
// NSNetService在客户端用于解析
@property(nonatomic, strong)NSMutableArray *services;
@property(strong,nonatomic)NSMutableArray *serverNameArray;
@property(strong,nonatomic)NSMutableArray *serverIpArray;
@property (nonatomic, copy)NSMutableArray *serverImageArray;
@property(strong,nonatomic)UITableView *serverList;
@end

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
         DDLogError(@"Error starting HTTP Server: %@", error);
	 }

    // 初始化NSNetServiceBrowser
    NSNetServiceBrowser *aNetServiceBrowser = [[NSNetServiceBrowser alloc] init];
    if(!aNetServiceBrowser) {
        // The NSNetServiceBrowser couldn't be allocated and initialized.
        DDLogError(@"aNetServiceBrowser is nil");
    }
    // 指定代理
    aNetServiceBrowser.delegate = self;
    self.serverBrowser = aNetServiceBrowser;
    // 查找服务
    // 接着使用NSNetServiceBrowser实例的searchForServicesOfType方法查找服务，方法中可以指定需要查找的服务类型和查找的域
    [self.serverBrowser searchForServicesOfType:@"_touch-able._tcp" inDomain:@"local"];

    self.serverNameArray = [NSMutableArray array];
    self.serverIpArray = [NSMutableArray array];
    self.serverImageArray = [NSMutableArray array];
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
    DDLogVerbose(@"www serviceName=%@, guidStr=%@", serviceName, guidStr);
	[delegate didFinishWithPinCode:serviceName guid:guidStr];
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (IBAction) cancelButtonPressed:(id)sender{
    for (NSNetService* service in self.services) {
        [service stop];
    }
    [self.services removeAllObjects];

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

#pragma mark tableView delegate
// tableView每个分区的行数，可以为各个分区设置不同的行数，根据section的值判断即可
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DDLogVerbose(@"serverName conut=%lu",(unsigned long)[self.serverNameArray count]);
    return [self.serverNameArray count];
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
    cell.textLabel.text         = [self.serverNameArray objectAtIndex:indexPath.row];
    cell.imageView.image        = [self.serverImageArray objectAtIndex:indexPath.row];

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
    return @"Server List";
}

// 页脚
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"....";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK",nil];
    DDLogVerbose(@"select server... ip:%@, serverName:%@", [self.serverIpArray objectAtIndex:indexPath.row], [self.serverNameArray objectAtIndex:indexPath.row]);
    [self.delegate didFinishWithPinCode:[self.serverNameArray objectAtIndex:indexPath.row] guid:[self.serverIpArray objectAtIndex:indexPath.row]];
}

#pragma mark netServiceBrowser delegate
- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindService:(NSNetService*)service moreComing:(BOOL)moreComing
{
    DDLogVerbose(@"find server... name:%@", service.name);

    if (!_services) {
        _services = [[NSMutableArray alloc] init];
    }

    [_services addObject:service];
    service.delegate = self;
    // 设置解析超时时间
    [service resolveWithTimeout:2.0];

    [self.serverNameArray addObject:service.name];

    if (!moreComing) {
        // 初始化
        self.serverList=[[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-360) style:UITableViewStylePlain];
        // 设置数据源
        NSMutableArray *images  = [NSMutableArray array];
        for(NSInteger index = 0;index<[self.serverNameArray count];index++){
            UIImage *image      = [UIImage imageNamed:@"settings"];
            [images addObject:image];
        }
        self.serverImageArray = [[NSMutableArray alloc] initWithArray:images];
        self.serverList.delegate = self;
        self.serverList.dataSource = self;
        // 添加到当前View
        [self.view addSubview:self.serverList];
    }
}

// 解析服务成功
- (void)netServiceDidResolveAddress:(NSNetService *)netService {
    //    [_service addObject:sender];
    NSData *address = [netService.addresses firstObject];
    struct sockaddr_in *socketAddress = (struct sockaddr_in *) [address bytes];
    NSString *serverName = netService.name;
    NSString *hostName = [netService hostName];
    Byte *bytes = (Byte *)[[netService TXTRecordData] bytes];
    int8_t lenth = (int8_t)bytes[0];
    const void*textData = &bytes[1];
    NSString *serverIp = [NSString stringWithUTF8String:inet_ntoa(socketAddress->sin_addr)];
    DDLogVerbose(@"resolve server... ip:%@, hostName:%@, serverName:%@, text:%s, length:%d",serverIp,hostName,serverName,textData,lenth);
    [self.serverIpArray addObject:serverIp];
}

// 解析服务失败
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    DDLogError(@"didNotResolve");
}

@end
