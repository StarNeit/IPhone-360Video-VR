//
//  LoginViewController.h
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 11/3/15.
//  Copyright © 2015 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebHelper.h"
#include "Constant.h"


@interface LoginViewController : UIViewController<HTTPWebServiceDelegate,UIAlertViewDelegate>
{
    int direction;
    int shakes;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
- (IBAction)actionLogin:(id)sender;

-(void)shake:(UITextField *)theOneYouWannaShake :(NSString*)errorText;
@end

