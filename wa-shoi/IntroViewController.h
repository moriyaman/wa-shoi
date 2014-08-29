//
//  IntroViewController.h
//  wa-shoi
//
//  Created by Yuri Hirane on 2014/08/27.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAIntroView.h"

@interface IntroViewController : UIViewController <EAIntroDelegate>

@property IBOutlet UIView * sessionView;
- (IBAction)facebookButtonTapped:(id)sender;

@end
