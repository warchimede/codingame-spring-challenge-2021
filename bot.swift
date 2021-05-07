import Glibc
import Foundation

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}
public var errStream = StderrOutputStream()

/**
 * Auto-generated code below aims at helping you parse
 * the standard input according to the problem statement.
 **/

let numberOfCells = Int(readLine()!)! // 37
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
    }
}

// game loop
while true {
    let day = Int(readLine()!)! // the game lasts 24 days: 0-23
    let nutrients = Int(readLine()!)! // the base score you gain from the next COMPLETE action
    let inputs = (readLine()!).split(separator: " ").map(String.init)
    let sun = Int(inputs[0])! // your sun points
    let score = Int(inputs[1])! // your current score
    let inputs2 = (readLine()!).split(separator: " ").map(String.init)
    let oppSun = Int(inputs2[0])! // opponent's sun points
    let oppScore = Int(inputs2[1])! // opponent's score
    let oppIsWaiting = inputs2[2] != "0" // whether your opponent is asleep until the next day
    let numberOfTrees = Int(readLine()!)! // the current amount of trees
    if numberOfTrees > 0 {
        for i in 0...(numberOfTrees-1) {
            let inputs = (readLine()!).split(separator: " ").map(String.init)
            let cellIndex = Int(inputs[0])! // location of this tree
            let size = Int(inputs[1])! // size of this tree: 0-3
            let isMine = inputs[2] != "0" // 1 if this is your tree
            let isDormant = inputs[3] != "0" // 1 if this tree is dormant
        }
    }
    let numberOfPossibleActions = Int(readLine()!)! // all legal actions
    if numberOfPossibleActions > 0 {
        for i in 0...(numberOfPossibleActions-1) {
            let possibleAction = readLine()! // try printing something from here to start with
        }
    }

    // Write an action using print("message...")
    // To debug: print("Debug messages...", to: &errStream)


    // GROW cellIdx | SEED sourceIdx targetIdx | COMPLETE cellIdx | WAIT <message>
    print("WAIT")
}
