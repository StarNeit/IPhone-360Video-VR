//
//  SearchViewController.h
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"

@interface SearchViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>
@property (nonatomic,retain) IBOutlet UITextField *text1;
@property (nonatomic,retain) IBOutlet UITextField *text2;
@property (nonatomic,retain) IBOutlet UITextField *text3;
@property (strong, nonatomic) IBOutlet UIPickerView *optionPicker;

@property (strong, nonatomic) IBOutlet UIView *pickerSupportView;
@property (strong, nonatomic) IBOutlet UITextField *text4;

@property (strong, nonatomic) NSMutableData *dataResponse;
@property (strong, nonatomic) NSMutableArray *arrVideos;

@property (strong, nonatomic) NSMutableArray *arrCategory;
@property (strong, nonatomic) NSMutableArray *arrSubcategory;
@property (strong, nonatomic) NSMutableArray *arrCities;

@property (strong, nonatomic) NSDictionary *dictCategory;
@property (strong, nonatomic) NSDictionary *dictSubcategory;
@property (strong, nonatomic) NSDictionary *dictCity;



- (IBAction)search:(id)sender;
- (IBAction)optionSelectionCancel:(id)sender;
- (IBAction)optionSelectionDone:(id)sender;
@end
