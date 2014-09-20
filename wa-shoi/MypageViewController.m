//
//  MypageViewController.m
//  wa-shoi
//
//  Created by Yuki Moriyama on 2014/09/14.
//  Copyright (c) 2014年 yuki.moriyama. All rights reserved.
//

#import "MypageViewController.h"
#import <Parse/Parse.h>
#import "LINEActivity.h"

@interface MypageViewController ()

@end

@implementation MypageViewController

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
    
    //自分で聞く用の「わっしょい」
    NSString *path = [[NSBundle mainBundle] pathForResource:@"kamiosakoWasshoi" ofType:@"m4a"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.kamiosakoWasshoi = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    
    
    // わっしょいの受信数を取得
    PFQuery *wasshoiQuery = [PFQuery queryWithClassName:@"Wasshoi"];
    [wasshoiQuery whereKey:@"friendUserObjectId" equalTo:[PFUser currentUser].objectId];
    [wasshoiQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            NSString *receiverStr = @"もらった数：";
            NSString *receiveCount = [NSString stringWithFormat:@"%lu", (unsigned long)[objects count]];
            NSString *recieveCountLabelStr = [receiverStr stringByAppendingString:receiveCount];
            _recieveCountLabel.text = recieveCountLabelStr;
        } else {
            
        }
    }];
    

    // わっしょいの送信数を取得
    PFQuery *wasshoiSendQuery = [PFQuery queryWithClassName:@"Wasshoi"];
    [wasshoiSendQuery whereKey:@"userObjectId" equalTo:[PFUser currentUser].objectId];
    [wasshoiSendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            NSString *senderStr = @"送った数：";
            NSString *sendCount = [NSString stringWithFormat:@"%lu", (unsigned long)[objects count]];
            NSString *sendCountLabelStr = [senderStr stringByAppendingString:sendCount];
            _sendCountLabel.text = sendCountLabelStr;
        } else {
          
        }
    }];
}


- (IBAction)say_Wasshoi: (id)sender {
    [self.kamiosakoWasshoi play];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareLink {
    
    NSString *text  = @"わっしょいめっちゃ面白いよ！";
    NSURL *url = [NSURL URLWithString:@"http://wasshoi.com"];
    NSArray *activityItems = @[text, url];
    LINEActivity *lineActivity = [[LINEActivity alloc] init];
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                               applicationActivities:@[lineActivity]];
    [self presentViewController:activityView animated:YES completion:nil];
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
