//
//  MoreDetailViewController.m
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 12/28/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import "MoreDetailViewController.h"
#import "PlayViewController.h"
#import "AsyncImageView.h"
#import "Global.h"
#import <Social/Social.h>
#import "NSString+HTML.h"
#import "VideoDownload.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import <FacebookSDK/FacebookSDK.h>
#import "WebViewController.h"
@interface MoreDetailViewController ()<NSStreamDelegate>

@end

@implementation MoreDetailViewController
@synthesize seletedRecord,managedObjectContext,localArrVideos;
@synthesize flag;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*
     NSString *deviceType = [UIDevice currentDevice].model;
     
     if(![[UIDevice currentDevice].model isEqualToString:@"iPhone"])
     */
    //[Global setFontRecursively:self.view];

    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
    [self.lblProgress setHidden:YES];
    UITapGestureRecognizer *myLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgBannerTapHandler:)];
    [self.imgBanner addGestureRecognizer:myLabelTap];
    
    UITapGestureRecognizer *urlLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lblBannerTapHandler:)];
    [self.lblUrl addGestureRecognizer:urlLabelTap];
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    managedObjectContext=app.managedObjectContext;
    [self.lblProgress setHidden:YES];
    if ([flag isEqualToString:@"Download"] ) {
        
        NSString *documentDir=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSLog(@"%@",seletedRecord);
        if ([[seletedRecord valueForKey:@"videoThumbnail"] isEqualToString:@"videoThumb.jpg"]){
            self.imgBanner.image=[UIImage imageNamed:[seletedRecord valueForKey:@"videoThumbnail"]];
        }else{
            NSString *filePath=[NSString stringWithFormat:@"%@/%@",documentDir,[seletedRecord valueForKey:@"videoThumbnail"]];
            self.imgBanner.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
        }

        
       
        
        NSString *str=[seletedRecord valueForKey:@"videoTitle"];
        str=[str stringByReplacingOccurrencesOfString:@"0x00B0" withString:[NSString stringWithFormat:@"%c",(char) 0x00B0]];
        
        self.lblTitle.text=str;
        self.lblCountry.text=[Global getStringValue:[seletedRecord valueForKey:@"videoCity"]];
        self.lblCategory.text=[[seletedRecord valueForKey:@"videoTitle"] stringByReplacingOccurrencesOfString:@"0x00B0" withString:[NSString stringWithFormat:@"%c",(char) 0x00B0]];
        self.lblDetail.text=[Global getStringValue:[seletedRecord valueForKey:@"videoDescription"]];
        self.lblLocation.text=[Global getStringValue:[seletedRecord valueForKey:@"videoCity"]];
        self.lblUrl.text=[Global getStringValue:[seletedRecord valueForKey:@"siteUrl"]];
    }else{
        
        NSString *str=[Global getStringValue:[seletedRecord objectForKey:@"video_title"]];
        str=[str stringByReplacingOccurrencesOfString:@"0x00B0" withString:[NSString stringWithFormat:@"%c",(char) 0x00B0]];
        
        self.lblTitle.text=str;
        self.lblCountry.text=[Global getStringValue:[seletedRecord objectForKey:@"video_city"]];
        self.lblCategory.text=[[Global getStringValue:[seletedRecord objectForKey:@"video_title"] ]stringByReplacingOccurrencesOfString:@"0x00B0" withString:[NSString stringWithFormat:@"%c",(char) 0x00B0]];
        self.lblDetail.text=[Global getStringValue:[seletedRecord objectForKey:@"video_description"]];
        self.lblLocation.text=[Global getStringValue:[seletedRecord objectForKey:@"video_city"]];
        self.lblUrl.text=[Global getStringValue:[seletedRecord objectForKey:@"website_link"]];
        self.imgBanner.imageURL = [NSURL URLWithString:[seletedRecord objectForKey:@"video_thumbnail"]];
        
        self.lblProgress.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [label setText:[NSString stringWithFormat:@"%.0f%%", (progress*100)]];
            });
        };
        [self.lblProgress setBackBorderWidth: 4.0];
        [self.lblProgress setFrontBorderWidth: 2.5];
        [self.lblProgress setColorTable: @{
                                           NSStringFromProgressLabelColorTableKey(ProgressLabelTrackColor):[UIColor redColor],
                                           NSStringFromProgressLabelColorTableKey(ProgressLabelProgressColor):[UIColor greenColor]
                                           }];
        
    }
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [Global backButton:self];
    
    _imgBanner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    if (self.view.bounds.size.height==480/*||([[UIDevice currentDevice].model isEqualToString:@"iPhone"])||([[UIDevice currentDevice].model isEqualToString:@"iPhone Simulator"])*/) {
        CGRect frm=self.moreDetailSupportView.frame;
        self.moreDetailSupportView.frame=CGRectMake(frm.origin.x, frm.origin.y+50, frm.size.width,frm.size.height);
        //self.moreDetailSupportView.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin;
    }
}
-(void)lblBannerTapHandler:(UIGestureRecognizer *)gestureRecognizer {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",self.lblUrl.text]];
    //[substring stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        
    }else{
        [Global showAlertMessageWithOkButtonAndTitle:@"360 VUZ" andMessage:@"URL can not open."];
    }
}
-(void)imgBannerTapHandler:(UIGestureRecognizer *)gestureRecognizer {
    
    if (![[[[seletedRecord valueForKey:@"videoFileLink"] componentsSeparatedByString:@"##"]objectAtIndex:0] isEqualToString:@"NA"]) {
        NSLog(@"seletedRecord%@",seletedRecord);
        if ([[seletedRecord objectForKey:@"videotype"] isEqualToString:@"html"])
        {
            [self performSegueWithIdentifier:@"webView" sender:nil];
        }else{
            //video_type
            [self performSegueWithIdentifier:@"videoPlayer" sender:nil];
        }
        //[self performSegueWithIdentifier:@"videoPlayer" sender:nil];
    }
    // [self performSegueWithIdentifier:@"videoPlayer" sender:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString: @"videoPlayer"]){
        AppDelegate *app;app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        app.downloadFlag=@"yes";
        
        if ([flag isEqualToString:@"Download"] ) {
            NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
            [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
            PlayViewController *view=(PlayViewController *)segue.destinationViewController;
            NSString* stringURL =[[[seletedRecord valueForKey:@"videoFileLink"] componentsSeparatedByString:@"##"] objectAtIndex:0];
            view.localVideoPath=stringURL;
            view.flagPath=@"local";
        }else {
            NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
            [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
            PlayViewController *view=(PlayViewController *)segue.destinationViewController;
            NSString* stringURL =[seletedRecord objectForKey:@"video_link"];
            view.videoPath=stringURL;
            view.flagPath=@"server";
            view.videoDict=seletedRecord;
        }
    }else if([segue.identifier isEqualToString: @"webView"]){
        WebViewController *view=(WebViewController *)segue.destinationViewController;
        NSString* stringURL =[seletedRecord valueForKey:@"videoLink"];
        view.strURL=stringURL;
    }
}


- (IBAction)facebookShare:(id)sender {
    
  //  UIButton *btnTemp=(UIButton *)sender;
    
    //   NSString *strLink=  [[arrVideos objectAtIndex:btnTemp.tag] objectForKey:@"video_link"];
    // Check if the Facebook app is installed and we can present the share dialog
    NSString * videoID = @"";
    if ([flag isEqualToString:@"Download"] )
    {
        videoID = [seletedRecord  valueForKey:@"videoId"];
    }else{
        videoID = [seletedRecord  objectForKey:@"video_id"];
    }
    
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    
    params.link = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.360mea.com/video-detail?id=%@",videoID]];
    
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
                                       [NSString stringWithFormat:@"http://www.360mea.com/video-detail?id=%@",videoID], @"link",
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


- (IBAction)twilterShare:(id)sender {
    
    NSString * videoID = @"";
    NSString * videoThumb = @"";
    if ([flag isEqualToString:@"Download"] )
    {
        videoID = [seletedRecord  valueForKey:@"videoId"];
        videoThumb = [seletedRecord  valueForKey:@"videoThumbnail"];

    }else{
        videoID = [seletedRecord  objectForKey:@"video_id"];
        videoThumb = [seletedRecord  valueForKey:@"video_thumbnail"];

    }
    //    NSDictionary *videoDict=[arrVideos objectAtIndex:btn.tag];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Click on the link to view an amazing 360 video"];
        [tweetSheet addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.360mea.com/video-detail?id=%@",videoID]]];
        
        [tweetSheet addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:videoThumb]]]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }else{
        
        [Global showAlertMessageWithOkButtonAndTitle:@"360 VUZ" andMessage:@"Please login in Twitter." ];
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
            return exist;
            
        }else{
            exist= NO;
        }
        
    }
    
    return exist;
    // [self.collectionView reloadData];
    
}


