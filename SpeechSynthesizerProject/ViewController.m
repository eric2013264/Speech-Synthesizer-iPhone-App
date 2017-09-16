//
//  ViewController.m
//  SpeechSynthesizerProject
//
//  Created by Eric Chen on 3/20/16.
//  Copyright © 2016 WSU. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, AVSpeechSynthesizerDelegate>

//@property NSMutableArray* tableEntries;

@property (strong, nonatomic) NSArray *languageCodes;
@property (strong, nonatomic) NSDictionary *languageDictionary;
@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

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

@property (strong, nonatomic) NSString *restoredTextToSpeak;

@end

@implementation ViewController

// BACK
-(IBAction)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVC {
    
    
    if ([[unwindSegue identifier] isEqualToString:@"p2p1"]) {
        NSLog(@"Unwind from SETTINGS PAGE --> MAIN PAGE");
        
        SecondViewController *controller = (SecondViewController *)[unwindSegue sourceViewController];
    
        _emergencyContactNameString = controller.emergencyContactNameString; // PASS NAME BACK
        _emergencyContactNumberString = controller.emergencyContactNumberString; // PASS # BACK
        _userNameString = controller.userNameString; // PASS USERNAME BACK
        _dateOfBirthString = controller.dateOfBirthString; // PASS DOB BACK
        
        _medicalHealthInfoFieldString = controller.medicalHealthInfoFieldString; // PASS TEXT VIEW STUFF BACK
        
        //NSString *currentLanguageCode = [AVSpeechSynthesisVoice currentLanguageCode];
        
        NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
        
        self.selectedPitch = [preferences integerForKey:@"PrefKeySelectedPitch"];
        self.selectedSpeed = [preferences integerForKey:@"PrefKeySelectedSpeed"];
        self.speedControl.selectedSegmentIndex = self.selectedSpeed;
        self.pitchControl.selectedSegmentIndex = self.selectedPitch;
        self.selectedLanguage = [preferences stringForKey:@"PrefKeySelectedLanguage"];
        
        
        if (_emergencyContactNumberString == nil) {return;}  // Check for nil
        if (_emergencyContactNameString == nil) {return;} // Check for nil
        if (_userNameString == nil) {return;}
        

        
        
    }
    if ([[unwindSegue identifier] isEqualToString:@"p3p1"]) {
        NSLog(@"Unwind from TABLE VIEW PAGE --> MAIN PAGE");
        ThirdViewController *controller = (ThirdViewController *)[unwindSegue sourceViewController];

        _tableEntries = controller.tableEntries;
    }

}

