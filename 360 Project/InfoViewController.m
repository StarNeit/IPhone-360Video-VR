//  InforViewController.m
//  360 Project
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 12/6/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import "InfoViewController.h"
#import "Global.h"
#import "LoadingView.h"
@interface InfoViewController ()

@end

#import "Constant.h"

LoadingView *loadingView;
@implementation InfoViewController
@synthesize videoView,dataResponse;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationItem.titleView =[Global customNavigationImage:@"info.png"];
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
   // [self infoCall];
    
    UIDevice *device = [UIDevice currentDevice];					//Get the device object
    [device beginGeneratingDeviceOrientationNotifications];			//Tell it to start monitoring the
    
    for (id subview in videoView.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
    videoView.opaque = NO;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [self infoCall];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
}
- (void)embedYouTube:(NSString*)url frame:(CGRect)frame

{
    
    NSString* embedHTML = @"<html><head><style type=\"text/css\"> \"body {background-color: transparent;color: white;}\"</style></head><body style=\"margin:0\"><embed id=\"yt\" src=\"%@?rel=0\" type=\"application/x-shockwave-flash\"width=\"%0.0f\" height=\"%0.0f\" allowfullscreen=\"true\"></embed></body></html>";
   
    NSString* html = [NSString stringWithFormat:embedHTML, url, videoView.frame.size.width, videoView.frame.size.height];
    
    videoView.allowsInlineMediaPlayback = NO;
    
    [videoView loadHTMLString:html baseURL:nil];
    
}
#pragma mark - UIWebView Delegates

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}


- (IBAction)searchClick:(id)sender {
    
    [self performSegueWithIdentifier:@"searchSegue" sender:nil];
}
#pragma mark Info Call

-(void)infoCall{
    
    self.dataResponse=[NSMutableData data];
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@app_information",Default_URL]];
    NSString *postLength = [NSString stringWithFormat:@"%d", 0];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[NSData data ]];
    if ([Global isReachable]) {
        loadingView = [LoadingView loadingViewInView:self.view withText:@"Please Wait...."];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }else{
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"Internet is not connected!!"];
    }
    self.dataResponse=[NSMutableData data];
}

#pragma mark Connetion Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse %s##### response  %@",__FUNCTION__,response);
    [self.dataResponse setLength:0];
    //[resData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.dataResponse appendData:data];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    @try {
        NSLog(@"didFailWithError %s   --- %@ ",__FUNCTION__,[error description]);
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:[(NSString*)[error userInfo] valueForKey:@"NSLocalizedDescription"]];
        [loadingView removeView];
    }
    @catch (NSException *exception) {
        NSLog(@"didFailWithError %s   --- %@ ",__FUNCTION__,exception);
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:[exception reason]];
        [loadingView removeView];
    }
    @finally {
        
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading %s",__FUNCTION__);
    [loadingView removeView];
    
    NSMutableDictionary *dict=[[[NSJSONSerialization JSONObjectWithData:self.dataResponse options:0 error:nil]valueForKey:@"result"]  mutableCopy];
    [loadingView removeView];
    [self embedYouTube :[dict objectForKey:@"info_video_link"]  frame:self.view.frame];
    self.txtInfoView.text=[dict objectForKey:@"info_description"];
    
     self.lblTitle.text=[dict objectForKey:@"info_title"];
    
    // [videoView sizeToFit];
    
}

#pragma mark Orientation
-(BOOL)prefersStatusBarHidden{
    return NO;
}

#pragma mark Orientation changed
//-(void)orientationChanged:(id)sender{
//  //  [[self.view viewWithTag:100]removeFromSuperview];
//    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
//    {
//        NSMutableDictionary *dict=[[[NSJSONSerialization JSONObjectWithData:self.dataResponse options:0 error:nil]valueForKey:@"result"]  mutableCopy];
//        [loadingView removeView];
//        [self embedYouTube :[dict objectForKey:@"info_video_link"]  frame:self.view.frame];
//        
//        //[self infoCall];
//               // self.imgBorder.frame = CGRectMake(self.imgBorder.frame.origin.x, self.imgBorder.frame.origin.y, self.imgBorder.frame.size.width,200);
//        //        topBorder.tag=100;
//        //        topBorder.image=[UIImage imageNamed:@"logoborder.jpg"];
//        //        [self.view addSubview:topBorder];
//    }
//    else{
//                self.imgBorder.frame = CGRectMake(self.imgBorder.frame.origin.x, self.imgBorder.frame.origin.y, self.imgBorder.frame.size.width,500);
//        
//        //        topBorder.image=[UIImage imageNamed:@"logoborder.jpg"];
//        //        topBorder.tag=100;
//        //        [self.view addSubview:topBorder];
//        NSMutableDictionary *dict=[[[NSJSONSerialization JSONObjectWithData:self.dataResponse options:0 error:nil]valueForKey:@"result"]  mutableCopy];
//        [loadingView removeView];
//        [self embedYouTube :[dict objectForKey:@"info_video_link"]  frame:self.view.frame];
//        //  [self infoCall];
//    }
//}

@end