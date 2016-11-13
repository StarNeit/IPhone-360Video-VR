
//
//  PlayViewController.m
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 1/19/15.
//  Copyright (c) 2015 Hitaishin Infotech. All rights reserved.
//

#import "PlayViewController.h"
#import "AFNetworking.h"
#import <Panframe/Panframe.h>
#import "VideoDownload.h"
#import "Global.h"
#import "Constant.h"
#import "NavViewController.h"
#import "WBTabBarController.h"

#import "AppDelegate.h"
#define kDual 0
#define kSingle 1
#define kCancel 2
//#define HIDE_CONTROL_DELAY 5.0f
#define DEFAULT_VIEW_ALPHA 0.6f
#define HIDE_CONTROL_DELAY 5.0

#define MAX_OVERTURE 95.0
#define MIN_OVERTURE 25.0
#define DEFAULT_OVERTURE 100.0

int modeFlag;
AppDelegate *app;
@interface PlayViewController ()<PFAssetObserver, PFAssetTimeMonitor>
{
PFView * pfView;
id<PFAsset> pfAsset;
enum PFNAVIGATIONMODE currentmode;
    bool touchslider;
NSTimer *slidertimer;
int currentview;
    BOOL downloadFlag;
     IBOutlet UISlider *slider;
     UIImage *pauseImage;
    long long x;
    int y;
    CGFloat _overture;

}

- (void) onStatusMessage : (PFAsset *) asset message:(enum PFASSETMESSAGE) m;
- (void) onPlayerTime:(id<PFAsset>)asset hasTime:(CMTime)time;

@end


@implementation PlayViewController
@synthesize videoDict,videoPath,managedObjectContext,playButton;
@synthesize localArrVideos;


-(void)viewDidAppear:(BOOL)animated{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [self.view setNeedsDisplay];
//[NSThread detachNewThreadSelector:@selector(longMethod) toTarget:self withObject:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //[Global setFontRecursively:self.view];
    _overture = 90.0;

     x=10000.0;
     y= 1;
    app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    managedObjectContext=app.managedObjectContext;
    
     pauseImage = [UIImage imageNamed:@"pausescreen.png"];
    slider.value = 0;
    slider.enabled = false;
    [slider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateSelected];
    [slider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateDisabled];

    slidertimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                   target: self
                                                 selector:@selector(onPlaybackTime:)
                                                 userInfo: nil repeats:YES];
    
    
    
    currentmode = PF_NAVIGATION_MOTION;
    currentview = 0;
    
   // [pfView injectImage:pauseImage];
   
    
    [self createView];
    
    // create some hotspots
   //  [self createHotspots];
    
    
    // create a Panframe asset
    if (self.videoDict==nil) {
        [self.progressVIew setHidden:YES];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        [self createAssetWithUrl:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",[paths firstObject],self.localVideoPath]]];
    }else{
        [self.progressVIew setHidden:NO];
        [self createAssetWithUrl:[NSURL URLWithString:[videoDict objectForKey:@"video_link"]]];
    }
    
   // [[NSBundle mainBundle] URLForResource:@"PANO1" withExtension:@"m4v"];
   //  [self createAssetWithUrl:[[NSBundle mainBundle] URLForResource:@"PANO1" withExtension:@"m4v"]];
    UIDevice *device = [UIDevice currentDevice];					//Get the device object
    [device beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];	//Get the notification centre for the app
    [nc addObserver:self											//Add yourself as an observer
           selector:@selector(orientationChanged:)
               name:UIDeviceOrientationDidChangeNotification
             object:device];
    
    if ([pfAsset getStatus] == PF_ASSET_ERROR)
        [self stop];
    else
        if (self.videoDict==nil) {
        [pfAsset play];
        }
    modeFlag=kSingle;
    [playButton setImage:[UIImage imageNamed:@"playback_pause.png"] forState:UIControlStateNormal];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doSingleTap)]  ;
    singleTap.numberOfTapsRequired = 1;
    [pfView addGestureRecognizer:singleTap];
    
    /// Gesture for Video Zoom In & Zoom Out
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [pfView addGestureRecognizer:pinchRecognizer];
    
    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(hideControlsWithDurationAllTime:) userInfo:nil repeats:YES];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}
