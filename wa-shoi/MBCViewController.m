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
    _backImageView.image = [UIImage imageNamed:@"start2.jpg"];
    
    // Add new Font File
    self.Kaishi.titleLabel.font = [UIFont fontWithName:@"AoyagiKouzanTOTF.otf" size:53];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
