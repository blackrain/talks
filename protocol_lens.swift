//: Playground - noun: a place where people can play

import UIKit

// Protocols

protocol Quackable {
    func quack()
}

protocol Named {
    var name: String { get }
}

protocol SelfIdentiable {
    func showName()
}

protocol Walkable {
    func walk()
}

extension Quackable {
    func quack() { print("Quack !") }
}

extension SelfIdentiable where Self: Named {
    func showName() { print("My name is: \(name)") }
}

struct Duck: Quackable, Named, SelfIdentiable {
    let name = "Donald Duck"
}

extension Duck: Walkable {
    func walk() {
        print("I'm walking again.")
    }
}

let donaldDuck = Duck()
donaldDuck.showName()
donaldDuck.quack()
donaldDuck.walk()
let myName = donaldDuck.name

// Lenses

struct Address: CustomDebugStringConvertible {
    let street: String
    let number: Int
    
    var debugDescription: String {
        return "\(street) \(number)"
    }
}

struct User: CustomDebugStringConvertible {
    let name: String
    let address: Address
    
    var debugDescription: String {
        return "User: \(name) from \(address)"
    }
}

let user1 = User(name: "Adam", address: Address(street: "Poselska", number: 29))

extension User {
    func getAddress() -> Address { return self.address }
    func setAddress(address: Address) -> User { return User(name: self.name, address: address) }
}

extension Address {
    func getStreet() -> String { return self.street }
    func setStreet(street: String) -> Address { return Address(street: street, number: self.number) }
}

struct Lens<A, B> {
    let get: A -> B
    let set: (B, A) -> A
}

let userAddressLens = Lens<User, Address>(
    get: { $0.address },
    set: { (address, user) in User(name: user.name, address: address) }
)

let addressStreetLens = Lens<Address, String>(
    get: { $0.street },
    set: { (street, address) in Address(street: street, number: address.number) }
)

userAddressLens.get(user1)
userAddressLens.set(Address(street: "Francuska", number: 30), user1)
userAddressLens.get(user1)

func compose<A,B,C>(lhs: Lens<A,B>, _ rhs: Lens<B,C>) -> Lens<A,C> {
    return Lens<A,C>(
        get: { rhs.get(lhs.get($0)) },
        set: { (c,a) in lhs.set(rhs.set(c, lhs.get(a)), a) }
    )
}

let combinedLens = compose(userAddressLens, addressStreetLens)
combinedLens.get(user1)
combinedLens.set("Francuska", user1)

func * <A, B, C>(lhs: Lens<A,B>, rhs: Lens<B,C>) -> Lens<A,C> {
    return compose(lhs, rhs)
}

let combinedLens2 = userAddressLens * addressStreetLens
combinedLens2.get(user1)
combinedLens2.set("Francuska", user1)





