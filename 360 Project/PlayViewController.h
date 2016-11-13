//
//  PlayViewController.h
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 1/19/15.
//  Copyright (c) 2015 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KAProgressLabel.h"
#import "ViewController.h"

@interface PlayViewController : UIViewController<NSStreamDelegate>

@property (strong, nonatomic) NSString *localVideoPath;
@property (strong, nonatomic) NSDictionary *videoDict;
@property(nonatomic,retain)NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *videoPath;
@property (strong, nonatomic) NSString *flagPath;

@property (strong, nonatomic) NSMutableArray *localArrVideos;


@property (strong, nonatomic) NSString *isComingFromDeepLinking;
@property (strong, nonatomic) IBOutlet KAProgressLabel *progressVIew;
@property (strong, nonatomic) IBOutlet UIView *playerControlBackgroundView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton, *closeButton;
@property (strong, nonatomic) IBOutlet UIButton *gyroButton;
@property (strong, nonatomic) IBOutlet UIButton *mirrorButton;
@property (strong, nonatomic) IBOutlet UIButton *downloadButton;
- (IBAction)playButtonTouched:(id)sender;
- (IBAction)gyroButtonTouched:(id)sender;
- (IBAction)backButtonTouched:(id)sender;
- (IBAction)switchButton:(id)sender;
- (IBAction)downloadVideo:(id)sender;

@end
