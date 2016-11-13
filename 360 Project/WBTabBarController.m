//
//  WBTabBarController.m
//  CustomTabBar
//
//  Created by Tito Ciuro on 4/21/12.
//
// Copyright (c) 2012 Webbo, L.L.C. All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//

#import "WBTabBarController.h"
#import "Global.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
@interface WBTabBarController ()
{
    UIImageView *topBorder;
}
@end

@implementation WBTabBarController

@synthesize plusController;
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
- (BOOL)shouldAutorotate {
    
    NSLog(@"%@",self.viewControllers.lastObject);
    return [self.viewControllers.lastObject shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self.viewControllers.lastObject shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[Global setFontRecursively:self.view];

    UIDevice *device = [UIDevice currentDevice];					//Get the device object
    [device beginGeneratingDeviceOrientationNotifications];			//Tell it to start monitoring the accelerometer for orientation
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];	//Get the notification centre for the app
    [nc addObserver:self											//Add yourself as an observer
           selector:@selector(orientationChanged:)
               name:UIDeviceOrientationDidChangeNotification
             object:device];
    
    UIImage *tabBarBackground = [UIImage imageNamed:@"tabBarBackground.png"];
    //[[UITabBar appearance] setBackgroundImage:tabBarBackground];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    
    if ([Global isIpad]) {
        /// Tab 1
        [self addFirstButtonWithImage:[UIImage imageNamed:@"home_1.png"] highlightImage:[UIImage imageNamed:@"home_2.png"] target:self action:@selector(firstButtonPressed:)];

        // Tab 2
        [self addSecondButtonWithImage:[UIImage imageNamed:@"down_1.png"] highlightImage:[UIImage imageNamed:@"down_2.png"] target:self action:@selector(secondButtonPressed:)];

        
        // Tab 3
        [self addThirdButtonWithImage:[UIImage imageNamed:@"share_1.png"] highlightImage:[UIImage imageNamed:@"share_2.png"] target:self action:@selector(ThirdButtonPressed:)];

        // Tab 4
        [self addFourthButtonWithImage:[UIImage imageNamed:@"mail_1.png"] highlightImage:[UIImage imageNamed:@"mail_2.png"] target:self action:@selector(ForthButtonPressed:)];
        
        [self.tabBar setBackgroundImage:[[UIImage alloc] init]];
        [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
        
        UIColor* color_green = [UIColor clearColor];
        self.tabBar.layer.borderWidth = 0.50;
        self.tabBar.layer.borderColor = color_green.CGColor;
        [[UITabBar appearance] setTintColor:color_green];
    }else{
        //// iPhone Tab bar controller
        // Tab 1
        [[self.tabBar.items objectAtIndex:0] setImage:[[UIImage imageNamed:@"home_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        [[self.tabBar.items objectAtIndex:0] setSelectedImage:[[UIImage imageNamed:@"home_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        // Tab 2
        [[self.tabBar.items objectAtIndex:1] setImage:[[UIImage imageNamed:@"download_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        [[self.tabBar.items objectAtIndex:1] setSelectedImage:[[UIImage imageNamed:@"down_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        // Tab 3
        [[self.tabBar.items objectAtIndex:2] setImage:[[UIImage imageNamed:@"contact_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        [[self.tabBar.items objectAtIndex:2] setSelectedImage:[[UIImage imageNamed:@"share_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        // Tab 4
        [[self.tabBar.items objectAtIndex:3] setImage:[[UIImage imageNamed:@"info_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        [[self.tabBar.items objectAtIndex:3] setSelectedImage:[[UIImage imageNamed:@"mail_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        [self.tabBar setBackgroundImage:[[UIImage alloc] init]];
        [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
        
        UIColor* color_green = [UIColor clearColor];
        self.tabBar.layer.borderWidth = 0.50;
        self.tabBar.layer.borderColor = color_green.CGColor;
        [[UITabBar appearance] setTintColor:color_green];
        
    }
    
    self.tabBarController.tabBar.backgroundImage= [UIImage imageNamed:@"tabbarbg.png"];
}
-(void)orientationChanged:(id)sender{
    //[[self.view viewWithTag:100]removeFromSuperview];
    if ([Global isIpad]) {
        


        if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
        {
           topBorder=[[UIImageView alloc]initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-90, [[UIScreen mainScreen] bounds].size.width, 1)];
            topBorder.tag=100;
            topBorder.image=[UIImage imageNamed:@"new_logoborder.png"];
         //   [self.view addSubview:topBorder];
            [self addFirstButtonWithImage:[UIImage imageNamed:@"home_1.png"] highlightImage:[UIImage imageNamed:@"home_2.png"] target:self action:@selector(firstButtonPressed:)];
            
            // Tab 2
            [self addSecondButtonWithImage:[UIImage imageNamed:@"down_1.png"] highlightImage:[UIImage imageNamed:@"down_2.png"] target:self action:@selector(secondButtonPressed:)];
            
            
            // Tab 3
            [self addThirdButtonWithImage:[UIImage imageNamed:@"share_1.png"] highlightImage:[UIImage imageNamed:@"share_2.png"] target:self action:@selector(ThirdButtonPressed:)];
            
            // Tab 4
            [self addFourthButtonWithImage:[UIImage imageNamed:@"mail_1.png"] highlightImage:[UIImage imageNamed:@"mail_2.png"] target:self action:@selector(ForthButtonPressed:)];
        }
        else{
            topBorder=[[UIImageView alloc]initWithFrame:CGRectMake(0, 931, 768, 3)];
            //CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
            topBorder.image=[UIImage imageNamed:@"new_logoborder.png"];
            topBorder.tag=100;
           [self.view addSubview:topBorder];
        }
       
        
        [self.tabBar setBackgroundImage:[[UIImage alloc] init]];
        [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
        
        UIColor* color_green = [UIColor clearColor];
        self.tabBar.layer.borderWidth = 0.50;
        self.tabBar.layer.borderColor = color_green.CGColor;
        [[UITabBar appearance] setTintColor:color_green];
    }
    else{
    
        if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
        {
            topBorder=[[UIImageView alloc]initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-52, [[UIScreen mainScreen] bounds].size.width, 1)];
            topBorder.tag=100;
            topBorder.image=[UIImage imageNamed:@"new_logoborder.png"];
            //   [self.view addSubview:topBorder];
        }
        else{
            topBorder=[[UIImageView alloc]initWithFrame:CGRectMake(0, 270, 500, 1)];
            topBorder.image=[UIImage imageNamed:@"new_logoborder.png"];
            topBorder.tag=100;
            // [self.view addSubview:topBorder];
        }
    
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    if ([Global isIpad]) {
        topBorder=[[UIImageView alloc]initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-90, [[UIScreen mainScreen] bounds].size.width, 3)];
        topBorder.image=[UIImage imageNamed:@"new_logoborder.png"];
        topBorder.tag=100;
        [self.view addSubview:topBorder];
    }else{
        topBorder=[[UIImageView alloc]initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-60, [[UIScreen mainScreen] bounds].size.width, 3)];
        topBorder.image=[UIImage imageNamed:@"new_logoborder.png"];
        topBorder.tag=100;
        [self.view addSubview:topBorder];
    }
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

// Create a custom UIButton and add it to the center of our tab bar
- (void)addFourthButtonWithImage:(UIImage *)buttonImage highlightImage:(UIImage *)highlightImage target:(id)target action:(SEL)action
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    if ([Global isIpad]) {
        
            button.frame=   CGRectMake([[UIScreen mainScreen] bounds].origin.x+576, [[UIScreen mainScreen] bounds].size.height-90 ,192, 90) ;
    }
    
    [button setImage:buttonImage forState:UIControlStateNormal];
    //[button setImage:highlightImage forState:UIControlStateHighlighted];
    button.tag=4;
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    self.view.backgroundColor=[UIColor blackColor];
    self.forthButton = button;
}

- (void)ForthButtonPressed:(id)sender
{
    [self setSelectedIndex:3];
    [self selectTab:104];

    [self performSelector:@selector(doHighlight:) withObject:sender afterDelay:0];
}

// Tab 1
- (void)addFirstButtonWithImage:(UIImage *)buttonImage highlightImage:(UIImage *)highlightImage target:(id)target action:(SEL)action
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    if ([Global isIpad]) {
        
            button.frame=   CGRectMake([[UIScreen mainScreen] bounds].origin.x, [[UIScreen mainScreen] bounds].size.height-90,192, 90) ;
    }
    
    [button setImage:buttonImage forState:UIControlStateNormal];
    //[button setImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    button.tag=1;
    [self.view addSubview:button];
    
    self.firstButton = button;
}

- (void)firstButtonPressed:(id)sender
{
    [self setSelectedIndex:0];
    
    [self selectTab:101];
    //[self tabBar:self.tabBar didSelectItem:[self.tabBar.items objectAtIndex:0]];

    [self performSelector:@selector(doHighlight:) withObject:sender afterDelay:0];
}

// Tab 2
- (void)addSecondButtonWithImage:(UIImage *)buttonImage highlightImage:(UIImage *)highlightImage target:(id)target action:(SEL)action
{
 
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    if ([Global isIpad])
    {
        button.frame=   CGRectMake([[UIScreen mainScreen] bounds].origin.x+192, [[UIScreen mainScreen] bounds].size.height-90, 192, 90) ;
    }
    
    [button setImage:buttonImage forState:UIControlStateNormal];
    //[button setImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.tag=2;
    [self.view addSubview:button];
    
    self.secondButton = button;
}

- (void)secondButtonPressed:(id)sender
{
    [self setSelectedIndex:1];
    [self selectTab:102];

    [self performSelector:@selector(doHighlight:) withObject:sender afterDelay:0];
}

// Tab 3
- (void)addThirdButtonWithImage:(UIImage *)buttonImage highlightImage:(UIImage *)highlightImage target:(id)target action:(SEL)action
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    if ([Global isIpad]) {
        
        button.frame=   CGRectMake([[UIScreen mainScreen] bounds].origin.x+384, [[UIScreen mainScreen] bounds].size.height-90, 192, 90) ;
    }
    
    [button setImage:buttonImage forState:UIControlStateNormal];
    //[button setImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.tag=3;
    [self.view addSubview:button];
    self.thirdButton = button;
}

- (void)ThirdButtonPressed:(id)sender
{

    [self setSelectedIndex:2];
    [self selectTab:103];
   // [self tabBar:self.tabBar didSelectItem:[self.tabBar.items objectAtIndex:2]];
    [self performSelector:@selector(doHighlight:) withObject:sender afterDelay:0];
}


- (void)doHighlight:(UIButton*)b {
    [b setHighlighted:YES];
}

- (void)doNotHighlight:(UIButton*)b {
    [b setHighlighted:NO];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    //if(self.tabBarController.selectedIndex != 2){
       // [self performSelector:@selector(doNotHighlight:) withObject:centerButton afterDelay:0];
    //}
}
- (void)selectTab:(int)tabID
{
    switch(tabID)
    {
        case 101:
            [self.firstButton setImage:[UIImage imageNamed:@"home_2.png"] forState:UIControlStateHighlighted];
            [self.secondButton setImage:[UIImage imageNamed:@"down_1.png"] forState:UIControlStateHighlighted];
            [self.thirdButton setImage:[UIImage imageNamed:@"share_1.png"] forState:UIControlStateHighlighted];
            [self.forthButton setImage:[UIImage imageNamed:@"mail_1.png"] forState:UIControlStateHighlighted];

            break;
        case 102:
            [self.firstButton setImage:[UIImage imageNamed:@"home_1.png"] forState:UIControlStateHighlighted];
            [self.secondButton setImage:[UIImage imageNamed:@"down_2.png"] forState:UIControlStateHighlighted];
            [self.thirdButton setImage:[UIImage imageNamed:@"share_1.png"] forState:UIControlStateHighlighted];
            [self.forthButton setImage:[UIImage imageNamed:@"mail_1.png"] forState:UIControlStateHighlighted];
            break;
        case 103:
            [self.firstButton setImage:[UIImage imageNamed:@"home_1.png"] forState:UIControlStateHighlighted];
            [self.secondButton setImage:[UIImage imageNamed:@"down_1.png"] forState:UIControlStateHighlighted];
            [self.thirdButton setImage:[UIImage imageNamed:@"share_2.png"] forState:UIControlStateHighlighted];
            [self.forthButton setImage:[UIImage imageNamed:@"mail_1.png"] forState:UIControlStateHighlighted];
            break;
        case 104:
            [self.firstButton setImage:[UIImage imageNamed:@"home_1.png"] forState:UIControlStateHighlighted];
            [self.secondButton setImage:[UIImage imageNamed:@"down_1.png"] forState:UIControlStateHighlighted];
            [self.thirdButton setImage:[UIImage imageNamed:@"share_1.png"] forState:UIControlStateHighlighted];
            [self.forthButton setImage:[UIImage imageNamed:@"mail_2.png"] forState:UIControlStateHighlighted];
            break;
    }
    self.selectedIndex = tabID;
}


- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}
- (BOOL)tabBarHidden {
    return self.firstButton.hidden && self.tabBar.hidden;
}

- (void)setTabBarHidden:(BOOL)tabBarHidden
{
    self.firstButton.hidden = tabBarHidden;
    self.tabBar.hidden = tabBarHidden;
}


@end
