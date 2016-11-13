//
//  ContactsViewController.m
//  360 Project
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 12/7/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import "ContactsViewController.h"
#import "LoadingView.h"
#import "Global.h"
#import <Social/Social.h>
#import "LiveStreamViewController.h"
#import "VideoListViewController.h"
#import "Constant.h"

#import "FBConnect.h"
#import "FacebookLikeView.h"


LoadingView *loadingView;
@interface ContactsViewController ()<FacebookLikeViewDelegate, FBSessionDelegate>
{
    Boolean isTopBar;
}
@property (nonatomic, strong) Facebook *facebook;
@property (nonatomic, strong) IBOutlet FacebookLikeView *facebookLikeView;

@end
NSMutableDictionary *dict;
@implementation ContactsViewController
@synthesize dataResponse;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {//158575400878173
        self.facebook = [[Facebook alloc] initWithAppId:@"893530320657596" andDelegate:self];
    }
    return self;
}


- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    //[Global setFontRecursively:self.view];

    [self contact];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];	//Get the notification centre for the app
    UIDevice *device = [UIDevice currentDevice];					//Get the device object
    [device beginGeneratingDeviceOrientationNotifications];
    [nc addObserver:self											//Add yourself as an observer
           selector:@selector(orientationChanged:)
               name:UIDeviceOrientationDidChangeNotification
             object:device];
    // Do any additional setup after loading the view.
}


#pragma mark FBSessionDelegate

- (void)fbDidLogin {
    self.facebookLikeView.alpha = 1;
    [self.facebookLikeView load];
}

- (void)fbDidLogout {
    self.facebookLikeView.alpha = 1;
    [self.facebookLikeView load];
}


-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    //self.navigationItem.titleView =[Global customNavigationImage:@"contact.png"];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIDeviceOrientationPortrait]
                                forKey:@"orientation"];

    if (self.view.bounds.size.height==480/*||([[UIDevice currentDevice].model isEqualToString:@"iPhone"])||([[UIDevice currentDevice].model isEqualToString:@"iPhone Simulator"])*/) {
        CGRect frm=self.contactSupportView.frame;
        self.contactSupportView.frame=CGRectMake(frm.origin.x, frm.origin.y+30, frm.size.width,frm.size.height);
        //self.moreDetailSupportView.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)contact{

    
    self.dataResponse=[NSMutableData data];

    
    //NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@contact_information",Default_URL]];
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@contact_information.php",Default_Video_URL]];

    //http://192.168.2.2:8088/360_wp/api/contact_information.php
    
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
    
    
    dict=[[[NSJSONSerialization JSONObjectWithData:self.dataResponse options:0 error:nil]valueForKey:@"result"]  mutableCopy];
    
    self.facebookLikeView.href = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",[dict objectForKey:@"facebook"]]];
    self.facebookLikeView.layout = @"button_count";
    self.facebookLikeView.showFaces = NO;
    self.facebookLikeView.alpha = 0;
    [self.facebookLikeView load];

    [self.btnPhone setTitle:[dict objectForKey:@"phone"] forState:UIControlStateNormal];
    //[self.btnFacebook setTitle:[dict objectForKey:@"facebook"] forState:UIControlStateNormal];
    //[self.btnTwitter setTitle:[dict objectForKey:@"twitter"] forState:UIControlStateNormal];
    [self.btnWebsite setTitle:[dict objectForKey:@"website"] forState:UIControlStateNormal];
    //[self.btnEmail setTitle:[dict objectForKey:@"email"] forState:UIControlStateNormal];
    
}

#pragma mark - Upper Bar Button Clicks
- (IBAction)actionWhatsHot:(id)sender {
    isTopBar=1;
    [self performSegueWithIdentifier:@"videoList" sender:nil];
    
}
- (IBAction)actionPopular:(id)sender {
    isTopBar=2;
    [self performSegueWithIdentifier:@"videoList" sender:nil];
}

- (IBAction)actionLiveStream:(id)sender
{
    [self performSegueWithIdentifier:@"liveStreaming" sender:nil];
    
}

