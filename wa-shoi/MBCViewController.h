//
//  MBCViewController.h
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/08/11.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MBCViewController : UIViewController

@property IBOutlet UIImageView * backImageView;

@property AVAudioPlayer *hand_drum;
- (IBAction)play_drum;

@end
