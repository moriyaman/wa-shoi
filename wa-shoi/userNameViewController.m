//
//  userNameViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/30.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "userNameViewController.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"
#import "WasshoiViewController.h"
#import "AlertView.h"

@interface userNameViewController ()

@end

@implementation userNameViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)closeuserPasswordTextFieldKeybord:(id)sender {
    [_userNameTextField resignFirstResponder];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (IBAction)formSubmit:(id)sender {

    NSString *user_name = self.userNameTextField.text;
    if(user_name == nil || [user_name length] == 0){
        [self showAlert:@"ユーザー名が入力されていません"];
    }else{
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"user_name" equalTo:user_name];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if(!error){
                if([objects count] > 0){
                    [self showAlert:@"入力されたユーザー名は既に存在しているため登録できません"];
                }else{
                    PFUser *user = [PFUser currentUser];
                    user[@"user_name"] = user_name;
                    
                    [SVProgressHUD setFont: [UIFont fontWithName:@"ヒラギノ明朝 ProN W3" size:20]];
                    [SVProgressHUD show];
                    [SVProgressHUD showWithStatus:@"登録中"];
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!succeeded) {
                            [SVProgressHUD dismiss];
                            [self showAlert:@"ユーザー名の登録に失敗しました。再度立ち上げ直して実行して下さい。"];
                        }else{
                            // ユーザの登録後setobject
                            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                            [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
                            [currentInstallation saveInBackground];
                            
                            double delayInSeconds =  1.0;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                [SVProgressHUD dismiss];
                                WasshoiViewController *wasshoiViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"wasshoiView"];
                                [self presentViewController:wasshoiViewcontroller animated:YES completion:nil];
                                
                            });
                            
                        }
                    }];
                    
                }
            }
        }];
    }

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
