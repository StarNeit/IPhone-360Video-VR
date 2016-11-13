//
//  ForgotPasswordViewController.m
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 11/4/15.
//  Copyright © 2015 Hitaishin Infotech. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "Global.h"
#include "NSString+NSString_Extended.h"
#import "Constant.h"
#import "AppDelegate.h"
@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Global backButton:self];

}
#pragma mark - IB's Action
- (IBAction)actionForgotPassword:(id)sender
{
    [self postData];
}

#pragma mark - Web Helper
-(void)postData{
    
    if ([self isNotZeroLengthString:self.txtEmail.text fieldName:@"Email"]&&[self isValidEmailORUsername:self.txtEmail.text])
    {
        //    loginFlag=kkloginAPI;
        NSMutableDictionary *dictPost=[NSMutableDictionary new];
        [dictPost setObject:self.txtEmail.text forKey:@"email"];
        [dictPost setObject:kkForgotPass forKey:@"methodName"];
        
        [dictPost setValue:@"iphone" forKey:@"model"];
        
#if TARGET_IPHONE_SIMULATOR
        NSLog(@"Running in Simulator - no app store or giro");
        [dictPost setObject:@"NA" forKey:@"deviceid"];
#else
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        [dictPost setObject:app.strDeviceToken!=nil?app.strDeviceToken:@"NA" forKey:@"deviceid"];
#endif
        
        WebHelper * serviceHelper=[[WebHelper alloc]init];
        [serviceHelper requestWithDictionaryPost:dictPost andDelegate:self action:kkActionForgot controllerView:self.view];
    }
}

#pragma mark Webservice Delegate
- (void)didFinishLoading:(NSURLConnection *)connection action:(NSInteger)sericeAction receiveData:(NSDictionary*)data code:(NSInteger)resopnseCode{
    switch (sericeAction) {
        case kkActionForgot:
        {
            
            if([[data  valueForKey:@"status"] intValue]==1){
                self.txtEmail.text = @"";
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


#pragma mark Validation
-(BOOL)isNotZeroLengthString:(NSString *)str fieldName:(NSString *)strFieldName{
    BOOL isValid=YES;
    
    if ([str length] == 0)
    {
        NSString *strMessage =[NSString stringWithFormat:@"Please enter %@.",strFieldName];
        // [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:strMessage];
        isValid=NO;
        if ([strFieldName isEqualToString:@"Email"]) {
            direction = 1;
            shakes = 0;
            [self shake:self.txtEmail:strMessage];
            [self.txtEmail becomeFirstResponder];
        }else{
            [self.txtEmail becomeFirstResponder];
            direction = 1;
            shakes = 0;
            [self shake:self.txtEmail:strMessage];
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
        [self.txtEmail becomeFirstResponder];
        direction = 1;
        shakes = 0;
        [self shake:self.txtEmail:strMessage];
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
