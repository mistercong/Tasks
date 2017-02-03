//
//  FOICustomerService.m
//  FOIToDoList
//
//  Created by Cong Nguyen on 1/31/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import "FOICustomerService.h"


@implementation FOICustomerService


+(NSURLSessionDataTask*)getTasksWithSuccess:(void(^)(NSArray *responseArray))success failure:(void(^)(NSError *error))failure{
    

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"https://api.fusionofideas.com/todo/getItems.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            failure(error);
        } else {
            NSLog(@"Response = %@ ResponseObject = %@", response, responseObject);
            //the objects are going to come back as a dictionary which has an array full of more dictionaries
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                //init the array
                NSArray *responseArray = responseObject[@"content"];
                success(responseArray);
            }else{
                //unknown object?
                NSLog(@"Unknown Object/response");
                NSError *error;
                failure(error);
            }
        }
    }];
    [dataTask resume];
    
    return dataTask;
}



+(NSURLSessionDataTask*)addTaskWithName:(NSString *)name
                            description:(NSString*)description
                             categoryID:(NSString*)categoryId
                                    due:(NSString*)due
                                success:(void(^)(NSString *itemID))success
                                failure:(void(^)(NSError *error))failure{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *urlString = @"https://api.fusionofideas.com/todo/addItem.php";
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    params[@"name"] = name;
    params[@"description"] = description;
    params[@"category_id"] = categoryId;
    params[@"due"] = due;
    
    
    
    NSURLSessionDataTask *dataTask = [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject[@"status"] isEqualToString:@"OK"]) {
                NSString *itemID = [responseObject[@"content"]stringValue];
                success(itemID);
            }else{
                NSLog(@"failed to add item");
                NSError *error;
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    return dataTask;
}


+(NSURLSessionDataTask*)deleteTaskWithID:(NSString*)identifier
                                 success:(void(^)(NSArray *responseArray))success
                                 failure:(void(^)(NSError *error))failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *urlString = @"https://api.fusionofideas.com/todo/deleteItem.php";
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    params[@"id"] = identifier;
    
    
    
    NSURLSessionDataTask *dataTask = [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject[@"status"] isEqualToString:@"OK"]) {
                success(responseObject);
            }else{
                NSLog(@"failed to delete item");
                NSError *error;
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    return dataTask;
}

+(NSURLSessionDataTask*)updateTaskWithID:(NSString*)identifier
                                    Name:(NSString *)name
                             description:(NSString*)description
                              categoryID:(NSString*)categoryId
                                     due:(NSString*)due
                               completed:(NSString*)completed
                                 success:(void(^)(NSArray *responseArray))success
                                 failure:(void(^)(NSError *error))failure{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *urlString = @"https://api.fusionofideas.com/todo/updateItem.php";
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    params[@"id"] = identifier;
    if(name) params[@"name"] = name;
    if(description) params[@"description"] = description;
    if(categoryId) params[@"category_id"] = categoryId;
    if(due) params[@"due"] = due;
    if (completed) params[@"completed"] = completed;
    
    
    
    NSURLSessionDataTask *dataTask = [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject[@"status"] isEqualToString:@"OK"]) {
                success(responseObject);
            }else{
                NSLog(@"failed to Update task");
                NSError *error;
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    return dataTask;
}


+(NSURLSessionDataTask*)getCategoriesWithSuccess:(void(^)(NSArray *responseArray))success failure:(void(^)(NSError *error))failure{
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"https://api.fusionofideas.com/todo/getCategories.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            failure(error);
        } else {
            NSLog(@"Response = %@ ResponseObject = %@", response, responseObject);
            //the objects are going to come back as a dictionary which has an array full of more dictionaries
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                //init the array
                NSArray *responseArray = responseObject[@"content"];
                success(responseArray);
            }else{
                //unknown object?
                NSLog(@"Unknown Object/response");
                NSError *error;
                failure(error);
            }
        }
    }];
    [dataTask resume];
    
    return dataTask;
}

+(NSURLSessionDataTask*)addCategoryWithName:(NSString *)name
                                    success:(void(^)(NSString *responseString))success
                                    failure:(void(^)(NSError *error))failure{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *urlString = @"https://api.fusionofideas.com/todo/addCategory.php";
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    params[@"name"] = name;
    
    NSURLSessionDataTask *dataTask = [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject[@"status"] isEqualToString:@"OK"]) {
                NSString *idString = [responseObject[@"content"]stringValue];
                success(idString);
                //will return "content" which has the ID
                
            }else{
                NSLog(@"failed to add category");
                NSError *error;
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    return dataTask;
}

+(NSURLSessionDataTask*)deleteCategoryWithID:(NSString *)identifier
                                    success:(void(^)(NSArray *responseArray))success
                                    failure:(void(^)(NSError *error))failure{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *urlString = @"https://api.fusionofideas.com/todo/deleteCategory.php";
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    params[@"id"] = identifier;
    
    NSURLSessionDataTask *dataTask = [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject[@"status"] isEqualToString:@"OK"]) {
                success(responseObject);
                //will return "content" which has the ID
                
            }else{
                NSLog(@"failed to delete category");
                NSError *error;
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    return dataTask;
}

+(NSURLSessionDataTask*)updateCategoryWithID:(NSString*)identifier
                                        name:(NSString *)name
                                     success:(void(^)(NSArray *responseArray))success
                                     failure:(void(^)(NSError *error))failure{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *urlString = @"https://api.fusionofideas.com/todo/updateCategory.php";
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    params[@"id"] = identifier;
    params[@"name"] = name;
    
    NSURLSessionDataTask *dataTask = [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject isKindOfClass:[NSDictionary class]]) {
            NSLog(@"Reply JSON: %@", responseObject);
            
            if ([responseObject[@"status"] isEqualToString:@"OK"]) {
                success(responseObject);
            }else{
                NSLog(@"failed to update category");
                NSError *error;
                failure(error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    return dataTask;
}



@end
