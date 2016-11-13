
//  VideoListViewController.m
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "VideoListViewController.h"
#import "Global.h"
#import "VideoListCell.h"
#import "PlayViewController.h"
#import "NSString+NSString_Extended.h"
#import <Social/Social.h>
#import "LoadingView.h"
#import "VideoDownload.h"
#import "AppDelegate.h"
#import "NSString+HTML.h"
#import "MoreDetailViewController.h"
#import "Global.h"
#import "LiveStreamViewController.h"
#import "Constant.h"
#import "WebViewController.h"
#define kRealState @"1"
#define kEvent @"2"
#define kWedding @"2"
#define kOther @"2"
#define kDonation @"2"
#define kLiveBroadcast @"6"

AppDelegate *app;
@interface VideoListViewController ()<NSStreamDelegate>
{
    BOOL cancel;
}
@end
LoadingView *loadingView;

@implementation VideoListViewController
@synthesize managedObjectContext;
@synthesize dataResponse,arrVideos;
@synthesize headerImageName,navigationBarImage;
@synthesize strCategory,strSubcategory,strCity,strKeywords,localArrVideos;
@synthesize strPopular,strWhatsHot;

#pragma mark View Life Cycle


- (void)viewDidLoad {
    
    [super viewDidLoad];
    //[Global setFontRecursively:self.view];
    
    self.recordNotFound.text=@"No Videos Available";
     self.recordNotFound.textColor=[UIColor whiteColor];
     self.recordNotFound.textAlignment=NSTextAlignmentCenter;
     self.recordNotFound.font=[UIFont fontWithName:@"MyriadPro-Semibold" size:22.0f];
     self.recordNotFound.hidden = true;
    
     app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 30;
    NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationIsPortrait(UIDeviceOrientationPortrait)];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    self.navigationItem.titleView =[Global customNavigationImage:navigationBarImage];

}

