//
//  VideoListViewController.h
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoListViewControllerSearch : UIViewController<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableDictionary *dicResponse;
- (IBAction)moreDetail:(id)sender;

@property (strong, nonatomic) NSMutableData *dataResponse;
@property (strong, nonatomic) NSMutableArray *arrVideos,*localArrVideos;
@property (strong, nonatomic) NSString *headerImageName;
@property (strong, nonatomic) NSString *navigationBarImage;
@property (strong, nonatomic) NSString *strCategory;
@property (strong, nonatomic) NSString *strSubcategory;
@property (strong, nonatomic) NSString *strCity;
@property (strong, nonatomic) NSString *strKeywords;
@property(nonatomic,retain)NSManagedObjectContext *managedObjectContext;

- (IBAction)searchClick:(id)sender;
- (IBAction)postToTwitter:(id)sender;
- (IBAction)postToFacebook:(id)sender;
- (IBAction)videoDownload:(id)sender;
@end
