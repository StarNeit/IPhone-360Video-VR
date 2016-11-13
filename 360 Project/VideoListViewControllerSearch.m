
//  VideoListViewController.m
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//
#import <FacebookSDK/FacebookSDK.h>
#import "VideoListViewControllerSearch.h"
#import "VideoListViewController.h"
#import "Global.h"
#import "VideoListCell.h"
#import "PlayViewController.h"
#import "NSString+NSString_Extended.h"
#import <Social/Social.h>
#import "LoadingView.h"
#import "VideoDownload.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "MoreDetailViewController.h"
#import "AFNetworking.h"
#import "Constant.h"
#import "LiveStreamViewController.h"
#import "WebViewController.h"

#define kRealState @"1"
#define kEvent @"2"
#define kWedding @"2"
#define kOther @"2"
#define kDonation @"2"
#define kLiveBroadcast @"6"


@interface VideoListViewControllerSearch ()<NSStreamDelegate>
{
    Boolean isTopBar;
}
@end
LoadingView *loadingView;
@implementation VideoListViewControllerSearch
@synthesize dataResponse,arrVideos;
@synthesize headerImageName,navigationBarImage,managedObjectContext;
@synthesize strCategory,strSubcategory,strCity,strKeywords,dicResponse;
@synthesize localArrVideos;
#pragma mark View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //[Global setFontRecursively:self.view];

    //self.navigationItem.titleView =[Global customNavigationImage:navigationBarImage];
    
    arrVideos =[dicResponse objectForKey:@"videoslist"];
              //  [self.collectionView reloadData];
    if (![arrVideos count]==0 && arrVideos.count>0) {
        [self.collectionView reloadData];
    }else{
        UILabel *recordNotFound=[[UILabel alloc]initWithFrame:CGRectMake(60, 200, 200,60)];
        
        recordNotFound.text=@"No Video Available";
        recordNotFound.textColor=[UIColor whiteColor];
        recordNotFound.textAlignment=NSTextAlignmentCenter;
        recordNotFound.font=[UIFont fontWithName:@"MyriadPro-Semibold" size:22.0f];
        
        [self.view addSubview:recordNotFound];
    }

}

-(void)viewWillAppear:(BOOL)animated{

    [Global backButton:self];
   // [self listOfVideo];
   AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    managedObjectContext=app.managedObjectContext;
    

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.tabBarController.tabBar.hidden = NO;
    
    for (UIView *btn in [self.tabBarController.view subviews]) {
        if ([btn class]==[UIButton class]&&btn.tag>=1&&btn.tag<=4) {
            UIButton *button=(UIButton *)btn;
            button.hidden=NO;
        }
        if(btn.tag==100){
            btn.hidden=NO;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button Click

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

    ///
}

- (IBAction)postToTwitter:(id)sender {
    UIButton *btn=(UIButton *)sender;
    NSDictionary *videoDict=[arrVideos objectAtIndex:btn.tag];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];

        [tweetSheet setInitialText:@"Click on the link to view an amazing 360 video"];
        [tweetSheet addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.360mea.com/video-detail?id=%@",[videoDict objectForKey:@"video_id"]]]];
        
        
        [tweetSheet addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[videoDict objectForKey:@"video_thumbnail"]]]]];
        
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }else{
    
        [Global showAlertMessageWithOkButtonAndTitle:@"360 VUZ" andMessage:@"Please login in Twitter." ];
    }
}

