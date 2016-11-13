//
//  Global.m
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import "Global.h"
#import "Constant.h"
#import "Reachability.h"
#import "UIImageView+AFNetworking.h"
#define REACHABLE_HOST @"www.google.com"

int randNum;
#define REACHABLE_HOST @"www.google.com"

#define COMMENT_LABEL_WIDTH 320
#define COMMENT_LABEL_MIN_HEIGHT 180


id nav;
id viewControllerInstance;
id viewControllerTap;
id badgeCartViewController;

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
@implementation Global

+(void)backButton:(id)sender{
    viewControllerInstance=sender;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];backBtn.frame = CGRectMake(0, 0, 60, 20);
    UIImage *backBtnImage = [UIImage imageNamed:@"back.png"]  ;
    [backBtn setImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goback) forControlEvents:UIControlEventTouchUpInside];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [backBtn setContentEdgeInsets:UIEdgeInsetsMake(0, -15, 0,10)];
    }
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
    ((UIViewController *)viewControllerInstance).navigationItem.leftBarButtonItem = backButton;
    
}

+(void)goback
{
    [((UIViewController *)viewControllerInstance).navigationController popViewControllerAnimated:YES];
}

+(UILabel*)customNavigationTitle:(NSString *)title{
    CGRect frame;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        frame = CGRectMake(0, 0, 110, 50);
    }else{
        frame = CGRectMake(0, 0, 100, 44);
    }
    UILabel *label = [[UILabel alloc] initWithFrame:frame] ;
    label.backgroundColor = [UIColor clearColor];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        [label setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:19.0f]];
    }else{
        [label setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:16.0f]];
    }
    
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor =[UIColor whiteColor];
    label.text = title;
    return label;
}


+(UIImageView *)customNavigationImage:(NSString *)imgName{
    CGRect frame;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        frame = CGRectMake(-20, 0, 110, 33);
    }else{
        frame = CGRectMake(-20, 0, 100, 30);
    }
    UIImageView *image = [[UIImageView alloc] initWithFrame:frame] ;
    image.image=[UIImage imageNamed:imgName];
    image.contentMode=UIViewContentModeScaleAspectFit;
    return image;
}

+ (void)showAlertMessageWithOkButtonAndTitle:(NSString *)strTitle andMessage:(NSString *)strMessage
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
}

+ (BOOL) isReachable
{
    Reachability * reach = [Reachability reachabilityWithHostname:REACHABLE_HOST];
    return [reach isReachable];
    
}
+(BOOL)isIpad{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        return YES; /* Device is iPad */
    }else{
        return NO;
    }
}

