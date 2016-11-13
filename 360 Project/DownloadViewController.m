//
//  DownloadViewController.m
//  360 Project
//
//  Created by Hitaishin Technologies on 12/8/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadViewCell.h"
#import <Social/Social.h>
#import "VideoDownload.h"
#import "AppDelegate.h"
#import "Global.h"
#import "PlayViewController.h"
#import "MoreDetailViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking.h"
#import "KAProgressLabel.h"
#import "Global.h"
#import "WebViewController.h"
#import "LiveStreamViewController.h"
#import "VideoListViewController.h"
AppDelegate *app;

@interface DownloadViewController ()<NSStreamDelegate>
{
    BOOL isDownloading;
    Boolean isTopBar;
    NSIndexPath *downloadIndexPaht;
}
@end

@implementation DownloadViewController
@synthesize managedObjectContext,arrVideos;
- (void)viewDidLoad {
    [super viewDidLoad];
    //[Global setFontRecursively:self.view];

    app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    //self.navigationItem.titleView =[Global customNavigationImage:@"download1.png"];
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
    // Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated{
    
    NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIDeviceOrientationPortrait]
                                forKey:@"orientation"];

    
    self.tabBarController.tabBar.hidden=NO;
    for (UIView *btn in [self.tabBarController.view subviews]) {
        if ([btn class]==[UIButton class]&&btn.tag>=1&&btn.tag<=4) {
            UIButton *button=(UIButton *)btn;
            button.hidden=NO;
        }
        if(btn.tag==100){
            btn.hidden=NO;
        }
    }
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self videosForCoreData];

}

-(void)videosForCoreData{
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
    // Set self's events array to the mutable array, then clean up.
    [self setArrVideos:mutableFetchResults];
    [self.collectionView reloadData];

}


