//
//  ArrayExtensions.swift
//  EZSwiftExtensions
//
//  Created by Goktug Yilmaz on 15/07/15.
//  Copyright (c) 2015 Goktug Yilmaz. All rights reserved.
//
import UIKit

public func ==<T: Equatable>(lhs: [T]?, rhs: [T]?) -> Bool {
    switch (lhs, rhs) {
    case (.some(let lhs), .some(let rhs)):
        return lhs == rhs
    case (.none, .none):
        return true
    default:
        return false
    }
}

extension Array {
    
    ///EZSE: Get a sub array from range of index
    public func get(at range:ClosedRange<Int>) -> Array {
        var subArray = Array()
        let lowerBound = range.lowerBound > 0 ? range.lowerBound : 0
        let upperBound = range.upperBound > self.count - 1 ? self.count - 1 : range.upperBound
        for index in lowerBound...upperBound {
            subArray.append(self[index])
        }
        return subArray
    }

    /// EZSE: Checks if array contains at least 1 item which type is same with given element's type
    public func containsType<T>(of element: T) -> Bool {
        let elementType = type(of: element)
        return first { type(of: $0) == elementType} != nil
    }

    /// EZSE: Decompose an array to a tuple with first element and the rest
    public func decompose() -> (head: Iterator.Element, tail: SubSequence)? {
        return (count > 0) ? (self[0], self[1..<count]) : nil
    }

    /// EZSE: Iterates on each element of the array with its index. (Index, Element)
    public func forEachEnumerated(_ body: @escaping (_ offset: Int, _ element: Element) -> ()) {
        self.enumerated().forEach(body)
    }

    /// EZSE: Gets the object at the specified index, if it exists.
    public func get(at index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }

    /// EZSE: Prepends an object to the array.
    public mutating func insertFirst(_ newElement: Element) {
        insert(newElement, at: 0)
    }

    /// EZSE: Returns a random element from the array.
    public func random() -> Element? {
        guard count > 0 else { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }

    /// EZSE: Reverse the given index. i.g.: reverseIndex(2) would be 2 to the last
    public func reverseIndex(_ index: Int) -> Int? {
        guard index >= 0 && index < count else { return nil }
        return Swift.max(self.count - 1 - index, 0)
    }

//    /// EZSE: Shuffles the array in-place using the Fisher-Yates-Durstenfeld algorithm.
//    public mutating func shuffle() {
//        guard self.count > 1 else { return }
//        var j: Int
//        for i in 0..<(self.count-2) {
//            j = Int(arc4random_uniform(UInt32(self.count - i)))
//            if i != i+j { swap(from: self[i] as! Int, to: self[i+j]) }
//        }
//    }
//
//    /// EZSE: Shuffles copied array using the Fisher-Yates-Durstenfeld algorithm, returns shuffled array.
//    public func shuffled() -> Array {
//        var result = self
//        result.shuffle()
//        return result
//    }

    /// EZSE: Returns an array with the given number as the max number of elements.
    public func takeMax(_ n: Int) -> Array {
        return Array(self[0..<Swift.max(0, Swift.min(n, count))])
    }

    /// EZSE: Checks if test returns true for all the elements in self
    public func testAll(_ body: @escaping (Element) -> Bool) -> Bool {
        return self.first { !body($0) } == nil
    }

    /// EZSE: Checks if all elements in the array are true or false
    public func testAll(is condition: Bool) -> Bool {
        return testAll { ($0 as? Bool) ?? !condition == condition }
    }
}

extension Array where Element: Equatable {

    /// EZSE: Checks if the main array contains the parameter array
    public func contains(_ array: [Element]) -> Bool {
        return array.testAll { self.index(of: $0) ?? -1 >= 0 }
    }

    /// EZSE: Checks if self contains a list of items.
    public func contains(_ elements: Element...) -> Bool {
        return elements.testAll { self.index(of: $0) ?? -1 >= 0 }
    }

    /// EZSE: Returns the indexes of the object
    public func indexes(of element: Element) -> [Int] {
        return self.enumerated().compactMap { ($0.element == element) ? $0.offset : nil }
    }

