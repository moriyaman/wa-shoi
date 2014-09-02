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
    
    NSLog(@"現在のユーザ: %@", [PFUser currentUser]);
    
    PFUser * toUser = [PFUser currentUser];
    NSLog(@"現在のユーザ: %@", toUser.objectId);
    
    // Do any additional setup after loading the view.
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
  
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if(granted){
                // ユーザーがアドレス帳へのアクセスを許可した場合
                [self getContact];
                
                
            }else{
                // ユーザーがアドレス帳へのアクセスを許可しなかった場合
                
                // アラートを表示するなど
            }
        });
    }else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // ユーザーがアドレス帳へのアクセスを以前に許可した場合
        [self getContact];
     
    }else{
        // ユーザーがアドレス帳へのアクセスを以前に拒否した場合
        
        // アラートを表示するなど
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
