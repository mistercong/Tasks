//
//  TaskTableViewCell.m
//  FOIToDoList
//
//  Created by Cong Nguyen on 2/2/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import "TaskTableViewCell.h"

@implementation TaskTableViewCell




-(IBAction)checkButtonTapped:(id)sender{
    
    if (self.aDelegate && [self.aDelegate respondsToSelector:@selector(checkMarkButtonTapped:)]) {
        [self.aDelegate checkMarkButtonTapped:self];
    }
}





@end
