//
//  WasshoiViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/08/25.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "WasshoiViewController.h"
#import <Parse/Parse.h>

@interface WasshoiViewController ()

@end

@implementation WasshoiViewController

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
    
    //long press
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;
    lpgr.delegate = self;
    [_wasshoiUserTableView addGestureRecognizer:lpgr];
    
    // Do any additional setup after loading the view.
    _wasshoiUserTableView.delegate = self;
    _wasshoiUserTableView.dataSource = self;
    
    PFUser * toUser = [PFUser currentUser];
    
    // 友達一覧を獲得
    PFQuery *friendQuery = [PFQuery queryWithClassName:@"Friend"];
    [friendQuery whereKey:@"user" equalTo:toUser];
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" matchesKey:@"friendUserObjectId" inQuery:friendQuery];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            _dataFriendUserLists = [NSMutableArray arrayWithArray:objects];
            [self.wasshoiUserTableView reloadData];
        } else {
            [self showAlert:@"通信エラーが発生しました"];
        }
    }];

}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
       CGPoint p = [gestureRecognizer locationInView:self.wasshoiUserTableView];
       NSIndexPath *indexPath = [self.wasshoiUserTableView indexPathForRowAtPoint:p];
       if (indexPath == nil) {
          NSLog(@"long press on table view but not on a row");
       } else {
          UITableViewCell *cell = [self.wasshoiUserTableView cellForRowAtIndexPath:indexPath];
          if (cell.isHighlighted) {
            SystemSoundID hirai_long_wasshoi_scoud;
            NSString *path = [[NSBundle mainBundle] pathForResource:@"kamiosakoWasshoi" ofType:@"m4a"];
            NSURL *url = [NSURL fileURLWithPath:path];
            AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &hirai_long_wasshoi_scoud);
            AudioServicesPlaySystemSound(hirai_long_wasshoi_scoud);
            NSLog(@"long press on table view at section %d row %d", indexPath.section, indexPath.row);
          }
       }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataFriendUserLists.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1; //とりあえずセクションは1個
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell = [_wasshoiUserTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    NSString *userName = [self.dataFriendUserLists[indexPath.row] objectForKey:@"user_name"];
    UILabel *userNameLabel = [cell viewWithTag:1];
    userNameLabel.text = userName;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PFUser * friendUser = self.dataFriendUserLists[indexPath.row];
    PFUser * user = [PFUser currentUser];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"pa-ni- wasshoi", @"alert",
                          @"Hirai_wasshoi.m4a", @"sound",
                          nil];
    
    // Create our Installation query
    
    PFQuery *userQuery = [PFUser query];
    [userQuery getObjectWithId: @"58Cvn81ySB"];
    
    // Find devices associated with these users
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" matchesQuery:userQuery];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setMessage:@"pa-ni-"];
    [push setData:data];
    [push sendPushInBackground];
    
    
    // Date create
    PFObject *wasshoi = [PFObject objectWithClassName:@"Wasshoi"];
    PFRelation *userRelation = [wasshoi relationForKey:@"user"];
    [userRelation addObject:user];
    PFRelation *friendRelation = [wasshoi relationForKey:@"friendUser"];
    [friendRelation addObject:friendUser];
    wasshoi[@"userObjectId"] = user.objectId;
    wasshoi[@"friendUserObjectId"] = friendUser.objectId;
    
    [wasshoi saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            [self showAlert:@"わっしょいに失敗しました"];
        } else {
            NSLog(@"成功");
        }
    }];
    
    return;
}

- (IBAction)firstViewReturnActionForSegue:(UIStoryboardSegue *)segue
{
    NSLog(@"First view return action invoked.");
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

- (void)showAlert:(NSString*)text
{
    Class class = NSClassFromString(@"UIAlertController");
    //if(class){
    // UIAlertControllerを使ってアラートを表示
    //    UIAlertController *alert = nil;
    //    alert = [UIAlertController alertControllerWithTitle:@"Title"
    //                                                message:text
    //                                         preferredStyle:UIAlertControllerStyleAlert];
    //    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
    //                                              style:UIAlertActionStyleDefault
    //                                            handler:nil]];
    //    [self presentViewController:alert animated:YES completion:nil];
    //}else{
    // UIAlertViewを使ってアラートを表示
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Title"
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
    //}
}


@end
