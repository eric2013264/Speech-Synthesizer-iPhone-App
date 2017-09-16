//
//  FifthViewController.m
//  SpeechSynthesizerProject
//
//  Created by Eric Chen on 3/29/16.
//  Copyright © 2016 WSU. All rights reserved.
//

#import "FifthViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface FifthViewController ()
{
    AVAudioPlayer *_audioPlayer;
}
@end

@implementation FifthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPreviousView:)];
    swipeRight.numberOfTouchesRequired = 1;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UITapGestureRecognizer *easterEggTapRecognizer = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(easterEggTapRecognizer:)];
    easterEggTapRecognizer.numberOfTapsRequired = 5;
    [self.view addGestureRecognizer:easterEggTapRecognizer];
    
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"WSU_Cougar_Roar"
                                         ofType:@"mp3"]];
    
    _audioPlayer = [[AVAudioPlayer alloc]
                                  initWithContentsOfURL:url
                                  error:nil];
}

- (void)easterEggTapRecognizer:(UITapGestureRecognizer *)sender {
    //CGPoint tapPoint = [sender locationInView:self.view];  // Declare point
    
    self.Cougar_Image_View.hidden = NO;
    
    [_audioPlayer play];
    
    NSTimeInterval delayInSeconds = 2.74;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        self.Cougar_Image_View.hidden = YES;
    });
    
    NSLog(@"Easter Egg Found");
}
    

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gotoPreviousView:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
