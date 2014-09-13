//
//  FriendListsViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/02.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "FriendListsViewController.h"
#import <Parse/Parse.h>

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
    
    PFUser * toUser = [PFUser currentUser];
    
    // 友達一覧を獲得
    PFQuery *friendQuery = [PFQuery queryWithClassName:@"Friend"];
    [friendQuery whereKey:@"user" equalTo:toUser];
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" doesNotMatchKey:@"friendUserObjectId" inQuery:friendQuery];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            NSLog(@"テスト: %@", objects);
            _dataUserLists = [NSMutableArray arrayWithArray:objects];
            [self.userFriendsTableView reloadData];
            
        } else {
            NSLog(@"メール:");
        }
    }];
    
    
    // 以下 電話帳から
    // Do any additional setup after loading the view.
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if(granted){
                // ユーザーがアドレス帳へのアクセスを許可した場合
                // [self getContact];
                
                
            }else{
                // ユーザーがアドレス帳へのアクセスを許可しなかった場合
                
                // アラートを表示するなど
            }
        });
    }else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // ユーザーがアドレス帳へのアクセスを以前に許可した場合
        // [self getContact];
        
    }else{
        // ユーザーがアドレス帳へのアクセスを以前に拒否した場合
        
        // アラートを表示するなど
    }
    
    
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    NSLog(@"メール: %@", searchText);
    NSLog(@"メール: %@", predicate);
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
            NSLog(@"メール:");
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
            NSLog(@"メール: %@", email);
        }
        // NSString *mail = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonEmailProperty));

    }
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
        // HUD消したり・・・
        if (!succeeded) {
            // エラー処理
            NSLog(@"失敗しました");
        } else {
            NSLog(@"成功");
        }
    }];
}

@end
