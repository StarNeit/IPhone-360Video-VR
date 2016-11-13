//
//  Global.h
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <CoreGraphics/CoreGraphics.h>

@interface Global : NSObject
+(void)backButton:(id)sender;
+(void)goback;

+(UILabel*)customNavigationTitle:(NSString *)title;
+(UIImageView *)customNavigationImage:(NSString *)imgName;

+ (void)showAlertMessageWithOkButtonAndTitle:(NSString *)strTitle andMessage:(NSString *)strMessage;
+ (BOOL) isReachable;
+(BOOL)isIpad;
//// New Methds

@property(strong,nonatomic)id nav;
+(void)setDefaultFor:(NSString*)key andData:(id)data;
+(id)getDefaultFor:(NSString*)key;
+ (UIBarButtonItem *)setAddToCardWithBadge: (id )sender ;
+ (void)shoppingCartClick;
+(void)setBadgeCount:(int)count;
+(NSArray *)getCountries;
+ (void)backButton:(id)sender;
+ (void)goback;
+(NSDictionary*)getUserProfile;
+(NSString*)getUserId;
+(NSString*)getUserPassword;
+(NSDictionary*)getUserData;
+(void)loadAdWithAds:(UIView *)view;
+(BOOL)isEndDateIsSmallerThanCurrent:(NSString *)checkEndDate;
+ (BOOL) isIphone5thGeneration;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (NSString *)getMD5FromString:(NSString *)source;
+ (NSString*) getUrlFromPropertylist :(NSString*)action;
+ (BOOL)hasFourInchDisplay;
+(NSString *)dateStringFromDate:(NSString *)dateObj;
+ (NSMutableDictionary *)recursiveNullRemove:(NSMutableDictionary *)dictionaryResponse;
//+(UIBarButtonItem *)rightHomeButton:(id)sender;
+(NSString*)Trim:(NSString*)value;
+(BOOL)stringExists:(NSString *)str;
+(NSString *)getStringValue:(NSString *)str;
+(BOOL)dictionaryExists:(NSObject *)dic;


+ (void)setLabelMyriadProRegularFont:(UILabel *)label;
+ (void)setLabelMyriadProCondFont:(UILabel *)label;
+ (void)setTextFieldMyriadProRegularFont:(UITextField *)textField;
+ (void)setFontRecursively:(UIView *)view;
@end
