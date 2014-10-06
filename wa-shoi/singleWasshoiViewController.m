//
//  singleWasshoiViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/10/02.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "singleWasshoiViewController.h"

@interface singleWasshoiViewController ()

@end

@implementation singleWasshoiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    //自分で聞く用の「わっしょい」
    NSString *path = [[NSBundle mainBundle] pathForResource:@"kamiosakoWasshoiShort" ofType:@"m4a"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.kamiosakoWasshoi = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)sayWasshoi {
    [self.kamiosakoWasshoi play];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
