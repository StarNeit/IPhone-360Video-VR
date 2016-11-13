//
//  VIDVideoPlayerViewController.m
//  Video360
//
//  Created by Jean-Baptiste Rieu on 24/05/13.
//  Copyright (c) 2013 Video360 Developper. All rights reserved.
//

#import "VIDVideoPlayerViewController.h"
#import "VIDGlkViewController.h"
#import "Global.h"
#import "AppDelegate.h"
#import "VideoDownload.h"

#define ONE_FRAME_DURATION 0.03

#define HIDE_CONTROL_DELAY 5.0f
#define DEFAULT_VIEW_ALPHA 0.6f

#define kDual 0
#define kSingle 1
#define kCancel 2

#import "Constant.h"

int modeFlag;

NSString * const kTracksKey         = @"tracks";
NSString * const kPlayableKey		= @"playable";
NSString * const kRateKey			= @"rate";
NSString * const kCurrentItemKey	= @"currentItem";
NSString * const kStatusKey         = @"status";

static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;

static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;

@interface VIDVideoPlayerViewController ()
{
    VIDGlkViewController *_glkViewController;
    VIDGlkViewController *glkViewController;
    AVPlayerItemVideoOutput* _videoOutput;
    AVPlayer* _player;
    AVPlayerItem* _playerItem;
    dispatch_queue_t _myVideoOutputQueue;
    id _notificationToken;
    id _timeObserver;
    
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    
    
}


@end

@implementation VIDVideoPlayerViewController
@synthesize videoPath,localVideoPath,videoDict,managedObjectContext,flagPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString *)url
{
    //    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    //    if (self) {
    //        [self setVideoPath:url];
    //    }
    return self;
}

-(void)setupVideoPlaybackForLocalURL:(NSURL*)url
{
    
    NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
    _myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
    [_videoOutput setDelegate:self queue:_myVideoOutputQueue];
    
    _player = [[AVPlayer alloc] init];
    
    // Do not take mute button into account
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory:AVAudioSessionCategoryPlayback
                    error:&error];
    if (!success) {
        NSLog(@"Could not use AVAudioSessionCategoryPlayback", nil);
    }
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[[asset URL] path]]) {
        NSLog(@"file does not exist");
    }
    
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
    
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        
        dispatch_async( dispatch_get_main_queue(),
                       ^{
                           
                           for (NSString *thisKey in requestedKeys)
                           {
                               NSError *error = nil;
                               AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
                               if (keyStatus == AVKeyValueStatusFailed)
                               {
                                   [self assetFailedToPrepareForPlayback:error];
                                   return;
                               }
                           }
                           
                           NSError* error = nil;
                           AVKeyValueStatus status = [asset statusOfValueForKey:kTracksKey error:&error];
                           if (status == AVKeyValueStatusLoaded)
                           {
                               _playerItem = [AVPlayerItem playerItemWithAsset:asset];
                               
                               
                               [_playerItem addOutput:_videoOutput];
                               [_player replaceCurrentItemWithPlayerItem:_playerItem];
                               [_videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ONE_FRAME_DURATION];
                               
                               [[NSNotificationCenter defaultCenter] addObserver:self
                                                                        selector:@selector(playerItemDidReachEnd:)
                                                                            name:AVPlayerItemDidPlayToEndTimeNotification
                                                                          object:_playerItem];
                               
                               seekToZeroBeforePlay = NO;
                               
                               [_playerItem addObserver:self
                                             forKeyPath:kStatusKey
                                                options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                                context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
                               
                               [_player addObserver:self
                                         forKeyPath:kCurrentItemKey
                                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                            context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
                               
                               [_player addObserver:self
                                         forKeyPath:kRateKey
                                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                            context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
                               
                               
                               [self initScrubberTimer];
                               
                               [self syncScrubber];
                               [self syncScrubberBuffering];
                               
                           }
                           else
                           {
                               NSLog(@"%@ Failed to load the tracks.", self);
                           }
                       });
    }];
    
    
}

