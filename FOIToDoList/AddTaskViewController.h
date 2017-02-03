//
//  AddTaskViewController.h
//  FOIToDoList
//
//  Created by Cong Nguyen on 2/1/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task+CoreDataClass.h"

@protocol AddTaskViewControllerDelegate <NSObject>

-(void)refreshTasks;

@end

@interface AddTaskViewController : UIViewController

@property (nonatomic, weak) id<AddTaskViewControllerDelegate>delegate;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) Task *taskToEdit;

@property (nonatomic) BOOL viewMode;

@end
