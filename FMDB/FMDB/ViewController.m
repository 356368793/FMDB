//
//  ViewController.m
//  FMDB
//
//  Created by 肖晨 on 15/8/18.
//  Copyright (c) 2015年 肖晨. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#import "Student.h"
#import "StudentTool.h"

@interface ViewController () <UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *ageField;
@property (assign, nonatomic) sqlite3 *db;
@property (strong, nonatomic) NSMutableArray *students;
- (IBAction)insert;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (NSMutableArray *)students
{
    if (_students == nil) {
        _students = [[NSMutableArray alloc] init];
    }
    return _students;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 增加搜索框
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    
    // 初始化数据库
    [self setupDb];
    
    // 查询数据
    [self searchData];
    
    // 关闭数据库
//    sqlite3_close(db);
}

/**
 *  测试FMDB的使用
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 添加数据
//    for (int i = 0; i < 100; i++) {
//        Student *s = [[Student alloc] init];
//        s.name = [NSString stringWithFormat:@"小明-%d", i];
//        s.age = arc4random() %5 + 15;
//        [StudentTool addStudent:s];
//    }
    
    // 取出数据
    NSArray *students = [StudentTool students];
    for (Student *s in students) {
        NSLog(@"%@  %d", s.name, s.age);
    }
}

/**
 *  查询数据
 */
- (void)searchData
{
    const char *sql = "SELECT name, age FROM t_student";
    sqlite3_stmt *stmt = NULL;
    // 准备
    int status = sqlite3_prepare_v2(self.db, sql, -1, &stmt, NULL);
    if (status == SQLITE_OK) { // 准备成功
        while (sqlite3_step(stmt) == SQLITE_ROW) { // 成功指向一条数据
            const char *name = (const char *)sqlite3_column_text(stmt, 0);
            int age = sqlite3_column_int(stmt, 1);
            
            Student *s = [[Student alloc] init];
            s.name = [NSString stringWithUTF8String:name];
            s.age = age;
            [self.students addObject:s];
        }
    }
}

/**
 *  初始化数据库
 */
- (void)setupDb
{
    // 打开数据库
    NSString *fileName = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"student.sqlite"];
    // 数据库实例对象
    int status = sqlite3_open(fileName.UTF8String, &_db);
    if (status == SQLITE_OK) {
        //        NSLog(@"打开数据库成功");
        // 创表
        const char *sql = "CREATE TABLE IF NOT EXISTS t_student (id integer PRIMARY KEY, name text NOT NULL, age integer)";
        char *errmsg = NULL;
        sqlite3_exec(_db, sql, NULL, NULL, &errmsg);
        if (errmsg) {
            NSLog(@"创表失败----%s", errmsg);
        }
    } else {
        NSLog(@"打开数据库失败");
    }
}

- (IBAction)insert {
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_student (name, age) VALUES ('%@', %d);",self.nameField.text, self.ageField.text.intValue];
    sqlite3_exec(self.db, sql.UTF8String, NULL, NULL, NULL);
    
    Student *s = [[Student alloc] init];
    s.name = self.nameField.text;
    s.age = self.ageField.text.intValue;
    [self.students addObject:s];
    [self.tableView reloadData];
}

/**
 *  模糊查询
 */
#pragma mark -UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // 移除所有记录
    [self.students removeAllObjects];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT name, age FROM t_student WHERE name LIKE '%%%@%%' OR age LIKE '%%%@%%'", searchText, searchText];
    sqlite3_stmt *stmt = NULL;
    // 准备
    int status = sqlite3_prepare_v2(self.db, sql.UTF8String, -1, &stmt, NULL);
    if (status == SQLITE_OK) { // 准备成功
        while (sqlite3_step(stmt) == SQLITE_ROW) { // 成功指向一条数据
            const char *name = (const char *)sqlite3_column_text(stmt, 0);
            int age = sqlite3_column_int(stmt, 1);
            
            Student *s = [[Student alloc] init];
            s.name = [NSString stringWithUTF8String:name];
            s.age = age;
            [self.students addObject:s];
        }
    }
    // 刷新所有记录
    [self.tableView reloadData];
}

#pragma mark -UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    Student *s = self.students[indexPath.row];
    
    cell.textLabel.text = s.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", s.age];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.students.count;
}

@end
