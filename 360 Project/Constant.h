//
//  Constant.h
//  360 VUZ
//
//  Created by Harish Patidar on 04/11/15.
//  Copyright (c) 2015 Hitaishin Infotech. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#ifndef _60_MEA_Constant_h
#define _60_MEA_Constant_h


/// For Thread
#define STARTBACKGROUNDTASK  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#define STARTMAINTRHEAD                             dispatch_async(dispatch_get_main_queue(), ^(){
#define ENDMAINTHREAD                               });
#define ENDBACKGROUNDTASK });

/// API URL
 #define Default_URL @"http://www.360mea.com/app/"
#define Default_NEW_URL @"http://360mea.com/api/api.php?action="
#define Default_Video_URL @"http://360mea.com/api/"

#define Default_NEW_SERVER_URL @"http://www.360mea.com/demonew/api/"

//#define Default_NEW_URL @"http://166.62.84.69/api/api.php?action="
//#define Default_NEW_URL @"http://162.144.122.148/360_wp/api/api.php?action="
//#define Default_Video_URL @"http://166.62.84.69/api/"


//http://166.62.84.69/api/video_list.php
//#define Default_Video_URL @"http://162.144.122.148/360_wp/api/"



#define APP_NAME                    @"360 VUZ"

// Method 
#define APPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

#define METHODP @"POST"
#define METHODG @"GET"
#define MethodName  @"methodName"

#define kGallery 0
#define kCamera  1
#define kCancel  2





// API Actions
#define kkActionLogin           0
#define kkActionSignUp          1
#define kkActionForgot          2
#define kkActionHomeCategory    3



//api methods
#define kkLogin              @"login"
#define kkSignUp             @"signup"
#define kkForgotPass         @"forgot_password"



#define kkHomeCategory       @"category_list"




#endif