    /// EZSE: Returns the last index of the object
    public func lastIndex(of element: Element) -> Int? {
        return indexes(of: element).last
    }

    /// EZSE: Removes the first given object
    public mutating func removeFirst(_ element: Element) {
        guard let index = self.index(of: element) else { return }
        self.remove(at: index)
    }

    // EZSE: Removes all occurrences of the given object
    public mutating func removeAll(_ elements: Element...) {
        for element in elements {
            for index in self.indexes(of: element).reversed() {
                self.remove(at: index)
            }
        }
    }

    /// EZSE: Difference of self and the input arrays.
    public func difference(_ values: [Element]...) -> [Element] {
        var result = [Element]()
        elements: for element in self {
            for value in values {
                //  if a value is in both self and one of the values arrays
                //  jump to the next iteration of the outer loop
                if value.contains(element) {
                    continue elements
                }
            }
            //  element it's only in self
            result.append(element)
        }
        return result
    }

    /// EZSE: Intersection of self and the input arrays.
    public func intersection(_ values: [Element]...) -> Array {
        var result = self
        var intersection = Array()

        for (i, value) in values.enumerated() {
            //  the intersection is computed by intersecting a couple per loop:
            //  self n values[0], (self n values[0]) n values[1], ...
            if i > 0 {
                result = intersection
                intersection = Array()
            }

            //  find common elements and save them in first set
            //  to intersect in the next loop
            value.forEach { (item: Element) -> Void in
                if result.contains(item) {
                    intersection.append(item)
                }
            }
        }
        return intersection
    }

    /// EZSE: Union of self and the input arrays.
    public func union(_ values: [Element]...) -> Array {
        var result = self
        for array in values {
            for value in array {
                if !result.contains(value) {
                    result.append(value)
                }
            }
        }
        return result
    }

    /// EZSE: Returns an array consisting of the unique elements in the array
    public func unique() -> Array {
        return reduce([]) { $0.contains($1) ? $0 : $0 + [$1] }
    }
}
//MARK: - Json

public extension Array {
    public func jsonData(prettify: Bool = false) -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions()
        return try? JSONSerialization.data(withJSONObject: self, options: options)
    }
    
    /// SwifterSwift: JSON String from dictionary.
    ///
    /// - Parameter prettify: set true to prettify string (default is false).
    /// - Returns: optional JSON String (if applicable).
    public func jsonString(prettify: Bool = false) -> String? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions()
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: options)
        return jsonData?.string(encoding: .utf8)
    }
}

// MARK: - Methods (Integer)
public extension Array where Element: BinaryInteger {
    
    /// SwifterSwift: Sum of all elements in array.
    /// Returns: sum of the array's elements (Integer).
    public func sum() -> Element {
        // http://stackoverflow.com/questions/28288148/making-my-function-calculate-average-of-array-swift
        return reduce(0, +)
    }
    
}

// MARK: - Methods (FloatingPoint)
public extension Array where Element: FloatingPoint {
    
    /// SwifterSwift: Average of all elements in array.
    /// Returns: average of the array's elements (FloatingPoint).
    public func average() -> Element {
        // http://stackoverflow.com/questions/28288148/making-my-function-calculate-average-of-array-swift
        return isEmpty ? 0 : reduce(0, +) / Element(count)
    }
    
    /// SwifterSwift: Sum of all elements in array.
    /// Returns: sum of the array's elements (FloatingPoint).
    public func sum() -> Element {
        // http://stackoverflow.com/questions/28288148/making-my-function-calculate-average-of-array-swift
        return reduce(0, +)
    }
    
}

// MARK: - Methods
public extension Array {
    
    /// SwifterSwift: Element at the given index if it exists.
    ///
    /// - Parameter index: index of element.
    /// - Returns: optional element (if exists).
    public func item(at index: Int) -> Element? {
        guard startIndex..<endIndex ~= index else { return nil }
        return self[index]
    }
    
    /// SwifterSwift: Remove last element from array and return it.
    ///
    /// - Returns: last element in array (if applicable).
    @discardableResult public mutating func pop() -> Element? {
        return popLast()
    }
    
