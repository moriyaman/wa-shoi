//
//  WasshoiViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/08/25.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "WasshoiViewController.h"

@interface WasshoiViewController ()

@end

@implementation WasshoiViewController

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
    
    //long press
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;
    lpgr.delegate = self;
    [_wasshoiUserTableView addGestureRecognizer:lpgr];
    
    // Do any additional setup after loading the view.
    _wasshoiUserTableView.delegate = self;
    _wasshoiUserTableView.dataSource = self;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
       CGPoint p = [gestureRecognizer locationInView:self.wasshoiUserTableView];
       NSIndexPath *indexPath = [self.wasshoiUserTableView indexPathForRowAtPoint:p];
       if (indexPath == nil) {
          NSLog(@"long press on table view but not on a row");
       } else {
          UITableViewCell *cell = [self.wasshoiUserTableView cellForRowAtIndexPath:indexPath];
          if (cell.isHighlighted) {
            SystemSoundID hirai_long_wasshoi_scoud;
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Hirai_long_wasshoi" ofType:@"mp3"];
            NSURL *url = [NSURL fileURLWithPath:path];
            AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &hirai_long_wasshoi_scoud);
            AudioServicesPlaySystemSound(hirai_long_wasshoi_scoud);
            NSLog(@"long press on table view at section %d row %d", indexPath.section, indexPath.row);
          }
       }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1; //とりあえずセクションは1個
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_wasshoiUserTableView dequeueReusableCellWithIdentifier:@"UserCell"];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SystemSoundID hirai_wasshoi_scoud;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Hirai_wasshoi" ofType:@"m4a"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &hirai_wasshoi_scoud);
    AudioServicesPlaySystemSound(hirai_wasshoi_scoud);
    return;
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