// TO
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"p1p2"]) { // FROM MAIN TO SETTINGS PAGE
        
        SecondViewController* controller = (SecondViewController *)[segue destinationViewController];
        
        controller.emergencyContactNameString = _emergencyContactNameString;
        controller.emergencyContactNumberString = _emergencyContactNumberString;
        controller.medicalHealthInfoFieldString = _medicalHealthInfoFieldString;
        controller.userNameString = _userNameString;
        controller.dateOfBirthString = _dateOfBirthString;
        
        NSLog(@"Segue from MAIN PAGE --> SETTINGS PAGE");
        
    }
    if ([[segue identifier] isEqualToString:@"p1p3"]) { // FROM MAIN TO COMMONLY USED PHRASES PAGE
        ThirdViewController* controller = (ThirdViewController *)[segue destinationViewController];
        NSLog(@"Segue from MAIN PAGE --> TABLE VIEW PAGE");
        
        controller.tableEntries = _tableEntries;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


// Language codes used to create custom voices. Array is sorted based
// on the display names in the language dictionary
- (NSArray *)languageCodes
{
    if (!_languageCodes)
    {
        _languageCodes = [self.languageDictionary keysSortedByValueUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return _languageCodes;
}

// Map between language codes and locale specific display name
- (NSDictionary *)languageDictionary
{
    if (!_languageDictionary)
    {
        NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
        NSArray *languages = [voices valueForKey:@"language"];
        
        NSLocale *currentLocale = [NSLocale autoupdatingCurrentLocale];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        for (NSString *code in languages)
        {
            dictionary[code] = [currentLocale displayNameForKey:NSLocaleIdentifier value:code];
        }
        _languageDictionary = dictionary;
    }
    return _languageDictionary;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self restoreUserPreferences];
    self.speedControl.selectedSegmentIndex = self.selectedSpeed;
    self.pitchControl.selectedSegmentIndex = self.selectedPitch;
    
    //self.languagePicker.textColor = [UIColor whiteColor];
    
    NSUInteger index = [self.languageCodes indexOfObject:_selectedLanguage];
    if (index != NSNotFound)
    {
        [self.languagePicker selectRow:index inComponent:0 animated:YES];
    }
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *restoredNameString = [defaults objectForKey:@"nameKey"];
    NSString *restoredInfoString = [defaults objectForKey:@"infoKey"];
    NSString *restoredPhoneString = [defaults objectForKey:@"phoneKey"];
    NSString *restoredUserNameString = [defaults objectForKey:@"userNameKey"];
    NSMutableArray *restoredPhraseArray = [defaults objectForKey:@"phraseArrayKey"];
    NSString *restoredDateOfBirthString = [defaults objectForKey:@"dateOfBirthKey"];
    NSString *restoredIsFirstBoot = [defaults objectForKey:@"isFirstBootKey"];
    
    _emergencyContactNameString = restoredNameString;
    _medicalHealthInfoFieldString = restoredInfoString;
    _emergencyContactNameString = restoredPhoneString;
    _dateOfBirthString = restoredDateOfBirthString;
    _userNameString = restoredUserNameString;
    _tableEntries = restoredPhraseArray;
    _isFirstBoot = restoredIsFirstBoot;
    
    
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
    
    if (![restoredUserNameString isEqualToString:@""]) {
        _userNameString = restoredUserNameString;
    }
    if (![restoredDateOfBirthString isEqualToString:@""]) {
        _dateOfBirthString = restoredDateOfBirthString;
    }
    // this check is done elsewhere for tableEntries
    
    if (![restoredIsFirstBoot isEqualToString:@""]) {
        _isFirstBoot = restoredIsFirstBoot;
    }
    if ([restoredIsFirstBoot isEqualToString:@"no"])
    {
        _overlayForMainView.hidden = YES;
        _overlayButton.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self restoreUserPreferences];
    NSUInteger index = [self.languageCodes indexOfObject:_selectedLanguage];
    if (index != NSNotFound)
    {
        [self.languagePicker selectRow:index inComponent:0 animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.restoredTextToSpeak)
    {
        self.textInput.text = self.restoredTextToSpeak;
        self.restoredTextToSpeak = nil;
    }
}


- (void)restoreUserPreferences
{
    NSString *currentLanguageCode = [AVSpeechSynthesisVoice currentLanguageCode];
    
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaults = @{ @"PrefKeySelectedPitch":[NSNumber numberWithInteger:PitchControlNormalPitch],
                                @"PrefKeySelectedSpeed":[NSNumber numberWithInteger:SpeedControlNormalSpeed],
                                @"PrefKeySelectedLanguage":currentLanguageCode
                                };
    [preferences registerDefaults:defaults];
    
    self.selectedPitch = [preferences integerForKey:@"PrefKeySelectedPitch"];
    self.selectedSpeed = [preferences integerForKey:@"PrefKeySelectedSpeed"];
    self.selectedLanguage = [preferences stringForKey:@"PrefKeySelectedLanguage"];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.textInput.text forKey:@"KeySpeechText"];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    self.restoredTextToSpeak = [coder decodeObjectForKey:@"KeySpeechText"];
    [super decodeRestorableStateWithCoder:coder];
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
    [preferences setInteger:self.selectedPitch forKey:@"PrefKeySelectedPitch"];     // Save to preferences
    [preferences synchronize];
}

- (IBAction)speak:(UIButton *)sender
{
    if (self.textInput.text && !self.synthesizer.isSpeaking)
    {
        AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.selectedLanguage];
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:self.textInput.text];
        
        utterance.voice = voice;
        
        float adjustedRate = AVSpeechUtteranceDefaultSpeechRate * [self rateModifier];
        
        if (adjustedRate > AVSpeechUtteranceMaximumSpeechRate)
        {
            adjustedRate = AVSpeechUtteranceMaximumSpeechRate;
        }
        
        if (adjustedRate < AVSpeechUtteranceMinimumSpeechRate)
        {
            adjustedRate = AVSpeechUtteranceMinimumSpeechRate;
        }
        
        utterance.rate = adjustedRate;
        
        float pitchMultiplier = [self pitchModifier];
        if ((pitchMultiplier >= 0.5) && (pitchMultiplier <= 2.0))
        {
            utterance.pitchMultiplier = pitchMultiplier;
        }
        
        [self.synthesizer speakUtterance:utterance];
    }
}

