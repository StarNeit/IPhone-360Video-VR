//
//  ContactsViewController.h
//  360 Project
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 12/7/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ContactsViewController : UIViewController<MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSMutableData *dataResponse;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIView *contactSupportView;

- (IBAction)websiteClick:(id)sender;
- (IBAction)facebookClick:(id)sender;
- (IBAction)twitterClick:(id)sender;
- (IBAction)emailClick:(id)sender;
- (IBAction)phoneClick:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnWebsite;
@property (strong, nonatomic) IBOutlet UIImageView *borderImage;
@property (strong, nonatomic) IBOutlet UIButton *btnFacebook;
@property (strong, nonatomic) IBOutlet UIButton *btnTwitter;
@property (strong, nonatomic) IBOutlet UIButton *btnEmail;
@property (strong, nonatomic) IBOutlet UIButton *btnPhone;



- (IBAction)facebookShare:(id)sender;
- (IBAction)twitterShare:(id)sender;
- (IBAction)searchVideo:(id)sender;

@end
