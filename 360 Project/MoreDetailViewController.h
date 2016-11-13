//
//  MoreDetailViewController.h
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 12/28/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KAProgressLabel.h"
@interface MoreDetailViewController : UIViewController<UIGestureRecognizerDelegate>
@property (nonatomic,strong)NSMutableDictionary*seletedRecord;
@property (nonatomic, strong)NSString *flag;
@property (nonatomic, strong)NSMutableArray *localArrVideos;
@property (strong, nonatomic) IBOutlet UIImageView *imgBanner;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblCountry;
@property (strong, nonatomic) IBOutlet UILabel *lblCategory;
@property (strong, nonatomic) IBOutlet UILabel *lblDetail;
@property (strong, nonatomic) IBOutlet UIView *moreDetailSupportView;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblUrl;
@property (strong, nonatomic) IBOutlet UIButton *btnDownload;

- (IBAction)facebookShare:(id)sender;
- (IBAction)twilterShare:(id)sender;
- (IBAction)downloads:(id)sender;
- (IBAction)search:(id)sender;

@property (strong, nonatomic) IBOutlet KAProgressLabel *lblProgress;

- (IBAction)playVideo:(id)sender;
@property(nonatomic,retain)NSManagedObjectContext *managedObjectContext;
@end
