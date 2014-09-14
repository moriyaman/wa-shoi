//
//  LoginViewController.h
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/03.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property IBOutlet UITextField * userPasswordTextField;
@property IBOutlet UITextField * userNameTextField;

- (IBAction)closeuserPasswordTextFieldKeybord:(id)sender;
- (IBAction)closeuserNameTextFieldKeybord:(id)sender;
- (IBAction)loginSubmit:(id)sender;
- (IBAction)facebookButtonTapped:(id)sender;


@end