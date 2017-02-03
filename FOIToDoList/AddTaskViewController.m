//
//  AddTaskViewController.m
//  FOIToDoList
//
//  Created by Cong Nguyen on 2/1/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import "AddTaskViewController.h"
#import "FOICustomerService.h"
#import "MagicalRecordMan.h"
#import <MagicalRecord/MagicalRecord.h>

@interface AddTaskViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dueLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, strong) IBOutlet UIView *divider1;
@property (nonatomic, strong) IBOutlet UIView *divider2;
@property (nonatomic, strong) IBOutlet UIView *divider3;

@property (nonatomic, weak) IBOutlet UITextField *taskTitleField;
@property (nonatomic, weak) IBOutlet UITextField *dueDateField;
@property (nonatomic, weak) IBOutlet UITextField *aDescriptionField;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *addButton;

@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *longDateFormatter;


@property (nonatomic,strong) NSString *cacheTaskTitle;
@property (nonatomic,strong) NSString *cachedueDate;
@property (nonatomic,strong) NSString *cacheDescription;


@property (nonatomic, assign) BOOL isViewEditMode;


@end

@implementation AddTaskViewController

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
    
    
    [self.titleLabel setAttributedText:[self addSpacing:1 forString:@"Task Title"]];
    [self.dueLabel setAttributedText:[self addSpacing:1 forString:@"Due Date"]];
    [self.descriptionLabel setAttributedText:[self addSpacing:1 forString:@"Description"]];
    
    self.navigationItem.leftBarButtonItem = [self getBackButton];
    self.isViewEditMode = NO;
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIToolbar *toolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,40)];
    toolbar.tintColor = [UIColor blackColor];
    toolbar.barTintColor = [UIColor whiteColor];
    toolbar.clipsToBounds = YES; //get rid of that top border
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closeDatePicker)];
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpaceLeft, doneButton, nil]];
    
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"MM/dd/yy"];
    
    self.longDateFormatter = [[NSDateFormatter alloc]init];
    [self.longDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    self.taskTitleField.delegate = self;
    self.dueDateField.delegate = self;
    self.aDescriptionField.delegate = self;
    
    self.dueDateField.inputView = self.datePicker;
    self.dueDateField.inputAccessoryView = toolbar;
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChangeMethod:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.taskTitleField];

    if (self.taskToEdit) {
        //then we need to prefill the text
        
        [self.taskTitleField setAttributedText: [self addSpacing:1 forString:self.taskToEdit.name]];
        //format the text to be friendly
        [self.dueDateField setAttributedText: [self addSpacing:1 forString:[self.dateFormatter stringFromDate:[self.longDateFormatter dateFromString:self.taskToEdit.due]]]];
        [self.aDescriptionField setAttributedText: [self addSpacing:1 forString:self.taskToEdit.aDescription]];
        self.dueDate = [self.longDateFormatter dateFromString:self.taskToEdit.due];
    }
    
    if (self.viewMode) {
        self.navigationItem.rightBarButtonItem = [self getEditButtonItem];
        
        
        [self disableOrEnableUserInteraction];
        
        self.titleLabel.alpha = 1;
        self.dueLabel.alpha = 1;
        self.descriptionLabel.alpha = 1;
        
        self.divider1.alpha = 0;
        self.divider2.alpha = 0;
        self.divider3.alpha = 0;
        
        [self.cancelButton addTarget:self action:@selector(deleteTasktapped) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setImage:[UIImage imageNamed:@"deleteButton"] forState:UIControlStateNormal];
        [self.addButton addTarget:self action:@selector(completeAndUncompleteTaskTapped) forControlEvents:UIControlEventTouchUpInside];
        
        if ([self.taskToEdit.completed isEqualToString:@"1"]) {
            [self.addButton setImage:[UIImage imageNamed:@"completedButton"] forState:UIControlStateNormal];
        }else{
            [self.addButton setImage:[UIImage imageNamed:@"completeButton"] forState:UIControlStateNormal];
        }
        
    }else{
        self.titleLabel.alpha = 0;
        self.dueLabel.alpha = 0;
        self.descriptionLabel.alpha = 0;
        
        self.divider1.alpha = 1;
        self.divider2.alpha = 1;
        self.divider3.alpha = 1;
        
        [self.cancelButton addTarget:self action:@selector(cancelTaskTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setImage:[UIImage imageNamed:@"cancelButton"] forState:UIControlStateNormal];
        [self.addButton addTarget:self action:@selector(addTaskTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.addButton setImage:[UIImage imageNamed:@"saveButton"] forState:UIControlStateNormal];
        
        [self checkTextFieldText];
    }
}


-(void)disableOrEnableUserInteraction{
    
    if (self.isViewEditMode) {
        self.taskTitleField.userInteractionEnabled = YES;
        self.dueDateField.userInteractionEnabled = YES;
        self.aDescriptionField.userInteractionEnabled = YES;
    }else{
        self.taskTitleField.userInteractionEnabled = NO;
        self.dueDateField.userInteractionEnabled = NO;
        self.aDescriptionField.userInteractionEnabled = NO;
        
        [self.view resignFirstResponder];
    }
    
}

-(void)switchToEditMode{
    
    self.isViewEditMode = YES;
    [self disableOrEnableUserInteraction];
    
    self.cacheTaskTitle = self.taskTitleField.text;
    self.cachedueDate = self.dueDateField.text;
    self.cacheDescription = self.aDescriptionField.text;
    
    self.navigationItem.rightBarButtonItem = [self getCancelEditButtonItem];
    
    //hide the lines
    
    [UIView animateWithDuration:.3 animations:^{
        self.titleLabel.alpha = 0;
        self.dueLabel.alpha = 0;
        self.descriptionLabel.alpha = 0;
        
        self.divider1.alpha = 1;
        self.divider2.alpha = 1;
        self.divider3.alpha = 1;
        
    }];
    
    //need buttons to have X and Checkmark
    [self.cancelButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.addButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    [self.cancelButton addTarget:self action:@selector(cancelEditMode) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setImage:[UIImage imageNamed:@"cancelButton"] forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(saveEditAndSwitchToViewMode) forControlEvents:UIControlEventTouchUpInside];
    [self.addButton setImage:[UIImage imageNamed:@"saveButton"] forState:UIControlStateNormal];
    
    [self checkTextFieldText];
    
}

-(void)cancelEditMode{
    
    self.isViewEditMode = NO;
    [self disableOrEnableUserInteraction];
    
    self.navigationItem.rightBarButtonItem = [self getEditButtonItem];
    
    [UIView animateWithDuration:.3 animations:^{
        
        [self.taskTitleField setAttributedText:[self addSpacing:1 forString:self.cacheTaskTitle]];
        [self.dueDateField setAttributedText: [self addSpacing:1 forString:self.cachedueDate]];
        [self.aDescriptionField setAttributedText:[self addSpacing:1 forString:self.cacheDescription]];
        
        self.titleLabel.alpha = 1;
        self.dueLabel.alpha = 1;
        self.descriptionLabel.alpha = 1;
        
        self.divider1.alpha = 0;
        self.divider2.alpha = 0;
        self.divider3.alpha = 0;
    }];
    
    // need buttons to have Trash and Complete
    [self.cancelButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.addButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    [self.cancelButton addTarget:self action:@selector(deleteTasktapped) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setImage:[UIImage imageNamed:@"deleteButton"] forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(completeAndUncompleteTaskTapped) forControlEvents:UIControlEventTouchUpInside];
    
    //depending if the task is already completed...then we need to choose the right button
    
    //the add button shoudl always been enabled here
    
    [self checkTextFieldText];
    
    if ([self.taskToEdit.completed isEqualToString:@"1"]) {
        [self.addButton setImage:[UIImage imageNamed:@"completedButton"] forState:UIControlStateNormal];
    }else{
        [self.addButton setImage:[UIImage imageNamed:@"completeButton"] forState:UIControlStateNormal];
    }
    
}

-(void)saveEditAndSwitchToViewMode{
    
    
    self.isViewEditMode = NO;
    [self disableOrEnableUserInteraction];
    self.navigationItem.rightBarButtonItem = [self getEditButtonItem];
    
    [self addTaskTapped];
    [UIView animateWithDuration:.3 animations:^{
        self.titleLabel.alpha = 1;
        self.dueLabel.alpha = 1;
        self.descriptionLabel.alpha = 1;
        
        
    }];
    
    // need buttons to have Trash and Complete
    [self.cancelButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.addButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    [self.cancelButton addTarget:self action:@selector(deleteTasktapped) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setImage:[UIImage imageNamed:@"deleteButton"] forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(completeAndUncompleteTaskTapped) forControlEvents:UIControlEventTouchUpInside];
    
    //depending if the task is already completed...then we need to choose the right button
    if ([self.taskToEdit.completed isEqualToString:@"1"]) {
        [self.addButton setImage:[UIImage imageNamed:@"completedButton"] forState:UIControlStateNormal];
    }else{
        [self.addButton setImage:[UIImage imageNamed:@"completeButton"] forState:UIControlStateNormal];
    }
}


-(UIBarButtonItem*)getBackButton{
    UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    customView.backgroundColor = [UIColor clearColor];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(12, 12, 20, 20)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    [button setImage:[UIImage imageNamed:@"backIcon"]forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelTaskTapped) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:button];
    UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc]initWithCustomView:button];
    [settingBarButton setTarget:self];
    return settingBarButton;
}


-(UIBarButtonItem*)getEditButtonItem{
    UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    customView.backgroundColor = [UIColor clearColor];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(12, 12, 20, 20)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 10)];
    [button setImage:[UIImage imageNamed:@"swipeEditIcon"]forState:UIControlStateNormal];
    [button addTarget:self action:@selector(switchToEditMode) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:button];
    UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc]initWithCustomView:button];
    [settingBarButton setTarget:self];
    return settingBarButton;
}