    /// SwifterSwift: Insert an element at the beginning of array.
    ///
    /// - Parameter newElement: element to insert.
    public mutating func prepend(_ newElement: Element) {
        insert(newElement, at: 0)
    }
    
    /// SwifterSwift: Insert an element to the end of array.
    ///
    /// - Parameter newElement: element to insert.
    public mutating func push(_ newElement: Element) {
        append(newElement)
    }
    
    /// SwifterSwift: Safely Swap values at index positions.
    ///
    /// - Parameters:
    ///   - index: index of first element.
    ///   - otherIndex: index of other element.
    public mutating func safeSwap(from index: Int, to otherIndex: Int)  {
        guard index != otherIndex,
            startIndex..<endIndex ~= index,
            startIndex..<endIndex ~= otherIndex else { return }
        
        self.swapAt(index, otherIndex)
    }
    
    /// SwifterSwift: Swap values at index positions.
    ///
    /// - Parameters:
    ///   - index: index of first element.
    ///   - otherIndex: index of other element.
    public mutating func swap(from index: Int, to otherIndex: Int)  {
        self.swapAt(index, otherIndex)
    }
    
    /// SwifterSwift: Get first index where condition is met.
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: first index where the specified condition evaluates to true. (optional)
    public func firstIndex(where condition: (Element) -> Bool) -> Int? {
        for (index, value) in lazy.enumerated() {
            if condition(value) { return index }
        }
        return nil
    }
    
    /// SwifterSwift: Get last index where condition is met.
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: last index where the specified condition evaluates to true. (optional)
    public func lastIndex(where condition: (Element) -> Bool) -> Int? {
        for (index, value) in lazy.enumerated().reversed() {
            if condition(value) { return index }
        }
        return nil
    }
    
    /// SwifterSwift: Get all indices where condition is met.
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: all indices where the specified condition evaluates to true. (optional)
    public func indices(where condition: (Element) -> Bool) -> [Int]? {
        var indicies: [Int] = []
        for (index, value) in lazy.enumerated() {
            if condition(value) { indicies.append(index) }
        }
        return indicies.isEmpty ? nil : indicies
    }
    
    /// SwifterSwift: Check if all elements in array match a conditon.
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: true when all elements in the array match the specified condition.
    public func all(match condition: @escaping (Element) -> Bool) -> Bool {
        return !contains { !condition($0) }
    }
    
    /// SwifterSwift: Check if no elements in array match a conditon.
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: true when no elements in the array match the specified condition.
    public func none(match condition: @escaping (Element) -> Bool) -> Bool {
        return !contains { condition($0) }
    }
    
    /// SwifterSwift: Get last element that satisfies a conditon.
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: the last element in the array matching the specified condition. (optional)
    public func last(where condition: (Element) -> Bool) -> Element? {
        for element in reversed() where condition(element) { return element }
        return nil
    }
    
    /// SwifterSwift: Filter elements based on a rejection condition.
    ///
    /// - Parameter condition: to evaluate the exclusion of an element from the array.
    /// - Returns: the array with rejected values filtered from it.
    public func reject(where condition: (Element) -> Bool) -> [Element] {
        return filter { return !condition($0) }
    }
    
    /// SwifterSwift: Get element count based on condition.
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: number of times the condition evaluated to true.
    public func count(where condition: (Element) -> Bool) -> Int {
        var count = 0
        for element in self {
            if condition(element) { count += 1 }
        }
        return count
    }
    
    /// SwifterSwift: Iterate over a collection in reverse order. (right to left)
    ///
    /// - Parameter body: a closure that takes an element of the array as a parameter.
    public func forEachReversed(body: (Element) -> Void) {
        reversed().forEach { body($0) }
    }
    
    
    /// SwifterSwift: Calls given closure with each element where condition is true.
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Parameter body: a closure that takes an element of the array as a parameter.
    public func forEach(where condition: (Element) -> Bool, body: (Element) -> Void) {
        for element in self where condition(element) {
            body(element)
        }
    }
    
