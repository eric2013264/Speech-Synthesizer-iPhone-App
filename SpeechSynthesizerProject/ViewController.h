//
//  ViewController.h
//  SpeechSynthesizerProject
//
//  Created by Eric Chen on 3/20/16.
//  Copyright © 2016 WSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

// UI elements outlets
@property (weak, nonatomic) IBOutlet UITextField *textInput;
@property (weak, nonatomic) IBOutlet UISegmentedControl *speedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pitchControl;
@property (weak, nonatomic) IBOutlet UIPickerView *languagePicker;

// Table
@property NSMutableArray* tableEntries;

// Overlay
- (IBAction)overlayButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *overlayForMainView;
@property (weak, nonatomic) IBOutlet UIButton *overlayButton;
@property NSString* isFirstBoot;

// Emergency button action
- (IBAction)emergencyButtonPressed:(UIButton *)sender;

// Strings
@property NSString* emergencyContactNameString;
@property NSString* emergencyContactNumberString;
@property NSString* medicalHealthInfoFieldString;
@property NSString* userNameString;
@property (strong, nonatomic) NSString *selectedLanguage;
@property NSString* dateOfBirthString;

@property NSInteger* speed;
@property NSInteger* pitch;

@end

