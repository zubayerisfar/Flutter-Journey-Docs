class Encapsulation {
  int _variable = 0;

  Encapsulation();

  int get variable => _variable;

  set variable(int value) {
    _variable = value;
  }
}

class StaticDemoClass{
  static int counter = 0;
  StaticDemoClass(){
    counter++;
  }

}

class Student{
  String name;
  int age;

  Student(this.name, this.age);

  factory Student.guest() { 
    return Student('Default User', 18);
  }
}

class Database {
  static final Database _instance = Database._create(); 

  Database._create(){
    print("Database instance created");
  }

  factory Database() {
    return _instance;
  }

  void connect() {
    print('Connected to database');
  }
}

mixin Logger {
  void log(String message) {
    print("log: $message");
  }
}

class UserService with Logger {
  void createUser() {
    log("User created");
  }
}

extension NumberCheck on int {
  bool isEvenNumber() {
    return this % 2 == 0;
  }
}

class Student2 {
  String name;
  int age;

  Student2(this.name, this.age);

  @override
  bool operator == (Object obj) {
    return obj is Student2 && name == obj.name && age == obj.age; // is keyword checks if the object is of type Student2
  }

  @override
  String toString() {
    return "Student: $name, Age: $age";
  }
}


class Base{
  String name;
  int age;

  Base(this.name,this.age);

  Base.copyWith(Base obj) : name = obj.name, age = obj.age; // one liner function
}

void main() {

  //  -----------------STEP 1: Encapsulation------------------------

  Encapsulation encapsulation = Encapsulation();
  encapsulation.variable = 10; // setting the value using the setter
  print(encapsulation.variable); // getting the value using the getter

  // in an another file i cannot access the _variable directly because it is private
  // print(encapsulation._variable); // this will cause an error because _variable is private

  // -----------------STEP 2: Static Keyword------------------------
  StaticDemoClass obj1 = StaticDemoClass();
  StaticDemoClass obj2 = StaticDemoClass();
  StaticDemoClass obj3 = StaticDemoClass();

  print(StaticDemoClass.counter);  // will print 3 as three objects have been made

  // -----------------STEP 3: Factory Constructor------------------------

  Student student1 = Student('Isfar', 20);
  print('Student 1: Name: ${student1.name}, Age: ${student1.age}');
  Student student2 = Student.guest();
  print('Student 2: Name: ${student2.name}, Age: ${student2.age}');

  // -----------------STEP 4: Singleton Pattern------------------------
  var db1 = Database();
  var db2 = Database();
  var db3 = Database();

  print(db1 == db2); // true
  print(db2 == db3); // true

  db1.connect();

  // -----------------STEP 5: Mixins------------------------
  UserService userService = UserService();
  userService.createUser();

  // -----------------STEP 6: Extension Methods------------------------
  int number = 4;
  print(number.isEvenNumber()); // true

  // -----------------STEP 7: Operator Overloading------------------------

  Student2 studentA = Student2('Reduan', 22);
  Student2 studentB = Student2('Reduan', 22);
  print(studentA == studentB); // true
  print(studentA); // Student: Reduan, Age: 22

  // -----------------STEP 8: Copy Constructor------------------------

  Base base1 = Base('Zubayer', 30);
  Base base2 = Base.copyWith(base1);
  print(base1.name); // Zubayer
  print(base2.name); // Zubayer

}