-(void)doSingleTap{
    if(self.playerControlBackgroundView.hidden){
        self.playerControlBackgroundView.alpha = 0.0;
        self.playerControlBackgroundView.hidden = NO;
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^(void) {
                             
                             self.playerControlBackgroundView.alpha = DEFAULT_VIEW_ALPHA;
                         }
                         completion:nil];

    }else {
        [self hideControlsSlowly];
    }
 
}
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    //NSLog(@"Pinch scale: %f", recognizer.scale);
    if (recognizer.scale > 1) {
        /// pinch out
        //NSLog(@"Zoom out");
        if (_overture > 40)
        {
            _overture--;
        }
        [pfView setFieldOfView:_overture];
    }else if (recognizer.scale < 1 ){
        //NSLog(@"Zoom In");
        /// pinch in
        if (_overture < 100)
        {
            _overture++;
        }
        [pfView setFieldOfView:_overture];
    }

}

- (void) createHotspots
{
    // create some sample hotspots on the view and register a callback
    
    id<PFHotspot> hp1 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp2 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp3 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp4 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp5 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    id<PFHotspot> hp6 = [pfView createHotspot:[UIImage imageNamed:@"hotspot.png"]];
    
    [hp1 setCoordinates:0 andX:0 andZ:0];
    [hp2 setCoordinates:40 andX:5 andZ:0];
    [hp3 setCoordinates:80 andX:1 andZ:0];
    [hp4 setCoordinates:120 andX:-5 andZ:0];
    [hp5 setCoordinates:160 andX:-10 andZ:0];
    [hp6 setCoordinates:220 andX:0 andZ:0];
    
    [hp3 setSize:2];
    [hp3 setAlpha:0.5f];
    
    [hp1 setTag:1];
    [hp2 setTag:2];
    [hp3 setTag:3];
    [hp4 setTag:4];
    [hp5 setTag:5];
    [hp6 setTag:6];
    
    [hp1 addTarget:self action:@selector(onHotspot:)];
    [hp2 addTarget:self action:@selector(onHotspot:)];
    [hp3 addTarget:self action:@selector(onHotspot:)];
    [hp4 addTarget:self action:@selector(onHotspot:)];
    [hp5 addTarget:self action:@selector(onHotspot:)];
    [hp6 addTarget:self action:@selector(onHotspot:)];
}

- (void) onHotspot:(id<PFHotspot>) hotspot
{
    // log the hotspot triggered
    NSLog(@"Hotspot triggered. Tag: %d", [hotspot getTag]);
    
    // animate the hotspot to show the user it was clicked
    [hotspot animate];
}
-(void)viewWillAppear:(BOOL)animated{
    //downloadFlag=NO;
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    if (self.videoDict!=nil) {
    self.progressVIew.progressLabelVCBlock = ^(KAProgressLabel *label, CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [label setText:[NSString stringWithFormat:@"%.0f%%", (progress*100)]];
        });
    };
    [self.progressVIew setBackBorderWidth: 4.0];
    [self.progressVIew setFrontBorderWidth: 3.5];
    [self.progressVIew setColorTable: @{
                                       NSStringFromProgressLabelColorTableKey(ProgressLabelTrackColor):[UIColor redColor],
                                       NSStringFromProgressLabelColorTableKey(ProgressLabelProgressColor):[UIColor greenColor]
                                       }];

     [self.progressVIew setText:@"Buffering.."];
    }
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = YES;
   // [self updatePlayButton];
    
    for (UIView *btn in [self.tabBarController.view subviews]) {
        if ([btn class]==[UIButton class]&&btn.tag>=1&&btn.tag<=4) {
            UIButton *button=(UIButton *)btn;
            button.hidden=YES;
        }
        
        UIImageView *tabBarBorder=(UIImageView*)[btn viewWithTag:100];
        if(tabBarBorder.tag==100){
            tabBarBorder.hidden=YES;
        }
    }
  //  [NSTimer scheduledTimerWithTimeInterval:0.0001f target:self selector:@selector(longMethod) userInfo:nil repeats:YES];

    // [self longMethod];
}
-(void)viewWillDisappear:(BOOL)animated
{
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.tabBarController.tabBar.hidden = NO;
   // [self updatePlayButton];
    
    for (UIView *btn in [self.tabBarController.view subviews]) {
        if ([btn class]==[UIButton class]&&btn.tag>=1&&btn.tag<=4) {
            UIButton *button=(UIButton *)btn;
            button.hidden=NO;
        }
        
        UIImageView *tabBarBorder=(UIImageView*)[btn viewWithTag:100];
        if(tabBarBorder.tag==100){
            tabBarBorder.hidden=NO;
        }
    }
    NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationIsPortrait(UIDeviceOrientationPortrait)];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

