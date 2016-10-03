//: Playground - noun: a place where people can play

import UIKit

struct D {
    var key: String?
    var value: String?
    
    func asDic() -> [String: String]? {
        if let key = key, let value = value {
            return [ key: value ]
        } else {
            return nil
        }
    }
}

func hoge() -> D? {
//    return D(key: "a", value: "b")
    return nil
}

let a = hoge().flatMap { $0.asDic() }.flatMap { (s) -> [D]? in
    var ds = [D]()
    s.forEach({ (k, v) in
        ds.append(D(key: k, value: v))
    })
    return ds
}
print("\(a)")

