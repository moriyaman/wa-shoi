//
//  singleWasshoiViewController.h
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/10/02.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface singleWasshoiViewController : UIViewController

@property AVAudioPlayer *kamiosakoWasshoi;

- (IBAction)sayWasshoi;

@end
