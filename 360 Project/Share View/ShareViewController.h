//
//  ShareViewController.h
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 11/7/15.
//  Copyright © 2015 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController<UIDocumentInteractionControllerDelegate>
@property(nonatomic,retain) UIDocumentInteractionController *documentationInteractionController;
@end
