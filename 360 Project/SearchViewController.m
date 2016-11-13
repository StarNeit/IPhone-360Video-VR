//
//  SearchViewController.m
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import "SearchViewController.h"
#import "LoadingView.h"
#import "Global.h"
#import "VideoListViewControllerSearch.h"
#import "Constant.h"

#define kCategory 1
#define kSubcategory 2
#define kCity 3

#define kSearchData 1
#define kListOfResult 2

LoadingView *loadingView;

@interface SearchViewController ()
{
    NSMutableDictionary *dictSearchResult;
    NSInteger category;
}
@end

int pickerFlag;
int apiFlag;

@implementation SearchViewController
UIPickerView *languageSelect;
NSMutableArray *pickerData;
UITextField *currentTextfield;
@synthesize optionPicker,pickerSupportView;
@synthesize text1,text2,text3;
@synthesize arrCategory,arrSubcategory,arrCities;


#pragma mark View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    ////[Global setFontRecursively:self.view];

    [pickerSupportView setHidden:YES];
    arrSubcategory=[[NSMutableArray alloc]init ];
    // Do any additional setup after loading the view.
    [self commonData];
}


-(void)viewWillAppear:(BOOL)animated{

    self.navigationItem.titleView =[Global customNavigationTitle:@"Search"];
    [Global backButton:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Picker View Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView; {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component; {
    int count=0;
    if (pickerFlag==kCategory) {
        count=[arrCategory count];
    }else if (pickerFlag==kCity) {
        count=[arrCities count];
    } else if (pickerFlag==kSubcategory && [arrSubcategory isKindOfClass:[NSMutableArray class]]) {
        count=[arrSubcategory count];
    }
    return count;
}

-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    pickerView.backgroundColor = [UIColor whiteColor];
    return [pickerData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}



- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* tView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 40)];
    tView.textColor=[UIColor whiteColor];
    tView.textAlignment=NSTextAlignmentCenter;
    [tView setFont:[UIFont fontWithName:@"Discognate" size:18]];
    
    if (pickerFlag==kCategory) {
        tView.text=[[arrCategory objectAtIndex:row] objectForKey:@"category_name"];
    }else if (pickerFlag==kCity) {
        tView.text=[[arrCities objectAtIndex:row] objectForKey:@"city_name"];
    } else if (pickerFlag==kSubcategory&&[arrSubcategory isKindOfClass:[NSMutableArray class]]) {
        if (arrSubcategory.count>0) {
             tView.text=[[arrSubcategory objectAtIndex:row] objectForKey:@"subcategory_name"];
        }
       
    }
    
    return tView;
}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[pickerData objectAtIndex:row] attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
    
}

#pragma mark UITextfield Functions


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    
    if (textField == self.text1)
    {
        pickerFlag=kCategory;
        [textField resignFirstResponder];
        currentTextfield = textField;
//        pickerData= [[NSMutableArray alloc] initWithObjects:@"Dubai",@"Sharjah",@"Abudhabi",@"Fujairah", nil];
        optionPicker.showsSelectionIndicator = YES;
        pickerSupportView.hidden = NO;
     }
    
    else  if (textField == self.text2)
    {
        pickerFlag=kCity;
        [textField resignFirstResponder];
        currentTextfield = textField;
//        pickerData= [[NSMutableArray alloc] initWithObjects:@"Arab",@"Asian",@"Bakery",@"Bar Food",@"Barbecue",@"Bistro",@"Brazillian",@"Burgers",nil];
         optionPicker.showsSelectionIndicator = YES;
        pickerSupportView.hidden = NO;
        
     }
    
    else  if (textField == self.text3)
    {
        pickerFlag=kSubcategory;
        [textField resignFirstResponder];
        currentTextfield = textField;
//        pickerData= [[NSMutableArray alloc] initWithObjects:@"Arab",@"Asian",@"Bakery",@"Bar Food",@"Barbecue",@"Bistro",@"Brazillian",@"Burgers",nil];
         optionPicker.showsSelectionIndicator = YES;
        pickerSupportView.hidden = NO;
     }
    [optionPicker reloadAllComponents];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{              // called when 'return' key pressed. return NO to ignore.
    
    [textField resignFirstResponder];
    return YES;
}