- (IBAction)downloads:(id)sender {
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if ([app.isDownloading isEqualToString:@"NO"])
    {
    [self performSelector: @selector(downloadAction:)
               withObject: nil
               afterDelay: 0.1];
    }else{
        UIAlertView *alertShow = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:@"Another Video is  downloading" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
        [alertShow show];
        [self.lblProgress setHidden:YES];
    }
    

    
  }
- (IBAction)downloadAction:(id)sender
{
    if ([flag isEqualToString:@"Download"]) {
        
        UIAlertView *alertShow = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:@"Video is already downloaded." delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
        [alertShow show];
        
    }else{
        
        UIButton *btn=(UIButton *)sender;
        NSLog(@"seleted video %d",[self videosForCoreData:[seletedRecord valueForKey:@"video_id"]]);
        if ([self videosForCoreData:[seletedRecord valueForKey:@"video_id"]] ) {
            UIAlertView *alertShow = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:@"Video is either downloading or downloaded." delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
            [alertShow show];
            
        }else {
            
            AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
            if ([app.isDownloading isEqualToString:@"NO"])
            {
                [NSThread detachNewThreadSelector:@selector(callThread:) toTarget:self withObject:btn];
                
            }else{
                UIAlertView *alertShow = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:@"Another Video is  downloading" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
                [alertShow show];
                [self.lblProgress setHidden:YES];
            }
        }
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.tabBarController setSelectedIndex:1];
}
-(void)callThread :(id)sender{
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    app.isDownloading = @"YES";
    [self.lblProgress setHidden:NO];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self downloadVideoAndSave:[seletedRecord objectForKey:@"video_link"] thumbNailURL:[seletedRecord objectForKey:@"video_thumbnail"] dic:seletedRecord :self.lblProgress];
    
}
-(void)downloadVideoAndSave :(NSString*)videoUrl thumbNailURL:(NSString *)strThumb dic:(NSDictionary *)videoDic :(KAProgressLabel *)lblProgress
{
    __block NSManagedObjectContext *managedObjectContextNew;
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    managedObjectContextNew=app.managedObjectContext;
    app.isDownloading = @"YES";
    
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
        [video setSiteUrl:[videoDic objectForKey:@"website_link"]];
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
            app.isDownloading = @"NO";

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

- (IBAction)search:(id)sender {
    
    [self performSegueWithIdentifier:@"detailSearch" sender:nil];
    
}

- (IBAction)playVideo:(id)sender {
    NSLog(@"seletedRecord%@",seletedRecord);
    NSString * videoType = @"";
    if ([flag isEqualToString:@"Download"] )
    {
        videoType = [seletedRecord  valueForKey:@"videoType"];
    }else{
        videoType = [seletedRecord  objectForKey:@"videotype"];
    }
    
    if ([videoType isEqualToString:@"html"])
    {
        [self performSegueWithIdentifier:@"webView" sender:nil];
    }else{
        //videotype
        [self performSegueWithIdentifier:@"videoPlayer" sender:nil];
    }
}
#pragma mark Orientation
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}


@end
