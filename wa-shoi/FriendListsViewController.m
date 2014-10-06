//
//  FriendListsViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/02.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "FriendListsViewController.h"
#import <Parse/Parse.h>
#import "LINEActivity.h"
#import "AlertView.h"

@interface FriendListsViewController ()

@end

@implementation FriendListsViewController

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

    _userFriendsTableView.delegate = self;
    _userFriendsTableView.dataSource = self;
    _searchBar.delegate = self;

    // 以下 電話帳から
    // Do any additional setup after loading the view.
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if(granted){
                // ユーザーがアドレス帳へのアクセスを許可した場合
                [self getContact];
            }else{
                [self showAlert:@"アドレス帳へのアクセスを許可する事で、友達を捜しやすくなります"];
            }
        });
    }else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // ユーザーがアドレス帳へのアクセスを以前に許可した場合
        [self getContact];

    }else{
        // ユーザーがアドレス帳へのアクセスを以前に拒否した場合
        //[self showAlert:@"アドレス帳へのアクセスを許可する事で、友達を捜しやすくなります"];
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    // NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];

    //self.searchResult = [NSMutableArray arrayWithArray: [self.tableData filteredArrayUsingPredicate:resultPredicate]];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];

    PFQuery *friendQuery = [PFQuery queryWithClassName:@"Friend"];
    [friendQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" doesNotMatchKey:@"friendUserObjectId" inQuery:friendQuery];
    [userQuery whereKey:@"user_name" hasPrefix:searchBar.text];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            _dataUserLists = [NSMutableArray arrayWithArray:objects];
            [self.userFriendsTableView reloadData];

        } else {
            [self showAlert:@"通信エラーが発生しました"];
        }
    }];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if( [searchText length] != 0 )
    {
        // インクリメンタル検索
    }
}


- (void)getContact
{
    _mailLists = [NSMutableArray arrayWithArray:@[]];
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];

    for (int i = 0; i < nPeople; i++)
    {
        @try {
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            if(person != nil){
              ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
              NSString *email;
              if (ABMultiValueGetCount(emails) > 0) {
                  email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emails, 0);
                  [_mailLists addObject:email];
              }
            }
        }
        @catch (NSException *exception) {
        }
        @finally {

        }
    }

    PFQuery *friendQuery = [PFQuery queryWithClassName:@"Friend"];
    [friendQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" doesNotMatchKey:@"friendUserObjectId" inQuery:friendQuery];
    [userQuery whereKey:@"email" containedIn:_mailLists];

    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            _dataUserLists = [NSMutableArray arrayWithArray:objects];
            [self.userFriendsTableView reloadData];
        } else {
            [self showAlert:@"通信エラーが発生しました"];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataUserLists.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1; //とりあえずセクションは1個
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"FriendCell";
    UITableViewCell *cell = [_userFriendsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }

    NSString *userName = [self.dataUserLists[indexPath.row] objectForKey:@"user_name"];
    UILabel *userNameLabel = (UILabel *)[cell viewWithTag:1];
    userNameLabel.text = userName;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSIndexPath *selectedIndexPath = [tableView indexPathForSelectedRow];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    UITableViewCell *cell = [_userFriendsTableView cellForRowAtIndexPath:indexPath];
    
    UILabel *userNameLabel = (UILabel *)[cell viewWithTag:1];
    NSString *userName = userNameLabel.text;
    
    CGRect cellBounds = cell.bounds;
    [indicator setCenter:CGPointMake((cellBounds.size.width)/2, (cellBounds.size.height)/2)];
    [cell addSubview:indicator];
    [indicator startAnimating];
    userNameLabel.text = @"";
    
    double delayInSeconds =  1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        PFUser * friendUser = self.dataUserLists[indexPath.row];
        PFUser * user = [PFUser currentUser];
        
        //既に友達登録されていないか確認
        PFQuery *friendQuesry = [PFQuery queryWithClassName:@"Friend"];
        [friendQuesry whereKey:@"userObjectId" equalTo:user.objectId];
        [friendQuesry whereKey:@"friendUserObjectId" equalTo:friendUser.objectId];
        [friendQuesry findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if(!error){
                if([objects count] > 0){
                    [self showAlert:@"既に友達登録が完了しています。"];
                }else{
                    PFObject *friend = [PFObject objectWithClassName:@"Friend"];
                    PFRelation *userRelation = [friend relationForKey:@"user"];
                    [userRelation addObject:user];
                    
                    PFRelation *friendRelation = [friend relationForKey:@"friendUser"];
                    [friendRelation addObject:friendUser];
                    friend[@"userObjectId"] = user.objectId;
                    friend[@"friendUserObjectId"] = friendUser.objectId;
                    [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!succeeded) {
                            [self showAlert:@"友達の登録に失敗しました。再度起動し直して実行してください"];
                            [indicator removeFromSuperview];
                            userNameLabel.text = userName;
                        } else {
                            [indicator removeFromSuperview];
                            userNameLabel.text = @"追加完了";
                            
                            double washoiDelayInSeconds =  1.0;
                            dispatch_time_t washoiPopTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(washoiDelayInSeconds * NSEC_PER_SEC));
                            dispatch_after(washoiPopTime, dispatch_get_main_queue(), ^(void){
                                NSIndexPath *cellIndexPath = [self.userFriendsTableView indexPathForCell:cell];
                                [self.dataUserLists removeObjectAtIndex:cellIndexPath.row];
                                [_userFriendsTableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                                
                            });
                            [tableView deselectRowAtIndexPath:indexPath animated:YES];

                        }
                    }];
                }
            }
        }];
    });
    
}

- (void)showAlert:(NSString*)text
{
    
    AlertView *alertView = [AlertView new];
    [alertView setTitle:@"Error"];
    [alertView setOtherButtonTitle:@"OK"];
    [alertView setText:text];
    [alertView show];
}

- (IBAction)shareLink {

    NSString *text  = @"わっしょいを皆に送って盛り上げよう Appstoreでわっしょいで検索してみて！";
    NSArray *activityItems = @[text];
    LINEActivity *lineActivity = [[LINEActivity alloc] init];

    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                               applicationActivities:@[lineActivity]];
    [self presentViewController:activityView animated:YES completion:nil];
}


@end