-(void)commonData{
    
    
    self.dataResponse=[NSMutableData data];
    
    
    apiFlag=kSearchData;
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@category_search.php",Default_NEW_SERVER_URL]];
        
    NSString *postLength = [NSString stringWithFormat:@"%d", 0];
    
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:[NSData data ]];
    if ([Global isReachable]) {
        loadingView = [LoadingView loadingViewInView:self.view withText:@"Please Wait...."];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }else{
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"Internet is not connected!!"];
    }
    
    
}



-(void)searchVideo{
    
    apiFlag=kListOfResult;
    
    self.dataResponse=[NSMutableData data];

    NSMutableDictionary *dictPost=[NSMutableDictionary new];
    
   // [];category_id=1&sub category_id=5&city=Dubai&keyword=degree
     [dictPost setValue:[self.dictCategory valueForKey:@"category_id"] forKey:@"category_id"];
     [dictPost setValue:[self.dictSubcategory valueForKey:@"subcategory_id"] forKey:@"subcategory_id"];
     [dictPost setValue:[self.dictCity valueForKey:@"city_name"] forKey:@"city"];
     [dictPost setValue:self.text4.text forKey:@"keyword"];
    
    [dictPost setValue:@"iphone" forKey:@"model"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([[prefs stringForKey:@"deviceToken"] length]>0) {
        [dictPost setObject:[prefs stringForKey:@"deviceToken"] forKey:@"devicetoken"];
    }else{
        [dictPost setObject:@"NA" forKey:@"devicetoken"];
    }
    //// Login ID
    [dictPost setValue:[prefs valueForKey:@"userID"] forKey:@"id"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictPost
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];

    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];


    NSData *jsonDataNew = [jsonString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@video_list.php",Default_NEW_SERVER_URL]];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonDataNew length]];

    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [request setHTTPBody:jsonDataNew];
    if ([Global isReachable]) {
        loadingView = [LoadingView loadingViewInView:self.view withText:@"Please Wait...."];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }else{
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"Internet is not connected!!"];
    }
}
-(NSString*)urlEscapeString:(NSString *)unencodedString
{
    CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return s;
}


-(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary
{
    NSMutableString *urlWithQuerystring = [[NSMutableString alloc] initWithString:urlString];
    
    for (id key in dictionary) {
        NSString *keyString = [key description];
        NSString *valueString = [[dictionary objectForKey:key] description];
        
        if ([urlWithQuerystring rangeOfString:@"?"].location == NSNotFound) {
            [urlWithQuerystring appendFormat:@"?%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        } else {
            [urlWithQuerystring appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        }
    }
    return urlWithQuerystring;
}
#pragma mark Connetion Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse %s##### response  %@",__FUNCTION__,response);
    [self.dataResponse setLength:0];
    //[resData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.dataResponse appendData:data];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    @try {
        NSLog(@"didFailWithError %s   --- %@ ",__FUNCTION__,[error description]);
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:[(NSString*)[error userInfo] valueForKey:@"NSLocalizedDescription"]];
        [loadingView removeView];
    }
    @catch (NSException *exception) {
        NSLog(@"didFailWithError %s   --- %@ ",__FUNCTION__,exception);
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:[exception reason]];
        [loadingView removeView];
    }
    @finally {
        
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading %s",__FUNCTION__);
    [loadingView removeView];
    if (apiFlag==kSearchData) {
     NSMutableDictionary * dictCommanResult=[[[NSJSONSerialization JSONObjectWithData:self.dataResponse options:0 error:nil]valueForKey:@"result"]  mutableCopy];
    arrCategory=[dictCommanResult objectForKey:@"category_subcategory"];
    arrCities=[dictCommanResult objectForKey:@"cities"];
        
        
        
    }else if (apiFlag==kListOfResult){
        
         dictSearchResult=[[[NSJSONSerialization JSONObjectWithData:self.dataResponse options:0 error:nil]valueForKey:@"result"]  mutableCopy];
    [self performSegueWithIdentifier:@"searchresult" sender:nil];
    }
}




