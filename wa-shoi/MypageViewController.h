//
//  MypageViewController.h
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/14.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MypageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *sendCountLabel;
@property IBOutlet UITableView * myPageTableView;
@property (nonatomic, assign) NSInteger wasshoiSendCnt;

@property AVAudioPlayer *kamiosakoWasshoi;

- (void)say_Wasshoi;
- (void)shareLink;
- (void)logout;


@end
