//
//  FriendListsViewController.h
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/02.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <YLImageView.h>

@interface FriendListsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>

@property IBOutlet UITableView * userFriendsTableView;
@property (nonatomic, strong) NSMutableArray *dataUserLists;
@property (nonatomic, strong) NSMutableArray *mailLists;
@property (nonatomic, strong) NSMutableArray *searchResult;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (IBAction)shareLink;

@end
