//
//  AppDelegate.h
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Constant.h"
#import "Global.h"
#import "LoadingView.h"
#import "InitialViewController.h"
#import "PlayViewController.h"
#import <FacebookSDK/FacebookSDK.h> // Facebook framework

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIImageView *fView;
    UIView *rView;

}

@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) NSDictionary *refererAppLink;
@property (strong , nonatomic)NSString *downloadFlag,*isDownloading;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableData *dataResponse;
@property (strong, nonatomic) NSMutableArray *arrVideos;
@property (strong, nonatomic)NSString *strDeviceToken;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@property (strong, nonatomic) InitialViewController *customLoginViewController;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)logoutFromFb;

@end

