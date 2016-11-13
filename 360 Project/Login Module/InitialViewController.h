//
//  InitialViewController.h
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 11/3/15.
//  Copyright © 2015 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "WebHelper.h"
#include "Constant.h"
#import "WebHelper.h"

@interface InitialViewController : UIViewController<HTTPWebServiceDelegate>
- (IBAction)crossPressed:(id)sender;
- (IBAction)actionFacebookLogin:(id)sender;
@end