- (float)rateModifier
{
    float rate = 1.0;
    switch (self.selectedSpeed)
    {
        case SpeedControlFiftyPercentSpeed:
            rate = 0.50;
            break;
        case SpeedControlSeventyFivePercentSpeed:
            rate = 0.75;
            break;
        case SpeedControlNormalSpeed:
            rate = 1.0;
            break;
        case SpeedControlOneHundredTwentyPercentSpeed:
            rate = 1.25;
            break;
        default:
            rate = 1.0;
            break;
    }
    return rate;
}

- (float)pitchModifier
{
    float pitch = 1.0;
    switch (self.selectedPitch)
    {
        case PitchControlDeepPitch:
            pitch = 0.75;
            break;
        case PitchControlNormalPitch:
            pitch = 1.0;
            break;
        case PitchControlHighPitch:
            pitch = 1.5;
            break;
        default:
            pitch = 1.0;
            break;
    }
    return pitch;
}


- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.textInput.text];
    // Highlight the text we're reading
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:characterRange];
    self.textInput.attributedText = text;
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.textInput.attributedText];
    [text removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, [text length])];
    self.textInput.attributedText = text;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.languageCodes count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //                                                         x  y  width height
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]; // your frame, so picker gets "colored"

    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    label.textAlignment = NSTextAlignmentCenter;
    NSString *languageCode = self.languageCodes[row];
    NSString *languageName = self.languageDictionary[languageCode];

    label.text = [NSString stringWithFormat:@"%@",languageName];

    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedLanguage = [self.languageCodes objectAtIndex:row];
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:self.selectedLanguage forKey:@"PrefKeySelectedLanguage"];
    [preferences synchronize];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *languageCode = self.languageCodes[row];
    NSString *languageName = self.languageDictionary[languageCode];
    return languageName;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



- (IBAction)overlayButtonPressed:(UIButton *)sender {
    if (_overlayForMainView.hidden != YES) {
        _overlayForMainView.hidden = YES;
        _overlayButton.hidden = YES;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"no" forKey:@"isFirstBootKey"];    // bye overlay
        [defaults synchronize];
    }
}

- (IBAction)emergencyButtonPressed:(UIButton *)sender {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"EMERGENCY BUTTON PRESSED"
                                                                   message:@"WOULD YOU LIKE TO CALL YOUR EMERGENCY CONTACT/EMERGENCY PERSONNEL? (IF NO EMERGENCY CONTACT IS GIVEN, THIS WILL CALL EMERGENCY PERSONNEL)"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* affirmativeAction = [UIAlertAction actionWithTitle:@"YES"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [self processAlert1Actions:action];
                                                          }];
    
    UIAlertAction* negativeAction = [UIAlertAction actionWithTitle:@"NO"
                                                         style:(UIAlertActionStyleDefault)
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                       }];
    
    [alert addAction:affirmativeAction];
    [alert addAction:negativeAction];
    
    
    [self presentViewController:alert  animated:YES completion:nil];
    // Call Authorities

    // Call Emergency contact
    
    // Send Geocode to emergency contact?
    
}

- (void)processAlert1Actions:(UIAlertAction*)action {
    if ([[action title] isEqualToString:@"YES"]) {
        NSLog(@"EMERGENCY BUTTON ALERT:  YES button clicked");
        
        // CASE 1: Emergency phone field is initialized and empty
        if ((_emergencyContactNumberString != nil) && [_emergencyContactNumberString isEqualToString:@""])
        {
            NSString *phoneNumber = [@"tel://" stringByAppendingString:@"911"];  // No emergency contact, call 911
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            NSLog(@"Emergency phone field is initialized and empty");
        }
        // CASE 2: Emergency phone field is initialized and not empty
        else if ((_emergencyContactNumberString != nil) && ![_emergencyContactNumberString isEqualToString:@""])
        {
            NSString *phoneNumber = [@"tel://" stringByAppendingString:_emergencyContactNumberString];  // Call the emergency contact if it's given
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            NSLog(@"Emergency phone field is initialized and not empty");
        }
        // CASE 3: Emergency phone field is uninitialized so it's probably empty
        else {
            NSString *phoneNumber = [@"tel://" stringByAppendingString:@"911"];  // No emergency contact, call 911
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            NSLog(@"Emergency phone field is uninitialized");
        }
    }
    else if
        ([[action title] isEqualToString:@"CANCEL"]) {
            NSLog(@"EMERGENCY BUTTON ALERT: Cancel button clicked");
        }
}

// Explained in Read Me Mar 28. Function used to supress a weird conflicting constraints compiler error. Mostly in the output.
- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {
    for(UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if([window.class.description isEqual:@"UITextEffectsWindow"])
        {
            [window removeConstraints:window.constraints];
        }
    }
}


@end
