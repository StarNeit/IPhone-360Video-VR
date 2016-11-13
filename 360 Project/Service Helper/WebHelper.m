//
//  OSG_WebHelper.m
//  OSG_Project
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 9/3/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import "WebHelper.h"
#import "Global.h"
#import "Constant.h"
//#import "AMTumblrHud.h"
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation WebHelper
{
    NSMutableData* gloabalData;
    NSInteger statusCode;
    NSInteger serviceAction;
    UIView *controllerView;
    UIAlertView *alert;
    NSURLConnection *connectionRequest;
}
@synthesize delegate;

#pragma mark - connection delegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    [loadingView removeView];
   // [delegate didReceiveResponse:response];
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    statusCode = [HTTPResponse statusCode];
    gloabalData = [[NSMutableData alloc]init];
    [gloabalData setLength:0];
    NSLog(@"didReceiveResponse %s##### response  %@",__FUNCTION__,response);

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [gloabalData appendData:data];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    
    [alert dismissWithClickedButtonIndex:0 animated:YES];

    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:APP_NAME message:[[[error userInfo] valueForKey:@"NSLocalizedDescription"] stringByAppendingString:@" Please try again."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    
       NSLog(@"%@",[[error userInfo] valueForKey:@"NSLocalizedDescription"]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
   // [tumblrHUD hide];
   
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    NSError* error;
    NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:gloabalData
                                                         options:kNilOptions
                                                           error:&error];
    NSString* responseString;
    responseString = [[NSString alloc] initWithData:gloabalData encoding:NSUTF8StringEncoding];
      NSLog(@"responseString === %@",responseString);
       NSMutableDictionary*list=[Global recursiveNullRemove:[responseData mutableCopy]];
    
    [delegate didFinishLoading:connection action:serviceAction receiveData:list code:statusCode];
}

-(void)requestWithDictionary:(NSDictionary *)dictionary andDelegate:(id<HTTPWebServiceDelegate>)delegateNew action:(NSInteger )action controllerView:(UIView *)view AndImage:(UIImage*)outletImage imageController:(NSString *)imagePath{
    delegate=delegateNew;
    serviceAction=action;
    controllerView=view;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    //Set Params
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:120];
    [request setHTTPMethod:@"POST"];
    
    //Create boundary, it can be anything
    NSString *boundary = @"------VohpleBoundary4QuqLuM1cE5lMwCy";
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    //[request setValue:APIKey forHTTPHeaderField:@"apikey"];
    // post body
    NSMutableData *body = [NSMutableData data];
    
    
    for (NSString *param in dictionary) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [dictionary objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    //user_profile && outlet_image
    NSString *FileParamConstant = imagePath;
    
    NSData *imageData = UIImageJPEGRepresentation(outletImage, 1);
    
    //Assuming data is not nil we add this to the multipart form
    if (imageData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type:image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //Close off the request with the boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the request
    [request setHTTPBody:body];
    //
    // set URL
    NSString *urlString=[Default_NEW_URL stringByAppendingString:[dictionary valueForKey:@"methodName"]];
    
    [request setURL:[NSURL URLWithString:urlString]];
    
        if ([Global isReachable]) {
            [NSThread detachNewThreadSelector:@selector(showLoadingView:) toTarget:self withObject:view];
            [NSURLConnection connectionWithRequest:request delegate:self];
        }else{
            [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"Internet not connected"];
        }
    
}
-(void)requestWithDictionaryPost:(NSDictionary *)dictionary andDelegate:(id<HTTPWebServiceDelegate>)delegateNew action:(NSInteger )action controllerView:(UIView *)view{
    
    delegate=delegateNew;
    serviceAction=action;
    
      NSString *urlString=[Default_NEW_URL stringByAppendingString:[dictionary valueForKey:@"methodName"]];
    NSURL *url=[NSURL URLWithString:urlString];
    
    NSData *jsData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    //
    NSString *dataProfile = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithData:jsData                                                                                 encoding:NSUTF8StringEncoding]];
    
    
    NSData *postData = [dataProfile dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    //NSData *data = [dataProfile dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *postString = [self addQueryStringToUrlString:@"" withDictionary:dictionary];
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];

    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:APIKey forHTTPHeaderField:@"apikey"];
    [request setHTTPBody:data];
    
    NSLog(@"Content-Type: %@", [request valueForHTTPHeaderField:@"Content-Type"]);
    
    if (connectionRequest != nil) {
        [connectionRequest cancel];
        connectionRequest = nil;
    }

    if ([Global isReachable]) {
        [self showLoadingView:view];
      //  [NSThread detachNewThreadSelector:@selector(showLoadingView:) toTarget:self withObject:view];
        connectionRequest  = [[NSURLConnection alloc] initWithRequest:request
                                                              delegate:self startImmediately:NO];
        [connectionRequest scheduleInRunLoop:[NSRunLoop mainRunLoop]
                              forMode:NSDefaultRunLoopMode];
        [connectionRequest start];
    }else{
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"Internet not connected"];
    }
}

