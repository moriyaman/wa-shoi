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
    //WasshoiViewController *wasshoiViewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"wasshoiView"];
    //[self presentViewController:wasshoiViewcontroller animated:YES completion:nil];
    
}

@end
