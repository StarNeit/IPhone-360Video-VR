//
//  NSString+NSString_Extended.h
//  WhatLightApp
//
//  Created by Hitaishin Technologies on 7/12/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_Extended)
- (NSString *)urlencode ;
-(BOOL)isValidEmail;
-(BOOL)isValidContactNo;
@end
