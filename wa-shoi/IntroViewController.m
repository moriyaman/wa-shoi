//
//  IntroViewController.m
//  wa-shoi
//
//  Created by Yuri Hirane on 2014/08/27.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "IntroViewController.h"
#import <Parse/Parse.h>
#import "FriendListsViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    EAIntroPage *page1 = [EAIntroPage pageWithCustomViewFromNibNamed:@"IntroPage1"];
    EAIntroPage *page2 = [EAIntroPage pageWithCustomViewFromNibNamed:@"IntroPage2"];
    EAIntroPage *page3 = [EAIntroPage pageWithCustomViewFromNibNamed:@"IntroPage3"];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
    
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
