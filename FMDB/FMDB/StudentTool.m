//
//  StudentTool.m
//  FMDB
//
//  Created by 肖晨 on 15/8/18.
//  Copyright (c) 2015年 肖晨. All rights reserved.
//

#import "StudentTool.h"
#import "Student.h"
#import "FMDB.h"

@implementation StudentTool

static FMDatabase *_db;

+ (void)initialize
{
    // 1.打开数据库
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"students.sqlite"];
    _db = [FMDatabase databaseWithPath:path];
    [_db open];
    
    // 2.创表
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_student (id integer PRIMARY KEY, name text NOT NULL, age integer);"];
}

+ (void)addStudent:(Student *)student
{
    [_db executeUpdateWithFormat:@"INSERT INTO t_student (name, age) VALUES (%@, %d);", student.name, student.age];
}
+ (NSArray *)students
{
    // 得到结果集
    FMResultSet *set = [_db executeQuery:@"SELECT * FROM t_student;"];
    
    // 不断往下取数据
    NSMutableArray *students = [NSMutableArray array];
    while (set.next) {
        // 获得当前所指向的数据
        Student *s = [[Student alloc] init];
        s.name = [set stringForColumn:@"name"];
        s.age = [set intForColumn:@"age"];
        [students addObject:s];
    }
    return students;
}


@end
