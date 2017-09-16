//
//  SixthViewController.m
//  SpeechSynthesizerProject
//
//  Created by Eric Chen on 4/12/16.
//  Copyright © 2016 WSU. All rights reserved.
//

#import "SixthViewController.h"
#import "SecondViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface SixthViewController ()

@property (strong, nonatomic) NSArray *languageCodes;
@property (strong, nonatomic) NSDictionary *languageDictionary;

@end

@implementation SixthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDate *currentDate = [NSDate date];

    [_myDatePicker setMaximumDate:currentDate];
    [_myDatePicker setValue:[UIColor whiteColor] forKey:@"textColor"];
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    self.selectedLanguage = [preferences stringForKey:@"PrefKeySelectedLanguage"];
    NSUInteger index = [self.languageCodes indexOfObject:self.selectedLanguage];
    if (index != NSNotFound)
    {
        [self.myLanguagePicker selectRow:index inComponent:0 animated:YES]; 
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
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

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.languageCodes count];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.

 }

@end
