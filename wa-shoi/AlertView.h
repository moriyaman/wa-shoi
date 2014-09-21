//
//  AlertView.h
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/20.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertView : NSObject
{
    NSString *_text;
    NSString *_title;
    NSString *_cancelButtonTitle;
    NSString *_otherButtonTitle;
}

- (NSString *)text;

- (void)setText:(NSString *)text;
- (void)setTitle:(NSString *)title;
- (void)setCancelButtonTitle:(NSString *)title;
- (void)setOtherButtonTitle:(NSString *)title;
- (void)show;

@end
