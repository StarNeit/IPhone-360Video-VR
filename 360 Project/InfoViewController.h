//
//  InforViewController.h
//  360 Project
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 12/6/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController
{
UIWebView *videoView;
}
@property (strong, nonatomic) IBOutlet UIImageView *imgBorder;
@property (strong, nonatomic) NSMutableData *dataResponse;
@property (strong, nonatomic) IBOutlet UIWebView *videoView;
- (IBAction)searchClick:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UITextView *txtInfoView;
@end