-(UIBarButtonItem*)getCancelEditButtonItem{
    UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    customView.backgroundColor = [UIColor clearColor];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(12, 12, 20, 20)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 10)];
    [button setImage:[UIImage imageNamed:@"swipeEditIcon"]forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelEditMode) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:button];
    UIBarButtonItem *settingBarButton = [[UIBarButtonItem alloc]initWithCustomView:button];
    [settingBarButton setTarget:self];
    return settingBarButton;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == self.taskTitleField) {
        [self.dueDateField becomeFirstResponder];
    }else if (textField == self.dueDateField){
        [self.aDescriptionField becomeFirstResponder];
    }else{
        [self.aDescriptionField resignFirstResponder];
    }
    
    return YES;
}// called when 'return' key pressed. return NO to ignore.

-(void)textFieldDidChangeMethod:(NSNotification*)notication{
    [self checkTextFieldText];
    
    [(UITextField*)notication.object setAttributedText:[self addSpacing:1 forString:[(UITextField*)notication.object text]]];
}

-(NSAttributedString *)addSpacing:(double)spacing forString:(NSString*)string{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
    [text addAttribute:NSKernAttributeName value:[NSNumber numberWithDouble:spacing] range:NSMakeRange(0, text.length)];
    return text;
}

-(void)checkTextFieldText{
    if (self.taskTitleField.text.length < 1) {
        self.addButton.enabled = NO;
        [self.addButton setImage:[UIImage imageNamed:@"saveButtonInactive"] forState:UIControlStateNormal];
    }else{
        self.addButton.enabled = YES;
        [self.addButton setImage:[UIImage imageNamed:@"saveButton"] forState:UIControlStateNormal];
    }
}

- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker
{
    self.dueDate = datePicker.date;
    self.dueDateField.text = [self.dateFormatter stringFromDate:self.dueDate];
}


-(void)closeDatePicker{
    [self.dueDateField resignFirstResponder];
}

-(void)deleteTasktapped{
    
    [FOICustomerService deleteTaskWithID:self.taskToEdit.identifier success:^(NSArray *responseArray) {
        
    } failure:^(NSError *error) {
        NSLog(@"failure to delete task");
    }];
    
    //remove from local
    [MagicalRecordMan deleteTask:self.taskToEdit withCompletion:^(BOOL didComplete) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTasks)]) {
            [self.delegate refreshTasks];
        }
    }];
    
    //need to show overlay, and then dismiss
    
    
}

-(void)completeAndUncompleteTaskTapped{
    
    
    if ([self.taskToEdit.completed isEqualToString:@"0"]) {
        self.taskToEdit.completed = @"1";
        self.taskToEdit.completedDate = @"";
        
        //need to animte button
        //change button
        [self.addButton setImage:[UIImage imageNamed:@"completedButton"] forState:UIControlStateNormal];
    }else{
        self.taskToEdit.completed = @"0";
        self.taskToEdit.completedDate = [self.longDateFormatter stringFromDate:[NSDate date]];
        
        //need to animate button
        [self.addButton setImage:[UIImage imageNamed:@"completeButton"] forState:UIControlStateNormal];
    }
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTasks)]) {
        [self.delegate refreshTasks];
    }
    
    [FOICustomerService updateTaskWithID:self.taskToEdit.identifier Name:self.taskToEdit.name description:self.taskToEdit.aDescription categoryID:self.taskToEdit.category_id due:self.taskToEdit.due completed:self.taskToEdit.completed success:^(NSArray *responseArray) {
        NSLog(@"SUCCESS");
        
    } failure:^(NSError *error) {
        NSLog(@"failure to update the task");
    }];
}


