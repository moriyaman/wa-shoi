//
//  UserFormViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/01.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "UserFormViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "FriendListsViewController.h"
#import "AlertView.h"
#import "SVProgressHUD.h"


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

    _userFormTableView.dataSource = self;
    _userFormTableView.delegate = self;
 
    self.userFormLabelAndText = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)sender
{
    CGSize kbSize = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, (kbSize.height-60), 0);
        [self.userFormTableView setContentInset:edgeInsets];
        [self.userFormTableView setScrollIndicatorInsets:edgeInsets];
    }];
}

- (void)keyboardWillHide:(NSNotification *)sender
{
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
        [self.userFormTableView setContentInset:edgeInsets];
        [self.userFormTableView setScrollIndicatorInsets:edgeInsets];
    }];
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *)[textField superview];
    NSIndexPath *indexPath = [self.userFormTableView indexPathForCell:cell];
    [self.userFormTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; //とりあえずセクションは1個
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 == 1){
        return 20;
    }else{
        return 60;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userFormCell";
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
                break;
            case 1:
                textField.placeholder = @"メールアドレス";
                break;
            case 2:
                textField.placeholder = @"パスワード";
                [textField setSecureTextEntry:YES];
                break;
        }
        textField.delegate = self;
        textField.tag = (indexPath.row)+5;
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
        case 5:
            fieldName = @"userName";
            break;
        case 7:
            fieldName = @"mailAddress";
            break;
        case 9:
            fieldName = @"password";
            break;
    }
    
    [_userFormLabelAndText setObject:textField.text forKey:fieldName];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 == 0){
        
        switch (indexPath.row/2) {
            case 0:
                break;
            case 1:
                break;
            case 2:
                break;
            case 3:
                break;
            case 4:
                break;
            default:
                break;
        }
    }
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)userFormSubmit:(id)sender {
    
    PFUser *user = [PFUser user];
    
    AlertView *alertView = [AlertView new];
    [alertView setTitle:@"Error"];
    [alertView setOtherButtonTitle:@"OK"];
    
    NSString *userName = [_userFormLabelAndText objectForKey:@"userName"];
    NSString *mailAddress = [_userFormLabelAndText objectForKey:@"mailAddress"];
    NSString *password = [_userFormLabelAndText objectForKey:@"password"];
    
    if([userName length] == 0){
        [alertView setText:@"ユーザ名が入力されていません"];
    }else if([mailAddress length] == 0){
        [alertView setText:@"メールアドレスが入力されていません"];
    }else if([password length] == 0){
        [alertView setText:@"パスワードが入力されていません"];
    }
        
    if(alertView.text != nil){

      [alertView show];

    }else{
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"user_name" equalTo:userName];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if(!error){
                if([objects count] >= 1){
                    [alertView setText:@"入力されたユーザー名は既に登録されています"];
                    [alertView show];
                }else{
                    
                    // create_user
                    user.username = userName;
                    user.password = password;
                    [user setObject:userName
                             forKey:@"user_name"];
                    [user setObject:mailAddress
                             forKey:@"email"];
                    
                    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(!error){
                            // ユーザの登録後setobject
                            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                            [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
                            [currentInstallation saveInBackground];
                            
                            [SVProgressHUD setFont: [UIFont fontWithName:@"ヒラギノ明朝 ProN W3" size:20]];
                            [SVProgressHUD show];
                            [SVProgressHUD showWithStatus:@"アカウント作成中"];
                            
                            // 遅延処理
                            double delayInSeconds =  1.0;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                FriendListsViewController *friendListsViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"friendLists"];
                                [self presentViewController:friendListsViewcontroller animated:YES completion:nil];
                            });
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
            
            [SVProgressHUD setFont: [UIFont fontWithName:@"ヒラギノ明朝 ProN W3" size:20]];
            [SVProgressHUD show];
            [SVProgressHUD showWithStatus:@"ログイン中"];
            
            // 遅延処理
            double delayInSeconds =  1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [SVProgressHUD dismiss];
                FriendListsViewController *friendListsViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"friendLists"];
                [self presentViewController:friendListsViewcontroller animated:YES completion:nil];
            });
        }
        
    }];
}



@end