-(void)viewWillAppear:(BOOL)animated{
    cancel=NO;
    NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIDeviceOrientationPortrait]
                                forKey:@"orientation"];
     self.recordNotFound.hidden = true;

    [Global backButton:self];
    [self listOfVideo];
  
    
    //self.headerImage.image=[UIImage imageNamed:headerImageName];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
}
-(void)viewDidAppear:(BOOL)animated{
    for (UIView *btn in [self.tabBarController.view subviews]) {
        if ([btn class]==[UIButton class]&&btn.tag>=1&&btn.tag<=4) {
            UIButton *button=(UIButton *)btn;
            button.hidden=NO;
            [btn setHidden:NO];
        }
        if(btn.tag==100){
            btn.hidden=NO;
        }
    }
    self.tabBarController.tabBar.hidden = NO;
    [self.view setNeedsDisplay];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Upper Bar Button Clicks
- (IBAction)actionWhatsHot:(id)sender {
    strWhatsHot = @"1";
    strPopular = @"";
    //[arrVideos removeAllObjects];
    //[self.collectionView reloadData];
    [self listOfVideo];
}
- (IBAction)actionPopular:(id)sender {
    strWhatsHot = @"";
    strPopular = @"1";
    //[arrVideos removeAllObjects];
    //[self.collectionView reloadData];
    [self listOfVideo];
}
- (IBAction)actionLiveStream:(id)sender
{
    [self performSegueWithIdentifier:@"liveStreaming" sender:nil];
}

#pragma mark Button Click

- (IBAction)searchClick:(id)sender {
    [self performSegueWithIdentifier:@"searchSegue" sender:self];
}

- (IBAction)postToWhatsApp:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    ////
    NSString * msg =[NSString stringWithFormat:@"http://www.360mea.com/video-detail?id=%@",[[arrVideos objectAtIndex:btn.tag] objectForKey:@"video_id"]];
    
    msg = [msg stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    msg = [msg stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    msg = [msg stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    msg = [msg stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    msg = [msg stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    msg = [msg stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",msg];
    NSURL * whatsappURL = [NSURL URLWithString:urlWhats];

    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"WhatsApp not installed." message:@"Your device has no WhatsApp installed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}
- (IBAction)postToTwitter:(id)sender {
    UIButton *btn=(UIButton *)sender;
//    NSDictionary *videoDict=[arrVideos objectAtIndex:btn.tag];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Click on the link to view an amazing 360 video"];
        [tweetSheet addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.360mea.com/video-detail?id=%@",[[arrVideos objectAtIndex:btn.tag] objectForKey:@"video_id"]]]];
        

        [tweetSheet addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[arrVideos objectAtIndex:btn.tag] objectForKey:@"video_thumbnail"]]]]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }else{
    
        [Global showAlertMessageWithOkButtonAndTitle:@"360 VUZ" andMessage:@"Please login in Twitter." ];
    }
}

- (IBAction)postToFacebook:(id)sender {
    //publish_actions
    UIButton *btnTemp=(UIButton *)sender;
    
//   NSString *strLink=  [[arrVideos objectAtIndex:btnTemp.tag] objectForKey:@"video_link"];
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    
    params.link = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.360mea.com/video-detail?id=%@",[[arrVideos objectAtIndex:btnTemp.tag] objectForKey:@"video_id"]]];
    
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
                                       [NSString stringWithFormat:@"http://www.360mea.com/video-detail?id=%@",[[arrVideos objectAtIndex:btnTemp.tag] objectForKey:@"video_id"]], @"link",
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








//- (IBAction)postToFacebook:(id)sender
//{
//    
//    // Check if the Facebook app is installed and we can present the share dialog
//    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
//    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
//    
//    
//    FBShareDialogParams *p = [[FBShareDialogParams alloc] init];
//    p.link = [NSURL URLWithString:@"http://developers.facebook.com/ios"];
//    BOOL canShareFB = [FBDialogs canPresentShareDialogWithParams:p];
//    
//    
//    // If the Facebook app is installed and we can present the share dialog
//    if ([FBDialogs canPresentShareDialogWithParams:params]) {
//        
//        // Present share dialog
//        [FBDialogs presentShareDialogWithLink:params.link
//                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                          if(error) {
//                                              // An error occurred, we need to handle the error
//                                              // See: https://developers.facebook.com/docs/ios/errors
//                                              NSLog(@"Error publishing story: %@", error.description);
//                                          } else {
//                                              // Success
//                                              NSLog(@"result %@", results);
//                                          }
//                                      }];
//        
//        // If the Facebook app is NOT installed and we can't present the share dialog
//    } else {
//        // FALLBACK: publish just a link using the Feed dialog
//        
//        // Put together the dialog parameters
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                       @"Sharing Tutorial", @"name",
//                                       @"Build great social apps and get more installs.", @"caption",
//                                       @"Allow your users to share stories on Facebook from your app using the iOS SDK.", @"description",
//                                       @"https://developers.facebook.com/docs/ios/share/", @"link",
//                                       @"http://i.imgur.com/g3Qc1HN.png", @"picture",
//                                       nil];
//        
//        // Show the feed dialog
//        [FBWebDialogs presentFeedDialogModallyWithSession:nil
//                                               parameters:params
//                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
//                                                      if (error) {
//                                                          // An error occurred, we need to handle the error
//                                                          // See: https://developers.facebook.com/docs/ios/errors
//                                                          NSLog(@"Error publishing story: %@", error.description);
//                                                      } else {
//                                                          if (result == FBWebDialogResultDialogNotCompleted) {
//                                                              // User canceled.
//                                                              NSLog(@"User cancelled.");
//                                                          } else {
//                                                              // Handle the publish feed callback
//                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
//                                                              
//                                                              if (![urlParams valueForKey:@"post_id"]) {
//                                                                  // User canceled.
//                                                                  NSLog(@"User cancelled.");
//                                                                  
//                                                              } else {
//                                                                  // User clicked the Share button
//                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
//                                                                  NSLog(@"result %@", result);
//                                                              }
//                                                          }
//                                                      }
//                                                  }];
//    }
//}








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


- (IBAction)videoDownload:(id)sender {
    //DOWNLOAD STARTED
    UIButton *btn=(UIButton *)sender;
    
     NSDictionary *videoDict=[arrVideos objectAtIndex:btn.tag];
    
    if ([self videosForCoreData:[videoDict valueForKey:@"video_id"]] ) {
        UIAlertView *alertShow = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:@"Video is either downloading or downloaded." delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
        [alertShow show];

    }else {
    
        [NSThread detachNewThreadSelector:@selector(callThread:) toTarget:self withObject:btn];
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.tabBarController setSelectedIndex:1];
}
-(void)callThread :(id)sender{
    
    UIButton *btn=(UIButton *)sender;
    VideoListCell *cell=(VideoListCell*)[btn superview];
    KAProgressLabel *progress=(KAProgressLabel*)[cell viewWithTag:1000];
    [progress setHidden:NO];
    NSDictionary *videoDict=[arrVideos objectAtIndex:btn.tag];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self downloadVideoAndSave:[videoDict objectForKey:@"video_link"] thumbNailURL:[videoDict objectForKey:@"video_thumbnail"] dic:videoDict :progress];
    
}

- (IBAction)moreDetailAction:(id)sender {
    
    UIButton *moreButton=(UIButton*)sender;
    NSIndexPath *index=[NSIndexPath indexPathWithIndex:moreButton.tag];
    [self performSegueWithIdentifier:@"moreDetail" sender:index];
}

-(void)downloadVideoAndSave :(NSString*)videoUrl thumbNailURL:(NSString *)strThumb dic:(NSDictionary *)videoDic :(KAProgressLabel *)lblProgress
{
  __block NSManagedObjectContext *managedObjectContextNew;
    
   
    managedObjectContextNew=app.managedObjectContext;
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:strThumb] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
     NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/%ld.jpg", documentsDirectory,(long)[user integerForKey:@"fileName"]];
    
   
   // NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"1.mp4"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
    operation.outputStream.delegate = self;
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        [lblProgress setProgress:((float)totalBytesRead / totalBytesExpectedToRead)];
        
        NSLog(@"downloadComplete.... %f",(float)totalBytesRead / totalBytesExpectedToRead);
    }];
  
    [operation setCompletionBlock:^{
        NSLog(@"downloadComplete! %@",videoDic);
                //app.downloadFlag=@"yes";
                NSString  *filePath = [NSString stringWithFormat:@"%ld.jpg", (long)[user integerForKey:@"fileName"]];
        
                        VideoDownload *video = (VideoDownload *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoDownload" inManagedObjectContext:managedObjectContextNew];
                        
                        [video setCategory:[Global getStringValue:[videoDic objectForKey:@"category_name"]]];
                        [video setVideoCity:[Global getStringValue:[videoDic objectForKey:@"video_city"]]];
                        [video setSiteUrl:[Global getStringValue:[videoDic objectForKey:@"website_link"]]];
                        [video setVideoFileLink:[NSString stringWithFormat:@"NA##%@",videoUrl]];
                        [video setVideoId:[NSNumber numberWithInt:[[videoDic objectForKey:@"video_id"] intValue]]];
        
                        if ([user integerForKey:@"fileName"]==nil) {
                            [user setInteger:0 forKey:@"fileName"];
                        }
                        [video setVideoLink:videoUrl];
                        [video setVideoTitle:[Global getStringValue:[videoDic objectForKey:@"video_title"]]];
                        [video setUploadDate:[Global getStringValue:[videoDic objectForKey:@"upload_date"]]];
                        if([videoDic objectForKey:@"meta_data"] != (id)[NSNull null]){
                            [video setMetaData:[Global getStringValue:[videoDic objectForKey:@"meta_data"]]];
                        }
                        [video setVideoThumbnail:filePath];
                        [video setSubcategory:[Global getStringValue:[videoDic objectForKey:@"subcategory_name"]]];
                        [video setVideoDescription:[Global getStringValue:[videoDic objectForKey:@"video_description"]]];
                        [video setVideoType:[Global getStringValue:[videoDic objectForKey:@"videotype"]]];
        
        
                         // Commit the change.
                        NSError *error;
                        if (![managedObjectContextNew save:&error]) {
                            // Handle the error.
                        }
                        [user setInteger:[user integerForKey:@"fileName"]+1 forKey:@"fileName"];
        
        [self performSelectorOnMainThread:@selector(showAlertWithTitle:)
                               withObject:@"Download Started. See on download tab."
                            waitUntilDone:YES];
                    NSLog(@"write successfull image");
        [self addAttributeToAllFolder];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
        });
          [lblProgress setHidden:YES];
    }];
    
    
  }
