//
//  IntroViewController.m
//  wa-shoi
//
//  Created by Yuri Hirane on 2014/08/27.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "IntroViewController.h"
#import <Parse/Parse.h>
#import "FriendListsViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

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
    EAIntroPage *page1 = [EAIntroPage pageWithCustomViewFromNibNamed:@"IntroPage1"];
    EAIntroPage *page2 = [EAIntroPage pageWithCustomViewFromNibNamed:@"IntroPage2"];
    EAIntroPage *page3 = [EAIntroPage pageWithCustomViewFromNibNamed:@"IntroPage3"];
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                }
            }];
            
            // FBRequest* friendsRequest = [FBRequest requestForMyFriends];
            // [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
            //                                             NSDictionary* result,
            //                                              NSError *error) {
            //    NSArray* friends = [result objectForKey:@"data"];
            //    for (NSDictionary<FBGraphUser>* friend in friends) {
            //        NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
            //    }
            //}];
            
            
            FriendListsViewController *friendListsViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"friendLists"];
            [self presentViewController:friendListsViewcontroller animated:YES completion:nil];
            
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