-(void)viewDidLoad
{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext=app.managedObjectContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    
    UIDevice *device = [UIDevice currentDevice];					//Get the device object
    [device beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];	//Get the notification centre for the app
    [nc addObserver:self											//Add yourself as an observer
           selector:@selector(orientationChanged:)
               name:UIDeviceOrientationDidChangeNotification
             object:device];
    
    
    modeFlag=kSingle;
    if ([flagPath isEqualToString:@"local"]) {
        [self setupVideoPlaybackForLocalURL:[NSURL fileURLWithPath:videoPath]];
    }else{
        [self setupVideoPlaybackForURL:videoPath];
    }
    
    
    [self configureGLKView];
    [self configurePlayButton];
    [self configureProgressSlider];
    [self configureControleBackgroundView];
    [self configureBackButton];
    [self configureGyroButton];
    
    
#if SHOW_DEBUG_LABEL
    self.debugView.hidden = NO;
#endif
}
#pragma mark Orientation
//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationLandscapeLeft;
//}
//
//
//- (BOOL) shouldAutorotate {
//    return NO;
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
//{
//    return UIInterfaceOrientationIsLandscape(UIInterfaceOrientationLandscapeLeft);
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationLandscapeLeft/* |UIInterfaceOrientationPortrait|UIInterfaceOrientationLandscapeRight*/ ;
//}
-(void)viewDidAppear:(BOOL)animated{
    
    
    //   NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    //   [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

-(void)viewDidDisappear:(BOOL)animated{
    
       [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.tabBarController.tabBar.hidden = NO;
    
//     NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationIsPortrait(UIDeviceOrientationPortrait)];
//     [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
 
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self pause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self updatePlayButton];
    [_player seekToTime:[_player currentTime]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(__bridge NSString *)(AVPlayerDemoPlaybackViewControllerRateObservationContext) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self setPlayerControlBackgroundView:nil];
    [self setPlayButton:nil];
    [self setProgressSlider:nil];
    [self setBackButton:nil];
    _glkViewController=nil;
    glkViewController=nil;
    _videoOutput=nil;_player=nil;_playerControlBackgroundView=nil;_playerItem=nil;
    
    //[AVQueuePlayer removeTimeObserver:self];
  
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [super viewWillDisappear:animated];
    
    @try{
        [self removePlayerTimeObserver];
        [_playerItem removeObserver:self forKeyPath:kStatusKey];
        [_playerItem removeOutput:_videoOutput];
        [_player removeObserver:self forKeyPath:kCurrentItemKey];
        [_player removeObserver:self forKeyPath:kRateKey];
    }@catch(id anException){
        //do nothing
    }
    _videoOutput = nil;
    _playerItem = nil;
    _player = nil;
    self.view=nil;
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.tabBarController.tabBar.hidden = NO;
    [self updatePlayButton];
    
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

-(void)viewWillAppear:(BOOL)animated
{
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = YES;
    [self updatePlayButton];
    
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
            
            NSString  *filePath = [NSString stringWithFormat:@"%@/%d.mp4", documentsDirectory,[user integerForKey:@"fileName"]];
            
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


- (CVPixelBufferRef) retrievePixelBufferToDraw
{
    CVPixelBufferRef pixelBuffer = [_videoOutput copyPixelBufferForItemTime:[_playerItem currentTime] itemTimeForDisplay:nil];
    
    return pixelBuffer;
}

#pragma mark video setting
- (IBAction)modeChange:(id)sender{
    
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Mode" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:                         @"Dual",@"Single",nil];
    
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)switchButton:(id)sender {
    
    if (modeFlag==kSingle) {
        modeFlag=kDual;
        [self configureGLKView];
    }else{
        modeFlag=kSingle;
        [self configureGLKView];
    }
    
}

- (IBAction)downloadVideo:(id)sender {
    if(videoDict!=nil){
        VideoDownload *video = (VideoDownload *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoDownload" inManagedObjectContext:managedObjectContext];
        
        [video setCategory:[videoDict objectForKey:@"category_name"]];
        [video setVideoCity:[videoDict objectForKey:@"video_city"]];
        [video setVideoId:[NSNumber numberWithInt:[[videoDict objectForKey:@"video_id"] intValue]]];
        
        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
        
        if ([user integerForKey:@"fileName"]==nil) {
            [user setInteger:0 forKey:@"fileName"];
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString  *filePath = [NSString stringWithFormat:@"%@/%d.mp4", documentsDirectory,[user integerForKey:@"fileName"]];
        NSString  *fileVideoPath = [NSString stringWithFormat:@"%@/%d.jpg", documentsDirectory,[user integerForKey:@"fileName"]];
        
        
        [video setVideoLink:filePath];
        [video setVideoTitle:[Global getStringValue:[videoDict objectForKey:@"video_title"]]];
        [video setUploadDate:[Global getStringValue:[videoDict objectForKey:@"upload_date"]]];
        [video setMetaData:[Global getStringValue:[videoDict objectForKey:@"meta_data"]]];
        [video setVideoThumbnail:fileVideoPath];
        [video setSubcategory:[Global getStringValue:[videoDict objectForKey:@"subcategory_name"]]];
        [video setVideoDescription:[Global getStringValue:[videoDict objectForKey:@"video_description"]]];
        [video setVideoType:[Global getStringValue:[videoDict objectForKey:@"videotype"]]];
        
        // Commit the change.
        NSError *error;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
        
        [self downloadVideoAndSave:[videoDict objectForKey:@"video_link"]];
        
        
    }else{
        
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"You have already downloaded this video"];
        
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case kDual:
            modeFlag=kDual;
            [self configureGLKView];
            break;
            
        case kSingle:
            modeFlag=kSingle;
            [self configureGLKView];
            break;
            
        case kCancel:
            
            break;
            
        default:
            
            break;
    }
}

-(void)setupVideoPlaybackForURL:(NSString*)path
{
    
    NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
    _myVideoOutputQueue = dispatch_queue_create("myVideoOutputQueue", DISPATCH_QUEUE_SERIAL);
    [_videoOutput setDelegate:self queue:_myVideoOutputQueue];
    
    _player = [[AVPlayer alloc] init];
    
    // Do not take mute button into account
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory:AVAudioSessionCategoryPlayback
                    error:&error];
    if (!success) {
        NSLog(@"Could not use AVAudioSessionCategoryPlayback", nil);
    }
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:path] options:nil];
    
    
    //    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    //
    //    NSError *err = NULL;
    //    CMTime time = CMTimeMake(1, 60);
    //
    //    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    //    UIImage *thumbnail = [UIImage imageWithCGImage:imgRef];
    //
    //    UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    //    imgView.image=thumbnail;
    //    [self.view addSubview:imgView];
    
    
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
    
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        
        dispatch_async( dispatch_get_main_queue(),
                       ^{
                           /* Make sure that the value of each key has loaded successfully. */
                           for (NSString *thisKey in requestedKeys)
                           {
                               NSError *error = nil;
                               AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
                               if (keyStatus == AVKeyValueStatusFailed)
                               {
                                   [self assetFailedToPrepareForPlayback:error];
                                   return;
                               }
                           }
                           
                           NSError* error = nil;
                           AVKeyValueStatus status = [asset statusOfValueForKey:kTracksKey error:&error];
                           if (status == AVKeyValueStatusLoaded)
                           {
                               _playerItem = [AVPlayerItem playerItemWithAsset:asset];
                               
                               
                               [_playerItem addOutput:_videoOutput];
                               [_player replaceCurrentItemWithPlayerItem:_playerItem];
                               [_videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:ONE_FRAME_DURATION];
                               
                               /* When the player item has played to its end time we'll toggle
                                the movie controller Pause button to be the Play button */
                               [[NSNotificationCenter defaultCenter] addObserver:self
                                                                        selector:@selector(playerItemDidReachEnd:)
                                                                            name:AVPlayerItemDidPlayToEndTimeNotification
                                                                          object:_playerItem];
                               
                               seekToZeroBeforePlay = NO;
                               
                               [_playerItem addObserver:self
                                             forKeyPath:kStatusKey
                                                options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                                context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
                               NSLog(@"ranges : %@",_playerItem.loadedTimeRanges);
                               //    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
                               
                               [_player addObserver:self
                                         forKeyPath:kCurrentItemKey
                                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                            context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
                               
                               [_player addObserver:self
                                         forKeyPath:kRateKey
                                            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                            context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
                               
                               
                               [self initScrubberTimer];
                               
                               [self syncScrubber];
                               
                               
                               
                               //    CVPixelBufferRef buffer = [[self output] copyPixelBufferForItemTime:[[self playerItem] currentTime] itemTimeForDisplay:nil];
                           }
                           else
                           {
                               NSLog(@"%@  ", self);
                           }
                       });
    }];
}

#pragma mark rendering glk view management
-(void)configureGLKView
{
    for (UIView *view in self.view.subviews) {
        if ([view class]==[GLKView class]) {
            [view removeFromSuperview];
        }
    }
    
    switch (modeFlag) {
            
        case kSingle:
            _glkViewController = [[VIDGlkViewController alloc] init];
            
            _glkViewController.videoPlayerController = self;
            
            [self.view insertSubview:_glkViewController.view belowSubview:_playerControlBackgroundView];
            
            [self addChildViewController:_glkViewController];
            [_glkViewController didMoveToParentViewController:self];
            
            //    _glkViewController.view.frame = self.view.bounds;
            _glkViewController.view.frame= self.view.bounds;
            
            
            break;
            
        case kDual:
            
            _glkViewController = [[VIDGlkViewController alloc] init];
            
            _glkViewController.videoPlayerController = self;
            
            [self.view insertSubview:_glkViewController.view belowSubview:_playerControlBackgroundView];
            [self addChildViewController:_glkViewController];
            [_glkViewController didMoveToParentViewController:self];
            
            _glkViewController.view.frame= CGRectMake(0,0,self.view.frame.size.width/2 /*self.view.frame.size.width/4*/ , self.view.frame.size.height);
            
            glkViewController = [[VIDGlkViewController alloc] init];
            
            glkViewController.videoPlayerController = self;
            
            [self.view insertSubview:glkViewController.view belowSubview:_playerControlBackgroundView];
            [self addChildViewController:glkViewController];
            [_glkViewController didMoveToParentViewController:self];
            
            glkViewController.view.frame=CGRectMake( self.view.frame.size.width/2 ,0,     self.view.frame.size.width/2 , self.view.frame.size.height);
            
            break;
            
        default:
            break;
    }
    
    if(_glkViewController.isUsingMotion)
    {
        [_glkViewController stopDeviceMotion];
        [glkViewController stopDeviceMotion];
        
    }else{
        [_glkViewController startDeviceMotion];
        [glkViewController startDeviceMotion];
    }
    
    _gyroButton.selected = _glkViewController.isUsingMotion;
    _gyroButton.selected = glkViewController.isUsingMotion;
    // _glkViewController.videoPlayerController.view.layer.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0].CGColor;
}




#pragma mark play button management
-(void)configurePlayButton
{
    
    _playButton.backgroundColor = [UIColor clearColor];
    _playButton.showsTouchWhenHighlighted = YES;
    
    [self disablePlayerButtons];
    
    [self updatePlayButton];
}

- (IBAction)playButtonTouched:(id)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if([self isPlaying]){
        [self pause];
    }else{
        [self play];
    }
}

- (void) updatePlayButton
{
    
    [_playButton setImage:[UIImage imageNamed:[self isPlaying] ? @"playback_pause" : @"playback_play"]
                 forState:UIControlStateNormal];
}

-(void) play
{
    if ([self isPlaying])
        return;
    /* If we are at the end of the movie, we must seek to the beginning first
     before starting playback. */
    if (YES == seekToZeroBeforePlay)
    {
        seekToZeroBeforePlay = NO;
        [_player seekToTime:kCMTimeZero];
    }
    
    [self updatePlayButton];
    [_player play];
    
    [self scheduleHideControls];
}

- (void) pause
{
    if (![self isPlaying])
        return;
    
    [self updatePlayButton];
    [_player pause];
    
    [self scheduleHideControls];
}

#pragma mark progress slider management
-(void) configureProgressSlider
{
    _progressSlider.continuous = NO;
    _progressSlider.value = 0;
    
    [_progressSlider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateNormal];
    [_progressSlider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateHighlighted];
}

#pragma mark back and gyro button management
-(void) configureBackButton
{
    _backButton.backgroundColor = [UIColor clearColor];
    _backButton.showsTouchWhenHighlighted = YES;
    
}

-(void) configureGyroButton
{
    _gyroButton.backgroundColor = [UIColor clearColor];
    _gyroButton.showsTouchWhenHighlighted = YES;
    
}





#pragma mark controls management

-(void)enablePlayerButtons
{
    _playButton.enabled = YES;
    _backButton.enabled = YES;
}

-(void)disablePlayerButtons
{
    _playButton.enabled = NO;
    _backButton.enabled = NO;
    
}

-(void)configureControleBackgroundView
{
    
    _playerControlBackgroundView.layer.cornerRadius = 8;
    
}

-(void) toggleControls
{
    if ([UIDevice currentDevice].orientation==UIDeviceOrientationLandscapeRight)
    {
        if(_playerControlBackgroundView.hidden){
            [self showControlsFast];
        }else{
            [self hideControlsFast];
        }
        [self scheduleHideControls];
    }
}

-(void) scheduleHideControls
{
    if(!_playerControlBackgroundView.hidden)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(hideControlsSlowly) withObject:nil afterDelay:HIDE_CONTROL_DELAY];
    }
}

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