#pragma mark Prevent from iCloud backup.
- (void)showAlertWithTitle:(NSString *)t
{
    UIAlertView *alert11 = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:t delegate:self cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
    [alert11 show];
}
- (void)addAttributeToAllFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];
    
    for (int i =0; i < [dirContents count]; i++) {
        NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",documentsPath,[dirContents objectAtIndex:i]]];
        //this is your method (addSkipBackupAttributeToItemAtURL:)
        if ([self addSkipBackupAttributeToItemAtURL:url]) {
            NSLog(@"success! could add do not backup attribute to folder");
        }
    }
}
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL

{
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    
    
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                    
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    if(!success){
        
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        
    }
    
    return success;
    
}

#pragma mark Collection View Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    //-55 is a tweak value to remove top spacing
    return CGSizeMake(1, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if([Global isIpad]){
        return CGSizeMake(self.view.frame.size.width-20, 205);
    }else{
        return CGSizeMake(self.view.frame.size.width-20, 130);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, -5, 10);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
   // [self.collectionView.collectionViewLayout invalidateLayout];
    
    return [arrVideos count];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    VideoListCell *cell;
    cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"videoListCell" forIndexPath:indexPath];
    
    NSDictionary *videoDict=[arrVideos objectAtIndex:indexPath.section];
    
  //  NSLog(@"Output radians as degrees: 360%c", (char) 0x00B0);
    
    NSString *str=[videoDict objectForKey:@"video_title"];
    str=[str stringByReplacingOccurrencesOfString:@"0x00B0" withString:[NSString stringWithFormat:@"%c",(char) 0x00B0]];
    
    cell.lblVideo.text=str;//[videoDict objectForKey:@"video_
    cell.lblCategory.text=[videoDict objectForKey:@"category_name"];
    cell.lblCountry.text=[videoDict objectForKey:@"video_city"];
    cell.lblDetails.text=[videoDict objectForKey:@"video_description"];
    cell.lblLink.text=[videoDict objectForKey:@"video_link"];
    cell.btnDownload.tag=indexPath.section;
    cell.moreDetail.tag=indexPath.section;
    cell.btnTwitter.tag=indexPath.section;
    cell.btnFacebook.tag=indexPath.section;
    cell.btnWhatsApp.tag=indexPath.section;
    /*cell.imgVideo.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleTopMargin;
     */
    cell.contentView.hidden=NO;
  //  cell.imgVideo.showActivityIndicator=YES;
    cell.downloadSlider.hidden=YES;
    if (selectedIndex.section==indexPath.section && selectedIndex !=nil) {
        cell.downloadSlider.hidden=NO;
    }
