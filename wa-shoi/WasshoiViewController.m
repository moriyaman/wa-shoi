//
//  WasshoiViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/08/25.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "WasshoiViewController.h"
#import <Parse/Parse.h>
#import "FriendListsViewController.h"

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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2 == 1){
        return 20;
    }else{
        return 80;
    }
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
            }
        }
    }
}


// click event on right utility button
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index;
{
    NSIndexPath *cellIndexPath = [self.wasshoiUserTableView indexPathForCell:cell];
    PFUser *friendUser = self.dataFriendUserLists[cellIndexPath.row/2];
    PFUser *user = [PFUser currentUser];
    
    if(index == 0){
        
        PFObject *blockUser = [PFObject objectWithClassName:@"BlockUser"];
        PFRelation *userRelation = [blockUser relationForKey:@"user"];
        [userRelation addObject:user];
        
        PFRelation *friendRelation = [blockUser relationForKey:@"friendUser"];
        [friendRelation addObject:friendUser];
        
        blockUser[@"userObjectId"] = user.objectId;
        blockUser[@"friendUserObjectId"] = friendUser.objectId;
        
        [blockUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [self showAlert:@"Blockの登録に失敗しました。再度起動し直して実行してください"];
            }
        }];
        // block
        
    }else if (index == 1){
        
        PFQuery *friendQuery = [PFQuery queryWithClassName:@"Friend"];
        [friendQuery whereKey:@"userObjectId" equalTo:user.objectId];
        [friendQuery whereKey:@"friendUserObjectId" equalTo:friendUser.objectId];
        [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            [objects[0] deleteInBackground];
        }];
        
        [self.dataFriendUserLists removeObjectAtIndex:(cellIndexPath.row)/2];
        
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:cellIndexPath.row+1 inSection:cellIndexPath.section];
        [_wasshoiUserTableView deleteRowsAtIndexPaths:@[cellIndexPath, newPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((self.dataFriendUserLists.count)*2)+2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; //とりあえずセクションは1個
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserCell";
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    int friendAddCellNum = (int)self.dataFriendUserLists.count*2;
    if ((long)indexPath.row >= friendAddCellNum) {
        if(indexPath.row % 2 == 0){
            UILabel *userNameLabel = [cell viewWithTag:1];
            userNameLabel.text = @"";
        }else{
            UILabel *userNameLabel = [cell viewWithTag:1];
            UIView *backView = [cell viewWithTag:2];
            userNameLabel.text = nil;
            backView.backgroundColor = [UIColor clearColor];
            UIView *plusView = [cell viewWithTag:3];
            [plusView removeFromSuperview];
        }
    }else{
        // 偶数の場合はクリアなラベルに. 奇数の場合のみデータを表示
        if(indexPath.row % 2 == 0){
            cell.rightUtilityButtons = [self rightButtons];
            cell.delegate = self;
            NSString *userName = [self.dataFriendUserLists[(indexPath.row)/2] objectForKey:@"user_name"];
            UILabel *userNameLabel = [cell viewWithTag:1];
            userNameLabel.text = userName;
        }else{
            UILabel *userNameLabel = [cell viewWithTag:1];
            UIView *backView = [cell viewWithTag:2];
            userNameLabel.text = nil;
            backView.backgroundColor = [UIColor clearColor];
        }
        UIView *plusView = [cell viewWithTag:3];
        [plusView removeFromSuperview];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"Block"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    int friendAddCellNum = (int)self.dataFriendUserLists.count*2;
    
    if ((long)indexPath.row >= friendAddCellNum){

        FriendListsViewController *friendListsViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"friendLists"];
        [self presentViewController:friendListsViewcontroller animated:YES completion:nil];
        
    }else if(indexPath.row % 2 == 0){
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        UITableViewCell *cell = [_wasshoiUserTableView cellForRowAtIndexPath:indexPath];
        
        UILabel *userNameLabel = [cell viewWithTag:1];
        NSString *userName = userNameLabel.text;
        
        [indicator setCenter:CGPointMake(142, 31)];
        [cell addSubview:indicator];
        [indicator startAnimating];
        userNameLabel.text = @"";
        
        // 遅延処理
        double delayInSeconds =  1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [indicator removeFromSuperview];
            userNameLabel.text = @"わっしょーい！";
        });
        
        // 遅延処理2
        double washoiDelayInSeconds =  2.0;
        dispatch_time_t washoiPopTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(washoiDelayInSeconds * NSEC_PER_SEC));
        dispatch_after(washoiPopTime, dispatch_get_main_queue(), ^(void){
            
            
            PFUser * friendUser = self.dataFriendUserLists[(indexPath.row)/2];
            PFUser * user = [PFUser currentUser];
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"pa-ni- wasshoi", @"alert",
                                  @"kamiosakoWasshoi.m4a", @"sound",
                                  nil];
            
            
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
            
            //[indicator removeFromSuperview];
            //userNameLabel.text = @"わっしょーい！";
            
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
            
            //最後に名前を戻す
            userNameLabel.text = userName;
        });
        
        // 動きの部分
        NSInteger lastSectionIndex = [_wasshoiUserTableView numberOfSections] - 1;
        NSInteger lastRowIndex = [_wasshoiUserTableView numberOfRowsInSection:lastSectionIndex] - 1;
        
        NSIndexPath *topRow = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *topNextRow = [NSIndexPath indexPathForRow:1 inSection:0];
        
        NSIndexPath *clickNextPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        
        [_wasshoiUserTableView beginUpdates];
        [_wasshoiUserTableView moveRowAtIndexPath:indexPath toIndexPath:topRow];
        [_wasshoiUserTableView moveRowAtIndexPath:clickNextPath toIndexPath:topNextRow];
        [_wasshoiUserTableView endUpdates];
    }
    return;
}


- (IBAction)firstViewReturnActionForSegue:(UIStoryboardSegue *)segue
{
    NSLog(@"First view return action invoked.");
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (destinationIndexPath.row < _dataFriendUserLists.count) {
        // sourceIndexPath(移動元のインデックス)から、行データを得る
        PFUser *user =[self.dataFriendUserLists objectAtIndex:(sourceIndexPath.row)/2];
        
        //[_wasshoiUserTableView beginUpdates];
        
        [self.dataFriendUserLists removeObjectAtIndex:(sourceIndexPath.row)/2];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:sourceIndexPath.row+1 inSection:sourceIndexPath.section];
        
        [_wasshoiUserTableView deleteRowsAtIndexPaths:@[sourceIndexPath, newPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.dataFriendUserLists insertObject:user atIndex:(destinationIndexPath.row)/2];
        
        NSIndexPath *destinationNextPath = [NSIndexPath indexPathForRow:destinationIndexPath.row+1 inSection:destinationIndexPath.section];
        [_wasshoiUserTableView insertRowsAtIndexPaths:@[destinationIndexPath, destinationNextPath]
                                     withRowAnimation:UITableViewRowAnimationLeft];
        
        //[_wasshoiUserTableView endUpdates];
        
    }
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
