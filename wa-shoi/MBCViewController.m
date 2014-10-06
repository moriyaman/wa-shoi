//
//  MBCViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/08/11.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "MBCViewController.h"
#import "WasshoiViewController.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"

@interface MBCViewController ()

@end

@implementation MBCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // _backImageView.image = [UIImage imageNamed:@"start2.jpg"];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hand_drum" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.hand_drum = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    
    
}


- (void)viewDidAppear:(BOOL)animated
{
    if([PFUser currentUser].sessionToken != nil && [[PFUser currentUser].sessionToken length] > 0){
        [self afterLogined];
    }
    
}

- (IBAction)play_drum: (id)sender {
    [self.hand_drum play];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)afterLogined
{
    [SVProgressHUD setFont: [UIFont fontWithName:@"ヒラギノ明朝 ProN W3" size:20]];
    [SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"ログイン中"];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation[@"user"] = [PFUser currentUser];
    [currentInstallation saveInBackground];
    
    // 遅延処理
    double delayInSeconds =  1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [SVProgressHUD dismiss];
        WasshoiViewController *wasshoiViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"wasshoiView"];
        [self presentViewController:wasshoiViewcontroller animated:YES completion:nil];
    });

    
}

@end