//    else{
//    cell.downloadSlider.hidden=YES;
//    }
    
   // NSURL *url = [NSURL URLWithString:[videoDict objectForKey:@"video_thumbnail"]];
   
    NSURL *url = [NSURL URLWithString:[videoDict objectForKey:@"video_thumbnail"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@"videoThumb.jpg"];
    __weak VideoListCell *weakCell = cell;
   [cell.imgVideo setImageWithURLRequest:request
                                     placeholderImage:placeholderImage
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  
                                                  weakCell.imgVideo.image = image;
                                                  [weakCell setNeedsLayout];
                                                  
                                              } failure:nil];

   [cell.imgVideo setNeedsDisplay];
    
  
    cell.imgVideo.contentMode=UIViewContentModeScaleToFill;
    
    cell.downloadSlider.tag=indexPath.section;
    cell.tag=indexPath.section;
    cell.lblProgress.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [label setText:[NSString stringWithFormat:@"%.0f%%", (progress*100)]];
        });
    };
    //[cell.lblProgress setHidden:YES];
    [cell.lblProgress setBackBorderWidth: 4.0];
    [cell.lblProgress setFrontBorderWidth: 2.5];
    [cell.lblProgress setColorTable: @{
                                  NSStringFromProgressLabelColorTableKey(ProgressLabelTrackColor):[UIColor redColor],
                                  NSStringFromProgressLabelColorTableKey(ProgressLabelProgressColor):[UIColor greenColor]
                                  }];
    
    return cell;
    
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  //  self.progValue =0.0f;
    selectedCollection=(VideoListCell*)[collectionView cellForItemAtIndexPath:indexPath];
    //selectedCollection.downloadSlider.hidden=NO;
    selectedIndex=indexPath;
    selectedColl=collectionView;
    NSDictionary *videoDict=[arrVideos objectAtIndex:indexPath.section];
    if ([[videoDict objectForKey:@"videotype"] isEqualToString:@"html"])
    {
        [self performSegueWithIdentifier:@"webView" sender:selectedIndex];
    }else{
        //video_type
        [self performSegueWithIdentifier:@"videoPlayer" sender:selectedIndex];
    }
  // [self longMethod:indexPath];
  //  [NSThread detachNewThreadSelector:@selector(longMethod:) toTarget:self withObject:indexPath];
   
}

