//
//  WebViewController.m
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 11/8/15.
//  Copyright © 2015 Hitaishin Infotech. All rights reserved.
//

#import "WebViewController.h"
#import "Global.h"
@interface WebViewController ()

@end

@implementation WebViewController
@synthesize webView,strURL;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Global backButton:self];
    
    [webView.layer setMasksToBounds:YES];
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [webView loadRequest:req];

}



-(void)webViewDidFinishLoad:(UIWebView *)webView {
    // MBProgress Bar Stop
    //NSLog(@"finish");
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    // [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowMBProgressBar object:nil];
    //NSLog(@"Start");
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    //NSLog(@"fail");
    // MBProgress Bar Stop
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //NSLog(@"shouldStartLoadWithRequest Loading: %@", [request URL]);
    //[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowMBProgressBar object:nil];
    return TRUE;
    
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


-(IBAction)backPushed:(id)sender{
    
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
