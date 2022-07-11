//
//  CURDTests.swift
//  
//
//  Created by Plumk on 2022/7/11.
//

import XCTest
@testable import PLDB

enum Gender: Int, PLDBEnum {
    case woman = 0
    case man = 1
}

struct User: PLDBModel {
    
    /// 表名
    static var tableName: String { "User" }
    
    /// 唯一id
    static var uniqueIdName: String { "id" }
    var uniqueId: Int { self.id }
    
    @Column(primaryKey: true, autoIncrement: true, index: true)
    var id = 0
    
    @Column
    var gender = Gender.man
    
    @Column
    var name: String?
    
    @Column
    var pet: Pet?
    
    @Column
    var bool: Bool?
    
    @Column
    var data: Data?
    
    @Column
    var date: Date?
    
    @Column
    var float: Float?
    
    @Column
    var double: Double?
    
}

struct Pet: PLDBModel {
    
    /// 表名
    static var tableName: String { "Pet" }
    
    /// 唯一id
    static var uniqueIdName: String { "id" }
    var uniqueId: Int { self.id }
    
    @Column(primaryKey: true, autoIncrement: true, index: true)
    var id = 0
    
    @Column
    var name: String?
    
}


final class CURDTests: XCTestCase {
    
    func createDBPath() -> String {
        var path = FileManager.default.homeDirectoryForCurrentUser
        path.appendPathComponent("pl_test.db")
//        try? FileManager.default.removeItem(at: path)
        return path.relativePath
    }
    
    func createDB() -> PLDB {
        let db = PLDB(path: createDBPath())
        
        XCTAssert(db.open(), "数据库打开失败")
        db.createTable(User())
        db.createTable(Pet())
        return db
    }
    
    func insertOneData() -> PLDB {
        let db = createDB()
        let user = db.create(User(name: "xxx", pet: Pet(name: "dog")))
        print(user)
        return db
    }
    
    func testCreate() throws {
        _ = createDB()
    }
    
    
    func testInsert() throws {
        _ = insertOneData()
    }
    
    func testBatchInsert() throws {
        let db = createDB()
        for i in 1 ... 10000 {
            _ = db.create(User(name: "user_\(i)"))
        }
    }
    
    func testBatchInsert_Transaction() throws {
        let db = createDB()
        XCTAssert(db.beginTransaction(), "开启事务失败")
        
        for i in 1 ... 10000 {
            _ = db.create(User(name: "user_\(i)"))
        }
        XCTAssert(db.commit(), "提交事务失败")
    }
    
    func testQuery() throws {
    
        
        let db = createDB()
        
        if let user = db.query(User.self).first() {
            print(user)
        }
        
        if let users = db.query(User.self).all() {
            print(users.count)
        }
    }
    
    func testDelete() throws {
        let db = createDB()
        
        if let user = db.query(User.self).first() {
            db.delete(user)
        }
        
        _ = db.deleteTable(User.self)
    }
    
    func testUpdate() throws {
        let db = createDB()
        if let user = db.query(User.self).first() {
            user.pet?.name = "fff"
            user.name = "zzz"
            db.save(user)
        }
    }
}
