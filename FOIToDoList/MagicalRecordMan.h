//
//  MagicalRecordMan.h
//  FOIToDoList
//
//  Created by Cong Nguyen on 2/1/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task+CoreDataClass.h"
#import "Category+CoreDataClass.h"

@interface MagicalRecordMan : NSObject


+(void)saveCategoriesWithArray:(NSArray*)categoryArray completion:(void(^)(BOOL didComplete))completion;

+(void)deleteCategory:(Category*)category withCompletion:(void(^)(BOOL didComplete))completion;
+(void)saveTasksWithArray:(NSArray*)tasksArray completion:(void(^)(BOOL didComplete))completion;
+(void)deleteTask:(Task*)task withCompletion:(void(^)(BOOL didComplete))completion;


@end
