//
//  MypageViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/14.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "MypageViewController.h"
#import <Parse/Parse.h>
#import "LINEActivity.h"
#import "MBCViewController.h"
#import "FriendListsViewController.h"
#import "ScrollViewController.h"
#import "HowToWasshoiViewController.h"
#import "SVProgressHUD.h"
#import "ChanegUserNameViewController.h"

@interface MypageViewController ()

@end

@implementation MypageViewController

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
    
    //自分で聞く用の「わっしょい」
    NSString *path = [[NSBundle mainBundle] pathForResource:@"kamiosakoWasshoiShort" ofType:@"m4a"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.kamiosakoWasshoi = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];

    // わっしょいの送信数を取得
    PFQuery *wasshoiSendQuery = [PFQuery queryWithClassName:@"Wasshoi"];
    [wasshoiSendQuery whereKey:@"userObjectId" equalTo:[PFUser currentUser].objectId];
    [wasshoiSendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            _wasshoiSendCnt = [objects count];
        } else {
            //特になにもしない
        }
    }];
    
    _myPageTableView.delegate = self;
    _myPageTableView.dataSource = self;

}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 14;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; //とりあえずセクションは1個
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 == 1){
        return 20;
    }else{
        return 80;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    UILabel *settingNameLabel = (UILabel *)[cell viewWithTag:1];

    if(indexPath.row % 2 == 0){
        
        
        switch(indexPath.row/2){
            case 0:
                settingNameLabel.text = [NSString stringWithFormat:@"ユーザー名：%@", [[PFUser currentUser] objectForKey:@"user_name"]];
                settingNameLabel.font = [UIFont fontWithName:@"ヒラギノ明朝 ProN W6" size:20];
                break;
            case 1:
                settingNameLabel.text = @"自分にわっしょい";
                settingNameLabel.font = [UIFont fontWithName:@"ヒラギノ明朝 ProN W6" size:25];
                break;
            case 2:
                settingNameLabel.text = @"友達を招待";
                settingNameLabel.font = [UIFont fontWithName:@"ヒラギノ明朝 ProN W6" size:25];
                break;
            case 3:
                settingNameLabel.text = @"友達検索";
                settingNameLabel.font = [UIFont fontWithName:@"ヒラギノ明朝 ProN W6" size:25];
                break;
            case 4:
                settingNameLabel.text = @"わっしょいとは？";
                settingNameLabel.font = [UIFont fontWithName:@"ヒラギノ明朝 ProN W6" size:25];
                break;
            case 5:
                settingNameLabel.text = [NSString stringWithFormat:@"わっしょいした数：%lu", (unsigned long)_wasshoiSendCnt];
                settingNameLabel.font = [UIFont fontWithName:@"ヒラギノ明朝 ProN W6" size:25];
                break;
            case 6:
                settingNameLabel.text = @"ログアウト";
                settingNameLabel.font = [UIFont fontWithName:@"ヒラギノ明朝 ProN W6" size:25];
                break;
        }
        
        UIView *customColorView = [[UIView alloc] init];
        customColorView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.90];
        cell.selectedBackgroundView =  customColorView;
    }else{
        UIView *backView = [cell viewWithTag:3];
        settingNameLabel.text = nil;
        backView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 == 0){
        
        switch (indexPath.row/2) {
            case 0:
                [self moveChangeUserName];
                break;
            case 1:
                [self.kamiosakoWasshoi play];
                break;
            case 2:
                [self shareLink];
                break;
            case 3:
                [self moveFriendList];
                break;
            case 4:
                [self moveHowToWasshoi];
                break;
            case 6:
                [self logout];
                break;
            default:
                break;
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        //UIView *backView = [cell viewWithTag:3];
        //backView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.90];
    }
    return;
}

- (void)moveFriendList {
    FriendListsViewController *friendListController = [self.storyboard instantiateViewControllerWithIdentifier:@"friendLists"];
    [self presentViewController:friendListController animated:YES completion:nil];
}

- (void)moveHowToWasshoi {
    HowToWasshoiViewController *howToWasshoiController = [self.storyboard instantiateViewControllerWithIdentifier:@"howToWasshoi"];
    [self presentViewController:howToWasshoiController animated:YES completion:nil];
}

- (void)moveChangeUserName {
    ChanegUserNameViewController *chanegUserNameViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChanegUserNameView"];
    [self presentViewController:chanegUserNameViewController animated:YES completion:nil];
}

- (void)say_Wasshoi {
    [self.kamiosakoWasshoi play];
}

- (void)modalPrivacyPolicy {
    ScrollViewController *scrollViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"privacyPolicy"];
    [self presentViewController:scrollViewcontroller animated:YES completion:nil];
}

- (void)modalTermsView {
    ScrollViewController *scrollViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"termsView"];
    [self presentViewController:scrollViewcontroller animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareLink {
    
    NSString *text  = @"わっしょいめっちゃ面白いよ！";
    NSURL *url = [NSURL URLWithString:@"http://wasshoi.com"];
    NSArray *activityItems = @[text, url];
    LINEActivity *lineActivity = [[LINEActivity alloc] init];
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                               applicationActivities:@[lineActivity]];
    [self presentViewController:activityView animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *backView = [cell viewWithTag:3];
    if(indexPath.row % 2 == 0){
        backView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.90];
    }else{
        backView.backgroundColor = [UIColor clearColor];
    }
}

- (void)logout {
    [SVProgressHUD setFont: [UIFont fontWithName:@"ヒラギノ明朝 ProN W3" size:20]];
    [SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"ログアウト中"];
    [PFUser logOut];
    // 遅延処理
    double delayInSeconds =  2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [SVProgressHUD showSuccessWithStatus:@"ログアウト完了"];
        [SVProgressHUD popActivity];

        MBCViewController *mbcViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"mbcView"];
        [self presentViewController:mbcViewcontroller animated:YES completion:nil];
    });
}

@end
