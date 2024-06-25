import XCTest

struct ArithmeticOperations {
    func addition(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 + num2)
        }
    }
    
    func subtraction(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            handler(num1 - num2)
        }
    }
    
    func multiplication(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
            handler(num1 * num2)
        }
    }
}

class MovieQuizTests: XCTestCase {
    func testAddiction() throws {
        let aristmeticOperations = ArithmeticOperations()
        let num1 = 10
        let num2 = 20
        
        aristmeticOperations.addition(num1: num1, num2: num2) { result in
            XCTAssertEqual(result, 3)
        }
    }
}
