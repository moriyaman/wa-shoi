//
//  MBCViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/08/11.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "MBCViewController.h"

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

- (IBAction)play_drum: (id)sender {
    [self.hand_drum play];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
