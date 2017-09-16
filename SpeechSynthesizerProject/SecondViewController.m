//
//  SecondViewController.m
//  SpeechSynthesizerProject
//
//  Created by Eric Chen on 4/12/16.
//  Copyright © 2016 WSU. All rights reserved.
//

#import "SecondViewController.h"
#import "SixthViewController.h"
#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface SecondViewController ()

@property (strong, nonatomic) NSArray *languageCodes;

typedef NS_ENUM(NSInteger, SpeedControlIndex)
{
    SpeedControlFiftyPercentSpeed = 0,
    SpeedControlSeventyFivePercentSpeed = 1,
    SpeedControlNormalSpeed = 2,
    SpeedControlOneHundredTwentyPercentSpeed = 3
};

typedef NS_ENUM(NSInteger, PitchControlIndex)
{
    PitchControlDeepPitch = 0,
    PitchControlNormalPitch = 1,
    PitchControlHighPitch = 2
};

@property (assign, nonatomic) SpeedControlIndex selectedSpeed;
@property (assign, nonatomic) PitchControlIndex selectedPitch;

@end

@implementation SecondViewController

- (void)viewWillAppear:(BOOL)animated {
    
    // Don't know why but when we come back to view controller two, we align personal_Info_Label to (0,0), this pushes it down a tiny bit.
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0]; // User doesn't even notice
    self.scrollView.frame = CGRectMake(0,74,414,763);
    [self.scrollView scrollRectToVisible:self.personal_Info_Label.frame animated:YES];
    [UIView commitAnimations];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _emergencyContactNameField.delegate = self;
    _emergencyContactPhoneField.delegate = self;
    _medicalHealthInfoField.delegate = self;
    _userNameField.delegate = self;
    
    // Restore saved values
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *restoredNameString = [defaults objectForKey:@"nameKey"];
    NSString *restoredInfoString = [defaults objectForKey:@"infoKey"];
    NSString *restoredPhoneString = [defaults objectForKey:@"phoneKey"];
    NSString *restoredUserNameString = [defaults objectForKey:@"userNameKey"];
    NSString *restoredDateOfBirthString = [defaults objectForKey:@"dateOfBirthKey"];
    
    if (restoredDateOfBirthString == nil) {
        restoredDateOfBirthString = @"XX/XX/XXXX";
    }
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPreviousView:)];
    swipeRight.numberOfTouchesRequired = 1;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    ///
    NSString *currentLanguageCode = [AVSpeechSynthesisVoice currentLanguageCode];
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSDictionary *SpeechDefaults = @{ @"PrefKeySelectedPitch":[NSNumber numberWithInteger:PitchControlNormalPitch],
                                @"PrefKeySelectedSpeed":[NSNumber numberWithInteger:SpeedControlNormalSpeed],
                                @"PrefKeySelectedLanguage":currentLanguageCode
                                };
    [preferences registerDefaults:SpeechDefaults];
    
    self.selectedPitch = [preferences integerForKey:@"PrefKeySelectedPitch"];
    self.selectedSpeed = [preferences integerForKey:@"PrefKeySelectedSpeed"];
    self.speedControl.selectedSegmentIndex = self.selectedSpeed;
    self.pitchControl.selectedSegmentIndex = self.selectedPitch;
    self.selectedLanguage = [preferences stringForKey:@"PrefKeySelectedLanguage"];
    
    ///
    //NSMutableArray *restoredPhraseArray = [defaults objectForKey:@"phraseArrayKey"];
    
    _emergencyContactNameField.text = restoredNameString;
    _medicalHealthInfoField.text = restoredInfoString;
    _emergencyContactPhoneField.text = restoredPhoneString;
    _userNameField.text = restoredUserNameString;
    [_dateOfBirth setTitle:restoredDateOfBirthString forState:(UIControlStateNormal)];
    [_language setTitle:self.selectedLanguage forState:(UIControlStateNormal)];
    
    if (![restoredNameString isEqualToString:@""]) {
        _emergencyContactNameString = restoredNameString;
    }
    if (![restoredInfoString isEqualToString:@""]) {
        _medicalHealthInfoFieldString = restoredInfoString;
    }
    if (![restoredPhoneString isEqualToString:@""]) {
        _emergencyContactNumberString = restoredPhoneString;
    }
    if (![restoredUserNameString isEqualToString:@""]) {
        _userNameString = restoredUserNameString;
    }
    if (![restoredDateOfBirthString isEqualToString:@""]) {
        _dateOfBirthString = restoredDateOfBirthString;
    }
}

