//
//  LiveStreamViewController.h
//  360 Project
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 12/12/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface LiveStreamViewController : UIViewController<UITextFieldDelegate,MFMailComposeViewControllerDelegate>


@property (strong, nonatomic) IBOutlet UIImageView *imgNoURL;
@property (strong, nonatomic) IBOutlet UILabel *lblNoLiveUrl;
- (IBAction)playLive:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnplayIcon;
@property (strong, nonatomic) NSString *headerImageName;
@property (strong, nonatomic) IBOutlet UILabel *lblNoURL;
@property (strong, nonatomic) NSString *navigationBarImage;
- (IBAction)SearchVideo:(id)sender;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *btnPLay;
@property (strong, nonatomic) IBOutlet UIScrollView *liveScrollView;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
- (IBAction)emailSubmit:(id)sender;
@property (strong, nonatomic) NSString *strCategory;
@end