    /// SwifterSwift: Reduces an array while returning each interim combination.
    ///
    /// - Parameter initial: initial value.
    /// - Parameter next: closure that combines the accumulating value and next element of the array.
    /// - Returns: an array of the final accumulated value and each interim combination.
    public func accumulate<U>(initial: U, next: (U, Element) -> U) -> [U] {
        var runningTotal = initial
        return map { element in
            runningTotal = next(runningTotal, element)
            return runningTotal
        }
    }
    
    /// SwifterSwift: Keep elements of Array while condition is true.
    ///
    /// - Parameter condition: condition to evaluate each element against.
    public mutating func keep(while condition: (Element) -> Bool) {
        for (index, element) in lazy.enumerated() {
            if !condition(element) {
                self = Array(self[startIndex..<index])
                break
            }
        }
    }
    
    /// SwifterSwift: Drop elements of Array while condition is true.
    ///
    /// - Parameter condition: condition to evaluate each element against.
    public mutating func drop(while condition: (Element) -> Bool) {
        for (index, element) in lazy.enumerated() {
            if !condition(element) {
                self = Array(self[index..<endIndex])
                return
            }
        }
        self = []
    }
    
    /// SwifterSwift: Take element of Array while condition is true.
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: All elements up until condition evaluates to false.
    public func take(while condition: (Element) -> Bool) -> [Element] {
        for (index, element) in lazy.enumerated() {
            if !condition(element) {
                return Array(self[startIndex..<index])
            }
        }
        return self
    }
    
    /// SwifterSwift: Skip elements of Array while condition is true.
    ///
    /// - Parameter condition: condition to eveluate each element against.
    /// - Returns: All elements after the condition evaluates to false.
    public func skip(while condition: (Element) -> Bool) -> [Element] {
        for (index, element) in lazy.enumerated() {
            if !condition(element) {
                return Array(self[index..<endIndex])
            }
        }
        return [Element]()
    }
}


// MARK: - Methods (Equatable)
public extension Array where Element: Equatable {
    
    /// SwifterSwift: Shuffle array. (Using Fisher-Yates Algorithm)
    public mutating func shuffle() {
        //http://stackoverflow.com/questions/37843647/shuffle-array-swift-3
        guard count > 1 else { return }
        for index in startIndex..<endIndex - 1 {
            let randomIndex = Int(arc4random_uniform(UInt32(endIndex - index))) + index
            if index != randomIndex { self.swapAt(index, randomIndex) }
        }
    }
    
    /// SwifterSwift: Shuffled version of array. (Using Fisher-Yates Algorithm)
    /// Returns: the array with its elements shuffled.
    public func shuffled() -> [Element] {
        var array = self
        array.shuffle()
        return array
    }
    
    /// SwifterSwift: Remove all instances of an item from array.
    ///
    /// - Parameter item: item to remove.
    public mutating func remove(element item: Element) {
        self = filter { $0 != item }
    }
    
    
    /// SwifterSwift: Remove all instances of an item from array.
    ///
    /// - Parameter item: item to remove.
    public mutating func removeAll(_ item: Element) {
        self = filter { $0 != item }
    }
    
    /// SwifterSwift: Remove all instances contained in items parameter from array.
    ///
    /// - Parameter items: items to remove.
    public mutating func removeAll(_ items: [Element]) {
        guard !items.isEmpty else { return }
        self = filter { !items.contains($0) }
    }
    
    /// SwifterSwift: Remove all duplicate elements from Array.
    public mutating func removeDuplicates() {
        // Thanks to https://github.com/sairamkotha for improving the method
        self = reduce([]){ $0.contains($1) ? $0 : $0 + [$1] }
    }
    
    /// SwifterSwift: Return array with all duplicate elements removed.
    /// - Returns: An array of unique elements.
    public func duplicatesRemoved() -> [Element] {
        // Thanks to https://github.com/sairamkotha for improving the property
        return reduce([]){ ($0 as [Element]).contains($1) ? $0 : $0 + [$1] }
    }
    
    /// SwifterSwift: First index of a given item in an array.
    ///
    /// - Parameter item: item to check.
    /// - Returns: first index of item in array (if exists).
    public func firstIndex(of item: Element) -> Int? {
        for (index, value) in lazy.enumerated() {
            if value == item { return index }
        }
        
        return nil
    }
}
