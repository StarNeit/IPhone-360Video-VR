//
//  VIDVideoPlayerViewController.h
//  Video360
//
//  Created by Jean-Baptiste Rieu on 24/05/13.
//  Copyright (c) 2013 Video360 Developper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VIDVideoPlayerViewController : UIViewController<AVPlayerItemOutputPullDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) NSString *videoPath;
@property (strong, nonatomic) NSString *flagPath;
@property (strong, nonatomic) IBOutlet UIView *playerControlBackgroundView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UISlider *progressSlider;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *gyroButton;

@property (strong, nonatomic) IBOutlet UISlider *progressBuffering;
@property (strong, nonatomic) NSString *localVideoPath;
@property (strong, nonatomic) NSDictionary *videoDict;
@property(nonatomic,retain)NSManagedObjectContext *managedObjectContext;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL*)url;

-(CVPixelBufferRef) retrievePixelBufferToDraw;
-(void) toggleControls;
- (IBAction)modeChange:(id)sender;

- (IBAction)switchButton:(id)sender;

- (IBAction)downloadVideo:(id)sender;
@end
