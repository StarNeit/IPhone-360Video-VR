//
//  LoginViewController.m
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 11/3/15.
//  Copyright © 2015 Hitaishin Infotech. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#include "NSString+NSString_Extended.h"
#import "Constant.h"
#import "WBTabBarController.h"
// Keyboard Manager
#import "IQKeyboardManager.h"
#import "IQKeyboardReturnKeyHandler.h"
#import "IQUIView+IQKeyboardToolbar.h"

@interface LoginViewController ()
{
    // Keyboard Manager
    IQKeyboardReturnKeyHandler *returnKeyHandler;
}
@end
@implementation LoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[Global setFontRecursively:self.view];

    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    self.scrollView.contentSize=CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height*1.2);
    self.scrollView.scrollEnabled=NO;
    
    // Keyboard Manager
    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
}
-(void) viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = false;
    [Global backButton:self];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barTintColor = [UIColor darkTextColor];
}
#pragma mark - IB's Action
- (IBAction)actionLogin:(id)sender {
    [self postData];
}

#pragma mark - Web Helper
-(void)postData{
    
    if ([self isNotZeroLengthString:self.txtUsername.text fieldName:@"Username"]&&[self isValidEmailORUsername:self.txtUsername.text]&&[self isNotZeroLengthString:self.txtPassword.text fieldName:@"Password"])
    {
        
        //    loginFlag=kkloginAPI;
        NSMutableDictionary *dictPost=[NSMutableDictionary new];
        [dictPost setObject:self.txtUsername.text forKey:@"email"];
        [dictPost setObject:self.txtPassword.text forKey:@"password"];
        [dictPost setObject:kkLogin forKey:@"methodName"];
        
        [dictPost setValue:@"iphone" forKey:@"model"];
        
#if TARGET_IPHONE_SIMULATOR
        NSLog(@"Running in Simulator - no app store or giro");
        [dictPost setObject:@"NA" forKey:@"deviceid"];
#else
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        [dictPost setObject:app.strDeviceToken!=nil?app.strDeviceToken:@"NA" forKey:@"deviceid"];
#endif
        
        WebHelper * serviceHelper=[[WebHelper alloc]init];
        [serviceHelper requestWithDictionaryPost:dictPost andDelegate:self action:kkActionLogin controllerView:self.view];
    }
    
}
#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self moveToHomePage];
}
#pragma mark Webservice Delegate
- (void)didFinishLoading:(NSURLConnection *)connection action:(NSInteger)sericeAction receiveData:(NSDictionary*)data code:(NSInteger)resopnseCode{
    switch (sericeAction) {
        case kkActionLogin:
        {
            if([[data  valueForKey:@"status"] intValue]==1){
                
                [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"isLogIn"];
                
                [[NSUserDefaults standardUserDefaults] setObject:[data valueForKey:@"id"] forKey:@"userID"];
                [self.txtUsername setText:@""];
                [self.txtPassword setText:@""];
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
-(void)moveToHomePage
{
    self.navigationController.navigationBarHidden = true;
    
    WBTabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"Tabbar"];
    //tbc.selectedIndex=0;
    [self.navigationController pushViewController:tbc animated:YES];
}

#pragma mark Utility Function
-(void)handleSingleTap:(UITapGestureRecognizer *)tap{
    [self.view endEditing:YES];
    [self animateScrollerDown];
}
-(void)animateScrollerDown{
    [UIView animateWithDuration:1 animations:^{
        self.scrollView.contentOffset = CGPointMake(0,0.0f );
    }];
}
-(void)animateScrollerUP{
    [UIView animateWithDuration:1 animations:^{
        self.scrollView.contentOffset = CGPointMake(0,self.txtPassword.frame.origin.y-10);
        //[self.scrollView setContentOffset:CGPointMake(0.0f,self.txtPassword.frame.origin.y-10) animated:YES];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Validation
-(BOOL)isNotZeroLengthString:(NSString *)str fieldName:(NSString *)strFieldName{
    BOOL isValid=YES;
    
    if ([str length] == 0)
    {
        NSString *strMessage =[NSString stringWithFormat:@"Please enter %@.",strFieldName];
        // [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:strMessage];
        isValid=NO;
        if ([strFieldName isEqualToString:@"Username"]) {
            direction = 1;
            shakes = 0;
            [self shake:self.txtUsername:strMessage];
            [self.txtUsername becomeFirstResponder];
        }else{
            [self.txtPassword becomeFirstResponder];
            direction = 1;
            shakes = 0;
            [self shake:self.txtPassword:strMessage];
        }
    }
    return isValid;
}

-(BOOL)isValidEmailORUsername:(NSString *)strEmail{
    BOOL isValid=YES;
    if (!([strEmail isValidEmail]||[strEmail isValidContactNo])){
        isValid=NO;
        NSString *strMessage =@"Please enter valid Email Id.";
        // [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:strMessage];
        [self.txtUsername becomeFirstResponder];
        direction = 1;
        shakes = 0;
        [self shake:self.txtUsername:strMessage];
    }
    return isValid;
}

#pragma pragma mark -  UITextfiled Shake

-(void)shake:(UITextField *)theOneYouWannaShake :(NSString*)errorText
{
    [UIView animateWithDuration:0.5 animations:^
     {
         theOneYouWannaShake.transform = CGAffineTransformMakeTranslation(2*direction, 0);
     }
                     completion:^(BOOL finished)
     {
         if(shakes >= 4)
         {
             theOneYouWannaShake.transform = CGAffineTransformIdentity;
             [theOneYouWannaShake setValue:[UIColor lightGrayColor]
                                forKeyPath:@"_placeholderLabel.textColor"];
             return;
         }
         theOneYouWannaShake.text=@"";
         
         [theOneYouWannaShake setValue:[UIColor redColor]
                            forKeyPath:@"_placeholderLabel.textColor"];
         
         // theOneYouWannaShake.placeholder=errorText;
         shakes++;
         direction = direction * -1;
         [self shake:theOneYouWannaShake: errorText];
     }];
}

#pragma mark Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.txtUsername]) {
        [self animateScrollerUP];
        
    }else if([textField isEqual:self.txtPassword]){
        [self animateScrollerDown];
        self.scrollView.scrollEnabled=NO;
    }
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.scrollView.scrollEnabled=YES;
    
    if (textField.tag==0) {
        
        self.scrollView.scrollEnabled=YES;
        [self animateScrollerDown];
        
    }else if(textField.tag==1){
        
        [self animateScrollerUP];
        
    }
}

# pragma mark - Keyboard helper
/// Keyboard helper
-(IBAction)disableKeyboardManager:(UIBarButtonItem*)barButton
{
    if ([[IQKeyboardManager sharedManager] isEnabled])
    {
        [[IQKeyboardManager sharedManager] setEnable:NO];
    }
    else
    {
        [[IQKeyboardManager sharedManager] setEnable:YES];
    }
    
    //[self refreshUI];
}

-(void)dealloc
{
    returnKeyHandler = nil;
}
-(void)previousAction:(UITextField*)textField
{
    NSLog(@"%@ : %@",textField,NSStringFromSelector(_cmd));
}

-(void)nextAction:(UITextField*)textField
{
    NSLog(@"%@ : %@",textField,NSStringFromSelector(_cmd));
}

-(void)doneAction:(UITextField*)textField
{
    NSLog(@"%@ : %@",textField,NSStringFromSelector(_cmd));
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
