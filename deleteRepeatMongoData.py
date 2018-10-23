#!/usr/bin/env python
# -*- coding:utf-8 -*-
from pymongo import MongoClient

settings = {
    "ip":'127.0.0.1',   #ip
    "port":27017,           #端口
    "db_name" : "cargonow",    #数据库名字
    "set_name" : "invoice_list"   #集合名字
}

class MyMongoDB(object):
    def __init__(self):
        try:
            self.conn = MongoClient(settings["ip"], settings["port"])
        except Exception as e:
            print(e)
        self.db = self.conn[settings["db_name"]]
        self.my_set = self.db[settings["set_name"]]

    def insert(self,dic):
        print("inser...")
        self.my_set.insert(dic)

    def update(self,dic,newdic):
        print("update...")
        self.my_set.update(dic,newdic)

    def delete(self,dic):
        print("delete...")
        self.my_set.remove(dic)

    def dbfind(self,dic):
        print("find...")
        data = self.my_set.find(dic)
        for result in data:
            print(result["name"],result["age"])

    def droprepeat(self):
        print("droprepeat...")
        c = self.my_set.count()
        print(c)
        data = self.my_set.aggregate(
                [{"$group":{
                    "_id":"$relatedno",
                    "max_addtime":{"$max":"$addtime"},
                    "min_addtime":{"$min":"$addtime"},
                    "count":{"$sum":1}
                    }
                },{"$match":{"count":{"$gt":1}}}]
            )
        for result in data:
            print(result)
            needdel = self.my_set.find({"relatedno":result["_id"],"addtime":{"$gt":result["min_addtime"]}})
            for edel in needdel:
                print(edel)
                #删除 
                self.my_set.remove(edel)

def main():
    #dic={"name":"zhangsan","age":18}
    mongo = MyMongoDB()
    #mongo.insert(dic)
    #mongo.dbfind({"name":"zhangsan"})

    #mongo.update({"name":"zhangsan"},{"$set":{"age":"25"}})
    #mongo.dbfind({"name":"zhangsan"})

    #mongo.delete({"name":"zhangsan"})
    #mongo.dbfind({"name":"zhangsan"})
    #mongo.insert(dic)
    #mongo.insert(dic)
    mongo.droprepeat()

if __name__ == "__main__":
    main()
