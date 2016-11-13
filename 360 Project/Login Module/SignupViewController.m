//
//  SignupViewController.m
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 11/3/15.
//  Copyright © 2015 Hitaishin Infotech. All rights reserved.
//

#import "SignupViewController.h"
#import "IQKeyboardManager.h"
#import "IQKeyboardReturnKeyHandler.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "WBTabBarController.h"
#include "NSString+NSString_Extended.h"
#import "Global.h"
#import "AppDelegate.h"

static int isMale=1;
@interface SignupViewController ()
{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
}

@property (strong, nonatomic) IBOutlet UITextField *txtFirstName;
@property (strong, nonatomic) IBOutlet UITextField *txtLastName;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtConfirmPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnMale;
@property (strong, nonatomic) IBOutlet UIButton *btnFeMale;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)actionMale:(id)sender;
- (IBAction)actionFeMale:(id)sender;

- (IBAction)actionSignUp:(id)sender;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[Global setFontRecursively:self.view];
    self.navigationController.navigationBarHidden = false;


    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barTintColor = [Global colorFromHexString:@"#2b91b7"];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    //self.scrollView.contentSize=CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height*1.2);
    //self.scrollView.scrollEnabled=NO;
    
    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];

    [Global backButton:self];

}
#pragma mark - IB's Action
- (IBAction)actionMale:(id)sender {
    isMale=1;
    [self.btnMale setImage:[UIImage imageNamed:@"cricselect.png"] forState:UIControlStateNormal];
    [self.btnFeMale setImage:[UIImage imageNamed:@"criclebtn.png"] forState:UIControlStateNormal];
}

- (IBAction)actionFeMale:(id)sender {
    isMale=0;
    [self.btnMale setImage:[UIImage imageNamed:@"criclebtn.png"] forState:UIControlStateNormal];
    [self.btnFeMale setImage:[UIImage imageNamed:@"cricselect.png"] forState:UIControlStateNormal];
}

- (IBAction)actionSignUp:(id)sender {
    [self postData];
}
#pragma mark - Web Helper
-(void)postData{
    
        if ([self isNotZeroLengthString:self.txtFirstName ]&&[self isNotZeroLengthString:self.txtLastName]&&[self isNotZeroLengthString:self.txtEmail]&&
            [self isValidEmailORUsername:self.txtEmail.text]
            && [self isNotZeroLengthString:self.txtPassword]&&[self isNotZeroLengthString:self.txtConfirmPassword] &&[self isEqualPassword:self.txtPassword :self.txtConfirmPassword])
    {
        //firstname lastname email gender password  regtype deviceid
        NSMutableDictionary *dictPost=[NSMutableDictionary new];
        
        [dictPost setObject:self.txtFirstName.text forKey:@"firstname"];
        [dictPost setObject:self.txtLastName.text forKey:@"lastname"];
        [dictPost setObject:self.txtEmail.text forKey:@"email"];
        [dictPost setValue:@"iphone" forKey:@"model"];

        [dictPost setObject:isMale ?@"male":@"female"  forKey:@"gender"];

        [dictPost setObject:self.txtPassword.text forKey:@"password"];
        [dictPost setObject:@"normal" forKey:@"regtype"];

        [dictPost setObject:kkSignUp forKey:@"methodName"];
        
#if TARGET_IPHONE_SIMULATOR
        NSLog(@"Running in Simulator - no app store or giro");
        [dictPost setObject:@"NA" forKey:@"deviceid"];
#else
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        [dictPost setObject:app.strDeviceToken!=nil?app.strDeviceToken:@"NA" forKey:@"deviceid"];
#endif
        
        WebHelper * serviceHelper=[[WebHelper alloc]init];
        [serviceHelper requestWithDictionaryPost:dictPost andDelegate:self action:kkActionSignUp controllerView:self.view];
    }
    
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
                [self.txtEmail setText:@""];
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
            [self shake:self.txtEmail:strMessage];
            [self.txtEmail becomeFirstResponder];
        }else{
            [self.txtPassword becomeFirstResponder];
            direction = 1;
            shakes = 0;
            [self shake:self.txtPassword:strMessage];
        }
    }
    return isValid;
}

-(BOOL)isNotZeroLengthString:(UITextField *)txtField{
    BOOL isValid=YES;
    
    if ([txtField.text length] == 0)
    {
        isValid=NO;
        direction = 1;
        shakes = 0;
        [self shake:txtField:nil];
        [txtField becomeFirstResponder];
    }
    return isValid;
}
-(BOOL)isEqualPassword:(UITextField *)txtField :(UITextField *)txtSecondTextField{
    
    BOOL isValid=YES;
    
    if (![txtField.text isEqualToString:txtSecondTextField.text])
    {
        isValid=NO;
        direction = 1;
        shakes = 0;
        [self shake:txtField:nil];
        txtField.placeholder=@"Password not matched";
        txtSecondTextField.placeholder=@"Password not matched";
        [txtField becomeFirstResponder];
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
