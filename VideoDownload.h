//
//  VideoDownload.h
//  360 VUZ
//
//  Created by Hitaishin Infotech Pvt. Ltd. on 1/9/15.
//  Copyright (c) 2015 Hitaishin Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VideoDownload : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * metaData;
@property (nonatomic, retain) NSString * siteUrl;
@property (nonatomic, retain) NSString * subcategory;
@property (nonatomic, retain) NSString * uploadDate;
@property (nonatomic, retain) NSString * videoCity;
@property (nonatomic, retain) NSString * videoDescription;
@property (nonatomic, retain) NSNumber * videoId;
@property (nonatomic, retain) NSString * videoLink;
@property (nonatomic, retain) NSString * videoThumbnail;
@property (nonatomic, retain) NSString * videoTitle;
@property (nonatomic, retain) NSString * videoFileLink,* videoType;

@end
