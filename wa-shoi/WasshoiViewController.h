//
//  WasshoiViewController.h
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/08/25.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <SWTableViewCell.h>
#import <YLImageView.h>

@interface WasshoiViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property IBOutlet UITableView * wasshoiUserTableView;
@property (nonatomic, strong) NSMutableArray *dataFriendUserLists;
@property (weak, nonatomic) IBOutlet YLImageView *lodingImage;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) NSInteger *counter;

@end
