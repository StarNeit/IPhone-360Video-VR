//
//  ViewController.m
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import "ViewController.h"
#import "VideoListViewController.h"
#import "HomeViewCell.h"
#import "LiveStreamViewController.h"
#import "Global.h"
#import <UIKit/UIKit.h>
#import "Constant.h"
#import "LoadingView.h"
#import "UIImageView+AFNetworking.h"

@interface ViewController ()
{
    NSHTTPURLResponse *httpResponse;
    Boolean isTopBar;
    NSMutableArray * arrayCategoryListData;
    NSIndexPath *selectedIndex;

    
//    NSArray *imageArray;
//    NSArray *stringArray;
    LoadingView *loadingView;
}
@end

@implementation ViewController
@synthesize dataResponse;



#define kRealState @"1"
#define kExperiences @"2"


#pragma mark View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    isTrue=YES;
    /// Show the Tab Bar
    [self moveToUpSide];
    
    arrayCategoryListData = [[NSMutableArray alloc] init];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];

    
//    imageArray = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"image2.png"],[UIImage imageNamed:@"image1.png"],[UIImage imageNamed:@"image2.png"], nil];
//    stringArray = [[NSArray alloc] initWithObjects:@"Experiences",@" Real Estate",@"Destination",nil];
    
    
    for (UIView *btn in [self.tabBarController.view subviews]) {
        if ([btn class]==[UIButton class]&&btn.tag>=1&&btn.tag<=4)
        {
            UIButton *button=(UIButton *)btn;
            button.hidden=YES;
        }
        
        UIImageView *tabBarBorder=(UIImageView*)[btn viewWithTag:100];
        if(tabBarBorder.tag==100){
            tabBarBorder.hidden=YES;
        }
    }
    self.tabBarController.tabBar.hidden=YES;
    [self commonData];
}
- (void)moveToUpSide
{
    [UIView animateWithDuration:1
                     animations:^{
                         rView.frame = CGRectMake(self.view.frame.origin.x,
                                                  -self.view.frame.size.height,
                                                  self.view.frame.size.width,
                                                  self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         for (UIView *btn in [self.tabBarController.view subviews]) {
                             if ([btn class]==[UIButton class]&&btn.tag>=1&&btn.tag<=4) {
                                 UIButton *button=(UIButton *)btn;
                                 button.hidden=NO;
                             }
                             UIImageView *tabBarBorder=(UIImageView*)[btn viewWithTag:100];
                             if(tabBarBorder.tag==100){
                                 tabBarBorder.hidden=NO;
                             }
                         }
                         self.tabBarController.tabBar.hidden=NO;
                     }];
    
}
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated {
    
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] != visible) return;
    
    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    }];
}

// know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

-(BOOL)prefersStatusBarHidden{
    return NO;
}
-(void)viewDidAppear:(BOOL)animated{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Connetion Delegate
-(void)commonData{
    
    //NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",@"http://www.360mea.com/demonew/api/common_data.php"]];
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@common_data.php",Default_NEW_SERVER_URL]];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", 0];
    self.dataResponse=[NSMutableData data];

    
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
    
    NSMutableDictionary *dict=[[[NSJSONSerialization JSONObjectWithData:self.dataResponse options:0 error:nil]valueForKey:@"result"]  mutableCopy];
    NSLog(@"dict%@",dict);

    arrayCategoryListData = [[NSMutableArray alloc] init];
    arrayCategoryListData =[dict objectForKey:@"category_subcategory"];
    NSLog(@"%@",arrayCategoryListData);
    
    if (arrayCategoryListData.count>0) {
        [self.collection reloadData];
    }else{
    }
    
    
}
#pragma mark UICollectionView methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
     return [arrayCategoryListData count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeViewCell *cell;
    static NSString *cellIdentifier = @"cvCell";
    cell = (HomeViewCell *)[self.collection dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *categoryDict=[arrayCategoryListData objectAtIndex:indexPath.row];
    
    NSURL *url = [NSURL URLWithString:[Global getStringValue:[categoryDict objectForKey:@"image"]]];
    //NSURL *url = [NSURL URLWithString:@"http://192.168.2.2:8088/360_wp/wp-content/plugins/ManageVideo/upload/videothumb/1458382386Lighthouse.jpg"];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@""];
    __weak HomeViewCell *weakCell = cell;
    [cell.imageView setImageWithURLRequest:request
                         placeholderImage:placeholderImage
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      
                                      weakCell.imageView.image = image;
                                      [weakCell setNeedsLayout];
                                      
                                  } failure:nil];
    
    [cell.imageView setNeedsDisplay];
    
    
    cell.imageView.contentMode=UIViewContentModeScaleToFill;
    
//    cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width / 2;
//    cell.imageView.clipsToBounds = YES;

//    CGRect finalCellFrame = cell.frame;
//    //check the scrolling direction to verify from which side of the screen the cell should come.
//    CGPoint translation = [collectionView.panGestureRecognizer translationInView:collectionView.superview];
//    if (translation.x > 0) {
//        cell.frame = CGRectMake(finalCellFrame.origin.x - 1000, - 500.0f, 0, 0);
//    } else {
//        cell.frame = CGRectMake(finalCellFrame.origin.x + 1000, - 500.0f, 0, 0);
//    }
//    
//    [UIView animateWithDuration:0.5f animations:^(void){
//        cell.frame = finalCellFrame;
//    }];
    
    return cell;
    
}

