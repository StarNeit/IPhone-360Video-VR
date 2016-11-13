//
//  SimplePlayerViewController.m
//  SimplePlayer
//
//  Created by Ron Bakker on 18-06-13.
//  Copyright (c) 2013 Mindlight. All rights reserved.
//

#import "PlayerViewController.h"
#import <Panframe/Panframe.h>
#import "VideoDownload.h"
#import "Global.h"
#import "Constant.h"

#import "AppDelegate.h"
#define kDual 0
#define kSingle 1
#define kCancel 2

int modeFlag;

@interface PlayerViewController () <PFAssetObserver, PFAssetTimeMonitor>
{
    PFView * pfView;
    id<PFAsset> pfAsset;
    enum PFNAVIGATIONMODE currentmode;
    bool touchslider;
    NSTimer *slidertimer;
    int currentview;
    
    IBOutlet UIButton *playbutton;
    IBOutlet UIButton *stopbutton;
    IBOutlet UIButton *navbutton;
    IBOutlet UIButton *viewbutton;
    IBOutlet UISlider *slider;
    
    IBOutlet UIActivityIndicatorView *seekindicator;
    
    UIImage *pauseImage;
}

- (void) onStatusMessage : (PFAsset *) asset message:(enum PFASSETMESSAGE) m;
- (void) onPlayerTime:(id<PFAsset>)asset hasTime:(CMTime)time;

@end

@implementation PlayerViewController
@synthesize videoDict,videoPath,view,managedObjectContext;

//-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
//    }
//    return self;
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //[Global setFontRecursively:self.view];

    slider.value = 0;
    slider.enabled = false;
    slider.hidden=YES;
    [slider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateSelected];
    [slider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateDisabled];
    
    slidertimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                   target: self
                                                 selector:@selector(onPlaybackTime:)
                                                 userInfo: nil repeats:YES];
    
    seekindicator.hidden = TRUE;
    
    currentmode = PF_NAVIGATION_MOTION;
    currentview = 0;
    [self normalButton:viewbutton];
    [self normalButton:navbutton];
    [self normalButton:playbutton];
    [self normalButton:stopbutton];
    
    pauseImage = [UIImage imageNamed:@"pausescreen.png"];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [view addGestureRecognizer:pinchRecognizer];
}

-(void)onPlaybackTime:(NSTimer *)timer
{
    // retrieve the playback time from an asset and update the slider
    
    if (pfAsset == nil)
        return;
    if (!touchslider && [pfAsset getStatus] != PF_ASSET_SEEKING)
    {
        CMTime t = [pfAsset getPlaybackTime];
        
        slider.value = CMTimeGetSeconds(t);
    }
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
//}
//
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    [self resetViewParameters];
//}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    [pfView setFieldOfView:100.0f];
}

