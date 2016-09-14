import Foundation

print("AAAAAA")

public protocol P {
    var id: Int? { get set }
}

public class C: P {
    public var id: Int? = nil
    
    init(id: Int? = nil) {
        if let _ = id {
         self.id = id
        }
    }
}

let c1 = C(id: 2)
let c2 = C(id: 2)

let a: [P] = [c1, c2]

let b = a.contains({ $0.id != nil && $0.id! == c2.id!  })

for obj in a where obj.id == 2 {
    print("SSSSS: \(obj.id)")
}

if let x = a.index(where: { $0.id! == 2 }) {
    print("AX: \(a[x])")
}

print(b)


NSDate(timeIntervalSince1970:12)

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "YYYY-MM-DD"
let date = dateFormatter.date(from: "196llll9-12-08")
let x:Int  = nil ?? 0
let interval = date?.timeIntervalSinceNow ?? 0

let age = Int( abs(interval) / (365*24*3600))



var M=1/19.0
M = 1/(1-18/19.0)

(16.0+17.0+18.0+19.0+20.0)/20.0


/*print("A  \(pow(20,0.05)/20)")
print("A  \(pow(20,0.1)/20)")
print("A  \(pow(20,0.15)/20)")
print("A  \(pow(20,0.2)/20)")
print("A  \(pow(20,0.25)/20)")
print("A  \(pow(20,0.3)/20)")
print("A  \(pow(20,0.35)/20)")
print("A  \(pow(20,0.4)/20)")
print("A  \(pow(20,0.45)/20)")
print("A  \(pow(20,0.5)/20)")
print("A  \(pow(20,0.55)/20)")
print("A  \(pow(20,0.6)/20)")
print("A  \(pow(20,0.65)/20)")
print("A  \(pow(20,0.7)/20)")
print("A  \(pow(20,0.75)/20)")
print("A  \(pow(20,0.8)/20)")
print("A  \(pow(20,0.85)/20)")
print("A  \(pow(20,0.9)/20)")
print("A  \(pow(20,0.95)/20)")
print("A  \(pow(20,1)/20)") */

let TLEN = 20
let bb = Double(TLEN)
var aa = 1
var xx = 1.0
var s1 = "12345678901234567890"
var s2 = "12345678901234567890"

for i in 1...TLEN {
    if (
        true //i == 20
        
        ) {
    var p = 4.0 //Double(i)/Float(TLEN)
    var pp = 1 - p
    
    var t = pow(Double(TLEN), pp)
    var x = t/Double(TLEN)
    xx = xx * Double(x)
        
    var zz = pow(Double(TLEN), -(p))
    print(" \(i) \(i/TLEN): \(t) \(x) \(xx) \(zz)")
    }
}

print("XXXX: \(xx)")


let MM = [0,     0,     0.014, 0,     0,     0.395, 0.317, 0, 0.389, 0.079, 0.0445,
         0.508, 0.613, 0.851, 0.732, 0.828, 0.615, 0.804, 0.685, 0.582]

var x1 = 1.0

for i in 1...TLEN {
    if (
        i == 19 ||
        i == 20
        ) {
            x1 = x1 * (1 - MM[i-1])
        }
}

print ("xxxx: \(x1 * 1.0/(((19-5)/19)*4+1))")






