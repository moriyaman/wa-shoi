//
//  UserFormViewController.h
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/01.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserFormViewController : UIViewController
<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate, UIGestureRecognizerDelegate>

- (IBAction)userFormSubmit:(id)sender;
- (IBAction)facebookButtonTapped:(id)sender;

@property IBOutlet UITableView * userFormTableView;
@property (strong, nonatomic) NSMutableDictionary *userFormLabelAndText;


@end