-(void)longMethod:(NSIndexPath *) indexPath {
   // 
    UIProgressView *activeProgressView = [(VideoListCell *)[selectedColl cellForItemAtIndexPath:indexPath] downloadSlider];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        float x = 0;
        for (int i=0; i < 25000000; i++) {
            x = i * 3.14;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           // self.progValue +=.01;
            activeProgressView.progress +=.01;
          //  activeProgressView.progress = self.progValue;
            if (activeProgressView.progress < .15){
                
                [self longMethod:indexPath];
            }else{
               
                selectedCollection = nil;
                activeProgressView.progress =0.0f;
                activeProgressView.progress = self.progValue;
                [selectedColl reloadSections:[[NSIndexSet alloc] initWithIndex:selectedIndex.section]]; NSLog(@"done");
                if (cancel!=YES) {
                    [self performSegueWithIdentifier:@"videoPlayer" sender:selectedIndex];
                }
                
            }
        });
    });
}
- (void)updateProgress:(NSTimer *)timer
{
    UIProgressView *videoProgress=(UIProgressView*)[selectedCollection viewWithTag:selectedIndex.section];
    static int count =0; count++;
    
    if (count <=20)
    {
        // self.progressLabel.text = [NSString stringWithFormat:@"%d %%",count*10];
        dispatch_async(dispatch_get_main_queue(), ^{
            videoProgress.progress = (float)count/20.0f;
        });
        
    } else
    {
        [self.myTimer invalidate];
        self.myTimer = nil;
        count=0;
        
        [self performSegueWithIdentifier:@"videoPlayer" sender:selectedIndex];
    }

    
   }
#pragma mark Get Video
-(BOOL)videosForCoreData :(NSString*)videoID{
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    managedObjectContext=app.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VideoDownload" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    // Order the events by creation date, most recent first.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoTitle" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    // Execute the fetch -- create a mutable copy of the result.
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
    }
    BOOL exist=NO;
    [self setLocalArrVideos:mutableFetchResults];
    for (VideoDownload *video in mutableFetchResults) {
  
        NSString * idd=@"";
        idd=[idd stringByAppendingString:[NSString stringWithFormat:@"%@",video.videoId]];
        if ([idd isEqualToString:videoID]) {
            exist= YES;
        
        }else{
            exist= NO;
        }
        
    }
    return exist;
    
}

