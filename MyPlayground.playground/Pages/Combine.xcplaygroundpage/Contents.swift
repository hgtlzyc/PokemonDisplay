import Foundation
import Combine

/*
 Created by lijia xu
    
*/

//Make tasks trackable, nonblocking and individually cancelable with generics and protocols


typealias CancelableIntTaskType = CancelableTask<AnyPublisher<Int, Never>>
var cancelableIntTasks = CancelableIntTaskType()

let taskIdArray = [
    startFizzBuzzTask(50, -80, &cancelableIntTasks),
    startOddEvenTask(600, 1000, &cancelableIntTasks),
    startFizzBuzzTask(600, 1000, &cancelableIntTasks),
    startOddEvenTask(600, 1000, &cancelableIntTasks),
    startFizzBuzzTask(2000, 2600, &cancelableIntTasks)
]

checkAllTasksStarted(taskIdArray)

DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    if let id = taskIdArray.compactMap({$0}).first {
        cancelableIntTasks.cancelTaskWithID(id)
    }
}

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    cancelableIntTasks.cancelAll()
}

//Odd Even/ *id E41 STARTED
//FizzBuzz/ *id 3C1 STARTED
//Odd Even/ *id 2D8 STARTED
//FizzBuzz/ *id C19 STARTED
//5 tasks initiated 4 started
//task at index 0 failed
//FizzBuzz/ id 3C1 fizzbuzz at 600 progress 0.0%
//Odd Even/ id E41 Even at 600 progress 0.0%
//Odd Even/ id 2D8 Even at 600 progress 0.0%
//FizzBuzz/ id C19 buzz at 2000 progress 0.0%
//Odd Even/ **E41 CANCELED at 600 progress: 0.0%
//Odd Even/ id 2D8 Odd at 601 progress 1.0%
//FizzBuzz/ id C19 fizz at 2001 progress 1.0%
//Odd Even/ id 2D8 Even at 602 progress 1.0%
//FizzBuzz/ id 3C1 fizz at 603 progress 1.0%
//Odd Even/ id 2D8 Odd at 603 progress 1.0%
//Odd Even/ **2D8 CANCELED at 603 progress: 1.0%
//FizzBuzz/ **3C1 CANCELED at 603 progress: 1.0%
//FizzBuzz/ **C19 CANCELED at 2003 progress: 1.0%

//Task related
func generateIntInRangePublisher(_ fromIndex: Int,_ toIndex: Int) -> AnyPublisher<Int, Never> {
    Array<Int>(fromIndex ..< toIndex).publisher
        .eraseToAnyPublisher()
}


func startOddEvenTask(_ fromIndex: Int,_ toIndex: Int,_ tasksContainer: inout CancelableIntTaskType) -> UUID? {
    guard toIndex > fromIndex else { return nil}
    let id = UUID()
    let tracker = IntInRangeProgressTracker(fromIndex, toIndex, uuid: id)
    
    tasksContainer.startTask(
        taskPublisher: generateIntInRangePublisher(fromIndex, toIndex),
        tracker: tracker,
        displayHelper: OddEvenDisplayHelper()
    ) { result in
        switch result {
        case .failure(let printerError):
            print(printerError.description)
        case .success(let finishedIndex):
            print("Odd Even finished at \(finishedIndex)")
        }
    }
    
    return id
}





func startFizzBuzzTask(_ fromIndex: Int,_ toIndex: Int,_ tasksContainer: inout CancelableIntTaskType) -> UUID?{
    guard toIndex > fromIndex else { return nil}
    let id = UUID()
    let tracker = IntInRangeProgressTracker(fromIndex, toIndex, uuid: id)
    
    tasksContainer.startTask(
        taskPublisher: generateIntInRangePublisher(fromIndex, toIndex),
        tracker: tracker,
        displayHelper: FizzBuzzDisplayHelper()
    ) { result in
        switch result {
        case .failure(let printerError):
            print(printerError.description)
        case .success(let finishedIndex):
            print("FizzBuzz finished at \(finishedIndex)")
        }
    }
    
    return id
}

struct IntInRangeProgressTracker: ProgressIndicable {
    var uuid: UUID
    let startValue: Int
    let toValue: Int
    var currentValue: Int
    
    init(_ startValue: Int,_ toValue: Int, uuid: UUID ) {
        self.startValue = startValue
        self.currentValue = startValue
        self.toValue = toValue <= startValue ? startValue + 1 : toValue
        self.uuid = uuid
    }
    
    var currentProgress: Double {
        Double(currentValue - startValue) / Double(toValue - startValue)
            * 100.0
    }
}

//Generic CancelableTask Container related

