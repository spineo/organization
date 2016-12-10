//
//  ManagedObjectUtils.m
//  Organization
//
//  Created by Stuart Pineo on 1/11/16.
//  Copyright (c) 2016 Stuart Pineo. All rights reserved.
//

#import "ManagedObjectUtils.h"
#import "DepEmployee.h"


@implementation ManagedObjectUtils

NSString * const UNASSIGNED = @"Unassigned";

+ (int)checkEmpCount:(NSString *)empName context:(NSManagedObjectContext *)context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DepEmployee" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    [fetch setPredicate: [NSPredicate predicateWithFormat:@"de_employee.name == %@", empName]];

    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    return (int)[results count];
}

+ (int)checkDepCount:(NSString *)depName context:(NSManagedObjectContext *)context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DepEmployee" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    [fetch setPredicate: [NSPredicate predicateWithFormat:@"de_department.name == %@", depName]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    return (int)[results count];
}

+ (DepEmployee *)getDepEmpObject:(NSString *)depName employee:(NSString *)empName context:(NSManagedObjectContext *)context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DepEmployee" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    [fetch setPredicate: [NSPredicate predicateWithFormat:@"de_department.name == %@ and de_employee.name == %@", depName, empName]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    if ([results count] == 0) {
        return nil;
    } else {
        return [results objectAtIndex:0];
    }
}

+ (Department *)queryDepartment:(NSString *)depName context:(NSManagedObjectContext *)context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Department" inManagedObjectContext:context];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    [fetch setEntity:entity];
    
    [fetch setPredicate: [NSPredicate predicateWithFormat:@"name == %@", depName]];
    
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetch error:&error];
    
    return [results objectAtIndex:0];
}

@end
