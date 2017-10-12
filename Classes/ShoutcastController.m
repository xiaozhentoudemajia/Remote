//
//  ShoutcastController.m
//  AcaRemote
//
//  Created by ALI_MAC on 2017/9/21.
//
//

#import "ShoutcastController.h"

@interface ShoutcastController ()

@end

@implementation ShoutcastController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 1.创建webview，并设置大小，"20"为状态栏高度
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 20)];
    webView.scalesPageToFit=YES;
    webView.delegate = self;

    // 2.创建请求
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.shoutcast.com"]];

    // 3.加载网页
    [webView loadRequest:request];

    // 最后将webView添加到界面
    [self.view addSubview:webView];
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

@end
