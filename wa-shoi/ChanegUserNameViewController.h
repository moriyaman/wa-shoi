//
//  ChanegUserNameViewController.h
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/10/03.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChanegUserNameViewController : UIViewController


@property IBOutlet UITextField * userNameTextField;

- (IBAction)closeUserNameTextFieldKeybord:(id)sender;
- (IBAction)formSubmit:(id)sender;


@end
