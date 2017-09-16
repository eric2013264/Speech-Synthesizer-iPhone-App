//
//  SixthViewController.h
//  SpeechSynthesizerProject
//
//  Created by Eric Chen on 4/12/16.
//  Copyright © 2016 WSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SixthViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *myDatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *myLanguagePicker;

@property (strong, nonatomic) NSString *selectedLanguage;

@end
