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
#import "AlertView.h"

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

- (void)incrementCounter:(UITableViewCell *)cell frame:(CGRect)backGaugeViewFrame increase:(float)increase{
    self.counter++;
    
    int counter = (int)self.counter;
    UIView *backGaugeView = (UIView *)[cell viewWithTag:4];
    CGRect new = CGRectMake(backGaugeViewFrame.origin.x, backGaugeViewFrame.origin.y, counter * increase, backGaugeViewFrame.size.height);
    backGaugeView.frame = new;
    
    if(counter * increase >= backGaugeViewFrame.size.width){
        [self.timer invalidate];
 
        
        // 下記はあとでまとめたい
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        NSIndexPath *indexPath = [self.wasshoiUserTableView indexPathForCell:cell];
        
        //user&friend
        PFUser * friendUser = self.dataFriendUserLists[(indexPath.row)/2];
        PFUser * user = [PFUser currentUser];
        
        UILabel *userNameLabel = (UILabel *)[cell viewWithTag:1];
        userNameLabel.text = @"";
        
        CGRect cellBounds = cell.bounds;
        [indicator setCenter:CGPointMake((cellBounds.size.width)/2, (cellBounds.size.height)/2)];
        [cell addSubview:indicator];
        [indicator startAnimating];
        
        //ブロックの確認
        PFQuery *blockUserQuesry = [PFQuery queryWithClassName:@"BlockUser"];
        [blockUserQuesry whereKey:@"friendUserObjectId" equalTo:user.objectId];
        [blockUserQuesry whereKey:@"userObjectId" equalTo:friendUser.objectId];
        [blockUserQuesry findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if(!error){
                if([objects count] > 0){
                    [indicator removeFromSuperview];
                    userNameLabel.text = [self.dataFriendUserLists[(indexPath.row)/2] objectForKey:@"user_name"];
                    [self showAlert:@"ブロック登録されているのでわっしょいできません"];
                }else{
                    
                    // 遅延処理
                    double delayInSeconds =  1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [indicator removeFromSuperview];
                        userNameLabel.text = @"わっしょーーーい！";
                    });
                    
                    // 遅延処理2
                    double washoiDelayInSeconds =  2.0;
                    dispatch_time_t washoiPopTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(washoiDelayInSeconds * NSEC_PER_SEC));
                    dispatch_after(washoiPopTime, dispatch_get_main_queue(), ^(void){
                        
                        NSString *notificationMsg = [[user objectForKey:@"user_name"] stringByAppendingString:@" わっしょーーーい！"];
                        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                              notificationMsg, @"alert",
                                              @"kamiosakoWasshoiLong.m4a", @"sound",
                                              nil];
                        
                        
                        PFQuery *userQuery = [PFUser query];
                        [userQuery getObjectWithId: friendUser.objectId];
                        
                        // Find devices associated with these users
                        PFQuery *pushQuery = [PFInstallation query];
                        [pushQuery whereKey:@"user" matchesQuery:userQuery];
                        
                        // Send push notification to query
                        PFPush *push = [[PFPush alloc] init];
                        [push setQuery:pushQuery]; // Set our Installation query
                        [push setMessage:@"wasshoi"];
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
                        
                        //最後に名前を戻す
                        userNameLabel.text = userNameLabel.text;
                        backGaugeView.frame = CGRectMake(backGaugeViewFrame.origin.x, backGaugeViewFrame.origin.y, 0, backGaugeViewFrame.size.height);
                    });
                }
            }
        }];
        
        
        // 動きの部分
        NSIndexPath *topRow = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *topNextRow = [NSIndexPath indexPathForRow:1 inSection:0];
        
        NSIndexPath *clickNextPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        
        [self.dataFriendUserLists removeObjectAtIndex:(indexPath.row)/2];
        [self.dataFriendUserLists insertObject:friendUser atIndex:topRow.row];
        
        [_wasshoiUserTableView beginUpdates];
        [_wasshoiUserTableView moveRowAtIndexPath:indexPath toIndexPath:topRow];
        [_wasshoiUserTableView moveRowAtIndexPath:clickNextPath toIndexPath:topNextRow];
        [_wasshoiUserTableView endUpdates];
    }
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

    SWTableViewCell *cell = (SWTableViewCell *)gestureRecognizer.view;
    UIView *backGaugeView = (UIView *)[cell viewWithTag:4];
    CGRect cellBounds = cell.bounds;
    CGRect backGaugeViewFrame = cell.frame;
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    float increase = cellBounds.size.width/2000;
    nameLabel.text = @"ろんぐ わっしょい！";

    NSIndexPath *indexPath = [self.wasshoiUserTableView indexPathForCell:cell];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.counter = 0;
        
        SEL selector = @selector(incrementCounter:frame:increase:);
        NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
        if (signature){
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setSelector:selector];
            [invocation setTarget:self];
            [invocation setArgument:&cell atIndex:2];
            [invocation setArgument:&backGaugeViewFrame atIndex:3];
            [invocation setArgument:&increase atIndex:4];
            [invocation invoke];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01f invocation:invocation repeats: YES];
        }
    }
    
    if ( gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.timer invalidate];
        int counter = (int)self.counter;
        if(counter*increase < backGaugeViewFrame.size.width){
            nameLabel.text = @"キャンセル";
            double delayInSeconds =  0.5f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                nameLabel.text = [self.dataFriendUserLists[(indexPath.row)/2] objectForKey:@"user_name"];
                backGaugeView.frame = CGRectMake(backGaugeViewFrame.origin.x, backGaugeViewFrame.origin.y, 0, backGaugeViewFrame.size.height);
            });
        }
        
        
    }


}