-(void)onPlaybackTime:(NSTimer *)timer
{
    
    if (pfAsset == nil)
        return;
     if (self.videoDict!=nil) {
    if (!touchslider && [pfAsset getStatus] != PF_ASSET_SEEKING)
    {
        CMTime timeToPlay = [pfAsset getPlaybackTime];
        CMTime totalTime = [pfAsset getDuration];
        
        float downloadTime=(float)CMTimeGetSeconds(timeToPlay)/CMTimeGetSeconds(totalTime);
        NSLog(@"buffering  %.2f",(float)CMTimeGetSeconds(timeToPlay)/CMTimeGetSeconds(totalTime));
        [self.progressVIew setProgress:(float)(CMTimeGetSeconds(timeToPlay)/CMTimeGetSeconds(totalTime)*10)];
        
        
        if ( downloadTime== (float)CMTimeGetSeconds(timeToPlay)/CMTimeGetSeconds(totalTime) ) {
            [pfAsset play];
        }else{
         [pfAsset play];
        }
        if (downloadTime>=.10 && downloadFlag==NO) {
            [pfAsset setTimeRange:CMTimeMakeWithSeconds(0, 1000) duration:kCMTimePositiveInfinity onKeyFrame:NO];
            downloadFlag=YES;
            [pfView run];
            [self.progressVIew setHidden:YES];
           
        }
        if (downloadFlag==YES) {
            slider.value = CMTimeGetSeconds(timeToPlay);
        }
    }
     }else{
         if (!touchslider && [pfAsset getStatus] != PF_ASSET_SEEKING)
         {
             downloadFlag=YES;
             CMTime t = [pfAsset getPlaybackTime];
             
             slider.value = CMTimeGetSeconds(t);
         }
     }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)downloadVideo:(id)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideControlsSlowly) withObject:nil afterDelay:HIDE_CONTROL_DELAY];
  //if ([self videosForCoreData:[videoDict valueForKey:@"video_id"]] ) {
    
    if((videoDict!=nil) && ![self videosForCoreDataDownLoad:[videoDict valueForKey:@"video_id"]] ){
//        UIAlertView *alert11 = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:@"Download Started" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
//        [alert11 show];
        [NSThread detachNewThreadSelector:@selector(callThreadForVideo:) toTarget:self withObject:videoDict];
       // [self downloadVideoAndSave:[videoDict objectForKey:@"video_link"] thumbNailURL:[videoDict objectForKey:@"video_thumbnail"] dic:videoDict];
  }else{
        
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"You have already downloaded this video"];
        
    }
}

-(BOOL)videosForCoreDataDownLoad:(NSString*)videoID{
    
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
- (IBAction)playButtonTouched:(id)sender {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideControlsSlowly) withObject:nil afterDelay:HIDE_CONTROL_DELAY];

   /// [self normalButton:sender];
    
    if (pfAsset != nil)
    {
       [pfAsset pause];
         return;
    }else
       [pfAsset play];return;
}


