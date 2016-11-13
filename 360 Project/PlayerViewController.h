//
//  SimplePlayerViewController.h
//  SimplePlayer
//
//  Created by Ron Bakker on 18-06-13.
//  Copyright (c) 2013 Mindlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerViewController : UIViewController<NSStreamDelegate>


@property (strong, nonatomic) NSString *localVideoPath;
@property (strong, nonatomic) NSDictionary *videoDict;
@property(nonatomic,retain)NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *videoPath;
@property (strong, nonatomic) NSString *flagPath;


@property (strong, nonatomic) IBOutlet UIView *playerControlBackgroundView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton, *closeButton;
@property (strong, nonatomic) IBOutlet UIButton *gyroButton;


- (IBAction)switchButton:(id)sender;

- (IBAction)downloadVideo:(id)sender;
@end