- (void)gotoPreviousView:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)emergencyNameDidEndEditing:(UITextField *)sender {
    NSLog(@"Emergency contact name field edited");
    _emergencyContactNameString = _emergencyContactNameField.text;
    
    // Save it
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_emergencyContactNameString forKey:@"nameKey"];
    [defaults synchronize];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"Start edit");
    
    // Focus on textfield
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.2];
    self.scrollView.frame = CGRectMake(0,0,400,380);
    [self.scrollView scrollRectToVisible:self.medicalHealthInfoField.frame animated:YES];
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"Saving user medical information textview contents");
    _medicalHealthInfoFieldString = _medicalHealthInfoField.text;
    [self.view endEditing:YES];
    
    // Move the focus back
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: 0.2]; // 20 status bar + 44 nav bar + 10 constraints = y axis 74 offset
    self.scrollView.frame = CGRectMake(0,74,414,675); // once pressed, if we set it to width height 414 763 then we lose 74 pixels. compensate by subtracting 74 from height
    [self.scrollView scrollRectToVisible:self.personal_Info_Label.frame animated:YES];
    [UIView commitAnimations];
    
    
    // Save it
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_medicalHealthInfoFieldString forKey:@"infoKey"];
    [defaults synchronize];
}

- (IBAction)emergencyNumberDidEndEditing:(UITextField *)sender {
    NSLog(@"Emergency contact phone field edited");
    _emergencyContactNumberString = _emergencyContactPhoneField.text;
    
    // Save it
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_emergencyContactNumberString forKey:@"phoneKey"];
    [defaults synchronize];
}

- (IBAction)userNameFieldDidEndEditing:(UITextField *)sender {
    NSLog(@"User name field edited");
    _userNameString = _userNameField.text;
    
    // Save it
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_userNameString forKey:@"userNameKey"];
    [defaults synchronize];
}

- (IBAction)dateOfBirthPressed:(UIButton *)sender {
    _userNameString = _userNameField.text;
    
    // Save it
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_userNameString forKey:@"userNameKey"];
    [defaults synchronize];
}

- (IBAction)languagePressed:(UIButton *)sender {
}

- (IBAction)done_button:(UIButton *)sender {
    [self textViewDidEndEditing:self.medicalHealthInfoField]; // Play hard ball and call manually
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];    // Remove keyboard
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsSecondViewController:(UIViewController *)subsequentVC {
    SixthViewController *controller = (SixthViewController *)[unwindSegue sourceViewController];
    if ([[unwindSegue identifier] isEqualToString:@"p6datep2"]) {
        NSLog(@"Unwind from DATE INPUT PAGE (DONE) --> SETTINGS PAGE");
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
        [dateFormatter setDateFormat:@"MM-dd-yyyy"];
        NSString *strDate = [dateFormatter stringFromDate:controller.myDatePicker.date];

        [_dateOfBirth setTitle:strDate forState:(UIControlStateNormal)];
        _dateOfBirthString = strDate;
        // Save it
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_dateOfBirthString forKey:@"dateOfBirthKey"];
        [defaults synchronize];
    }
    if ([[unwindSegue identifier] isEqualToString:@"p6languagep2"]) {
        NSLog(@"Unwind from LANGUAGE INPUT PAGE (DONE) --> SETTINGS PAGE");
        _selectedLanguage = controller.selectedLanguage;
        [_language setTitle:self.selectedLanguage forState:(UIControlStateNormal)];
        NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
        [preferences setObject:_selectedLanguage forKey:@"PrefKeySelectedLanguage"];
        [preferences synchronize];
    }
    if ([[unwindSegue identifier] isEqualToString:@"p5p2"]) {
        NSLog(@"Unwind from ABOUT PAGE --> SETTINGS PAGE");
    }
}

- (IBAction)unwindForCancel:(UIStoryboardSegue *)unwindSegue towardsSecondViewController:(UIViewController *)subsequentVC {
    // Nothing to do
    NSLog(@"Unwind from DATE INPUT PAGE (CANCEL) --> SETTINGS VIEW PAGE");
}

- (IBAction)speedSelected:(UISegmentedControl *)sender
{
    self.selectedSpeed = sender.selectedSegmentIndex;
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setInteger:self.selectedSpeed forKey:@"PrefKeySelectedSpeed"];    // Save to preferences
    [preferences synchronize];
}

- (IBAction)pitchSelected:(UISegmentedControl *)sender
{
    self.selectedPitch = sender.selectedSegmentIndex;
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setInteger:self.selectedPitch forKey:@"PrefKeySelectedPitch"];
    [preferences synchronize];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"Segue from SETTINGS PAGE --> ABOUT PAGE");
    
    //[self textViewDidEndEditing:self.medicalHealthInfoField]; // Play hard ball and call manually
    
    _emergencyContactNameField.text = _emergencyContactNameString;
    
    _emergencyContactPhoneField.text = _emergencyContactNumberString;
    _medicalHealthInfoField.text = _medicalHealthInfoFieldString;
    _userNameField.text = _userNameString;
    [_dateOfBirth setTitle:_dateOfBirthString forState:(UIControlStateNormal)];
    
}

@end
