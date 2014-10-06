//
//  userNameViewController.h
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/30.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface userNameViewController : UIViewController

@property IBOutlet UITextField * userNameTextField;

- (IBAction)closeuserPasswordTextFieldKeybord:(id)sender;
- (IBAction)formSubmit:(id)sender;

@end
