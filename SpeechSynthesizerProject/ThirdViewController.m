//
//  ThirdViewController.m
//  SpeechSynthesizerProject
//
//  Created by Eric Chen on 3/24/16.
//  Copyright © 2016 WSU. All rights reserved.
//

#import "ViewController.h"
#import "ThirdViewController.h"
#import "FourthViewController.h"

#import <AVFoundation/AVFoundation.h>



@interface ThirdViewController ()<AVSpeechSynthesizerDelegate>

//@property NSMutableArray* tableEntries;
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

@end

@implementation ThirdViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_tableEntries == nil) {
        _tableEntries = [[NSMutableArray alloc] init];
        [_tableEntries addObject:@"Hi I am in need of assistance"];
        [_tableEntries addObject:@"I use this app to help me talk"];
        [_tableEntries addObject:@"Saved phrases are super convenient"];
        [_tableEntries addObject:@"Add and save your own phrases!"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_tableEntries forKey:@"phraseArrayKey"];
        [defaults synchronize];
    }
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPreviousView:)];
    swipeRight.numberOfTouchesRequired = 1;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.myTable addGestureRecognizer:swipeRight];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *restoredIsFirstBoot = [defaults objectForKey:@"isFirstBootForTableViewKey"];
    _isFirstBoot = restoredIsFirstBoot;
    if (![restoredIsFirstBoot isEqualToString:@""]) {
        _isFirstBoot = restoredIsFirstBoot;
    }
    if ([restoredIsFirstBoot isEqualToString:@"no"])
    {
        _overlayForTableView.hidden = YES;
        _overlayButton.hidden = YES;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// As the breakpoints indicate. The MUTABLE aspect of mutableArrays is lost on me.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //remove the deleted object from your data source.
        //If your data source is an NSMutableArray, do this
        // Ours isn't but screw Apple's warning, let's make it one.

        _tableEntries = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"phraseArrayKey"]];
        [_tableEntries removeObjectAtIndex:indexPath.row];
        [_myTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_tableEntries forKey:@"phraseArrayKey"];
        [defaults synchronize];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Table cells don't have action so this is from http://www.appcoda.com/how-to-handle-row-selection-in-uitableview/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:@"Row Selected" message:@"You've selected a row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    */
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Selected phrase: %@",cell.textLabel.text);   // Cell label for debugging

    
    if (cell.textLabel.text && !_synthesizer.isSpeaking)
    {
        // Restore language preference
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString * _selectedLanguage = [defaults objectForKey:@"PrefKeySelectedLanguage"];
    
        AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:_selectedLanguage];
        
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:cell.textLabel.text];
        utterance.voice = voice;
        
        //float adjustedRate = AVSpeechUtteranceDefaultSpeechRate;
        //float adjustedPitch = 1.0;
        
        
        
        // match up these values 0 based indexing != the system rate scale
        // for example [0] which represents 0.25 speed are not the same thing
        // 0 into rate would result in a SUPER SLOW rate.
        
        // Rate
        NSNumber * _rateNumber = [defaults objectForKey:@"PrefKeySelectedSpeed"];
        NSInteger rateNumberInt = [_rateNumber intValue];
        
        float adjustedRate = AVSpeechUtteranceDefaultSpeechRate;
        
        if (rateNumberInt == 0) { // 0 based indexing so 0 is up first
            adjustedRate = AVSpeechUtteranceDefaultSpeechRate * 0.50;   // 50%
        }
        else if (rateNumberInt == 1){
            adjustedRate = AVSpeechUtteranceDefaultSpeechRate * 0.75;   // 75%
        }
        else if (rateNumberInt == 2){
            adjustedRate = AVSpeechUtteranceDefaultSpeechRate * 1.00;   // You get the point
        }
        else if (rateNumberInt == 3){
            adjustedRate = AVSpeechUtteranceDefaultSpeechRate * 1.25;
        }
        
        if (adjustedRate > AVSpeechUtteranceMaximumSpeechRate)  // Final checks CASE 1: over max, set to max
        {
            adjustedRate = AVSpeechUtteranceMaximumSpeechRate;
        }
        else if (adjustedRate < AVSpeechUtteranceMinimumSpeechRate) // CASE 2: under min, set to min
        {
            adjustedRate = AVSpeechUtteranceMinimumSpeechRate;
        }
        else {
            utterance.rate = adjustedRate;  // Within min and max, which means the rate is fine
        }
        
        // Pitch
        NSNumber * _pitchNumber = [defaults objectForKey:@"PrefKeySelectedPitch"];
        NSInteger pitchNumberInt = [_pitchNumber intValue];
        
        float adjustedPitch = 1.0;  // declared as default
        
        if (pitchNumberInt == 0) {
            adjustedPitch = 0.75;
        }
        if (pitchNumberInt == 1) {
            adjustedPitch = 1.0;
        }
        if (pitchNumberInt == 2) {
            adjustedPitch = 1.5;
        }
        
        if ((adjustedPitch >= 0.5) && (adjustedPitch <= 2.0)) // Final checks: just check the bounds or else remain 1
        {
            utterance.pitchMultiplier = adjustedPitch;
        }
    
        utterance.pitchMultiplier = adjustedPitch;
        
        
        [self.synthesizer speakUtterance:utterance];
        NSLog(@"Saying: %@",cell.textLabel.text);
    }
    //[messageAlert show];  // We can display an alert along with each phrase spoken
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Segue from TABLE VIEW PAGE --> ENTRY INPUT PAGE");
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // Title set using GUI not programmatically
    
    // Save table entries
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_tableEntries forKey:@"phraseArrayKey"];
    [defaults synchronize];
}

- (IBAction)unwindForDone:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVC {
    NSLog(@"Unwind from ENTRY INPUT PAGE (DONE) --> TABLE VIEW PAGE");
    FourthViewController* controller = (FourthViewController *) [unwindSegue sourceViewController];
    NSString* newEntry = controller.myTextField.text;
    if (newEntry != nil) {
        if (![newEntry isEqualToString:@""]) {
            //_tableEntries = [[NSMutableArray alloc] init];
            //[_tableEntries addObject:@"Entry 4"];
            _tableEntries = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"phraseArrayKey"]];

            [_tableEntries addObject:newEntry];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:_tableEntries forKey:@"phraseArrayKey"];
            [defaults synchronize];
            [_myTable reloadData];
        }
    }
}



- (IBAction)unwindForCancel:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVC {
    // Nothing to do
    NSLog(@"Unwind from ENTRY INPUT PAGE (CANCEL) --> TABLE VIEW PAGE");
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"myCell"];
    }
    cell.textLabel.text = [_tableEntries objectAtIndex: indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    return cell;
}

- (AVSpeechSynthesizer *)synthesizer
{
    if (!_synthesizer)
    {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
    }
    return _synthesizer;
}

- (void)gotoPreviousView:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)overlayButtonPressed:(UIButton *)sender {
    if (_overlayForTableView.hidden != YES) {
        _overlayForTableView.hidden = YES;
        _overlayButton.hidden = YES;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"no" forKey:@"isFirstBootForTableViewKey"];    // bye overlay
        [defaults synchronize];
    }
}
@end