class CancelableTask<P: Publisher>{
    private var subscriptions = [UUID : AnyCancellable]()
    //tracker’s associated type restricted to match publisher’s output type
    func startTask<T: ProgressIndicable> (
        taskPublisher: P,
        tracker: T,
        displayHelper: CancelableTaskDisplayHelper? = nil,
        handler: @escaping (_ result: Result<P.Output,CancelableTaskError>) -> Void
    ) -> Void where P.Output == T.ValueType {
        var tracker = tracker
        let id = tracker.uuid.uuidString.prefix(3)
        
        //slow down for testing
        let cancelableToken = taskPublisher
            .flatMap(maxPublishers: .max(1)) { val in
                Just(val).delay(for: .seconds(0.1), scheduler: DispatchQueue.main)
            }
            .subscribe(on: DispatchQueue.global(qos: .background))
            .handleEvents(
                receiveSubscription: { _ in
                    if let str = displayHelper?
                        .stringBasedOnTrackerEvent(tracker, .started, 3) {
                            print(str)
                        }
                },
                receiveOutput: { value in
                    tracker.currentValue = value
                    if let str = displayHelper?
                        .stringBasedOnTrackerEvent(tracker, .updateCurrent, 3){
                            print(str)
                        }
                },
                receiveCancel: {
                    handler(
                        .failure(
                            .subscriptionError(
                                displayHelper?.stringBasedOnTrackerEvent(tracker, .canceled, 3) ?? "\(id) cancelled"
                            )
                        )
                    )
                }
            )
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    handler(.success(tracker.currentValue))
                case .failure(let error):
                    handler(.failure(.publisherError(error)))
                }
            } receiveValue: { _ in }
        
        subscriptions[tracker.uuid] = cancelableToken
    }
    
    @discardableResult
    func cancelTaskWithID(_ id: UUID) -> Bool{
        if let task = subscriptions[id] {
            task.cancel()
            subscriptions.removeValue(forKey: id) != nil
            return true
        }
        return false
    }
    
    func cancelAll() {
        subscriptions.forEach{ $0.value.cancel()}
    }
}

enum CancelableTaskError: Error {
    case subscriptionError(String)
    case publisherError(Error)
    
    var description: String {
        switch self {
        case .subscriptionError(let description):
            return description
        case .publisherError(let description):
            return description.localizedDescription
        }
    }
}

protocol ProgressIndicable {
    associatedtype ValueType
    var uuid: UUID { get }
    var currentValue: ValueType {get set}
    var startValue: ValueType { get }
    var toValue: ValueType { get }
    var currentProgress: Double {get}
    
}

//helper functions
enum TasksFailureError: Error {
    case noIdAtIndexs([Int])
}

@discardableResult
func checkAllTasksStarted(_ tasksIdArray: [UUID?], displayLog: Bool = true) -> Result<Int,TasksFailureError> {
    let successedArray = taskIdArray.compactMap{$0}
    let isAllSuccess = taskIdArray.count == successedArray.count ? true : false
    var result: Result<Int,TasksFailureError>
    
    switch isAllSuccess {
    case true:
        result = .success(tasksIdArray.count)
    case false:
        let failedIndexes = tasksIdArray.enumerated().filter{$0.1 == nil}.map{$0.0}
        result = .failure(.noIdAtIndexs(failedIndexes))
    }
    
    guard displayLog else { return result }

    switch result {
    case .success(let total):
        print("All \(total) tasks started")
    case .failure(let error):
        switch error {
        case .noIdAtIndexs(let indexes):
            print("\(taskIdArray.count) tasks initiated \(successedArray.count) started")
            indexes.forEach{ print("task at index \($0) failed") }
        }
    }
    
    return result
}

enum TrackerEvent {
    case started
    case canceled
    case updateCurrent
}

protocol CancelableTaskDisplayHelper {
   func stringBasedOnTrackerEvent<T: ProgressIndicable> (_ tracker: T, _ eventType: TrackerEvent, _ prefix: Int) -> String?
}

struct OddEvenDisplayHelper: CancelableTaskDisplayHelper {
    
    func stringBasedOnTrackerEvent<T: ProgressIndicable> (_ tracker: T, _ eventType: TrackerEvent, _ prefix: Int ) -> String? {
        guard prefix > 0 else { return "id displayPrefix error"}
        
        let displayID = tracker.uuid.uuidString.prefix(prefix)
        
        var str = "/Odd Even/ "
        
        switch eventType {
        case .started:
            return str + "*id " + displayID + " STARTED"
        case .updateCurrent:
            guard let number = tracker.currentValue as? Int else {
                return str + "id:" + displayID + " val: \(tracker.currentValue)"
                    + " progress \(tracker.currentProgress.rounded(.up))%"
            }
            switch number.isMultiple(of: 2) {
            case true:
                str += "id \(displayID) Even at \(number)"
            case false:
                str += "id \(displayID) Odd at \(number)"
            }
            return str + " progress \(tracker.currentProgress.rounded(.up))%"
        case .canceled:
            return str + "**\(displayID) CANCELED at \(tracker.currentValue)"
                + " progress: \(tracker.currentProgress.rounded(.up))%"
        }
        
    }
}



struct FizzBuzzDisplayHelper: CancelableTaskDisplayHelper {
    
    func stringBasedOnTrackerEvent<T: ProgressIndicable> (_ tracker: T, _ eventType: TrackerEvent, _ prefix: Int ) -> String? {
        guard prefix > 0 else { return "id displayPrefix error"}
        
        let displayID = tracker.uuid.uuidString.prefix(prefix)
        var str = "/FizzBuzz/ "
        
        switch eventType {
        case .started:
            return str + "*id " + displayID + " STARTED"
        case .updateCurrent:
            guard let number = tracker.currentValue as? Int else {
                return str + "id:" + displayID + " val: \(tracker.currentValue)"
                    + " progress \(tracker.currentProgress.rounded(.up))%"
            }
            switch (number.isMultiple(of: 3), number.isMultiple(of: 5) ) {
            case (true, true):
                str += "id \(displayID) fizzbuzz at \(number)"
            case (true, false):
                str += "id \(displayID) fizz at \(number)"
            case (false, true):
                str += "id \(displayID) buzz at \(number)"
            case (false, false):
                return nil
            }
            return str + " progress \(tracker.currentProgress.rounded(.up))%"
        case .canceled:
            return str + "**\(displayID) CANCELED at \(tracker.currentValue)"
                + " progress: \(tracker.currentProgress.rounded(.up))%"
        }
        
    }
}
