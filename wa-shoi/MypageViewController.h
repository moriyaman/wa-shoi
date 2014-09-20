//
//  MypageViewController.h
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/14.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MypageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *sendCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *recieveCountLabel;
@property AVAudioPlayer *kamiosakoWasshoi;
- (IBAction)say_Wasshoi;
- (IBAction)shareLink;

@end
