//
//  VideoListViewController.h
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoListCell.h"
@interface VideoListViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
{
    UICollectionView *selectedColl;
    VideoListCell *selectedCollection;
    NSIndexPath *selectedIndex;
}
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIImageView *headerImage;
@property (strong, nonatomic) NSMutableData *dataResponse;
@property (strong, nonatomic) NSMutableArray *arrVideos,*localArrVideos;
@property (strong, nonatomic) NSString *headerImageName;
@property (strong, nonatomic) NSString *navigationBarImage;
@property (strong, nonatomic) NSString *strCategory,*strWhatsHot, *strPopular;
@property (strong, nonatomic) NSString *strSubcategory;
@property (strong, nonatomic) NSString *strCity;
@property (strong, nonatomic) NSString *strKeywords;
@property (nonatomic) float progValue;
@property(nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;
@property (nonatomic, strong)NSTimer *myTimer;
@property (nonatomic, strong)IBOutlet UILabel *recordNotFound;

- (IBAction)searchClick:(id)sender;
- (IBAction)postToTwitter:(id)sender;
- (IBAction)postToFacebook:(id)sender;
- (IBAction)videoDownload:(id)sender;
- (IBAction)moreDetailAction:(id)sender;

@end
