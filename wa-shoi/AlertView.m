//
//  AlertView.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/20.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "AlertView.h"

@implementation AlertView


- (void)setText:(NSString *)text
{
  _text = text;
}

- (void)setTitle:(NSString *)title{
    _title = title;
}

- (void)setCancelButtonTitle:(NSString *)title
{
    _cancelButtonTitle = title;
}

- (void)setOtherButtonTitle:(NSString *)title{
    _otherButtonTitle = title;
}

- (NSString *)text{
    return _text;
}

- (void)show
{
    Class class = NSClassFromString(@"UIAlertController");
    //if(class){
    // UIAlertControllerを使ってアラートを表示
    //    UIAlertController *alert = nil;
    //    alert = [UIAlertController alertControllerWithTitle:@"Title"
    //                                                message:text
    //                                         preferredStyle:UIAlertControllerStyleAlert];
    //    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
    //                                              style:UIAlertActionStyleDefault
    //                                            handler:nil]];
    //    [self presentViewController:alert animated:YES completion:nil];
    //}else{
    // UIAlertViewを使ってアラートを表示
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_title
                                                    message:_text
                                                   delegate:nil
                                          cancelButtonTitle:_cancelButtonTitle
                                          otherButtonTitles:_otherButtonTitle, nil];
    [alert show];
    //}
}


@end
