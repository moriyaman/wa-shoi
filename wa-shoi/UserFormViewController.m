//
//  UserFormViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/01.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "UserFormViewController.h"
#import <Parse/Parse.h>

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
    user.username = self.userNameTextField.text;
    user.password = self.userPasswordTextField.text;
    [user setObject:self.userNameTextField.text
             forKey:@"user_name"];
    [user setObject:self.userMailTextField.text
             forKey:@"email"];
    [user setObject:self.userPasswordTextField.text
             forKey:@"password"];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            // ユーザの登録後setobject
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
            [currentInstallation saveInBackground];
            
        }
    }];

    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
