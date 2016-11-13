//
//  SplashViewController.m
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 11/3/15.
//  Copyright © 2015 Hitaishin Infotech. All rights reserved.
//

#import "SplashViewController.h"
#import "WBTabBarController.h"
#import "InitialViewController.h"
@interface SplashViewController ()

@end

@implementation SplashViewController
int count = 0;
@synthesize logoImgView;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = true;

    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.logoImgView setTransform:CGAffineTransformRotate(self.logoImgView.transform, M_PI_2)];
    }completion:^(BOOL finished){
        if (finished) {
             [self rotateImageView];
            
        }
    }];
    
}

- (void)rotateImageView
{
   
                NSLog(@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"isLogIn"]);
                if([[[NSUserDefaults standardUserDefaults] valueForKey:@"isLogIn"] isEqualToString:@"1"])
                {
                   // [self performSegueWithIdentifier:@"Tabbar" sender:nil];
                    WBTabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"Tabbar"];
                    //tbc.selectedIndex=0;
                    [self.navigationController pushViewController:tbc animated:YES];
                }else{
                    
                    InitialViewController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"InitialView"];
                    //tbc.selectedIndex=0;
                    [self.navigationController pushViewController:tbc animated:YES];
                    
                }

}
-(void)viewWillAppear:(BOOL)animated
{

    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if (([segue.identifier isEqualToString:@"InitialView"])){
//    
//       // InitialViewController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"InitialView"];
//       // [self.navigationController presentViewController:tbc animated:YES completion:nil];
//        [self performSegueWithIdentifier:@"InitialView" sender:nil];
//        
//    }else{
//        [self moveToHomePage];
//    
//    }
//
//}


@end
