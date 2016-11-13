//
//  DownloadViewController.h
//  360 Project
//
//  Created by Hitaishin Technologies on 12/8/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KAProgressLabel.h"
@interface DownloadViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate>
@property(nonatomic,retain)NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UITextField *txtDownload;
@property (strong, nonatomic) KAProgressLabel *lblGlobalProgress;

@property (strong, nonatomic)NSMutableArray *arrVideos;


- (IBAction)downloadClick:(id)sender;
- (IBAction)facebookSharing:(id)sender;
- (IBAction)twitterSharing:(id)sender;
- (IBAction)deleteVideo:(id)sender;
- (IBAction)searchVideo:(id)sender;
- (IBAction)moreDetailAction:(id)sender;

-(void)downloadVideoAndSave :(NSString*)videoUrl;
@end