+(BOOL)isEndDateIsSmallerThanCurrent:(NSString *)checkEndDate
{
    //  NSString *s=@"2015-08-12";
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *enddate = [dateFormat dateFromString:checkEndDate];
    
    NSString* myString = [dateFormat stringFromDate:[NSDate date]];
    
    NSDate* currentdate = [dateFormat dateFromString:myString];
    switch ([currentdate compare:enddate])
    {
        case NSOrderedAscending:
            return YES;
            break;
        case NSOrderedSame:
            return YES;
            break;
        case NSOrderedDescending:
            return NO;
            break;
    }
}
+(void)shoppingCartClick{
    
    //    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    //    UIViewController *vc ;
    //    vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"myShoppingCard"];
    //    [((UIViewController *)badgeCartViewController).navigationController pushViewController:vc animated:YES];
    
}
+(NSString *)dateStringFromDate:(NSString *)dateObj{
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [format dateFromString:dateObj];
    
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"dd-MMM-yyyy";
    
    NSString *timeString = [timeFormatter stringFromDate: date];
    return timeString;
}
+(void)setDefaultFor:(NSString*)key andData:(id)data{
    
    NSUserDefaults *loginData= [NSUserDefaults standardUserDefaults];
    
    [loginData setObject:data forKey:key];
    [loginData synchronize];
    
}
+(void)loadAdWithAds:(UIView *)view{
    if ([[[[NSUserDefaults standardUserDefaults]objectForKey:@"ads"] valueForKey:@"advertise"] count]>0) {
        
        
        UIImageView *imgAd=(UIImageView*)[view.window viewWithTag:1111];
        
        //  [imgAd removeFromSuperview];
        
        if (imgAd!=nil) {
            [imgAd removeFromSuperview];
        }
        
        UIImageView *adImage=[[UIImageView alloc]initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height-50,0, 50)];
        adImage.image=[UIImage imageNamed:@"adv.png"];
        
        randNum = rand() % (([[[[NSUserDefaults standardUserDefaults]objectForKey:@"ads"] valueForKey:@"advertise"] count]) - 0) + 0;
        
        NSString *imgUrl=[[[[[NSUserDefaults standardUserDefaults]objectForKey:@"ads"] valueForKey:@"advertise"] objectAtIndex:randNum] valueForKey:@"image_url"];
        
        if (imgUrl!= (id)[NSNull null]) {
            NSURL *urlTemp = [NSURL URLWithString:imgUrl];
            [adImage  setImageWithURL:urlTemp placeholderImage:[UIImage imageNamed:@"adv.png"]];
        }
        adImage.tag=1111;
        
        
        [UIView animateWithDuration:1.0f
                         animations:^{
                             adImage.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height-50, [UIScreen mainScreen].bounds.size.width, 50);
                         }
                         completion:^(BOOL finished){
                             NSLog( @"woo! Finished animating the frame of myView! %d",randNum );
                         }];
        
        
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        
        [adImage addGestureRecognizer:tapGestureRecognizer];
        adImage.userInteractionEnabled=YES;
        
        
        [view.window addSubview:adImage];
        
    }
    
}
+(void)handleTapFrom:(UITapGestureRecognizer *)tap{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[[[[NSUserDefaults standardUserDefaults]objectForKey:@"ads"] valueForKey:@"advertise"] objectAtIndex:randNum] valueForKey:@"link"]]];
    
}
//
+(NSDictionary *)getUserProfile{
    NSUserDefaults *loginDataUser= [NSUserDefaults standardUserDefaults];
    NSDictionary *loginData=[loginDataUser objectForKey:@"myprofile"];
    return loginData;
}
+(NSString*)getUserId{
    NSUserDefaults *loginDataUser= [NSUserDefaults standardUserDefaults];
    NSDictionary *loginData=[loginDataUser objectForKey:@"loginData"];
    return [loginData valueForKey:@"user_id"];
}
+(NSString*)getUserPassword{
    NSUserDefaults *loginDataUser= [NSUserDefaults standardUserDefaults];
    NSDictionary *loginData=[loginDataUser objectForKey:@"loginData"];
    return [loginData valueForKey:@"password"];
}
+(NSDictionary*)getUserData{
    NSUserDefaults *loginDataUser= [NSUserDefaults standardUserDefaults];
    NSDictionary *loginData=[loginDataUser objectForKey:@"loginData"];
    return loginData;
}
+(id)getDefaultFor:(NSString*)key{
    NSUserDefaults *loginData= [NSUserDefaults standardUserDefaults];
    id object=  [loginData objectForKey:key];
    return object;
}


//+(UIBarButtonItem *)rightHomeButton:(id)sender{
//    nav=sender;
//    ((UIViewController *)nav).navigationController.navigationBar.translucent = NO;
//    UIImage *image = [UIImage imageNamed:@"home.png"];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setImage:image forState:UIControlStateNormal];
//    button.frame=CGRectMake(0.0, 100.0, 25.0, 25.0);
//    [button addTarget:self action:@selector(popView:)  forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
//    return barButton;
//
//}

//+(NSString *) randomStringWithLength: (int) len {
//
//    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
//
//    for (int i=0; i<len; i++) {
//        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
//    }
//
//    return randomString;
//}