//#define DEFAULT_VIEW_ALPHA 0.6f
-(void) hideControlsWithDuration:(NSTimeInterval)duration
{
    self.playerControlBackgroundView.alpha = DEFAULT_VIEW_ALPHA;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         
                         self.playerControlBackgroundView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         if(finished)
                             self.playerControlBackgroundView.hidden = YES;
                     }];
    
}
-(void) hideControlsWithDurationAllTime:(NSTimeInterval)duration
{
    //self.playerControlBackgroundView.alpha = DEFAULT_VIEW_ALPHA;
    [UIView animateWithDuration:duration
                          delay:2.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         
                         self.playerControlBackgroundView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         if(finished)
                             self.playerControlBackgroundView.hidden = YES;
                     }];
    
}
- (IBAction)gyroButtonTouched:(id)sender {
    
    // change navigation mode
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideControlsSlowly) withObject:nil afterDelay:HIDE_CONTROL_DELAY];

    if (pfView != nil)
    {
        if (currentmode == PF_NAVIGATION_MOTION)
        {
            currentmode = PF_NAVIGATION_TOUCH;
            [pfView  setRotationX:-0.01f];
        }
        else
        {
            [pfView  setRotationX:90.0f];
            currentmode = PF_NAVIGATION_MOTION;
        }
        [self resetViewParameters];
        [pfView setNavigationMode:currentmode];
    }
    
  
    
}
#pragma mark video communication
-(void)downloadVideoAndSave :(NSString*)videoUrl
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *yourVideoData=[NSData dataWithContentsOfURL:[NSURL URLWithString:videoUrl]];
        
        if (yourVideoData) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
            
            NSString  *filePath = [NSString stringWithFormat:@"%@/%ld.mp4", documentsDirectory,(long)[user integerForKey:@"fileName"]];
            
            if([yourVideoData writeToFile:filePath atomically:YES])
            {
                [user setInteger:[user integerForKey:@"fileName"]+1 forKey:@"fileName"];
                NSLog(@"write successfull");
            }
            else{
                NSLog(@"write failed");
            }
        }
    });
}
-(void) hideControlsSlowly
{
    [self hideControlsWithDuration:1.0];
}
#pragma mark back button
- (IBAction)backButtonTouched:(id)sender {
    [self stop];
    app.downloadFlag=@"no";
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.tabBarController.tabBar.hidden = NO;
    // [self updatePlayButton];
    
    for (UIView *btn in [self.tabBarController.view subviews]) {
        if ([btn class]==[UIButton class]&&btn.tag>=1&&btn.tag<=4) {
            UIButton *button=(UIButton *)btn;
            button.hidden=NO;
        }
        
        UIImageView *tabBarBorder=(UIImageView*)[btn viewWithTag:100];
        if(tabBarBorder.tag==100){
            tabBarBorder.hidden=NO;
        }
    }

    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideControlsSlowly) withObject:nil afterDelay:HIDE_CONTROL_DELAY];

    NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    if([_isComingFromDeepLinking isEqualToString:@"true"]){
        _isComingFromDeepLinking = @"false";
       // ViewController *myNewVC = [[ViewController alloc] init];
       // [self presentModalViewController:myNewVC animated:YES];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
   // ViewController *pc = (ViewController *)[mainStoryboard                                                                 instantiateViewControllerWithIdentifier:@"ViewController"];
                                        
        //NavViewController *pc = (NavViewController *)[mainStoryboard                                                                 instantiateViewControllerWithIdentifier:@"videoListNavigation"];
                                        
       // [self presentViewController:pc animated:YES completion:nil];
        
       // [self.navigationController popViewControllerAnimated:true];
        
        self.navigationController.navigationBarHidden = true;
        
        WBTabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"Tabbar"];
        //tbc.selectedIndex=0;
        //[self.navigationController pushViewController:tbc animated:YES];
        [self presentViewController:tbc animated:YES completion:nil];

        
        
    }else{
      [self.navigationController popViewControllerAnimated:YES];
    }
    
    
    
    
}
- (IBAction)switchButton:(id)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hideControlsSlowly) withObject:nil afterDelay:HIDE_CONTROL_DELAY];

    if (modeFlag==kSingle) {
        modeFlag=kDual;
        [pfView setViewMode:3 andAspect:16.0/9.0];
        
    }else{
        modeFlag=kSingle;
        [pfView setViewMode:0 andAspect:16.0/9.0];
        
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) createView
{
    // initialize an PFView
    pfView = [PFObjectFactory viewWithFrame:[self.view bounds]];
    pfView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    // set the appropriate navigation mode PFView
    [pfView setNavigationMode:currentmode];
    [pfView  setRotationX:90.0f];

    [pfView setBlindSpotLocation:PF_BLINDSPOT_BOTTOM];
    
    // add the view to the current stack of views
    [self.view addSubview:pfView];
    [self.view sendSubviewToBack:pfView];
    
    [pfView setViewMode:0 andAspect:16.0/9.0];
    
    // Set some parameters
    [self resetViewParameters];
    
    // start rendering the view
    if (self.videoDict==nil){
        [pfView run];
        [pfAsset play];
         downloadFlag=YES;
    }
}

- (void) resetViewParameters
{
    // set default FOV
   // [pfView setFieldOfView:75.0f];
    // register the interface orientation with the PFView
    [pfView setInterfaceOrientation:self.interfaceOrientation];
    switch(self.interfaceOrientation)
    {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            // Wider FOV which for portrait modes (matter of taste)
            [pfView setFieldOfView:90.0f];
            break;
        default:
            break;
    }
}
- (void) deleteView
{
    // stop rendering the view
    [pfView halt];
    // remove and destroy view
    [pfView removeFromSuperview];
     pfView = nil;
}

