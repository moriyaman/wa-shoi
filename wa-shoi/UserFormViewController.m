//
//  UserFormViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/01.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "UserFormViewController.h"
#import <Parse/Parse.h>
#import "FriendListsViewController.h"
#import "AlertView.h"


@interface UserFormViewController ()

@end

@implementation UserFormViewController

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

- (IBAction)closeuserNameTextFieldKeybord:(id)sender {
    [_userNameTextField resignFirstResponder];
}
- (IBAction)closeuserPasswordTextFieldKeybord:(id)sender {
    [_userPasswordTextField resignFirstResponder];
}
- (IBAction)closeuserMailTextFieldKeybord:(id)sender {
    [_userMailTextField resignFirstResponder];
}

- (IBAction)userFormSubmit:(id)sender {
    
    PFUser *user = [PFUser user];
    
    AlertView *alertView = [AlertView new];
    [alertView setTitle:@"Error"];
    [alertView setOtherButtonTitle:@"OK"];
    
    if([self.userNameTextField.text length] == 0){
        [alertView setText:@"ユーザ名が入力されていません"];
    }else if([self.userMailTextField.text length] == 0){
        [alertView setText:@"メールアドレスが入力されていません"];
    }else if([self.userPasswordTextField.text length] == 0){
        [alertView setText:@"パスワードが入力されていません"];
    }
        
    if(alertView.text != nil){

      [alertView show];

    }else{
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"user_name" equalTo:self.userNameTextField.text];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if(!error){
                if([objects count] >= 1){
                    [alertView setText:@"入力されたユーザー名は既に登録されています"];
                    [alertView show];
                }else{
                    
                    // create_user
                    user.username = self.userNameTextField.text;
                    user.password = self.userPasswordTextField.text;
                    [user setObject:self.userNameTextField.text
                             forKey:@"user_name"];
                    [user setObject:self.userMailTextField.text
                             forKey:@"email"];
                    
                    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(!error){
                            // ユーザの登録後setobject
                            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                            [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
                            [currentInstallation saveInBackground];
                            
                            FriendListsViewController *friendListsViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"friendLists"];
                            [self presentViewController:friendListsViewcontroller animated:YES completion:nil];
                        } else {
                            NSLog(@"%ld", (long)error.code);
                            
                            // errorの制御
                            if((long)error.code == 125){
                                [alertView setText:@"不正なメールアドレスです"];
                                [alertView show];
                            }else if ((long)error.code == 203){
                                [alertView setText:@"既にこのメールアドレスは登録されています"];
                                [alertView show];
                            }else{
                                [alertView setText:@"通信エラーが発生しました"];
                                [alertView show];
                            }
                        }
                    }];
                }
                
            } else {
                [alertView setText:@"通信エラーが発生しました"];
                [alertView show];
            }
        }];

        
    }
}

@end