//+(void)popView:(id)sender{
//    NSArray *viewControllers = ((UIViewController *)nav).navigationController.viewControllers;
//    int index=0;
//    for (int i=0; i<[viewControllers count]; i++) {
//        if ([[[viewControllers objectAtIndex:i] class]isEqual:[HomeViewController class]]) {
//            index=i;
//            break;
//        }
//    }
//    [((UIViewController *)nav).navigationController popToViewController: [viewControllers objectAtIndex:index] animated: YES];
//}

+ (BOOL)hasFourInchDisplay {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0);
}
+(UILabel*)customNavigationWithTitle:(NSString *)title{
    
    CGRect frame = CGRectMake(0, 0, 100, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame] ;
    label.backgroundColor = [UIColor clearColor];
    [label setFont:[UIFont fontWithName:@"Roboto" size:16.0f]];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor =[Global colorFromHexString:@"#ffffff"];
    label.text = title;
    
    return label;
}

+(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


+ (BOOL) isIphone5thGeneration
{
    UIScreen *MainScreen = [UIScreen mainScreen];
    UIScreenMode *ScreenMode = [MainScreen currentMode];
    CGSize Size = [ScreenMode size];
    
    if(Size.height == 568 || Size.height == 1136)
        return YES;
    else
        return NO;
}

//+ (NSString *)getMD5FromString:(NSString *)source{
//    NSLog(@"md -5 string : %@",source);
//    const char *src = [source UTF8String];
//    unsigned char result[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(src, strlen(src), result);
//    NSString *ret = [[NSString alloc] initWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
//                     result[0], result[1], result[2], result[3],
//                     result[4], result[5], result[6], result[7],
//                     result[8], result[9], result[10], result[11],
//                     result[12], result[13], result[14], result[15]
//                     ];
//    return [ret lowercaseString];
//}

+ (NSString*) getUrlFromPropertylist:(NSString*)action
{
    
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"aPLFUrlSetting"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"aPLFUrlSetting" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *plistDic = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListFromData:plistXML
                                              mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                              format:&format
                                              errorDescription:&errorDesc];
    if (!plistDic) {
    }
    
    return [[plistDic objectForKey:@"serviceUrl"]stringByAppendingString:action];
    
}
+ (NSMutableDictionary *)recursiveNullRemove:(NSMutableDictionary *)dictionaryResponse {
    
    NSMutableDictionary *dictionary = [dictionaryResponse mutableCopy];
    NSString *nullString = @"";
    for (NSString *key in [dictionary allKeys]) {
        id value = dictionary[key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            
            dictionary[key] = [self recursiveNullRemove:(NSMutableDictionary*)value];
            
        }else if([value isKindOfClass:[NSArray class]]){
            
            NSMutableArray *newArray = [value mutableCopy];
            for (int i = 0; i < [value count]; ++i) {
                
                id value2 = [value objectAtIndex:i];
                
                if ([value2 isKindOfClass:[NSDictionary class]]) {
                    newArray[i] = [self recursiveNullRemove:(NSMutableDictionary*)value2];
                }
                else if ([value2 isKindOfClass:[NSNull class]]){
                    newArray[i] = nullString;
                }
            }
            dictionary[key] = newArray;
        }else if ([value isKindOfClass:[NSNull class]]){
            dictionary[key] = nullString;
        }
    }
    return dictionary;
}

+ (NSMutableDictionary *)recursiveStringRemove:(NSMutableDictionary *)dictionaryResponse {
    
    NSMutableDictionary *dictionary = [dictionaryResponse mutableCopy];
    // NSString *nullString = @"-";
    for (NSString *key in [dictionary allKeys]) {
        id value = dictionary[key];
        
        if ([value isEqualToString:[NSString stringWithFormat:@"%@\\U2212",value]]) {
            
            dictionary[key] = [NSString stringWithFormat:@"%@-",value];
            
        }
    }
    return dictionary;
}
////// New methods
#pragma mark - Harish's  Functions

/// functions to set fonts
+ (void)setLabelHelveticaNeueLTComFont:(UILabel *)label{
    [label setFont:[UIFont  fontWithName:@"MyriadPro-Semibold" size:label.font.pointSize]];
}
+ (void)setLabelMyriadProRegularFont:(UILabel *)label{
    [label setFont:[UIFont  fontWithName:@"MyriadPro-Semibold" size:label.font.pointSize]];
}
+ (void)setLabelMyriadProCondFont:(UILabel *)label{
    [label setFont:[UIFont  fontWithName:@"MyriadPro-Semibold" size:label.font.pointSize]];
}

