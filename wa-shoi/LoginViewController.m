//
//  LoginViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/03.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "LoginViewController.h"
#import "WasshoiViewController.h"
#import "userNameViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "SVProgressHUD.h"
#import "AlertView.h"


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
    
    _userFormTableView.dataSource = self;
    _userFormTableView.delegate = self;
    
    self.userFormLabelAndText = [[NSMutableDictionary alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardShow:(NSNotification *)sender
{
    CGSize kbSize = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    int height;
    if(screenSize.width == 320.0 && screenSize.height == 480.0){
        height = 40;
    }else{
        height = 5;
    }
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, (kbSize.height-_userFormTableView.frame.origin.y/2-height), 0);
        [self.userFormTableView setContentInset:edgeInsets];
        [self.userFormTableView setScrollIndicatorInsets:edgeInsets];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)keyboardHide:(NSNotification *)sender
{
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
        [self.userFormTableView setContentInset:edgeInsets];
        [self.userFormTableView setScrollIndicatorInsets:edgeInsets];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; //とりあえずセクションは1個
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 == 1){
        return 10;
    }else{
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"loginFormCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    UITextField *textField = (UITextField *)[cell viewWithTag:1];
    
    if(indexPath.row % 2 == 0){
        
        switch(indexPath.row/2){
            case 0:
                textField.placeholder = @"ユーザー名";
                textField.tag = 0;
                break;
            case 1:
                textField.placeholder = @"パスワード";
                textField.tag = 1;
                [textField setSecureTextEntry:YES];
                break;
        }
        textField.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }else{
        UIView *contentView = [cell contentView];
        [textField removeFromSuperview];
        contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Make sure to set the label to have a ta
    
    NSString *fieldName;
    switch ((long)textField.tag) {
        case 0:
            fieldName = @"userName";
            break;
        case 1:
            fieldName = @"password";
            break;

    }
    
    [_userFormLabelAndText setObject:textField.text forKey:fieldName];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)loginSubmit:(id)sender {
    
    NSString *userName = [_userFormLabelAndText objectForKey:@"userName"];
    NSString *password = [_userFormLabelAndText objectForKey:@"password"];
    
    [SVProgressHUD setFont: [UIFont fontWithName:@"ヒラギノ明朝 ProN W3" size:20]];
    [SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"ログイン中"];
    
    [PFUser logInWithUsernameInBackground:userName
                                 password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if(user){
                                            
                                            // 遅延処理
                                            double delayInSeconds =  1.0;
                                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                [SVProgressHUD dismiss];
                                                WasshoiViewController *wasshoiViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"wasshoiView"];
                                                [self presentViewController:wasshoiViewcontroller animated:YES completion:nil];
                                            });

                                            // ユーザの登録後setobject
                                            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                                            currentInstallation[@"user"] = [PFUser currentUser];
                                            [currentInstallation saveInBackground];
                                            
                                        }else{
                                             [SVProgressHUD dismiss];
                                            [self showAlert:@"ユーザー名かパスワードが間違っています。"];
                                        }
                                    }
     ];
}


- (IBAction)facebookButtonTapped:(id)sender
{
    [SVProgressHUD setFont: [UIFont fontWithName:@"ヒラギノ明朝 ProN W3" size:20]];
    [SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"Facebookと通信中"];
    // パーミッション
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"email", @"read_friendlists"];
    FBSession *oursession = [[FBSession alloc] initWithPermissions:permissionsArray];
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
                    [SVProgressHUD dismiss];
                    NSString *last_name = [result objectForKey:@"last_name"];
                    NSString *user_name = [last_name stringByAppendingString:[result objectForKey:@"first_name"]];
                    
                    [[PFUser currentUser] setObject:[result objectForKey:@"email"]
                                             forKey:@"email"];
                    [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                             forKey:@"uid"];
                    [[PFUser currentUser] saveInBackground];
                    
                    // ユーザの登録後setobject
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    currentInstallation[@"user"] = [PFUser currentUser];
                    [currentInstallation saveInBackground];
                }
            }];
            
            [SVProgressHUD setFont: [UIFont fontWithName:@"ヒラギノ明朝 ProN W3" size:20]];
            [SVProgressHUD show];
            [SVProgressHUD showWithStatus:@"ログイン中"];

            // 遅延処理
            double delayInSeconds =  1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [SVProgressHUD dismiss];
                if([[PFUser currentUser] objectForKey:@"user_name"] == nil){
                    userNameViewController *userNameViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"userNameForm"];
                    [self presentViewController:userNameViewcontroller animated:YES completion:nil];
                }else{
                    WasshoiViewController *wasshoiViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"wasshoiView"];
                    [self presentViewController:wasshoiViewcontroller animated:YES completion:nil];
                }
            });
        }
        
    }];
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
