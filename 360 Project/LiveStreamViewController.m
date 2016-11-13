//
//  LiveStreamViewController.m
//  360 Project
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 12/12/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import "LiveStreamViewController.h"
#import "Global.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "LoadingView.h"
#import "PlayViewController.h"
#import "AppDelegate.h"

AppDelegate *app;
LoadingView *loadingView;
#import "Constant.h"

@interface LiveStreamViewController ()

@end
NSArray *jsonArray;
@implementation LiveStreamViewController
@synthesize headerImageName,navigationBarImage,strCategory;
- (void)viewDidLoad {
    
    //[Global setFontRecursively:self.view];

    self.txtEmail.delegate=self;
    [self.lblNoURL setHidden:YES];
    [self.imgNoURL setHidden:YES];
    [self.lblNoLiveUrl setHidden:YES];
    [self.btnplayIcon setHidden:YES];
    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    
   /* [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    */
     [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    
    NSValue* keyboardFrameBegin = [info valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameBegin CGRectValue];
    [self.liveScrollView setContentOffset:CGPointMake(0, keyboardFrame.size.height) animated:YES];

    
   }
- (void)keyboardWillHide:(NSNotification*)notification {

}
-(void)viewWillAppear:(BOOL)animated{
    
   // NSString *urlAsString = @"http://www.360mea.com/app/live_streaming";
   // NSURL *url = [[NSURL alloc] initWithString:urlAsString];
   // NSLog(@"%@", urlAsString);
    
   // [NSThread detachNewThreadSelector:@selector(loader) toTarget:self withObject:nil];
    
      [self.liveScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, 500)];
    
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.360mea.com/app/live_streaming"]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    
    if (error == nil)
    {
        // Parse data here
    }
    
    
//    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//        
//        if (error) {
//            [self.lblNoLiveUrl setHidden:NO];
//            [self.lblNoURL setHidden:NO];
//            [self.imgNoURL setHidden:NO];
//            [self.btnPLay setHidden:YES];
//            [self.btnplayIcon setHidden:YES];
//            [loadingView removeView];
//            //  [self.delegate fetchingGroupsFailedWithError:error];
//        } else {
       //     NSError *error = nil;
            jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if (error != nil) {
                [self.lblNoLiveUrl setHidden:NO];
                [self.lblNoURL setHidden:NO];
                [self.imgNoURL setHidden:NO];
                [self.btnPLay setHidden:YES];
                [self.btnplayIcon setHidden:YES];
                NSLog(@"Error parsing JSON.");
              //  [loadingView removeView];
            }
            else {
                
                @try {
                    
                    if ([[[jsonArray valueForKey:@"result"] valueForKey:@"success"] isEqualToString:@"true"]) {
                        NSLog(@"Array: %@", jsonArray);
                        [self.lblNoURL setHidden:YES];
                        [self.imgNoURL setHidden:YES];
                        [self.lblNoLiveUrl setHidden:YES];
                        [self.btnPLay setHidden:NO];
                        [self.btnplayIcon setHidden:NO];
                      //  [loadingView removeView];
                    }else{
                        [self.btnPLay setHidden:YES];
                        [self.btnplayIcon setHidden:YES];
                        [self.lblNoLiveUrl setHidden:NO];
                        [self.lblNoURL setHidden:NO];
                        [self.imgNoURL setHidden:NO];
                    }
                    
                }
                @catch (NSException *exception) {
                    //  NSLog(@"Array: %@", [exception userInfo]);
                  //  [loadingView removeView];
                }
                @finally {
                   // [loadingView removeView];
                }
            //    [loadingView removeView];
            }
            
    //    }
    //    [self setNeedsStatusBarAppearanceUpdate];
  //  }];
    
    
    self.navigationItem.titleView =[Global customNavigationImage:navigationBarImage];
    [Global backButton:self];
    self.txtEmail.text=@"";
    
   // self.liveScrollView.contentSize = CGSizeMake(self.view.frame.size.width , self.view.frame.size.height*0.15f);
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
}
- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL{

}
- (void)handleSingleTap:(UIGestureRecognizer *)singleTap {
    [self.liveScrollView setContentOffset:CGPointMake(0,0) animated:YES];
    [self.txtEmail resignFirstResponder];
   /// [loadingView removeView];
}
-(void)loader{
    loadingView = [LoadingView loadingViewInView:self.view withText:@"Please Wait...."];
}
-(void)playlive{
    
    [self performSegueWithIdentifier:@"videoPlayer" sender:nil];
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString: @"videoPlayer"]){
        // NSIndexPath *index=(NSIndexPath *)sender;
        app.downloadFlag=@"yes";
        NSMutableDictionary *liveStreamDic=[[NSMutableDictionary alloc]init];
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        
        PlayViewController *view=(PlayViewController *)segue.destinationViewController;
        NSString* stringURL =[[jsonArray valueForKey:@"result"] valueForKey:@"livestreaming_url"];
        view.videoPath=stringURL;
        view.flagPath=@"server";
        [liveStreamDic setValue:[[jsonArray valueForKey:@"result"] valueForKey:@"livestreaming_url"] forKey:@"video_link"];
        view.videoDict=liveStreamDic;
    }
}
-(BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    email=[ email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [emailTest evaluateWithObject:email];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}              // called when 'return' key pressed. return NO to ignore.


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
  NSLog(@"error of loading image ");
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
    NSLog(@"error of loading image view: %@",error);
    
}
- (IBAction)SearchVideo:(id)sender {
    [self performSegueWithIdentifier:@"searchSegue" sender:nil];

}

-(void)viewWillDisappear:(BOOL)animated{
    
}
- (IBAction)emailSubmit:(id)sender {
    
    if ([self validateEmailWithString:self.txtEmail.text]) {
        NSArray *toRecipents = [NSArray arrayWithObject:@"info@360mea.com"];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        
        [mc setToRecipients:toRecipents];
        [mc setSubject:@"Live Broadcast Notification."];
        [mc setMessageBody:[NSString stringWithFormat:@"My email is %@. Please keep me notified of the next live broadcast.",self.txtEmail.text ] isHTML:NO];
        
        [self presentViewController:mc animated:YES completion:NULL];
    }else{
        UIAlertView *alert11 = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:@"Email is not valid!" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
        [alert11 show];
        
    }
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
- (IBAction)playLive:(id)sender {
    
    [self playlive];
}
@end
