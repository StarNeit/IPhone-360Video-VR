//
//  SignupViewController.h
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 11/3/15.
//  Copyright © 2015 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebHelper.h"
#include "Constant.h"
@interface SignupViewController : UIViewController<HTTPWebServiceDelegate,UIAlertViewDelegate>
{
    int direction;
    int shakes;
}
-(void)shake:(UITextField *)theOneYouWannaShake :(NSString*)errorText;

@end