- (IBAction)postToFacebook:(id)sender {
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
    
    UIButton *btn=(UIButton *)sender;
    
    NSDictionary *videoDict=[arrVideos objectAtIndex:btn.tag];
    
    if ([self videosForCoreData:[videoDict valueForKey:@"video_id"]] ) {
        UIAlertView *alert11 = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:@"Video is either downloading or downloaded." delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
        [alert11 show];
        
    }else {
        
        [NSThread detachNewThreadSelector:@selector(callThread:) toTarget:self withObject:btn];
    }
    
//
//    UIButton *btn=(UIButton *)sender;
//    NSDictionary *videoDict=[arrVideos objectAtIndex:btn.tag];
//    VideoDownload *video = (VideoDownload *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoDownload" inManagedObjectContext:managedObjectContext];
//        
//    [video setCategory:[videoDict objectForKey:@"category_name"]];
//    [video setVideoCity:[videoDict objectForKey:@"video_city"]];
//    [video setVideoId:[NSNumber numberWithInt:[[videoDict objectForKey:@"video_id"] integerValue]]];
//
//    
//    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
//    
//    [user setInteger:[user integerForKey:@"fileName"]+1 forKey:@"fileName"];
//    
//
//    if ([user integerForKey:@"fileName"]==nil) {
//            [user setInteger:0 forKey:@"fileName"];
//    }
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    
//    NSString  *filePath = [NSString stringWithFormat:@"%@/%d.mp4", documentsDirectory,[user integerForKey:@"fileName"]];
//     NSString  *fileVideoPath = [NSString stringWithFormat:@"%@/%d.jpg", documentsDirectory,[user integerForKey:@"fileName"]];
//
//    
//    [video setVideoLink:filePath];
//    [video setVideoTitle:[videoDict objectForKey:@"video_title"]];
//    [video setUploadDate:[videoDict objectForKey:@"upload_date"]];
//    [video setMetaData:[videoDict objectForKey:@"meta_data"]];
//    [video setVideoThumbnail:fileVideoPath];
//    [video setSubcategory:[videoDict objectForKey:@"subcategory_name"]];
//    [video setVideoDescription:[videoDict objectForKey:@"video_description"]];
//    
//    
//    
//    // Commit the change.
//    NSError *error;
//    if (![managedObjectContext save:&error]) {
//        // Handle the error.
//    }
//    
//    [self downloadVideoAndSave:[videoDict objectForKey:@"video_link"] thumbNailURL:[videoDict objectForKey:@"video_thumbnail"]];
// 
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
-(void)downloadVideoAndSave :(NSString*)videoUrl thumbNailURL:(NSString *)strThumb dic:(NSDictionary *)videoDic :(KAProgressLabel *)lblProgress
{
    __block NSManagedObjectContext *managedObjectContextNew;
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
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
        [video setMetaData:[Global getStringValue:[videoDic objectForKey:@"meta_data"]]];
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
        
        UIAlertView *alert11 = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:@"Download Started. See on download tab." delegate:self cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
        [alert11 show];
        
        NSLog(@"write successfull image");
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //
        });
        [lblProgress setHidden:YES];
    }];
    
    
}

