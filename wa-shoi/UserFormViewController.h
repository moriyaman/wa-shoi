//
//  UserFormViewController.h
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/01.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserFormViewController : UIViewController
<UITextFieldDelegate, UIGestureRecognizerDelegate>

- (IBAction)closeuserNameTextFieldKeybord:(id)sender;
- (IBAction)closeuserPasswordTextFieldKeybord:(id)sender;
- (IBAction)closeuserMailTextFieldKeybord:(id)sender;

- (IBAction)userFormSubmit:(id)sender;

@property IBOutlet UITextField * userNameTextField;
@property IBOutlet UITextField * userPasswordTextField;
@property IBOutlet UITextField * userMailTextField;


@end