- (void)filterContentForSearchText:(NSString*)searchText
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"VideoDownload" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoTitle contains[c] %@", searchText];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    
    NSMutableArray* mutableFetchResults = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (mutableFetchResults == nil) {
        // Handle the error.
    }
    // Set self's events array to the mutable array, then clean up.
    [self setArrVideos:mutableFetchResults];
    [self.collectionView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Collection View Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(1, 0);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, -5, 10);
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return CGSizeMake(308, 145);
//}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if([Global isIpad]){
        return CGSizeMake(self.view.frame.size.width-20, 200);
    }else{
        return CGSizeMake(self.view.frame.size.width-20, 145);
    }
    
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [arrVideos count];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DownloadViewCell *cell;
    cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"videoListCell" forIndexPath:indexPath];
    
    VideoDownload *video=[arrVideos objectAtIndex:indexPath.section];
    
   
    NSString *str=video.videoTitle;
    str=[str stringByReplacingOccurrencesOfString:@"0x00B0" withString:[NSString stringWithFormat:@"%c",(char) 0x00B0]];
    
    cell.lblVideo.text=str;
   // cell.lblVideo.text=video.videoTitle;
    cell.lblCategory.text=video.category;
    cell.lblContry.text=video.videoCity;
    cell.lblDetail.text=video.videoDescription;
    cell.lblVideo.text=video.videoTitle;
    cell.lblVideoTitle.text=str;
    cell.imgVideo.contentMode=UIViewContentModeScaleAspectFit;
    
    cell.btndelete.tag=indexPath.section;
    cell.btnTwitter.tag=indexPath.section;
    cell.btnFacebook.tag=indexPath.section;
    cell.btnMoreDetail.tag=indexPath.section;
    cell.imgVideo.contentMode=UIViewContentModeScaleToFill;
    [cell.lblProgress setHidden:YES];
    NSString *documentDir=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
     NSString *filePath=nil;
    
    if ([video.videoThumbnail isEqualToString:@"videoThumb.jpg"]) {
         filePath=video.videoThumbnail;
        cell.imgVideo.image=[UIImage imageNamed:filePath];
    }else{
         filePath=[NSString stringWithFormat:@"%@/%@",documentDir,video.videoThumbnail];
        cell.imgVideo.image=[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
    }
    
    //[cell.lblProgress setHidden:YES];
    cell.lblProgress.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [label setText:[NSString stringWithFormat:@"%.0f%%", (progress*100)]];
            });
        };
    [cell.lblProgress setBackBorderWidth: 4.0];
    [cell.lblProgress setFrontBorderWidth: 2.5];
    [cell.lblProgress setColorTable: @{
                                       NSStringFromProgressLabelColorTableKey(ProgressLabelTrackColor):[UIColor redColor],
                                       NSStringFromProgressLabelColorTableKey(ProgressLabelProgressColor):[UIColor greenColor]
                                       }];
   
    
    if ([[[video.videoFileLink componentsSeparatedByString:@"##"]objectAtIndex:0] isEqualToString:@"NA"] && isDownloading==NO) {
        downloadIndexPaht=indexPath;
        [cell.lblProgress setHidden:NO];
        [self downloadVideoAndSave:[[video.videoFileLink componentsSeparatedByString:@"##"]objectAtIndex:1] : cell.lblProgress];
        
        
    }else{
        if (downloadIndexPaht==indexPath) {
            [cell.lblProgress setHidden:NO];
            self.lblGlobalProgress=cell.lblProgress;
        }else
     [cell.lblProgress setHidden:YES];
    }
    
    if (isDownloading==YES &&[[[video.videoFileLink componentsSeparatedByString:@"##"]objectAtIndex:0] isEqualToString:@"NA"]) {
        
        [cell.lblProgress setHidden:NO];
        self.lblGlobalProgress=cell.lblProgress;
    }else{
        
    }
    
    /*
     [video setCategory:[videoDic objectForKey:@"category_name"]];
     [video setVideoCity:[videoDic objectForKey:@"video_city"]];
     [video setSiteUrl:[videoDic objectForKey:@"website_link"]];
     [video setVideoFileLink:[NSString stringWithFormat:@"NA##%@",videoUrl]];
     [video setVideoId:[NSNumber numberWithInt:[[videoDic objectForKey:@"video_id"] intValue]]
     [video setVideoLink:videoUrl];
     [video setVideoTitle:[videoDic objectForKey:@"video_title"]];
     [video setUploadDate:[videoDic objectForKey:@"upload_date"]];
     [video setMetaData:[videoDic objectForKey:@"meta_data"]];
     [video setVideoThumbnail:filePath];
     [video setSubcategory:[videoDic objectForKey:@"subcategory_name"]];
     [video setVideoDescription:[videoDic objectForKey:@"video_description"]];

     */
    
    
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
     VideoDownload *video=[arrVideos objectAtIndex:indexPath.section];
    NSLog(@"array%@",arrVideos);
        NSLog(@"video.videoTitle%@",video.videoType);
     if (![[[video.videoFileLink componentsSeparatedByString:@"##"]objectAtIndex:0] isEqualToString:@"NA"]) {
         
         if ([video.videoType isEqualToString:@"html"])
         {
             [self performSegueWithIdentifier:@"webView" sender:indexPath];
         }else{
             //video_type
             [self performSegueWithIdentifier:@"videoPlayer" sender:indexPath];
         }
     }
}

