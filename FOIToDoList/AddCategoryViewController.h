//
//  AddCategoryViewController.h
//  FOIToDoList
//
//  Created by Cong Nguyen on 2/1/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category+CoreDataClass.h"

@protocol AddCategoryViewControllerDelegate <NSObject>

-(void)reloadCategories;

@end

@interface AddCategoryViewController : UIViewController


@property (nonatomic, weak) id<AddCategoryViewControllerDelegate>delegate;
@property (nonatomic, strong) Category *categoryToEdit;


@end
