//
//  MagicalRecordMan.m
//  FOIToDoList
//
//  Created by Cong Nguyen on 2/1/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import "MagicalRecordMan.h"
#import <MagicalRecord/MagicalRecord.h>



@implementation MagicalRecordMan



//handle the calls


+(void)saveCategoriesWithArray:(NSArray*)categoryArray completion:(void(^)(BOOL didComplete))completion{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        //get current categories
        NSArray *allCategories = [Category MR_findAllInContext:localContext];
        NSMutableArray *duplicateCategories = [[NSMutableArray alloc]init];
        NSMutableArray *categoryArrayCopy = [[NSMutableArray alloc]init];
        [categoryArrayCopy addObjectsFromArray:categoryArray];
        
        
        for (Category *existingCat in allCategories) {
            
            for (NSDictionary *catDict in categoryArray) {
                
                if ([catDict[@"id"] isEqualToString:existingCat.identifier]) {
                    //update it
                    [existingCat setName:catDict[@"name"]];
                    [existingCat setIdentifier:catDict[@"id"]];
                    [duplicateCategories addObject:catDict];
                }
            }
        }
        
        [categoryArrayCopy removeObjectsInArray:duplicateCategories];
        
        for (NSDictionary *newCatDict in categoryArrayCopy) {
            Category *category = [Category MR_createEntityInContext:localContext];
            [category setName:newCatDict[@"name"]];
            [category setIdentifier:newCatDict[@"id"]];
        }
        
    }completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        NSLog(@"Save Category is compelte now");
        completion(contextDidSave);
    }];
}

+(void)deleteCategory:(Category*)category withCompletion:(void(^)(BOOL didComplete))completion{
    BOOL result = [category MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    completion(result);
    
}

+(void)saveTasksWithArray:(NSArray*)tasksArray completion:(void(^)(BOOL didComplete))completion{
    


    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
        NSArray *allTasks = [Task MR_findAllInContext:localContext];
        NSMutableArray *duplicateTasks = [[NSMutableArray alloc]init];
        NSMutableArray *tasksArrayCopy = [[NSMutableArray alloc]init];
        [tasksArrayCopy addObjectsFromArray:tasksArray];
        
        
        for (Task *existingTask in allTasks) {
            
            for (NSDictionary *taskDict in tasksArray) {
                
                if ([taskDict[@"id"] isEqualToString:existingTask.identifier]) {
                    //update it
                    [existingTask setName:taskDict[@"name"]];
                    [existingTask setIdentifier:taskDict[@"id"]];
                    [existingTask setCategory_id:taskDict[@"category_id"]];
                    [existingTask setADescription:taskDict[@"description"]];
                    [existingTask setDue:taskDict[@"due"]];
                    [existingTask setCompleted:taskDict[@"completed"]];
                    [duplicateTasks addObject:taskDict];
                }
            }
        }
        
        [tasksArrayCopy removeObjectsInArray:duplicateTasks];
        
        for (NSDictionary *newTaskDict in tasksArrayCopy) {
            Task *task = [Task MR_createEntityInContext:localContext];
            [task setName:newTaskDict[@"name"]];
            [task setIdentifier:newTaskDict[@"id"]];
            [task setCategory_id:newTaskDict[@"category_id"]];
            [task setADescription:newTaskDict[@"description"]];
            [task setDue:newTaskDict[@"due"]];
            [task setCompleted:newTaskDict[@"completed"]];
        }
    }completion:^(BOOL contextDidSave, NSError * _Nullable error) {
        NSLog(@"Save Tasks is compelte now");
        completion(contextDidSave);
    }];
}


+(void)deleteTask:(Task*)task withCompletion:(void(^)(BOOL didComplete))completion{
    BOOL result = [task MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    completion(result);
    
}

+(void)saveSingleTask:(Task*)task withCompletion:(void(^)(BOOL didComplete))completion{
    
//    [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
//        
//        
//        
//    }completion:^(BOOL contextDidSave, NSError * _Nullable error) {
//        completion(contextDidSave);
//    }];
    
}








@end
