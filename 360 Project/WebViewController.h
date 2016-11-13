//
//  WebViewController.h
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 11/8/15.
//  Copyright © 2015 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
@property (strong, nonatomic) NSString *strURL;
@property (strong, nonatomic) IBOutlet UIWebView *webView;


-(IBAction)backPushed:(id)sender;
@end
