//
//  VideoListCell.m
//  360 Project
//
//  Created by Hitaishin Technologies on 12/5/14.
//  Copyright (c) 2014 Hitaishin Infotech. All rights reserved.
//

#import "VideoListCell.h"
#import "Global.h"
@implementation VideoListCell

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay]; // force drawRect:
    [Global setFontRecursively:self];

  //  self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
}

//-(void)awakeFromNib
//{
//    [super awakeFromNib];
//    
//    self.contentView.frame = self.bounds;
//    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//}
@end
