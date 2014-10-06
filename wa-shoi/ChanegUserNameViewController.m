//
//  ChanegUserNameViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/10/03.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "ChanegUserNameViewController.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"
#import "MypageViewController.h"
#import "AlertView.h"

@interface ChanegUserNameViewController ()

@end

@implementation ChanegUserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userNameTextField.text = [[PFUser currentUser] objectForKey:@"user_name"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeUserNameTextFieldKeybord:(id)sender {
    [_userNameTextField resignFirstResponder];
}

- (IBAction)formSubmit:(id)sender {
    NSString *user_name = self.userNameTextField.text;
    if(user_name == nil || [user_name length] == 0){
        [self showAlert:@"ユーザー名が入力されていません"];
    }else{
        
        [SVProgressHUD setFont: [UIFont fontWithName:@"ヒラギノ明朝 ProN W3" size:20]];
        [SVProgressHUD show];
        [SVProgressHUD showWithStatus:@"変更中"];
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"user_name" equalTo:user_name];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if(!error){
                if([objects count] > 0){
                    [SVProgressHUD dismiss];
                    [self showAlert:@"入力されたユーザー名は既に存在しているため登録できません"];
                }else{
                    PFUser *user = [PFUser currentUser];
                    user[@"user_name"] = user_name;
                    
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!succeeded) {
                            [SVProgressHUD dismiss];
                            [self showAlert:@"ユーザー名の変更に失敗しました。再度立ち上げ直して実行して下さい。"];
                        }else{
                            // ユーザの登録後setobject
                            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                            [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
                            [currentInstallation saveInBackground];
                            
                            double delayInSeconds =  1.0;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                [SVProgressHUD dismiss];
                                MypageViewController *myPageViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"myPage"];
                                [self presentViewController:myPageViewcontroller animated:YES completion:nil];
                                
                            });
                            
                        }
                    }];
                    
                }
            }
        }];
    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)showAlert:(NSString*)text
{
    AlertView *alertView = [AlertView new];
    [alertView setTitle:@"Error"];
    [alertView setOtherButtonTitle:@"OK"];
    [alertView setText:text];
    [alertView show];
}

@end
