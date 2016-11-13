//
//  ViewController.h
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebHelper.h"

@interface ViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,HTTPWebServiceDelegate>
{
    UIImageView *fView;
    UIView *rView;
    BOOL isTrue;
}
@property (strong, nonatomic) NSMutableData *dataResponse;
@property (strong, nonatomic) IBOutlet UICollectionView *collection;
- (IBAction)search:(id)sender;

@end