-(void) hideControlsFast
{
    [self hideControlsWithDuration:0.2];
}

-(void) hideControlsSlowly
{
    [self hideControlsWithDuration:1.0];
}

-(void) showControlsFast
{
    _playerControlBackgroundView.alpha = 0.0;
    _playerControlBackgroundView.hidden = NO;
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         
                         _playerControlBackgroundView.alpha = DEFAULT_VIEW_ALPHA;
                     }
                     completion:nil];
}

- (void)removeTimeObserverFro_player
{
    if (_timeObserver)
    {
        [_player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}


#pragma mark slider progress management
-(void)initScrubberTimer
{
    double interval = 0.1f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([_progressSlider bounds]);
        interval = 0.5f * duration / width;
    }
    
     [self removeTimeObserverFro_player];
    
    __weak VIDVideoPlayerViewController* weakSelf = self;
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                          queue:NULL /* If you pass NULL, the main queue is used. */
                                                     usingBlock:^(CMTime time)
                     {
                         [weakSelf syncScrubber];
                         [weakSelf syncScrubberBuffering];
                     }];
    
}
- (CMTime)playerItemDurationBuffering
{
    if(_playerItem.status== AVPlayerItemStatusUnknown){
        return([_playerItem duration]);
    }
    //    if (_playerItem.status == AVPlayerItemStatusReadyToPlay)
    //    {
    //        /*
    //         NOTE:
    //         Because of the dynamic nature of HTTP Live Streaming Media, the best practice
    //         for obtaining the duration of an AVPlayerItem object has changed in iOS 4.3.
    //         Prior to iOS 4.3, you would obtain the duration of a player item by fetching
    //         the value of the duration property of its associated AVAsset object. However,
    //         note that for HTTP Live Streaming Media the duration of a player item during
    //         any particular playback session may differ from the duration of its asset. For
    //         this reason a new key-value observable duration property has been defined on
    //         AVPlayerItem.
    //
    //         See the AV Foundation Release Notes for iOS 4.3 for more information.
    //         */
    //        return([_playerItem duration]);
    //    }
    
    return(kCMTimeInvalid);
}
- (CMTime)playerItemDuration
{
    //    if(_playerItem.status== AVPlayerItemStatusUnknown){
    //    return([_playerItem duration]);
    //    }
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        /*
         NOTE:
         Because of the dynamic nature of HTTP Live Streaming Media, the best practice
         for obtaining the duration of an AVPlayerItem object has changed in iOS 4.3.
         Prior to iOS 4.3, you would obtain the duration of a player item by fetching
         the value of the duration property of its associated AVAsset object. However,
         note that for HTTP Live Streaming Media the duration of a player item during
         any particular playback session may differ from the duration of its asset. For
         this reason a new key-value observable duration property has been defined on
         AVPlayerItem.
         
         See the AV Foundation Release Notes for iOS 4.3 for more information.
         */
        return([_playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}
- (void)syncScrubberBuffering
{
    CMTime playerDuration = [self playerItemDurationBuffering];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        _progressBuffering.minimumValue = 0.0f;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [_progressBuffering minimumValue];
        float maxValue = [_progressBuffering maximumValue];
        double time = CMTimeGetSeconds([_player currentTime]);
        
        [_progressBuffering setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

- (void)syncScrubber
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        _progressSlider.minimumValue = 0.0f;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [_progressSlider minimumValue];
        float maxValue = [_progressSlider maximumValue];
        double time = CMTimeGetSeconds([_player currentTime]);
        
        [_progressSlider setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (IBAction)beginScrubbing:(id)sender
{
    mRestoreAfterScrubbingRate = [_player rate];
    [_player setRate:0.0f];
    
    /* Remove previous timer. */
    [self removeTimeObserverFro_player];
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]])
    {
        UISlider* slider = sender;
        
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            float minValue = [slider minimumValue];
            float maxValue = [slider maximumValue];
            float value = [slider value];
            
            double time = duration * (value - minValue) / (maxValue - minValue);
            
            [_player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
        }
    }
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (IBAction)endScrubbing:(id)sender
{
    if (!_timeObserver)
    {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            CGFloat width = CGRectGetWidth([_progressSlider bounds]);
            double tolerance = 0.5f * duration / width;
            
            __weak VIDVideoPlayerViewController* weakSelf = self;
            _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:
                             ^(CMTime time)
                             {
                                 [weakSelf syncScrubber];
                                 [weakSelf syncScrubberBuffering];
                             }];
        }
    }
    
    if (mRestoreAfterScrubbingRate)
    {
        [_player setRate:mRestoreAfterScrubbingRate];
        mRestoreAfterScrubbingRate = 0.0f;
    }
}

- (BOOL)isScrubbing
{
    return mRestoreAfterScrubbingRate != 0.0f;
}

-(void)enableScrubber
{
    _progressSlider.enabled = YES;
}

-(void)disableScrubber
{
    _progressSlider.enabled = NO;
}
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
//                        change:(NSDictionary *)change context:(void *)context {
//
//    if(object == _player.currentItem && [keyPath isEqualToString:@"loadedTimeRanges"]){
//
//        NSArray *timeRanges = (NSArray*)[change objectForKey:NSKeyValueChangeNewKey];
//        if (timeRanges && [timeRanges count]) {
//            CMTimeRange timerange=[[timeRanges objectAtIndex:0]CMTimeRangeValue];
//
//
//        }
//    }
//}
- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    
    /* AVPlayerItem "status" property value observer. */
    
    if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext)
    {
        [self updatePlayButton];
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                [self syncScrubberBuffering];
                [self disableScrubber];
                [self disablePlayerButtons];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                [self initScrubberTimer];
                
                [self enableScrubber];
                [self enablePlayerButtons];
            }
                break;
                
                
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
                NSLog(@"Error fail : %@", playerItem.error);
            }
                break;
        }
    }else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext)
    {
        [self updatePlayButton];
    }
    
    else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext)
    {
        
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self syncScrubberBuffering];
    [self disableScrubber];
    [self disablePlayerButtons];
    
     _backButton.enabled = YES;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (BOOL)isPlaying
{
    return mRestoreAfterScrubbingRate != 0.0f || [_player rate] != 0.0f;
}

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    /* After the movie has played to its end time, seek back to time zero
     to play it again. */
    seekToZeroBeforePlay = YES;
}