#pragma mark Segue Delegate
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (([segue.identifier isEqualToString:@"liveStreaming"]))
    {
        /// Live Stream View
        LiveStreamViewController *liveView=(LiveStreamViewController *)segue.destinationViewController;
        liveView.strCategory=@"18";
        
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
    else if([segue.identifier isEqualToString: @"videoPlayer"]){
    NSIndexPath *index=sender;
        app.downloadFlag=@"yes";
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        
      VideoDownload *video=[arrVideos objectAtIndex:index.section];
        PlayViewController *view=(PlayViewController *)segue.destinationViewController;
//        VideoDownload *video=[arrVideos objectAtIndex:index.section];
        NSString* stringURL =[[video.videoFileLink componentsSeparatedByString:@"##"] objectAtIndex:0];
        view.localVideoPath=stringURL;
//        view.videoPath=stringURL;
//        view.flagPath=@"local";
//        view.videoDict=[arrVideos objectAtIndex:index.section];
       view.flagPath=@"local";
    }
    else if([segue.identifier isEqualToString: @"webView"]){
        NSIndexPath *index=sender;
        VideoDownload *video=[arrVideos objectAtIndex:index.section];
        WebViewController *view=(WebViewController *)segue.destinationViewController;
        NSString* stringURL = video.videoLink;
        view.strURL=stringURL;
    }
    else if([segue.identifier isEqualToString:@"searchSegue"]){
    }else{
        NSIndexPath *index=(NSIndexPath *)sender;
        
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        
        MoreDetailViewController *view=(MoreDetailViewController *)segue.destinationViewController;
        //  NSString* stringURL =[[arrVideos objectAtIndex:index.section] objectForKey:@"video_link"];
        NSLog(@"seletedRecord %@",[arrVideos objectAtIndex:index.section]);

        view.seletedRecord=[arrVideos objectAtIndex:index.section];
        view.flag=@"Download";
        //  view.videoDict=[arrVideos objectAtIndex:index.section];
        
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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

#pragma mark Download Delegate
- (IBAction)downloadClick:(id)sender {
    if (self.txtDownload.text ==nil || [self.txtDownload.text isEqualToString:@""])
    {
        [self videosForCoreData];
    }else
    {
        [self filterContentForSearchText:self.txtDownload.text];
        self.txtDownload.text = @"";

    }
}



- (IBAction)videoDownload:(id)sender {
    //DOWNLOAD STARTED
    UIAlertView *alert11 = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:@"Download Started" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
    [alert11 show];

    
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


- (IBAction)facebookSharing:(id)sender {
    UIButton *btnTemp=(UIButton *)sender;
    VideoDownload *video=[arrVideos objectAtIndex:btnTemp.tag];
//    NSString *strLink=  video.videoFileLink;
    // Check if the Facebook app is installed and we can present the share dialog
//    UIButton *btnTemp=(UIButton *)sender;
    
    //   NSString *strLink=  [[arrVideos objectAtIndex:btnTemp.tag] objectForKey:@"video_link"];
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    
    params.link = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.360mea.com/video-detail?id=%@",video.videoId]];
    
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
                                       [NSString stringWithFormat:@"http://www.360mea.com/video-detail?id=%@",video.videoId], @"link",
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
- (IBAction)twitterSharing:(id)sender {
    UIButton *btn=(UIButton *)sender;
    VideoDownload *video=[arrVideos objectAtIndex:btn.tag];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        //NSString *strFormat=[[NSString alloc]initWithFormat:@"Click on the link to view an amazing 360 video:%@\n%@\n%@",video.category,video.videoDescription,video.videoLink];
        [tweetSheet setInitialText:@"Click on the link to view an amazing 360 video"];
        [tweetSheet addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.360mea.com/video-detail?id=%@",video.videoId]]];
        [tweetSheet addImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:video.videoThumbnail]]]];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }else{
        
        [Global showAlertMessageWithOkButtonAndTitle:@"360 VUZ" andMessage:@"Please login in Twitter." ];
    }

}

- (IBAction)deleteVideo:(id)sender {
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if ([app.isDownloading isEqualToString:@"NO"])
    {
        UIButton *btnVideo=(UIButton *)sender;
        // Delete the managed object at the given index path.
        NSManagedObject *eventToDelete = [arrVideos objectAtIndex:btnVideo.tag];
        
        [managedObjectContext deleteObject:eventToDelete];
        
        // Update the array and table view.
        [arrVideos removeObjectAtIndex:btnVideo.tag];
        [self.collectionView reloadData];
        // Commit the change.
        NSError *error;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }else{
            // [self removeFile:<#(NSString *)#>]
        }
        
    }else{
        UIAlertView *alertShow = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:@"Video is  downloading" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
        [alertShow show];
    }

   }

- (void)removeFile:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:fileName error:&error];
    if (success) {
        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Congratulation:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [removeSuccessFulAlert show];
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}
- (IBAction)searchVideo:(id)sender {
    [self performSegueWithIdentifier:@"searchSegue" sender:nil];
}

