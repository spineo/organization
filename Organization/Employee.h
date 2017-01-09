//
//  Employee.h
//  
//
//  Created by Stuart Pineo on 12/31/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DepEmployee;

@interface Employee : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *employee_de;
@end

@interface Employee (CoreDataGeneratedAccessors)

- (void)addEmployee_deObject:(DepEmployee *)value;
- (void)removeEmployee_deObject:(DepEmployee *)value;
- (void)addEmployee_de:(NSSet *)values;
- (void)removeEmployee_de:(NSSet *)values;

@end