- (void) resetViewParameters
{
    // set default FOV
    [pfView setFieldOfView:75.0f];
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

- (void) createView
{
    // initialize an PFView
    pfView = [PFObjectFactory viewWithFrame:[self.view bounds]];
    //pfView = [PFObjectFactory viewWithFrame:CGRectMake(20, 20, 200, 200)];
    pfView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    // set the appropriate navigation mode PFView
    [pfView setNavigationMode:currentmode];
    
    // set an optional blackspot image
    [pfView setBlindSpotImage:@"blackspot.png"];
    [pfView setBlindSpotLocation:PF_BLINDSPOT_BOTTOM];
    
    // add the view to the current stack of views
    [self.view addSubview:pfView];
    [self.view sendSubviewToBack:pfView];
    
    [pfView setViewMode:0 andAspect:16.0/9.0];
    
    // Set some parameters
    [self resetViewParameters];
    
    // start rendering the view
    [pfView run];

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
    switch (m) {
        case PF_ASSET_SEEKING:
            NSLog(@"Seeking");
            seekindicator.hidden = FALSE;
            break;
        case PF_ASSET_PLAYING:
            NSLog(@"Playing");
            seekindicator.hidden = TRUE;
            CMTime t = [asset getDuration];
            slider.maximumValue = CMTimeGetSeconds(t);
            slider.minimumValue = 0.0;
            [playbutton setTitle:@"pause" forState:UIControlStateNormal];
            slider.enabled = true;
            break;
        case PF_ASSET_PAUSED:
            NSLog(@"Paused");
            [pfView setFieldOfView:100.0f];

            [playbutton setTitle:@"play" forState:UIControlStateNormal];
            break;
        case PF_ASSET_COMPLETE:
            NSLog(@"Complete");
            [asset setTimeRange:CMTimeMakeWithSeconds(0, 1000) duration:kCMTimePositiveInfinity onKeyFrame:NO];
            break;
        case PF_ASSET_STOPPED:
            NSLog(@"Stopped");
            [self stop];
            slider.value = 0;
            slider.enabled = false;
            break;
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
    
    [playbutton setTitle:@"play" forState:UIControlStateNormal];
}

- (IBAction) stopButton:(id) sender
{
    [self normalButton:sender];
    /*
    if (pfAsset == nil)
        return;
    */
    [self stop];
}

- (IBAction) playButton:(id) sender
{
    [self normalButton:sender];
    
    if (pfAsset != nil)
    {
        [pfAsset pause];
        [pfView injectImage:pauseImage];
        return;
    }
    
    // create a Panframe view
    [self createView];

    // create some hotspots
   // [self createHotspots];
    
    
    // create a Panframe asset
    [self createAssetWithUrl:[NSURL URLWithString:@"http://360degreemea.s3.amazonaws.com/1419012241.mp4"]];
    
    if ([pfAsset getStatus] == PF_ASSET_ERROR)
        [self stop];
    else
        [pfAsset play];
}

- (IBAction) toggleNavigation:(id) sender
{
    // change navigation mode
    
    if (pfView != nil)
    {
        if (currentmode == PF_NAVIGATION_MOTION)
        {
            currentmode = PF_NAVIGATION_TOUCH;
            [navbutton setTitle:@"touch" forState:UIControlStateNormal];
        }
        else
        {
            currentmode = PF_NAVIGATION_MOTION;
            [navbutton setTitle:@"motion" forState:UIControlStateNormal];
        }
        [pfView setNavigationMode:currentmode];
    }
    
    [self normalButton:navbutton];
}

- (IBAction) toggleView:(id) sender
{
    if (pfView != nil)
    {
        if (currentview == 0)
        {
            currentview = 1;
            [viewbutton setTitle:@"flat" forState:UIControlStateNormal];
        }
        else
        {
            currentview = 0;
            [viewbutton setTitle:@"sphere" forState:UIControlStateNormal];
        }
        [pfView setViewMode:currentview andAspect:2.0/1.0];
    }
    
    [self normalButton:viewbutton];
}

- (IBAction) hiliteButton:(id) sender
{
    UIButton *b = (UIButton *) sender;
    b.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:72.0/255.0 blue:160.0/255.0 alpha:1.0];
}

- (IBAction) normalButton:(id) sender
{
    UIButton *b = (UIButton *) sender;
    b.backgroundColor = [UIColor colorWithRed:127.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:1.0];
}

- (IBAction) sliderChanged:(id) sender
{    
}

- (IBAction) sliderUp:(id) sender
{
    if (pfAsset != nil)
        [pfAsset setTimeRange:CMTimeMakeWithSeconds(slider.value, 1000) duration:kCMTimePositiveInfinity onKeyFrame:NO];
    touchslider = false;
}

- (IBAction) sliderDown:(id) sender
{
    touchslider = true;
}
- (IBAction)downloadVideo:(id)sender {
    if(videoDict!=nil){
        UIAlertView *alert11 = [[UIAlertView alloc] initWithTitle:@"360 VUZ" message:@"Download Started" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil,nil];
        [alert11 show];

        
        VideoDownload *video = (VideoDownload *)[NSEntityDescription insertNewObjectForEntityForName:@"VideoDownload" inManagedObjectContext:managedObjectContext];
        
        [video setCategory:[Global getStringValue:[videoDict objectForKey:@"category_name"]]];
        [video setVideoCity:[Global getStringValue:[videoDict objectForKey:@"video_city"]]];
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
- (IBAction)gyroButtonTouched:(id)sender {

}

#pragma mark Animation
-(void) hideControlsWithDuration:(NSTimeInterval)duration
{
//    self.playerControlBackgroundView.alpha = DEFAULT_VIEW_ALPHA;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         
                         _playerControlBackgroundView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         if(finished)
                             _playerControlBackgroundView.hidden = YES;
                     }];
    
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

#pragma mark back button
- (IBAction)backButtonTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)switchButton:(id)sender {
    
    if (modeFlag==kSingle) {
        modeFlag=kDual;
     //   [self configureGLKView];
    }else{
        modeFlag=kSingle;
     //   [self configureGLKView];
    }
    
}
@end