// click event on right utility button
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index;
{
    NSIndexPath *cellIndexPath = [self.wasshoiUserTableView indexPathForCell:cell];
    PFUser *friendUser = self.dataFriendUserLists[cellIndexPath.row/2];
    PFUser *user = [PFUser currentUser];

    PFQuery *friendQuery = [PFQuery queryWithClassName:@"Friend"];
    [friendQuery whereKey:@"userObjectId" equalTo:user.objectId];
    [friendQuery whereKey:@"friendUserObjectId" equalTo:friendUser.objectId];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [objects[0] deleteInBackground];
    }];

    
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
                [self showAlert:@"ブロックの登録に失敗しました。再度起動し直して実行してください"];
                
                
            }else{
                
                [cell hideUtilityButtonsAnimated:YES];
                UILabel *userNameLabel = (UILabel *)[cell viewWithTag:1];
                UIView *backgroudView = (UILabel *)[cell viewWithTag:2];
                userNameLabel.text = @"ブロック！";
                backgroudView.backgroundColor = [UIColor colorWithRed:0.235 green:0.702 blue:0.443 alpha:1.0];
                
                double washoiDelayInSeconds =  2.0;
                dispatch_time_t washoiPopTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(washoiDelayInSeconds * NSEC_PER_SEC));
                dispatch_after(washoiPopTime, dispatch_get_main_queue(), ^(void){
                    [self.dataFriendUserLists removeObjectAtIndex:(cellIndexPath.row)/2];
                    
                    NSIndexPath *newPath = [NSIndexPath indexPathForRow:cellIndexPath.row+1 inSection:cellIndexPath.section];
                    [_wasshoiUserTableView deleteRowsAtIndexPaths:@[cellIndexPath, newPath] withRowAnimation:UITableViewRowAnimationFade];
                    
                });
            }
        }];
        // block
        
    }else if (index == 1){

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
            UILabel *userNameLabel = (UILabel *)[cell viewWithTag:1];
            userNameLabel.text = @"";
        }else{
            UILabel *userNameLabel = (UILabel *)[cell viewWithTag:1];
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
            UILabel *userNameLabel = (UILabel *)[cell viewWithTag:1];
            userNameLabel.text = userName;
            
            //long press
            UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                                  initWithTarget:self action:@selector(handleLongPress:)];
            lpgr.minimumPressDuration = 0.1f;
            lpgr.delegate = self;
            [cell addGestureRecognizer:lpgr];
            
        }else{
            UILabel *userNameLabel = (UILabel *)[cell viewWithTag:1];
            UIView *backView = [cell viewWithTag:2];
            UIView *backguageView = [cell viewWithTag:4];
            backguageView.frame = backView.frame;
            userNameLabel.text = nil;
            backView.backgroundColor = [UIColor clearColor];
            backguageView.backgroundColor = [UIColor clearColor];

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
                                                title:@"ブロック"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"削除"];
    
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
        
        //user&friend
        PFUser * friendUser = self.dataFriendUserLists[(indexPath.row)/2];
        PFUser * user = [PFUser currentUser];
        
        UILabel *userNameLabel = (UILabel *)[cell viewWithTag:1];
        NSString *userName = userNameLabel.text;
        
        CGRect cellBounds = cell.bounds;
        [indicator setCenter:CGPointMake((cellBounds.size.width)/2, (cellBounds.size.height)/2)];
        [cell addSubview:indicator];
        [indicator startAnimating];
        userNameLabel.text = @"";
        
        //ブロックの確認
        PFQuery *blockUserQuesry = [PFQuery queryWithClassName:@"BlockUser"];
        [blockUserQuesry whereKey:@"friendUserObjectId" equalTo:user.objectId];
        [blockUserQuesry whereKey:@"userObjectId" equalTo:friendUser.objectId];
        [blockUserQuesry findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if(!error){
                if([objects count] > 0){
                    [indicator removeFromSuperview];
                    userNameLabel.text = userName;
                    [self showAlert:@"ブロック登録されているのでわっしょいできません"];
                }else{
                    
                    
                    // 遅延処理
                    double delayInSeconds =  1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [indicator removeFromSuperview];
                        userNameLabel.text = @"わっしょい！";
                    });
                    
                    // 遅延処理2
                    double washoiDelayInSeconds =  2.0;
                    dispatch_time_t washoiPopTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(washoiDelayInSeconds * NSEC_PER_SEC));
                    dispatch_after(washoiPopTime, dispatch_get_main_queue(), ^(void){
                        
                        NSString *notificationMsg = [[user objectForKey:@"user_name"] stringByAppendingString:@" わっしょい！"];
                        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                              notificationMsg, @"alert",
                                              @"kamiosakoWasshoi.m4a", @"sound",
                                              nil];
                        
                        NSLog(@"aaaaaaaaa: %@", friendUser.objectId);
                        
                        PFQuery *userQuery = [PFUser query];
                        [userQuery getObjectWithId: friendUser.objectId];
                        
                        // Find devices associated with these users
                        PFQuery *pushQuery = [PFInstallation query];
                        [pushQuery whereKey:@"user" matchesQuery:userQuery];
                        
                        // Send push notification to query
                        PFPush *push = [[PFPush alloc] init];
                        [push setQuery:pushQuery]; // Set our Installation query
                        [push setMessage:@"wasshoi"];
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
                }
            }
        }];
        
        
        // 動きの部分
        NSIndexPath *topRow = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *topNextRow = [NSIndexPath indexPathForRow:1 inSection:0];
        
        NSIndexPath *clickNextPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        
        [self.dataFriendUserLists removeObjectAtIndex:(indexPath.row)/2];
        [self.dataFriendUserLists insertObject:friendUser atIndex:topRow.row];
        
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

- (void)showAlert:(NSString*)text
{

    AlertView *alertView = [AlertView new];
    [alertView setTitle:@"Error"];
    [alertView setOtherButtonTitle:@"OK"];
    [alertView setText:text];
    [alertView show];
}

@end