#pragma mark Button Click
- (IBAction)search:(id)sender {
    [self searchVideo ];
  // // [self performSegueWithIdentifier:@"searchresult" sender:nil];
}

- (IBAction)optionSelectionCancel:(id)sender {
    [pickerSupportView setHidden:YES];
}

- (IBAction)optionSelectionDone:(id)sender {
    
    if (pickerFlag==kCategory) {
        [currentTextfield setText:[[arrCategory objectAtIndex:[optionPicker selectedRowInComponent:0]]objectForKey:@"category_name"]];
           category=[[[arrCategory objectAtIndex:[optionPicker selectedRowInComponent:0]]objectForKey:@"category_id"] integerValue];
        self.dictCategory=[arrCategory objectAtIndex:[optionPicker selectedRowInComponent:0]];
        self.dictSubcategory=nil;
        self.text3.text=@"Details";
        arrSubcategory=[[arrCategory objectAtIndex:[optionPicker selectedRowInComponent:0]] objectForKey:@"subcategory"];
    }else if (pickerFlag==kCity) {
        [currentTextfield setText:[[arrCities objectAtIndex:[optionPicker selectedRowInComponent:0]] objectForKey:@"city_name"]];
        self.dictCity=[arrCities objectAtIndex:[optionPicker selectedRowInComponent:0]];
    } else if (pickerFlag==kSubcategory &&[arrSubcategory isKindOfClass:[NSMutableArray class]]) {
        if (arrSubcategory.count>0) {
            
        [currentTextfield setText:[[arrSubcategory objectAtIndex:[optionPicker selectedRowInComponent:0]] objectForKey:@"subcategory_name"]];
        self.dictSubcategory=[arrSubcategory objectAtIndex:[optionPicker selectedRowInComponent:0]];
    }
    }

    
    [pickerSupportView setHidden:YES];
}

#define kRealState @"1"
#define kEvent @"2"
#define kWedding @"3"
#define kOther @"4"
#define kDonation @"5"
#define kLiveBroadcast @"6"


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self.view endEditing:YES];
    if ([segue.identifier isEqualToString:@"searchresult"]) {
        VideoListViewControllerSearch *view=(VideoListViewControllerSearch *)segue.destinationViewController;
        view.dicResponse=[dictSearchResult mutableCopy];
        switch (category) {
            case 1:
            {
                view.strCategory=kRealState;
                //view.headerImageName=@"realestate_slide.jpg";
                //view.navigationBarImage=@"realestate.png";
                
                
            }
                break;
            case 2:{
                view.strCategory=kEvent;
                //view.headerImageName=@"event_slide.jpg";
                //view.navigationBarImage=@"event.png";
            }
                break;
            case 3:{
                view.strCategory=kWedding;
                //view.headerImageName=@"wedding_slide.jpg";
               //view.navigationBarImage=@"wedding.png";
            }
                break;
            case 4:
            {
                view.strCategory=kOther;
                //view.headerImageName=@"other_slide.jpg";
                //view.navigationBarImage=@"other.png";
            }
                
                break;
            case 5:{
                view.strCategory=kDonation;
                //view.headerImageName=@"donations_slide.jpg";
                //view.navigationBarImage=@"donations.png";
            }
                break;
            case 6:{
                view.strCategory=kLiveBroadcast;
                //view.headerImageName=@"other_slide.jpg";
                //view.navigationBarImage=@"livebrodcast.png";
            }
                break;
                
            default:
                break;
        }
        view.strSubcategory=[self.dictSubcategory objectForKey:@"subcategory_id"];
        view.strCity=[self.dictCity objectForKey:@"city_name"];
        view.strKeywords=self.text4.text;
        
 
    }
    
}


#pragma mark Orientation Delegate
-(BOOL)prefersStatusBarHidden{
    return NO;
}
@end