-(void)addTaskTapped{
    
    //gotta make a call for NEW!
    NSString *dateString = [self.longDateFormatter stringFromDate:self.dueDate];
    if (!self.taskToEdit) {
        
        [FOICustomerService addTaskWithName:self.taskTitleField.text description:self.aDescriptionField.text categoryID:self.categoryID due:dateString success:^(NSString *itemID) {
            
            //if successful then we need to add it to the coredata
//            NSString *dateString = [self.dateFormatter stringFromDate:self.dueDate];
            NSDictionary *taskDict = @{@"name":self.taskTitleField.text,
                                       @"description":self.aDescriptionField.text,
                                       @"id":itemID,
                                       @"due":dateString,
                                       @"category_id":self.categoryID};
            
            [MagicalRecordMan saveTasksWithArray:@[taskDict] completion:^(BOOL didComplete) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTasks)]) {
                    [self.delegate refreshTasks];
                    [self cancelTaskTapped];
                }
            }];
            
        } failure:^(NSError *error) {
            
        }];
    }else{
        //make a call for UPDATE
    
        [FOICustomerService updateTaskWithID:self.taskToEdit.identifier Name:self.taskTitleField.text description:self.aDescriptionField.text categoryID:self.taskToEdit.category_id due:dateString completed:self.taskToEdit.completed success:^(NSArray *responseArray) {
            
            NSLog(@"Update task Success");
        } failure:^(NSError *error) {
            NSLog(@"failure update Task");
        }];
        
        //save it anyway regardless of fail/success. we dont want it to look like it lags. the webservice call can just process int he background
        self.taskToEdit.name = self.taskTitleField.text;
        self.taskToEdit.aDescription = self.aDescriptionField.text;
        self.taskToEdit.due = dateString;
        
        [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTasks)]) {
            [self.delegate refreshTasks];
            
            if (!self.viewMode) {
                //close the screen if NOT viewmode
                [self cancelTaskTapped];
            }else{
                //go back to viewmode
            }
        }
        
    }
    
    
}
-(void)cancelTaskTapped{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