#pragma mark Collection view cell layout / size

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([Global isIpad]){
    CGSize mElementSize = CGSizeMake(250,230); // old 300,140
    return mElementSize;
    }else{
        CGSize mElementSize = CGSizeMake(210,155); //old size 130,63
        return mElementSize;
    }
}

#pragma mark Collection view cell paddings

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
   
    selectedIndex = indexPath;
    isTopBar=0;
    
    if (isTrue==YES)
    {
        [self performSegueWithIdentifier:@"videoList" sender:indexPath];
    }
}

#pragma mark Segue Delegate 

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if (([segue.identifier isEqualToString:@"liveStreaming"]))
    {
        /// Live Stream View
        LiveStreamViewController *liveView=(LiveStreamViewController *)segue.destinationViewController;

    }
    else if ([segue.identifier isEqualToString:@"searchSegue"]) {
        
    }else{
        VideoListViewController *view=(VideoListViewController *)segue.destinationViewController;
        if (isTopBar==1)
        {
            //// What's Hot
            view.strWhatsHot = @"1";
        }
        else if (isTopBar==2)
        {
            /// Popular
            view.strPopular = @"1";
        }
        else{
           view.strCategory=[[arrayCategoryListData valueForKey:@"category_id"] objectAtIndex:selectedIndex.row];
            NSLog(@"category::%@",view.strCategory);
            
            }
    }
}

#pragma mark Orientation
-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark - Upper Bar Button Clicks
- (IBAction)actionWhatsHot:(id)sender {
    isTopBar=1;
    [self performSegueWithIdentifier:@"videoList" sender:nil];

}
- (IBAction)actionPopular:(id)sender {
    isTopBar=2;
    [self performSegueWithIdentifier:@"videoList" sender:nil];
}

- (IBAction)actionLiveStream:(id)sender
{
    [self performSegueWithIdentifier:@"liveStreaming" sender:nil];

}

-(IBAction)search:(id)sender
{
    if (isTrue==YES) {
        
        [self performSegueWithIdentifier:@"searchSegue" sender:nil];
    }
   
    
}

/*
 #pragma mark - API Callings
 /*
 * Calling the Home Category List
 */
/*
-(void)postDataForCategoryList
{
    NSMutableDictionary *dictPost=[NSMutableDictionary new];
    
    [dictPost setObject:kkHomeCategory forKey:@"methodName"];
    WebHelper * serviceHelper=[[WebHelper alloc]init];
    [serviceHelper requestWithDictionaryPost:dictPost andDelegate:self action:kkActionHomeCategory controllerView:self.view];
}

#pragma mark Webservice Delegate
- (void)didFinishLoading:(NSURLConnection *)connection action:(NSInteger)sericeAction receiveData:(NSDictionary*)data code:(NSInteger)resopnseCode{
    switch (sericeAction) {
        case kkActionHomeCategory:
        {
            if([[data  valueForKey:@"status"] intValue]==1){
                arrayCategoryListData = [data objectForKey:@"arrayCategoryListData"];
                [self.collection reloadData];
            }else
            {
                UIAlertView *alt=[[UIAlertView alloc]initWithTitle:APP_NAME message:[data valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alt show];
            }
        }
            break;
            
        default:
            
            break;
    }
}
*/
@end
