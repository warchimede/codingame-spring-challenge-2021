import Glibc
import Foundation

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

////////////////////////////////////////////////////////////////////////////
enum Action: ExpressibleByStringLiteral, CustomStringConvertible, Equatable {
    private static let COMPLETE = "COMPLETE"
    private static let GROW = "GROW"
    private static let SEED = "SEED"
    private static let WAIT = "WAIT"

    case complete(Int)
    case grow(Int)
    case seed(source: Int, target: Int)
    case wait

    init(stringLiteral value: String) {
        let params = value.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: false)

        switch "\(params[0])" {
            case Self.COMPLETE: self = .complete(Int(params[1])!)
            case Self.GROW: self = .grow(Int(params[1])!)
            case Self.SEED: self = .seed(source: Int(params[1])!, target: Int(params[2])!)
            default: self = .wait
        }
    }

    var description: String {
        switch self {
            case .complete(let index): return "\(Self.COMPLETE) \(index)"
            case .grow(let source): return "\(Self.GROW) \(source)"
            case .seed(source: let source, target: let target): return "\(Self.SEED) \(source) \(target)"
            case .wait: return Self.WAIT
        }
    }
}

enum TreeSize: Int {
    case seed = 0
    case small
    case medium
    case big
}

struct Tree {
    let cellIndex: Int
    let isDormant: Bool
    let isMine: Bool
    let size: TreeSize
}

enum Richness: Int {
    case unusable = 0
    case low
    case medium
    case high
}

struct Cell {
    let index: Int
    let richness: Richness
    let neigh0: Int
    let neigh1: Int
    let neigh2: Int
    let neigh3: Int
    let neigh4: Int
    let neigh5: Int

    func isNeigh(cell: Cell) -> Bool {
        return [neigh0, neigh1, neigh2, neigh3, neigh4, neigh5].contains(cell.index)
    }
}

let centerIdx = 0
let cornersIdx = [19, 22, 25, 28, 31, 34]

// GROW
func growActions(from possibleActions: [Action]) -> [Action] {
    return possibleActions.filter {
        switch $0 {
            case .grow(_): return true
            default: return false
        }
    }
    .sorted {
        if case let .grow(idx0) = $0,
            case let .grow(idx1) = $1 {
                return idx0 < idx1
        }
        return false
    }
}

func growCenter(center: Int = centerIdx, actions: [Action]) -> Action? {
    return actions.first { return $0 == .grow(centerIdx) }
}

func growCorner(size: TreeSize, corners: [Int] = cornersIdx, trees: [Tree], actions: [Action]) -> Action? {
    return actions.first {
        if case let .grow(target) = $0 {
            let isCorner = corners.contains(target)
            let isRightSize = trees.first { $0.cellIndex == target && $0.size == size } != nil
            return isCorner && isRightSize
        }
        return false
    }
}

func growSize(_ size: TreeSize, trees: [Tree], actions: [Action]) -> Action? {
    return actions.first {
        if case let .grow(target) = $0 {
            let isRightSize = trees.first { $0.cellIndex == target && $0.size == size } != nil
            return isRightSize
        }
        return false
    }
}

// SEED
func seedActions(from possibleActions: [Action]) -> [Action] {
    return possibleActions.filter {
        switch $0 {
            case .seed(source: _, target: _): return true
            default: return false
        }
    }
    .sorted {
        if case let .seed(source: _, target: target0) = $0,
           case let .seed(source: _, target: target1) = $1 {
            return target0 < target1
        }
        return false
    }
}

func seedCenter(center: Int = centerIdx, actions: [Action]) -> Action? {
    actions.first {
        if case .seed(source: _, target: center) = $0 { return true }
        return false
    }
}

func seedCorner(cells: [Cell], corners: [Int] = cornersIdx, actions: [Action]) -> Action? {
    return actions.first {
        if case let .seed(source: source, target: target) = $0 {
            let sourceCell = cells[source]
            let targetCell = cells[target]
            return corners.contains(target) && !sourceCell.isNeigh(cell: targetCell)
        }
        return false
    }
}

func seedNoNeigh(cells: [Cell], trees: [Tree], actions: [Action]) -> Action? {
    let myTrees = trees.filter { $0.isMine }

    return actions.first {
        if case let .seed(source: _, target: target) = $0 {
            let targetCell = cells[target]

            return myTrees.reduce(true, { res, tree in
                let cell = cells[tree.cellIndex]
                return res && !cell.isNeigh(cell: targetCell)
            })
        }
        return false
    }
}

// COMPLETE
func completeActions(from possibleActions: [Action]) -> [Action] {
    return possibleActions.filter {
        switch $0 {
            case .complete(_): return true
            default: return false
        }
    }
    .sorted {
        if case let .complete(idx0) = $0,
            case let .complete(idx1) = $1 {
                return idx0 < idx1
        }
        return false
    }
}

// EVALUATIONS
func day3(cells: [Cell], trees: [Tree], grow: [Action], seed: [Action], sun: Int) -> Action {
    if let action = grow.first { return action }

    guard sun >= 3 else { return .wait }

    if trees.filter({ $0.isMine && $0.size == .seed }).count == 0,
        let action = seedCorner(cells: cells, actions: seed) {
        return action
    }

    if let action = seed.first { return action }

    return .wait
}

func day10(cells: [Cell], trees: [Tree], complete: [Action], grow: [Action], seed: [Action]) -> Action {
    if trees.filter({ $0.isMine && $0.size == .big }).count > 2,
        let action = complete.first {
        return action
    }

    return grow.first
    ?? seedNoNeigh(cells: cells, trees: trees, actions: seed)
    ?? .wait
}

