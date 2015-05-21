//
//  FirstViewController.h
//  ZHAW LSFM Exam App
//
//  Created by Adrian on 10.12.14.
//  Copyright (c) 2014 Adrian Busin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) BOOL guidedAccessOn;
//@property (nonatomic, assign) BOOL guidedProtectedAccessOn;
@property (nonatomic, assign) BOOL firstTimeGuidedAccessChange;

@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *localTimeLabel;
@property (nonatomic, strong) UILabel *serverTimeLabel;
//@property (nonatomic, strong) UILabel *volumeLevelLabel;
@property (nonatomic, strong) UILabel *networkStateLabel;
@property (nonatomic, strong) UILabel *hostStateLabel;
@property (nonatomic, strong) UILabel *memoryLevelLabel;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

//@property (nonatomic, strong) UILabel *checkResultLabel;

@property (nonatomic, strong) IBOutlet UIButton *updateButton;
@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *codeTextField;

- (IBAction)updateButtonClicked:(id)sender;
+(BOOL)guidedProtectedAccessOn;

@end

