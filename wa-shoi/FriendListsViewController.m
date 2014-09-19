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
        [self showAlert:@"アドレス帳へのアクセスを許可する事で、友達を捜しやすくなります"];
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    // NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];

    // self.searchResult = [NSMutableArray arrayWithArray: [self.tableData filteredArrayUsingPredicate:resultPredicate]];
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
            NSLog(@"テスト: %@", objects);
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
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSString *email;
        if (ABMultiValueGetCount(emails) > 0) {
            email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emails, 0);
            [_mailLists addObject:email];
        }
        // NSString *mail = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonEmailProperty));

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
    UILabel *userNameLabel = [cell viewWithTag:1];
    userNameLabel.text = userName;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    PFUser * friendUser = self.dataUserLists[indexPath.row];
    PFUser * user = [PFUser currentUser];

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
        } else {
            NSLog(@"成功");
        }
    }];
}

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

- (IBAction)shareLink {

    NSString *text  = @"わっしょいめっちゃ面白いよ！";
    NSURL *url = [NSURL URLWithString:@"http://wasshoi.com"];
    NSArray *activityItems = @[text, url];
    LINEActivity *lineActivity = [[LINEActivity alloc] init];

    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                               applicationActivities:@[lineActivity]];
    [self presentViewController:activityView animated:YES completion:nil];
}


@end
