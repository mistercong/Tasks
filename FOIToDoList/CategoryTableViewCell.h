//
//  CategoryTableViewCell.h
//  FOIToDoList
//
//  Created by Cong Nguyen on 2/2/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import <SWTableViewCell/SWTableViewCell.h>

@interface CategoryTableViewCell : SWTableViewCell
@property (nonatomic, weak) IBOutlet UILabel *categoryTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *taskCountLabel;
@end
