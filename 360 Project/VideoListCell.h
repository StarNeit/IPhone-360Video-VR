//
//  VideoListCell.h
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KAProgressLabel.h"


@interface VideoListCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgVideo;
@property (strong, nonatomic) IBOutlet UIButton *btnTwitter;
@property (strong, nonatomic) IBOutlet UIButton *btnDownload,*btnWhatsApp;
@property (strong, nonatomic) IBOutlet UIButton *btnFacebook;
@property (strong, nonatomic) IBOutlet UIButton *moreDetail;
@property (strong, nonatomic) IBOutlet KAProgressLabel *lblProgress;

@property (strong, nonatomic) IBOutlet UILabel *lblCountry;
@property (strong, nonatomic) IBOutlet UIProgressView *downloadSlider;
@property (strong, nonatomic) IBOutlet UILabel *lblCategory;
@property (strong, nonatomic) IBOutlet UILabel *lblDetails;
@property (strong, nonatomic) IBOutlet UILabel *lblLink;

@property (strong, nonatomic) IBOutlet UILabel *lblVideo;


@end
