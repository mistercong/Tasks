//
//  FOICustomerService.h
//  FOIToDoList
//
//  Created by Cong Nguyen on 1/31/17.
//  Copyright © 2017 misterCong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface FOICustomerService : NSObject

+(NSURLSessionDataTask*)getTasksWithSuccess:(void(^)(NSArray *responseArray))success
                                    failure:(void(^)(NSError *error))failure;


+(NSURLSessionDataTask*)addTaskWithName:(NSString *)name
                            description:(NSString*)description
                             categoryID:(NSString*)categoryId
                                    due:(NSString*)due
                                success:(void(^)(NSString *itemID))success
                                failure:(void(^)(NSError *error))failure;


+(NSURLSessionDataTask*)deleteTaskWithID:(NSString*)identifier
                                 success:(void(^)(NSArray *responseArray))success
                                 failure:(void(^)(NSError *error))failure;

+(NSURLSessionDataTask*)updateTaskWithID:(NSString*)identifier
                                    Name:(NSString *)name
                             description:(NSString*)description
                              categoryID:(NSString*)categoryId
                                     due:(NSString*)due
                               completed:(NSString*)completed
                                 success:(void(^)(NSArray *responseArray))success
                                 failure:(void(^)(NSError *error))failure;


+(NSURLSessionDataTask*)getCategoriesWithSuccess:(void(^)(NSArray *responseArray))success
                                         failure:(void(^)(NSError *error))failure;

+(NSURLSessionDataTask*)addCategoryWithName:(NSString *)name
                                    success:(void(^)(NSString *responseString))success
                                    failure:(void(^)(NSError *error))failure;

+(NSURLSessionDataTask*)deleteCategoryWithID:(NSString *)identifier
                                     success:(void(^)(NSArray *responseArray))success
                                     failure:(void(^)(NSError *error))failure;

+(NSURLSessionDataTask*)updateCategoryWithID:(NSString*)identifier
                                        name:(NSString *)name
                                     success:(void(^)(NSArray *responseArray))success
                                     failure:(void(^)(NSError *error))failure;

@end