#pragma mark gyro button
- (IBAction)gyroButtonTouched:(id)sender {
    
    if(_glkViewController.isUsingMotion)
    {
        [_glkViewController stopDeviceMotion];
        [glkViewController stopDeviceMotion];
        
    }else{
        [_glkViewController startDeviceMotion];
        [glkViewController startDeviceMotion];
    }
    
    _gyroButton.selected = _glkViewController.isUsingMotion;
    _gyroButton.selected = glkViewController.isUsingMotion;
    
}

#pragma mark back button
- (IBAction)backButtonTouched:(id)sender {
    [self removePlayerTimeObserver];
    
    [_player pause];
    
    [_glkViewController removeFromParentViewController];
    _glkViewController = nil;
    
    
    glkViewController=nil;
   // _videoOutput=nil;_player=nil;_playerControlBackgroundView=nil;_playerItem=nil;

    //  [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    // [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
    if (_timeObserver)
    {
        [_player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}
//- (BOOL)shouldAutorotate {
//    return YES;
//}
//
//- (NSUInteger)supportedInterfaceOrientations{
//    //return supported orientation masks
//    return UIInterfaceOrientationMaskLandscape;
//}
-(void)orientationChanged:(id)sender{
    
    NSLog(@"orientation : %d",[UIDevice currentDevice].orientation );
    
    // [[self.view viewWithTag:100]removeFromSuperview];
    if ([UIDevice currentDevice].orientation==UIDeviceOrientationLandscapeRight)
    {
      //  modeFlag=0;
       // [self configureGLKView];
        [self.playerControlBackgroundView setHidden:NO];
        
        //        UIImageView *topBorder=[[UIImageView alloc]initWithFrame:CGRectMake(0, 516, 320, 1)];
        //        topBorder.tag=100;
        //        topBorder.image=[UIImage imageNamed:@"logoborder.jpg"];
        // [self.view addSubview:topBorder];
    }
    else  if ([UIDevice currentDevice].orientation==UIDeviceOrientationPortrait){
        [self.playerControlBackgroundView setHidden:YES];
       // modeFlag=1;
      //  [self configureGLKView];
        //        UIImageView *topBorder=[[UIImageView alloc]initWithFrame:CGRectMake(0, 270, 568, 1)];
        //        topBorder.image=[UIImage imageNamed:@"logoborder.jpg"];
        //        topBorder.tag=100;
        //        [self.view addSubview:topBorder];
    }
}


@end
