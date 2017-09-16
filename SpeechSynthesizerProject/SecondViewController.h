//
//  SecondViewController.h
//  SpeechSynthesizerProject
//
//  Created by Eric Chen on 4/12/16.
//  Copyright © 2016 WSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController

// Text Fields
// Emergency contact information
@property (weak, nonatomic) IBOutlet UITextField *emergencyContactNameField;
@property (weak, nonatomic) IBOutlet UITextField *emergencyContactPhoneField;
- (IBAction)emergencyNameDidEndEditing:(UITextField *)sender;
- (IBAction)emergencyNumberDidEndEditing:(UITextField *)sender;

// User information
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
- (IBAction)userNameFieldDidEndEditing:(UITextField *)sender;
@property (weak, nonatomic) IBOutlet UIButton *dateOfBirth;
@property NSString* dateOfBirthString;

// Speech
@property (weak, nonatomic) IBOutlet UISegmentedControl *speedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pitchControl;
@property (weak, nonatomic) IBOutlet UIButton *language;

@property NSString* languageString;

@property (weak, nonatomic) IBOutlet UILabel *personal_Info_Label;
- (IBAction)done_button:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

// Text View
@property (weak, nonatomic) IBOutlet UITextView *medicalHealthInfoField;
@property NSString* medicalHealthInfoFieldString;

// Strings
@property NSString* emergencyContactNameString;
@property NSString* emergencyContactNumberString;

@property NSString* userNameString;
@property (strong, nonatomic) NSString *selectedLanguage;


@end