- (void) createAssetWithUrl:(NSURL *)url
{
    touchslider = false;
    
    // load an PFAsset from an url
    pfAsset = (id<PFAsset>)[PFObjectFactory assetFromUrl:url observer:(PFAssetObserver*)self];
    [pfAsset setTimeMonitor:self];
    // connect the asset to the view
    [pfView displayAsset:(PFAsset *)pfAsset];
}

- (void) deleteAsset
{
    if (pfAsset == nil)
        return;
    // disconnect the asset from the view
    [pfAsset setTimeMonitor:nil];
    [pfView displayAsset:nil];
    // stop and destroy the asset
    [pfAsset stop];
    pfAsset  = nil;
}



- (void) onPlayerTime:(id<PFAsset>)asset hasTime:(CMTime)time
{
    

}

- (void) onStatusMessage : (id<PFAsset>) asset message:(enum PFASSETMESSAGE) m
{
    NSLog(@"onStatusMessage %d",m);
    
    switch (m) {
        case PF_ASSET_SEEKING:
            NSLog(@"Seeking  ");
          //  seekindicator.hidden = FALSE;
           // [pfAsset pause];
          //  NSLog(@"download progress: %f",[pfAsset getDownloadProgress]);
            break;
        case PF_ASSET_PLAYING:
            NSLog(@"Playing");
           //  NSLog(@"download progress: %f",[pfAsset getDownloadProgress]);
          //  seekindicator.hidden = TRUE;
            if(downloadFlag==YES)[pfAsset setVolume:1.0];else [pfAsset setVolume:0.0];
            CMTime t = [asset getDuration];
            slider.maximumValue = CMTimeGetSeconds(t);
            slider.minimumValue = 0.0;
            [playButton setImage:[UIImage imageNamed:@"playback_pause.png"] forState:UIControlStateNormal];
            slider.enabled = true;
         
            break;
        case PF_ASSET_PAUSED:
            NSLog(@"Paused");
            [playButton setImage:[UIImage imageNamed:@"playback_play.png"] forState:UIControlStateNormal];
           // [playbutton setTitle:@"play" forState:UIControlStateNormal];
            break;
        case PF_ASSET_COMPLETE:
            NSLog(@"Complete");
            [asset setTimeRange:CMTimeMakeWithSeconds(0, 1000) duration:kCMTimePositiveInfinity onKeyFrame:NO];
           // [pfAsset stop];
            break;
        case PF_ASSET_STOPPED:
            NSLog(@"Stopped");
            [self stop];
            slider.value = 0;
            slider.enabled = false;
            break;
            case PF_ASSET_LOADED:
            NSLog(@"loaded");
            break;
        case PF_ASSET_DOWNLOADING:
             NSLog(@"loaded"); break;
        default:
            break;
    }
}


- (void) stop
{
    // stop the view
    [pfView halt];
    
    // delete asset and view
    [self deleteAsset];
    [self deleteView];

}
-(void)orientationChanged:(id)sender{

    if ([UIDevice currentDevice].orientation==UIDeviceOrientationLandscapeRight)
    {
        [self resetViewParameters];
    }
    
}

-(void)callThreadForVideo:(id)sender{
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    app.isDownloading = @"YES";
    
    NSDictionary *videoDictionary=(NSDictionary *)sender;
   
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self downloadVideoAndSave:[videoDictionary objectForKey:@"video_link"] thumbNailURL:[videoDictionary objectForKey:@"video_thumbnail"] dic:videoDictionary :nil];
    
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
            
        //    [lblProgress setProgress:((float)totalBytesRead / totalBytesExpectedToRead)];
            
         //   NSLog(@"downloadComplete.... %f",(float)totalBytesRead / totalBytesExpectedToRead);
        }];
        
        [operation setCompletionBlock:^{
          //  NSLog(@"downloadComplete! %@",videoDic);
            
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
            
            UIAlertView *alert11 = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:@"Download Started. See on download tab." delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
            [alert11 show];
            
            NSLog(@"write successfull image");
            [self addAttributeToAllFolder];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //
            });
            //[lblProgress setHidden:YES];
        }];
        
        
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

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationLandscapeLeft;
//}
//
//- (BOOL)shouldAutorotate {
//    return NO;
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
//  //  [image_signature setImage:[self resizeImage:image_signature.image]];
//    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
//}
//-(BOOL)shouldAutorotate {
//    return NO;
//}
//- (NSUInteger)supportedInterfaceOrientations {
// //   [image_signature setImage:[self resizeImage:image_signature.image]];
//    return UIInterfaceOrientationMaskLandscapeLeft;
//}
@end