func day11(cells: [Cell], trees: [Tree], complete: [Action], grow: [Action], seed: [Action]) -> Action {
    if trees.filter({ $0.isMine && $0.size == .big }).count > 2,
        let action = complete.first {
        return action
    }

    return grow.first
    ?? seedNoNeigh(cells: cells, trees: trees, actions: seed)
    ?? .wait
}

func day12(cells: [Cell], trees: [Tree], complete: [Action], grow: [Action], seed: [Action]) -> Action {
    if trees.filter({ $0.isMine && $0.size == .big }).count > 2,
        let action = complete.first {
        return action
    }

    return grow.first
    ?? seedNoNeigh(cells: cells, trees: trees, actions: seed)
    ?? .wait
}

func day13(cells: [Cell], trees: [Tree], complete: [Action], grow: [Action], seed: [Action]) -> Action {
    if let action = growSize(.medium, trees: trees, actions: grow) { return action }

    if trees.filter({ $0.isMine && $0.size == .big }).count > 2,
        let action = complete.first {
        return action
    }

    return grow.first
    ?? seedNoNeigh(cells: cells, trees: trees, actions: seed)
    ?? .wait
}

func computeAction(possibleActions: [Action], trees: [Tree], cells: [Cell], day: Int, sun: Int) -> Action {
    let grow = growActions(from: possibleActions)
    let seed = seedActions(from: possibleActions)
    let complete = completeActions(from: possibleActions)

    switch day {
    case 0: return .wait
    case 1: return grow.first ?? .wait
    case 2: return grow.first ?? seed.first ?? .wait
    case 3: return day3(cells: cells, trees: trees, grow: grow, seed: seed, sun: sun)
    case 4: return grow.first ?? .wait
    case 5: return growSize(.medium, trees: trees, actions: grow)
                ?? grow.first
                ?? .wait
    case let d where d <= 9: return grow.first
                                ?? seedNoNeigh(cells: cells, trees: trees, actions: seed)
                                ?? .wait
    case let d where d <= 12: return day10(cells: cells, trees: trees, complete: complete, grow: grow, seed: seed)
    case let d where d <= 14: return day13(cells: cells, trees: trees, complete: complete, grow: grow, seed: seed)
    case 15: return grow.first ?? .wait
    case 16: return day13(cells: cells, trees: trees, complete: complete, grow: grow, seed: seed)
    case 17: return grow.first ?? .wait
    case 18: return day13(cells: cells, trees: trees, complete: complete, grow: grow, seed: seed)
    case 19, 20: return grow.first ?? .wait
    default: return complete.first ?? grow.first ?? .wait
    }
}

////////////////////////////////////////////////////////////////////////////

/**
 * Auto-generated code below aims at helping you parse
 * the standard input according to the problem statement.
 **/

let numberOfCells = Int(readLine()!)! // 37
var cells = [Cell]()
if numberOfCells > 0 {
    for i in 0...(numberOfCells-1) {
        let inputs = (readLine()!).split(separator: " ").map(String.init)
        let index = Int(inputs[0])! // 0 is the center cell, the next cells spiral outwards
        let richness = Int(inputs[1])! // 0 if the cell is unusable, 1-3 for usable cells
        let neigh0 = Int(inputs[2])! // the index of the neighbouring cell for each direction
        let neigh1 = Int(inputs[3])!
        let neigh2 = Int(inputs[4])!
        let neigh3 = Int(inputs[5])!
        let neigh4 = Int(inputs[6])!
        let neigh5 = Int(inputs[7])!
        let cell = Cell(index: index, richness: Richness(rawValue: richness)!,
            neigh0: neigh0, neigh1: neigh1, neigh2: neigh2, neigh3: neigh3, neigh4: neigh4, neigh5: neigh5)
        cells.append(cell)
    }
}

// game loop
while true {
    let day = Int(readLine()!)! // the game lasts 24 days: 0-23
    let sunDirection = day % 6
    let nutrients = Int(readLine()!)! // the base score you gain from the next COMPLETE action
    let inputs = (readLine()!).split(separator: " ").map(String.init)
    let sun = Int(inputs[0])! // your sun points
    let score = Int(inputs[1])! // your current score
    let inputs2 = (readLine()!).split(separator: " ").map(String.init)
    let oppSun = Int(inputs2[0])! // opponent's sun points
    let oppScore = Int(inputs2[1])! // opponent's score
    let oppIsWaiting = inputs2[2] != "0" // whether your opponent is asleep until the next day
    let numberOfTrees = Int(readLine()!)! // the current amount of trees
    var trees = [Tree]()
    if numberOfTrees > 0 {
        for i in 0...(numberOfTrees-1) {
            let inputs = (readLine()!).split(separator: " ").map(String.init)
            let cellIndex = Int(inputs[0])! // location of this tree
            let size = Int(inputs[1])! // size of this tree: 0-3
            let isMine = inputs[2] != "0" // 1 if this is your tree
            let isDormant = inputs[3] != "0" // 1 if this tree is dormant
            trees.append(Tree(cellIndex: cellIndex, isDormant: isDormant, isMine: isMine, size: TreeSize(rawValue: size)!))
        }
    }
    let numberOfPossibleActions = Int(readLine()!)! // all legal actions
    var possibleActions: [Action] = []
    if numberOfPossibleActions > 0 {
        for i in 0...(numberOfPossibleActions-1) {
            let possibleAction = readLine()! // try printing something from here to start with
            let action = Action(stringLiteral: possibleAction)
            possibleActions.append(action)
        }
    }

    // Write an action using print("message...")
    // To debug: print("Debug messages...", to: &errStream)
    let action = computeAction(possibleActions: possibleActions, trees: trees, cells: cells, day: day, sun: sun)

    // GROW cellIdx | SEED sourceIdx targetIdx | COMPLETE cellIdx | WAIT <message>
    print(action.description)
}
