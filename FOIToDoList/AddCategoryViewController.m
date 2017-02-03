//
//  AddCategoryViewController.m
//  FOIToDoList
//
//  Created by Cong Nguyen on 2/1/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import "AddCategoryViewController.h"
#import "FOICustomerService.h"
#import "MagicalRecordMan.h"

@interface AddCategoryViewController () <UITextFieldDelegate>


@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIView *dividerView;

@end

@implementation AddCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *titleLabel = [UILabel new];
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"Avenir-Black" size:17.0],
                                 NSKernAttributeName: @4};
    titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.navigationItem.title attributes:attributes];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    self.textField.delegate = self;
    
    [self.cancelButton addTarget:self action:@selector(cancelTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.addButton addTarget:self action:@selector(addCategoryTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChangeMethod:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.textField];
    
    if (self.categoryToEdit) {
        self.textField.text = self.categoryToEdit.name;
    }
    
    [self checkTextFieldText];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.textField resignFirstResponder];
    return YES;
}// called when 'return' key pressed. return NO to ignore.

-(void)textFieldDidChangeMethod:(NSNotification*)notication{
    
    [self checkTextFieldText];
    
    [self.textField setAttributedText:[self addSpacing:1.2 forString:[(UITextField*)notication.object text]]];
}

-(NSAttributedString *)addSpacing:(double)spacing forString:(NSString*)string{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    [text addAttribute:NSKernAttributeName value:[NSNumber numberWithDouble:spacing] range:NSMakeRange(0, text.length)];
    return text;
}

-(void)checkTextFieldText{
    if (self.textField.text.length < 1) {
        self.addButton.enabled = NO;
        [self.addButton setImage:[UIImage imageNamed:@"saveButtonInactive"] forState:UIControlStateNormal];
    }else{
        self.addButton.enabled = YES;
        [self.addButton setImage:[UIImage imageNamed:@"saveButton"] forState:UIControlStateNormal];
    }
}

-(void)addCategoryTapped{
    
    
    
    if (!self.categoryToEdit) {
        NSLog(@"add category!??");
        //take the text from the field make a webservice call. and add it to the thingy
        [FOICustomerService addCategoryWithName:self.textField.text success:^(NSString *responseString) {
            //in the response array will be returned an ID in the form of a string
            //if it got to this block, then the webservice was complete
            //toss it into a dictionary
            NSDictionary *categoryDict = @{@"id":responseString,
                                           @"name":self.textField.text};
            [MagicalRecordMan saveCategoriesWithArray:@[categoryDict] completion:^(BOOL didComplete) {
                //save was complete, we need to tell the categoryView to reload
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(reloadCategories)]) {
                    [self.delegate reloadCategories];
                    [self cancelTapped];
                }
            }];
            
        } failure:^(NSError *error) {
            //i know this is bad. normally you are supposed to handle...
            NSLog(@"silent fail...");
        }];
    }else{
        [FOICustomerService updateCategoryWithID:self.categoryToEdit.identifier name:self.textField.text success:^(NSArray *responseArray) {
            NSDictionary *categoryDict = @{@"id":self.categoryToEdit.identifier,
                                           @"name":self.textField.text};
            [MagicalRecordMan saveCategoriesWithArray:@[categoryDict] completion:^(BOOL didComplete) {
                //save was complete, we need to tell the categoryView to reload
                if (self.delegate && [self.delegate respondsToSelector:@selector(reloadCategories)]) {
                    [self.delegate reloadCategories];
                    [self cancelTapped];
                }
            }];
        } failure:^(NSError *error) {
            //i know this is bad. normally you are supposed to handle...
            NSLog(@"silent fail...");
        }];
    }
    
    

    
}

-(void)cancelTapped{
    NSLog(@"cancel the add");
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
