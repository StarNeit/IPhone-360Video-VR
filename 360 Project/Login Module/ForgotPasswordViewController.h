//
//  ForgotPasswordViewController.h
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 11/4/15.
//  Copyright © 2015 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebHelper.h"
#include "Constant.h"

@interface ForgotPasswordViewController : UIViewController<HTTPWebServiceDelegate,UIAlertViewDelegate>
{
    int direction;
    int shakes;
}
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
- (IBAction)actionForgotPassword:(id)sender;

-(void)shake:(UITextField *)theOneYouWannaShake :(NSString*)errorText;


@end