-(void)listOfVideo{
    
    self.dataResponse=[NSMutableData data];
    
    NSMutableDictionary *dictPost=[NSMutableDictionary new];

    if (strCategory!=nil ) {
        [dictPost setObject:strCategory forKey:@"category_id"];
    }else{
        [dictPost setObject:@"" forKey:@"category_id"];
    }
    
    if (strSubcategory!=nil ) {
            [dictPost setObject:strSubcategory forKey:@"subcategory_id"];
    }else{
        [dictPost setObject:@"" forKey:@"subcategory_id"];
    }
    
    if (strKeywords!=nil ) {
        [dictPost setObject:strKeywords forKey:@"keyword"];
    }else{
        [dictPost setObject:@"" forKey:@"keyword"];
    }
    
    if (strCity!=nil ) {
        [dictPost setObject:strCity forKey:@"city"];
    }else{
        [dictPost setObject:@"" forKey:@"city"];
    }
    /// What's Hot
    if (strWhatsHot!=nil ) {
        [dictPost setObject:strWhatsHot forKey:@"whatshot"];
    }else{
        [dictPost setObject:@"" forKey:@"whatshot"];
    }
    ///  Popular
    if (strPopular!=nil ) {
        [dictPost setObject:strPopular forKey:@"popular"];
    }else{
        [dictPost setObject:@"" forKey:@"popular"];
    }
    
    [dictPost setValue:@"iphone" forKey:@"model"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([[prefs stringForKey:@"deviceToken"] length]>0) {
        [dictPost setObject:[prefs stringForKey:@"deviceToken"] forKey:@"devicetoken"];
    }else{
        [dictPost setObject:@"NA" forKey:@"devicetoken"];
    }
        //// Login ID
        [dictPost setValue:[prefs valueForKey:@"userID"] forKey:@"id"];
     NSLog(@"Dict%@",dictPost);
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictPost
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSData *jsonDataNew = [jsonString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

        //NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@app_category_video",Default_URL]];
        NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@video_list.php",Default_NEW_SERVER_URL]];
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonDataNew length]];
        
        
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:jsonDataNew];
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
    
    NSMutableDictionary *dict=[[[NSJSONSerialization JSONObjectWithData:self.dataResponse options:0 error:nil]valueForKey:@"result"]  mutableCopy];
    arrVideos = [[NSMutableArray alloc] init];
    arrVideos =[dict objectForKey:@"videoslist"];
    NSLog(@"%@",arrVideos);
    
    if (arrVideos.count>0) {
         self.recordNotFound.hidden = true;
        [self.collectionView reloadData];
    }else{
         self.recordNotFound.hidden = false;
    }
    
    
   }


#pragma mark Segue Delegate
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (cancel==YES) {
        return NO;
    }else{
        return YES;
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if([segue.identifier isEqualToString: @"videoPlayer"]){
    NSIndexPath *index=(NSIndexPath *)sender;
        app.downloadFlag=@"yes";
    NSNumber *value1 = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
   [[UIDevice currentDevice] setValue:value1 forKey:@"orientation"];

    PlayViewController *view=(PlayViewController *)segue.destinationViewController;
    NSString* stringURL =[[arrVideos objectAtIndex:index.section] objectForKey:@"video_link"];
    view.videoPath=stringURL;
    view.flagPath=@"server";
    view.videoDict=[arrVideos objectAtIndex:index.section];

    }
    else if([segue.identifier isEqualToString: @"liveStreaming"]){
        /// Live Stream View
        LiveStreamViewController *liveView=(LiveStreamViewController *)segue.destinationViewController;
        liveView.strCategory=kLiveBroadcast;
        //liveView.navigationBarImage=@"livebrodcast.png";
    }
    else if([segue.identifier isEqualToString: @"searchSegue"]){
    
    }
    else if([segue.identifier isEqualToString: @"webView"]){
        NSIndexPath *index=(NSIndexPath *)sender;
        WebViewController *view=(WebViewController *)segue.destinationViewController;
        NSString* stringURL =[[arrVideos objectAtIndex:index.section] objectForKey:@"video_link"];
        view.strURL=stringURL;
    }
    else{
        NSIndexPath *index=(NSIndexPath *)sender;
        
        //NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
       // [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        
        MoreDetailViewController *view=(MoreDetailViewController *)segue.destinationViewController;
        view.seletedRecord=[arrVideos objectAtIndex:index.section];
        view.flag=@"list";


    }
}

#pragma mark Orientation
-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)prefersStatusBarHidden{
    return NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    selectedIndex=nil;
    cancel=YES;
   // [operation pause];
   // operation =nil;
//    
//    [[self navigationController] setNavigationBarHidden:NO animated:YES];
//    self.tabBarController.tabBar.hidden = NO;
    
//    NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}
@end
