//
//  ShareViewController.m
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 11/7/15.
//  Copyright © 2015 Hitaishin Infotech. All rights reserved.
//

#import "ShareViewController.h"
#import "LoadingView.h"
#import "Global.h"
#import "Constant.h"
#import "LiveStreamViewController.h"
#import "VideoListViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>


@interface ShareViewController ()
{
 Boolean isTopBar;
}

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /// Set the Font & Color
    //[Global setFontRecursively:self.view];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionShareFacebook:(id)sender {
    //publish_actions
    
    //   NSString *strLink=  [[arrVideos objectAtIndex:btnTemp.tag] objectForKey:@"video_link"];
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://itunes.apple.com/us/app/360-mea-360-video-vr-player/id964118383?mt=8"];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog
        
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"", @"name",
                                       @"", @"caption",
                                       @"", @"description",
                                       [NSString stringWithFormat:@"https://itunes.apple.com/us/app/360-mea-360-video-vr-player/id964118383?mt=8"], @"link",
                                       @"", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User canceled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User canceled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
    
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}


- (IBAction)actionShareWhatspp:(id)sender {
    
//    //NSString * msg = @"https://itunes.apple.com/us/app/360-mea-360-video-vr-player/id964118383?mt=8";
//    NSString * msg = @"Install this free app, view and control exclusive amazing 360 degrees videos: ";
//    
//    //msg = [msg stringByAppendingString:@" Install this free app, view and control exclusive amazing 360 degrees videos"];
//
//    msg = [msg stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
//    msg = [msg stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
//    msg = [msg stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
//    msg = [msg stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
//    msg = [msg stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
//    msg = [msg stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
//    
//    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",msg];
//    NSURL * whatsappURL = [NSURL URLWithString:urlWhats];
//    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL])
//    {
//        [[UIApplication sharedApplication] openURL: whatsappURL];
//    }
//    else
//    {
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"WhatsApp not installed." message:@"Your device has no WhatsApp installed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//    }
    
    
    NSString * msg = @"Install this free app, view and control exclusive amazing 360 degrees videos. www.360mea.com";
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",msg];
    NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"WhatsApp not installed." message:@"Your device has no WhatsApp installed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL

                                               usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    
    self.documentationInteractionController =
    
    [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    
    self.documentationInteractionController.delegate = interactionDelegate;
    
    
    
    return self.documentationInteractionController;
    
}
- (IBAction)actionRateInStore:(id)sender {
    //964118383
    NSString * appId = @"964118383";
    NSString * theUrl = [NSString  stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software",appId];
    if ([[UIDevice currentDevice].systemVersion integerValue] > 6) theUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:theUrl]];
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

-(IBAction)search:(id)sender
{
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


@end
