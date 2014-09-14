//
//  LoginViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/03.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "FriendListsViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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
    [_userPasswordTextField resignFirstResponder];
}

- (IBAction)closeuserNameTextFieldKeybord:(id)sender {
    [_userNameTextField resignFirstResponder];
}


- (IBAction)loginSubmit:(id)sender {
    [PFUser logInWithUsernameInBackground:self.userNameTextField.text
                     password:self.userPasswordTextField.text
                        block:^(PFUser *user, NSError *error) {
                            if(user){
                                FriendListsViewController *friendListsViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"friendLists"];
                                [self presentViewController:friendListsViewcontroller animated:YES completion:nil];
                                
                                // ユーザの登録後setobject
                                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                                [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
                                [currentInstallation saveInBackground];
                                
                            }else{
                                NSLog(@"名前かパスワードが間違ってるよん");
                            }
                        }
     ];
}

- (IBAction)facebookButtonTapped:(id)sender
{
    // パーミッション
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"email", @"read_friendlists"];
    // Facebook アカウントを使ってログイン
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                NSLog(@"Facebook ログインをユーザーがキャンセル");
            } else {
                NSLog(@"Facebook ログイン中にエラーが発生: %@", error);
            }
        } else {
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSString *last_name = [result objectForKey:@"last_name"];
                    NSString *user_name = [last_name stringByAppendingString:[result objectForKey:@"first_name"]];
                    
                    [[PFUser currentUser] setObject:[result objectForKey:@"email"]
                                             forKey:@"email"];
                    [[PFUser currentUser] setObject:user_name
                                             forKey:@"user_name"];
                    [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                             forKey:@"uid"];
                    [[PFUser currentUser] saveInBackground];
                    
                    // ユーザの登録後setobject
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
                    [currentInstallation saveInBackground];

                }
            }];
            
            FriendListsViewController *friendListsViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"friendLists"];
            [self presentViewController:friendListsViewcontroller animated:YES completion:nil];
            
        }
        
    }];
}


@end