- (IBAction)searchVideo:(id)sender {
    
    [self performSegueWithIdentifier:@"searchSegue" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if (([segue.identifier isEqualToString:@"liveStreaming"]))
    {
        /// Live Stream View
        LiveStreamViewController *liveView=(LiveStreamViewController *)segue.destinationViewController;
        liveView.strCategory=@"18";
        
    }
    else if ([segue.identifier isEqualToString:@"searchSegue"]) {
        
    }else{
        VideoListViewController *view=(VideoListViewController *)segue.destinationViewController;
        if (isTopBar==1) {
            //// What's Hot
            view.strWhatsHot = @"1";
        }
        else if (isTopBar==2){
            /// Popular
            view.strPopular = @"1";
        }
    }
    
}

#pragma mark FacebookLikeViewDelegate

- (void)facebookLikeViewRequiresLogin:(FacebookLikeView *)aFacebookLikeView {
    [self.facebook authorize:[NSArray array]];
}

- (void)facebookLikeViewDidRender:(FacebookLikeView *)aFacebookLikeView {
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDelay:0.5];
    self.facebookLikeView.alpha = 1;
    [UIView commitAnimations];
}

- (void)facebookLikeViewDidLike:(FacebookLikeView *)aFacebookLikeView {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Liked"
                                                    message:@"You liked 360 VUZ. Thanks!"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)facebookLikeViewDidUnlike:(FacebookLikeView *)aFacebookLikeView {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unliked"
                                                    message:@"You unliked 360 VUZ. Where's the love?"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (IBAction)websiteClick:(id)sender {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",[dict objectForKey:@"website"]]];
    
   // NSURL *url = [NSURL URLWithString:@"http://google.com"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        
    }else{
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"URL can not open."];
    }
}

- (IBAction)facebookClick:(id)sender {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",[dict objectForKey:@"facebook"]]];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        
    }else{
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"URL can not open."];
    }

}

- (IBAction)twitterClick:(id)sender {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",[dict objectForKey:@"twitter"]]];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        
    }else{
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"URL can not open."];
    }
}

- (IBAction)emailClick:(id)sender {
    NSArray *toRecipents = [NSArray arrayWithObject:[dict objectForKey:@"email"]];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setToRecipients:toRecipents];
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)phoneClick:(id)sender {
    
    NSString *phoneNumber = [@"tel://" stringByAppendingString:[dict objectForKey:@"phone"]];
    NSURL *url = [NSURL URLWithString:phoneNumber];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        
    }else{
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"Phone can not open."];
    }

}

- (IBAction)facebookShare:(id)sender {
     if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
     {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller setInitialText:@""];
        [controller addURL:[NSURL URLWithString:@""]];
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
     else
    {
        [Global showAlertMessageWithOkButtonAndTitle:@"360 VUZ" andMessage:@"Please login in Facebook." ];
    }

}

- (IBAction)twitterShare:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Click on the link to view an amazing 360 video"];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        [Global showAlertMessageWithOkButtonAndTitle:@"360 VUZ" andMessage:@"Please login in Twitter." ];
    }

}


#pragma mark Orientation
-(BOOL)prefersStatusBarHidden{
    return NO;
}

#pragma mark Orientation changed
-(void)orientationChanged:(id)sender{
   // [[self.view viewWithTag:100]removeFromSuperview];
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
//        NSMutableDictionary *dict=[[[NSJSONSerialization JSONObjectWithData:self.dataResponse options:0 error:nil]valueForKey:@"result"]  mutableCopy];
//        [loadingView removeView];
//        [self embedYouTube :[dict objectForKey:@"info_video_link"]  frame:self.view.frame];
//        
        //[self infoCall];
        // self.imgBorder.frame = CGRectMake(self.imgBorder.frame.origin.x, self.imgBorder.frame.origin.y, self.imgBorder.frame.size.width,200);
        //        topBorder.tag=100;
        //        topBorder.image=[UIImage imageNamed:@"logoborder.jpg"];
        //        [self.view addSubview:topBorder];
        
            self.borderImage.frame=CGRectMake(self.borderImage.frame.origin.x, self.borderImage.frame.origin.y, self.borderImage.frame.size.width, self.borderImage.frame.size.height-110);
        
    }
    else{
       self.borderImage.frame=CGRectMake(self.borderImage.frame.origin.x, self.borderImage.frame.origin.y, self.borderImage.frame.size.width, self.borderImage.frame.size.height+110);
        
        //        topBorder.image=[UIImage imageNamed:@"logoborder.jpg"];
        //        topBorder.tag=100;
        //        [self.view addSubview:topBorder];
//        NSMutableDictionary *dict=[[[NSJSONSerialization JSONObjectWithData:self.dataResponse options:0 error:nil]valueForKey:@"result"]  mutableCopy];
//        [loadingView removeView];
//        [self embedYouTube :[dict objectForKey:@"info_video_link"]  frame:self.view.frame];
        //  [self infoCall];
    }
}

@end