- (IBAction)moreDetailAction:(id)sender {
    
    UIButton *moreButton=(UIButton*)sender;
     NSIndexPath *index=[NSIndexPath indexPathWithIndex:moreButton.tag];
    [self performSegueWithIdentifier:@"moreDetail" sender:index];

  
}
-(void)downloadVideoAndSave :(NSString*)videoUrl :(KAProgressLabel *)lblProgress
{
    __block NSManagedObjectContext *managedObjectContextNew;
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    managedObjectContextNew=app.managedObjectContext;
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:videoUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/%ld.mp4", documentsDirectory,(long)[user integerForKey:@"fileName"]-1];
    
   
    isDownloading=YES;
    // NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"1.mp4"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
    operation.outputStream.delegate = self;
    [operation start];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //isDownloading=NO;
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        dispatch_async( dispatch_get_global_queue(0, 0), ^{
          [self.lblGlobalProgress setProgress:((float)totalBytesRead / totalBytesExpectedToRead)];
            dispatch_async( dispatch_get_main_queue(), ^{
                // running synchronously on the main thread now -- call the handler
               
            });
        });
        
       
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        app.isDownloading = @"YES";
        NSLog(@"downloadComplete.... %f",(float)totalBytesRead / totalBytesExpectedToRead);
        if (totalBytesRead == totalBytesExpectedToRead) {
            app.isDownloading = @"NO";
             NSLog(@"Download successfull video");
        }
        
    }];
    
    [operation setCompletionBlock:^{

        
                NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
                
                NSString  *filePath = [NSString stringWithFormat:@"%ld.mp4", (long)[user integerForKey:@"fileName"]-1];
        
        
        NSFetchRequest *request=[[NSFetchRequest alloc]init];
        [request setEntity:[NSEntityDescription entityForName:@"VideoDownload" inManagedObjectContext:managedObjectContextNew]];
      //  [request setPredicate:[NSPredicate predicateWithFormat:@"videoFileLink=%@",filePath]];
        
        NSError *error;
        VideoDownload *video = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
        
        
        if (error) {
            //Handle any errors
        }
        
        NSString *videoFilePath=@"";//[NSString stringWithFormat:@"%@##%@",filePath,@"NA"];
        
        videoFilePath=[videoFilePath stringByAppendingString:[NSString stringWithFormat:@"%@##%@",filePath,@"NA"]];
        video.videoFileLink = videoFilePath;
        
        //Save it
        error = nil;
        if (![managedObjectContextNew save:&error]) {
            //Handle any error with the saving of the context
        }
        
         [self videosForCoreData];
         isDownloading=NO;
        [self addAttributeToAllFolder];
        NSLog(@"write successfull video");

        [lblProgress setHidden:YES];
         app.isDownloading = @"NO";
    }];
    
    
}
#pragma mark Orientation Delegate
-(BOOL)prefersStatusBarHidden{
    return NO;
}
-(void)downloadVideoAndSave :(NSString*)videoUrl{
    __block NSManagedObjectContext *managedObjectContextNew;
    
    
    managedObjectContextNew=app.managedObjectContext;
    
//    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:strThumb] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString  *filePath = [NSString stringWithFormat:@"%@/%ld.jpg", documentsDirectory,(long)[user integerForKey:@"fileName"]];
//    
//    
//    // NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"1.mp4"];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
//    operation.outputStream.delegate = self;
//    [operation start];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//    }];
//    
//    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        
//        [lblProgress setProgress:((float)totalBytesRead / totalBytesExpectedToRead)];
//        
//        NSLog(@"downloadComplete.... %f",(float)totalBytesRead / totalBytesExpectedToRead);
//    }];
//    
//    [operation setCompletionBlock:^{
//        NSLog(@"downloadComplete! %@",videoDic);
        //app.downloadFlag=@"yes";
        NSString  *filePath = @"videoThumb.jpg";
        
        VideoDownload *video = (VideoDownload *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoDownload" inManagedObjectContext:managedObjectContextNew];
        
        [video setCategory:@"Default"];
        [video setVideoCity:@"Default"];
        [video setSiteUrl:@"Default"];
        [video setVideoFileLink:[NSString stringWithFormat:@"NA##%@",videoUrl]];
        [video setVideoId:[NSNumber numberWithInt:(int)[user integerForKey:@"fileName"]]];
        
        if ([user integerForKey:@"fileName"]==nil) {
            [user setInteger:0 forKey:@"fileName"];
        }
        [video setVideoLink:videoUrl];
        [video setVideoTitle:@"Default"];
        [video setUploadDate:@"Default"];
        [video setMetaData:@"Default"];
        [video setVideoThumbnail:filePath];
        [video setSubcategory:@"Default"];
        [video setVideoDescription:@"Default"];
        [video setVideoType:@"Default"];
    
        // Commit the change.
        NSError *error;
        if (![managedObjectContextNew save:&error]) {
            // Handle the error.
        }
        [user setInteger:[user integerForKey:@"fileName"]+1 forKey:@"fileName"];
        
//        [self performSelectorOnMainThread:@selector(showAlertWithTitle:)
//                               withObject:@"Download Started. See on download tab."
//                            waitUntilDone:YES];
        NSLog(@"write successfull image");
        [self addAttributeToAllFolder];
    
    [self videosForCoreData];
    
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            //
//        });
      //  [lblProgress setHidden:YES];
   // }];
    
    
}

#pragma mark Prevent from iCloud backup.

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

@end
