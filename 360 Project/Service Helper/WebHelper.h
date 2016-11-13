//
//  OSG_WebHelper.h
//  OSG_Project
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 9/3/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol HTTPWebServiceDelegate <NSObject,NSURLConnectionDelegate,NSURLConnectionDataDelegate>
@optional
- (void)didReceiveResponse:(NSURLResponse *)response;
- (void)didFailWithError:(NSError *)error;
@required
- (void)didFinishLoading:(NSURLConnection *)connection action:(NSInteger)sericeAction receiveData:(NSDictionary*)data code:(NSInteger)resopnseCode;
@end

@interface WebHelper : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

//image + data
-(void)requestWithDictionary:(NSDictionary *)dictionary andDelegate:(id<HTTPWebServiceDelegate>)delegateNew action:(NSInteger )action controllerView:(UIView *)view AndImage:(UIImage*)outletImage imageController:(NSString *)imagePath;

//post
-(void)requestWithDictionaryPost:(NSDictionary *)dictionary andDelegate:(id<HTTPWebServiceDelegate>)delegateNew action:(NSInteger )action controllerView:(UIView *)view;

//Profile
-(void)requestWithDictionaryProfile:(NSDictionary *)dictionary andDelegate:(id<HTTPWebServiceDelegate>)delegateNew action:(NSInteger )action controllerView:(UIView *)view;

-(void)saveProfilePick;


-(void)requestWithDictionaryForPromotion:(NSDictionary *)dictionary andDelegate:(id<HTTPWebServiceDelegate>)delegateNew action:(NSInteger )action controllerView:(UIView *)view;


@property (nonatomic, strong) id<HTTPWebServiceDelegate> delegate;
@end
