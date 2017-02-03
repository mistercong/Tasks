//
//  TaskTableViewCell.h
//  FOIToDoList
//
//  Created by Cong Nguyen on 2/2/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import <SWTableViewCell/SWTableViewCell.h>

@protocol TaskTableViewCellDelegate<NSObject>

-(void)checkMarkButtonTapped:(SWTableViewCell*)cell;

@end

@interface TaskTableViewCell : SWTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *aDescriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIButton *checkButton;
@property (nonatomic, weak) id<TaskTableViewCellDelegate>aDelegate;


@end
