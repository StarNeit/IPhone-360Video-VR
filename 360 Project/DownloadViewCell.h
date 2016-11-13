//
//  DownloadViewCell.h
//  360 Project
//
//  Created by Hitaishin Technologies on 12/8/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KAProgressLabel.h"
@interface DownloadViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgVideo;
@property (strong, nonatomic) IBOutlet UIButton *btnTwitter;
@property (strong, nonatomic) IBOutlet UILabel *lblVideoTitle;
@property (strong, nonatomic) IBOutlet UIButton *btndelete;
@property (strong, nonatomic) IBOutlet KAProgressLabel *lblProgress;
@property (strong, nonatomic) IBOutlet UIButton *btnFacebook;
@property (strong, nonatomic) IBOutlet UILabel *lblVideo;
@property (strong, nonatomic) IBOutlet UILabel *lblContry;
@property (strong, nonatomic) IBOutlet UIButton *btnMoreDetail;
@property (strong, nonatomic) IBOutlet UILabel *lblCategory;
@property (strong, nonatomic) IBOutlet UILabel *lblDetail;
 
@end