//-(void)downloadVideoAndSave :(NSString*)videoUrl thumbNailURL:(NSString *)strThumb
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//        NSData *yourVideoData=[NSData dataWithContentsOfURL:[NSURL URLWithString:videoUrl]];
//
//        if (yourVideoData) {
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *documentsDirectory = [paths objectAtIndex:0];
//            NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
//
//            NSString  *filePath = [NSString stringWithFormat:@"%@/%d.mp4", documentsDirectory,[user integerForKey:@"fileName"]];
//            
//            if([yourVideoData writeToFile:filePath atomically:YES])
//            {
//               
//                NSLog(@"write successfull");
//            }
//            else{
//                NSLog(@"write failed");
//            }
//        }
//        
//        NSData *thumbData=[NSData dataWithContentsOfURL:[NSURL URLWithString:strThumb]];
//        if (thumbData) {
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *documentsDirectory = [paths objectAtIndex:0];
//            NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
//            
//            NSString  *filePath = [NSString stringWithFormat:@"%@/%d.jpg", documentsDirectory,[user integerForKey:@"fileName"]];
//            
//            if([thumbData writeToFile:filePath atomically:YES])
//            {
//                NSLog(@"write successfull");
//            }
//            else{
//                NSLog(@"write failed");
//            }
//        }
//
//    });
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//            });
//}
#pragma mark Collection View Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    //-55 is a tweak value to remove top spacing
    return CGSizeMake(1, 0);
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return CGSizeMake(308, 115);
//}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if([Global isIpad]){
        return CGSizeMake(self.view.frame.size.width, 200);
    }else{
        return CGSizeMake(self.view.frame.size.width, 130);
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, -5, 10);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [arrVideos count];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    VideoListCell *cell;
    
    cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"videoListCell" forIndexPath:indexPath];
    NSDictionary *videoDict=[arrVideos objectAtIndex:indexPath.section];
    
    NSString *str=[videoDict objectForKey:@"video_title"];
    str=[str stringByReplacingOccurrencesOfString:@"0x00B0" withString:[NSString stringWithFormat:@"%c",(char) 0x00B0]];
    
    cell.lblVideo.text=str;
    cell.lblCategory.text=[videoDict objectForKey:@"category_name"];
    cell.lblCountry.text=[videoDict objectForKey:@"video_city"];
    cell.lblDetails.text=[videoDict objectForKey:@"video_description"];
    cell.lblLink.text=[videoDict objectForKey:@"video_link"];
    cell.btnDownload.tag=indexPath.section;
    cell.moreDetail.tag=indexPath.section;
    cell.btnTwitter.tag=indexPath.section;
    cell.btnFacebook.tag=indexPath.section;
    cell.btnWhatsApp.tag=indexPath.section;

    cell.contentView.hidden=NO;
    NSURL *url = [NSURL URLWithString:[videoDict objectForKey:@"video_thumbnail"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@"your_placeholder"];
    __weak VideoListCell *weakCell = cell;
    [cell.imgVideo setImageWithURLRequest:request
                         placeholderImage:placeholderImage
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      
                                      weakCell.imgVideo.image = image;
                                      [weakCell setNeedsLayout];
                                      
                                  } failure:nil];
    
    [cell.imgVideo setNeedsDisplay];

    cell.imgVideo.contentMode=UIViewContentModeScaleToFill;
     [cell.lblProgress setBackBorderWidth: 4.0];
    [cell.lblProgress setFrontBorderWidth: 2.5];
    [cell.lblProgress setColorTable: @{
                                       NSStringFromProgressLabelColorTableKey(ProgressLabelTrackColor):[UIColor redColor],
                                       NSStringFromProgressLabelColorTableKey(ProgressLabelProgressColor):[UIColor greenColor]
                                       }];

    cell.lblProgress.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [label setText:[NSString stringWithFormat:@"%.0f%%", (progress*100)]];
        });
    };
    //[cell.lblProgress setHidden:YES];
   [cell.moreDetail setTag:indexPath.section];
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *videoDict=[arrVideos objectAtIndex:indexPath.section];
    if ([[videoDict objectForKey:@"videotype"] isEqualToString:@"html"])
    {
        [self performSegueWithIdentifier:@"webView" sender:indexPath];
    }else{
        //video_type
        [self performSegueWithIdentifier:@"videoPlayer" sender:indexPath];
    }
   // [self performSegueWithIdentifier:@"videoplay" sender:indexPath];
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
    arrVideos =[dict objectForKey:@"videoslist"];
    
    
   
   }


#pragma mark Segue Delegate
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
    // [self.collectionView reloadData];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIButton *btn=(UIButton*)sender;
    
    if (([segue.identifier isEqualToString:@"liveStreaming"]))
    {
        /// Live Stream View
        LiveStreamViewController *liveView=(LiveStreamViewController *)segue.destinationViewController;
        liveView.strCategory=kLiveBroadcast;
        //liveView.navigationBarImage=@"livebrodcast.png";
        
    }
    else if ([segue.identifier isEqualToString:@"videoList"]) {
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
    else if ([segue.identifier isEqualToString:@"searchSegue"]) {
        
    }else if([segue.identifier isEqualToString: @"videoPlayer"]){
    NSIndexPath *index=sender;
       AppDelegate *app;
        app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        app.downloadFlag=@"yes";
       NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
       [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        
       PlayViewController *view=(PlayViewController *)segue.destinationViewController;
     NSString* stringURL =[[arrVideos objectAtIndex:index.section] objectForKey:@"video_link"];
    view.videoPath=stringURL;
        view.flagPath=@"server";
    view.videoDict=[arrVideos objectAtIndex:index.section];
    }
    else if([segue.identifier isEqualToString: @"webView"]){
        NSIndexPath *index=(NSIndexPath *)sender;
        WebViewController *view=(WebViewController *)segue.destinationViewController;
        NSString* stringURL =[[arrVideos objectAtIndex:index.section] objectForKey:@"video_link"];
        view.strURL=stringURL;
    }
    else if([segue.identifier isEqualToString: @"searchdetail"]){
         NSIndexPath *index=[NSIndexPath indexPathWithIndex:btn.tag];
        MoreDetailViewController *detail=[segue destinationViewController];
        detail.flag=@"search";
        detail.seletedRecord=[arrVideos objectAtIndex:index.section];
    }
}

#pragma mark Orientation

-(BOOL)prefersStatusBarHidden{
    return NO;
}

- (IBAction)moreDetail:(id)sender {
   UIButton *btn=(UIButton *)sender;
    [self performSegueWithIdentifier:@"searchdetail" sender:btn];
}

@end
