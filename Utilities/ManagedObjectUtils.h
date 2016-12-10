//
//  ManagedObjectUtils.h
//  Organization
//
//  Created by Stuart Pineo on 1/11/16.
//  Copyright (c) 2016 Stuart Pineo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Department.h"
#import "DepEmployee.h"


@interface ManagedObjectUtils : NSObject

extern NSString * const UNASSIGNED;

+ (int)checkEmpCount:(NSString *)empName context:(NSManagedObjectContext *)context;
+ (int)checkDepCount:(NSString *)depName context:(NSManagedObjectContext *)context;
+ (DepEmployee *)getDepEmpObject:(NSString *)depName employee:(NSString *)empName context:(NSManagedObjectContext *)context;
+ (Department *)queryDepartment:(NSString *)depName context:(NSManagedObjectContext *)context;

@end
