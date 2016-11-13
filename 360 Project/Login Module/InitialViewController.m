//
//  InitialViewController.m
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 11/3/15.
//  Copyright © 2015 Hitaishin Infotech. All rights reserved.
//

#import "InitialViewController.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "WBTabBarController.h"
#import "JSON.h"


@interface InitialViewController ()
@property (strong, nonatomic)  AppDelegate *appDelegate;
@end

@implementation InitialViewController
@synthesize appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
   
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = true;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"isLogIn"] isEqualToString:@"1"])
    {
        [self moveToHomePage];
        return;
    }
    
}
-(void) viewDidAppear:(BOOL)animated{
    
}

-(void) viewDidDisappear:(BOOL)animated{
    
}

-(void) viewWillDisappear:(BOOL)animated{
    
}
-(void)moveToHomePage
{
    self.navigationController.navigationBarHidden = true;
    
    WBTabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"Tabbar"];
    //tbc.selectedIndex=0;
    [self.navigationController pushViewController:tbc animated:YES];
}

- (IBAction)crossPressed:(id)sender {
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    [[NSUserDefaults standardUserDefaults] setObject:currentDeviceId forKey:@"userID"];
}

#pragma mark : Facebook Methods
- (IBAction)actionFacebookLogin:(id)sender
{
    if ([Global isReachable]) {
        //NSLog(@"new session created");
//        appDelegate.session = [[FBSession alloc] initWithPermissions:@[@"public_profile", @"email", @"user_friends"]];
//        // if the session isn't open, let's open it now and present the login UX to the user
//        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
//                                                         FBSessionState status,
//                                                         NSError *error) {
//            // and here we make sure to update our UX according to the new session state
//            [self updateView];
//        }];
        
        
        // If the session state is any of the two "open" states when the button is clicked
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            [FBSession.activeSession closeAndClearTokenInformation];
            
            // If the session state is not any of the two "open" states when the button is clicked
        } else {
            // Open a session showing the user the login UI
            // You must ALWAYS ask for public_profile permissions when opening a session
            [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"email"]
                                               allowLoginUI:YES
                                          completionHandler:
             ^(FBSession *session, FBSessionState state, NSError *error) {
                 
                 // Retrieve the app delegate
                 //AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                 // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                 [self.appDelegate sessionStateChanged:session state:state error:error];
                 
                 
                 
                 if (FBSession.activeSession.isOpen) {
                     [[FBRequest requestForMe] startWithCompletionHandler:
                      ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                          if (!error) {
                              NSLog(@"accesstoken %@",[NSString stringWithFormat:@"%@",session.accessTokenData]);
                              NSLog(@"user id %@",user.objectID);
                              NSLog(@"Email %@",[user objectForKey:@"email"]);
                              NSLog(@"User Name %@",user.first_name);
                              NSMutableDictionary *dictParms = [[NSMutableDictionary alloc] init];
                              
                              
                              [dictParms setValue:[user valueForKey:@"email"] forKey:@"email"];
                              [dictParms setValue:[user valueForKey:@"first_name"] forKey:@"firstname"];
                              [dictParms setValue:[user valueForKey:@"last_name"] forKey:@"lastname"];
                              [dictParms setObject:[user valueForKey:@"gender"]  forKey:@"gender"];
                              [dictParms setValue:@"iphone" forKey:@"model"];
                              [dictParms setValue:user.objectID forKey:@"fbid"];
                              [dictParms setObject:@"facebook" forKey:@"regtype"];
                              
                              [dictParms setObject:kkSignUp forKey:@"methodName"];
                              
                              [self updateView:dictParms];
                          }
                      }];
                 }
                 
                 
             }];
        }
        
        
        

    }else{
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"Internet not connected"];
    }
    
   
}

- (void)updateView:(NSMutableDictionary *)dictParms {
    
            // valid account UI is shown whenever the session is open
        // ****** get user information **********
        // ****** get user information **********
        
        //[dictParms setValue:appDelegate.session.accessTokenData.accessToken forKey:@"token"];
        
#if TARGET_IPHONE_SIMULATOR
        NSLog(@"Running in Simulator - no app store or giro");
        [dictParms setObject:@"NA" forKey:@"deviceid"];
#else
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        [dictParms setObject:app.strDeviceToken!=nil?app.strDeviceToken:@"NA" forKey:@"deviceid"];
#endif
        //[self moveToHomePage];
        WebHelper * serviceHelper=[[WebHelper alloc]init];
        [serviceHelper requestWithDictionaryPost:dictParms andDelegate:self action:kkActionSignUp controllerView:self.view];
    
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self moveToHomePage];
}

#pragma mark Webservice Delegate
- (void)didFinishLoading:(NSURLConnection *)connection action:(NSInteger)sericeAction receiveData:(NSDictionary*)data code:(NSInteger)resopnseCode{
    switch (sericeAction) {
        case kkActionSignUp:
        {
            if([[data  valueForKey:@"status"] intValue]==1){
                
                [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"isLogIn"];
                [[NSUserDefaults standardUserDefaults] setObject:[data valueForKey:@"id"] forKey:@"userID"];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:APP_NAME message:[data valueForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }else{
                
                UIAlertView *alt=[[UIAlertView alloc]initWithTitle:APP_NAME message:[data valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alt show];
            }
            
        }
        break;
        default:
        break;
    }
}


// ------------> Code for requesting facebook user link with application ends here <------------

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen)
    {
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        //[self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            //[self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                //[self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                //[self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        //[self userLoggedOut];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