-(void)requestWithDictionaryForPromotion:(NSDictionary *)dictionary andDelegate:(id<HTTPWebServiceDelegate>)delegateNew action:(NSInteger )action controllerView:(UIView *)view{
    
    delegate=delegateNew;
    serviceAction=action;
    
    NSString *urlString=[Default_NEW_URL stringByAppendingString:[dictionary valueForKey:@"methodName"]];
    NSURL *url=[NSURL URLWithString:urlString];
    
    NSData *jsData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];

    NSString *dataProfile = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithData:jsData                                                                                 encoding:NSUTF8StringEncoding]];
    NSData *postData = [dataProfile dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:APIKey forHTTPHeaderField:@"apikey"];
    [request setHTTPBody:postData];
    
    NSLog(@"Content-Type: %@", [request valueForHTTPHeaderField:@"Content-Type"]);
    
    if ([Global isReachable]) {
        
        [NSThread detachNewThreadSelector:@selector(showLoadingView:) toTarget:self withObject:view];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }else{
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"Internet not connected"];
    }
    
}


-(void)showLoadingView :(UIView *)view{
    
       if (view!=nil) {
           alert = [[UIAlertView alloc] initWithTitle:@"Please Wait..." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
         
           UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
           [indicator startAnimating];
          
           [alert setValue:indicator forKey:@"accessoryView"];
           [alert show];

    }
   // loadingView = [LoadingView loadingViewInView:view withText:@"Please Wait...."];
}
-(void)requestWithDictionaryProfile:(NSDictionary *)dictionary andDelegate:(id<HTTPWebServiceDelegate>)delegateNew action:(NSInteger )action controllerView:(UIView *)view{
    delegate=delegateNew;
    serviceAction=action;
    controllerView=view;
    
    NSData *jsData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    //
    NSString *dataProfile = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithData:jsData                                                                                 encoding:NSUTF8StringEncoding]];
    NSString *urlString=[Default_NEW_URL stringByAppendingString:[dictionary valueForKey:@"methodName"]];
    if ([dictionary valueForKey:@"page"]!=nil) {
        urlString=[urlString stringByAppendingString:@"/"];
        urlString=[urlString stringByAppendingString:[dictionary valueForKey:@"page"]];
    }
        NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *postData = [dataProfile dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    NSString *postString = [self addQueryStringToUrlString:@"" withDictionary:dictionary];
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"request to server with data == %@",postString);
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:APIKey forHTTPHeaderField:@"apikey"];
    [request setHTTPBody:data];
    
    if ([Global isReachable]) {
        [NSThread detachNewThreadSelector:@selector(showLoadingView:) toTarget:self withObject:view];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }else{
        [Global showAlertMessageWithOkButtonAndTitle:APP_NAME andMessage:@"Internet not connected"];
    }

}
-(void)saveProfilePick{

    NSUserDefaults *loginDataUser= [NSUserDefaults standardUserDefaults];
    
    NSData* myEncodedImageData = [loginDataUser objectForKey:@"profileImage"];
    UIImage* image = [UIImage imageWithData:myEncodedImageData];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@uploadimage",Default_NEW_URL]]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    //[request setValue:APIKey forHTTPHeaderField:@"apikey"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString * contentT=@"Content-Disposition: form-data; name=\"file_upload\"; filename=";
 
    NSDictionary *loginData=[loginDataUser objectForKey:@"loginData"];
   
    contentT = [contentT stringByAppendingString: [loginData valueForKey:@"userid"]];
    contentT = [contentT stringByAppendingString: @".png\r\n" ];
    
    [body appendData:[[NSString stringWithString: contentT] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [request setHTTPBody:body];
    
    if ([Global isReachable]) {
        [NSURLConnection connectionWithRequest:request delegate:self];
       // loadingView = [LoadingView loadingViewInView:self.view withText:@"Please Wait...."];
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
            [urlWithQuerystring appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
    }
    return urlWithQuerystring;
}

@end
