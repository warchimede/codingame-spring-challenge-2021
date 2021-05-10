import Glibc
import Foundation

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

////////////////////////////////////////////////////////////////////////////
enum Action: ExpressibleByStringLiteral, CustomStringConvertible {
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
}

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

func computeAction(possibleActions: [Action], day: Int) -> Action {
    let grow = growActions(from: possibleActions)
    let seed = seedActions(from: possibleActions)
    let complete = completeActions(from: possibleActions)

    if day <= 18 {
        return grow.first ?? seed.first ?? .wait
    } else {
        return complete.first ?? grow.first ?? seed.first ?? .wait
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
    let action = computeAction(possibleActions: possibleActions, day: day)

    // GROW cellIdx | SEED sourceIdx targetIdx | COMPLETE cellIdx | WAIT <message>
    print(action.description)
}