+ (void)setTextFieldMyriadProRegularFont:(UITextField *)textField{
    [textField setFont:[UIFont  fontWithName:@"MyriadPro-Semibold" size:textField.font.pointSize]];
}
+ (void)setTextFieldHelveticaNeueLTComFont:(UITextField *)textField{
    [textField setFont:[UIFont  fontWithName:@"MyriadPro-Semibold" size:textField.font.pointSize]];
}

// setting fonts in all views and their subviews in a viewcontroller
+ (void)setFontRecursively:(UIView *)view{
    if([view isKindOfClass:[UILabel class]]){
        UILabel *label=(UILabel *)view;
        //NSLog(@"label %@",label.text);
        [Global setLabelMyriadProRegularFont:label];
    }
    else if([view isKindOfClass:[UITextField class]]){
        UITextField *textField=(UITextField *)view;
        [Global setTextFieldMyriadProRegularFont:textField];
        textField.borderStyle=UITextBorderStyleNone;
        //[textField setBackground:[UIImage imageNamed:@"text-box.png"]];
        [textField setTextColor:[UIColor blackColor]];
    }
    else if([view isKindOfClass:[UITextView class]]){
        UITextView *textView=(UITextView *)view;
        [textView setFont:[UIFont  fontWithName:@"MyriadPro-Semibold" size:textView.font.pointSize]];
        //[textView setBackgroundColor:[CommonClass colorWithHexString:@"#e3f5ff"]];
        [textView setTextColor:[UIColor blackColor]];
    }
    else if([view isKindOfClass:[UIButton class]]){
        UIButton *button=(UIButton *)view;
        //[CommonClass setTextFieldMuseoThreeHundredFont:textField];
        [button.titleLabel setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:button.titleLabel.font.pointSize]];
        //[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        //        if(button.frame.size.width>100){
        //            button.layer.cornerRadius = 10; // this value vary as per your desire
        //            button.clipsToBounds = YES;
        //        }
    }
    else{
        for (UIView *subView in [view subviews]) {
            [Global setFontRecursively:subView];
        }
    }
}

/************************************************
 Method				:	String functions for the check the String balnk and valid:
 Purpose			:	This method will retuns the balnk if String invalid
 Return Value		:	String
 Modified By		:	Harish Patidar
 Modified On		:	21/10/2015
 ************************************************/
/// Trim for String
+(NSString*)Trim:(NSString*)value
{
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return value;
}

// checks whether string value exists or it contains null or null in string
+(BOOL)stringExists:(NSString *)str{
    if(str==nil){
        return false;
    }
    if (![str isKindOfClass:[NSString class]]) {
        return false;
    }
    if(str==(NSString *)[NSNull null]){
        return false;
    }
    if([str isEqualToString:@"<null>"]){
        return false;
    }
    if([str isEqualToString:@"(null)"]){
        return false;
    }
    str=[Global Trim:str];
    if([str isEqualToString:@""]){
        return false;
    }
    if(str.length == 0){
        return false;
    }
    return true;
}

// returns string value after removing null and unwanted characters
+(NSString *)getStringValue:(NSString *)str{
    if ([Global stringExists:str]) {
        str=[str stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
        
        str=[Global Trim:str];
        
        if ([str isEqualToString:@"{}"]) {
            str=@"";
        }
        
        if ([str isEqualToString:@"()"]) {
            str=@"";
        }if ([str isEqualToString:@"null"]) {
            str=@"";
        }
        return str;
    }
    return @"";
}

// checks whether dictionary exists or not
+(BOOL)dictionaryExists:(NSObject *)dic{
    if(dic==nil){
        return false;
    }
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return false;
    }
    if(dic==[NSNull null]){
        return false;
    }
    return true;
}


@end
