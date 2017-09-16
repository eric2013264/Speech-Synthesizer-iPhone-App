//
//  ThirdViewController.h
//  SpeechSynthesizerProject
//
//  Created by Eric Chen on 3/24/16.
//  Copyright © 2016 WSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThirdViewController : UIViewController

// Table
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property NSMutableArray* tableEntries;

// Overlay
- (IBAction)overlayButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *overlayForTableView;
@property (weak, nonatomic) IBOutlet UIButton *overlayButton;

// Strings
@property NSString* isFirstBoot;
@property (strong, nonatomic) NSString *selectedLanguage;
@end
 