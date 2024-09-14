import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

const int UNSELECTED = -1;
const int NONUMBER = 13*13*13*13 + 1; // unreachable number

class _MyAppState extends State<MyApp> {
  List<int> originalNums = [NONUMBER, NONUMBER, NONUMBER, NONUMBER];
  List<int> currentNums = [NONUMBER, NONUMBER, NONUMBER, NONUMBER];
  int numsSelected = 0;
  int selectedNumIndex = UNSELECTED;
  int selectedOpIndex = UNSELECTED;
  final List<bool> selectedOps = [false, false, false, false];

  void getNewNumbers() {
    Random rng = new Random();
    for (int i = 0; i < 4; i++) {
      currentNums[i] = rng.nextInt(13) + 1;
      originalNums[i] = currentNums[i];
    }
  }

  void resetSelection() {
    selectedNumIndex = UNSELECTED;
    selectedOpIndex = UNSELECTED;
    for (int i = 0; i < selectedOps.length; i++) {
      selectedOps[i] = false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNewNumbers();
  }

  Widget getButton(int index) {
    if (currentNums[index] == NONUMBER) {
      return emptySpace();
    } else {
      return numberButton(currentNums[index], index);
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Make 24',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white
            )
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getButton(0),
                  getButton(1)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getButton(2),
                  getButton(3)
                ],
              ),
              ToggleButtons(
                renderBorder: false,
                fillColor: Colors.white,
                isSelected: selectedOps,
                onPressed: (int index) {
                  setState(() {
                    if (selectedOpIndex == UNSELECTED) {
                      // no operation selected, select operation index
                      selectedOps[index] = true;
                      selectedOpIndex = index;
                    } else if (selectedOpIndex == index) {
                      // unselect the selected operation
                      selectedOps[index] = false;
                      selectedOpIndex = UNSELECTED;
                    } else {
                      // changing operation, first unselect original
                      selectedOps[selectedOpIndex] = false;
                      // select new
                      selectedOps[index] = true;
                      selectedOpIndex = index;
                    }
                  });
                },
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                      '+',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                        '-',
                        style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                        'x',
                        style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                        '÷',
                        style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.deepPurple,
                      child: IconButton(
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              getNewNumbers();
                              resetSelection();
                            });
                          },
                          icon: const Icon(Icons.restart_alt, size: 30)
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.deepPurple,
                      child: IconButton(
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              for (int i = 0; i < 4; i++) {
                                currentNums[i] = originalNums[i];
                              }
                              resetSelection();
                            });
                          },
                          icon: const Icon(Icons.restore_outlined, size: 30)
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  Widget numberButton(int n, int index) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        width: 170,
        height: 170,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              if (selectedNumIndex == UNSELECTED) {
                selectedNumIndex = index;
              } else if (selectedNumIndex == index) {
                // if select the selected number unselect
                selectedNumIndex = UNSELECTED;
              } else if (selectedOpIndex != UNSELECTED) {
                // check against division by zero
                if (!(selectedOpIndex == 3 && currentNums[index] == 0)) {
                  performOperation(selectedNumIndex, index, selectedOpIndex);
                  selectedNumIndex = index;
                  selectedOps[selectedOpIndex] = false;
                  selectedOpIndex = UNSELECTED;
                }
              } else if (selectedOpIndex == UNSELECTED) {
                selectedNumIndex = index;
              }
            });
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: index == selectedNumIndex ? Colors.deepPurple : Colors.grey,
          ),
          child: Text(
            '$n',
            style: const TextStyle(
                color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 60
            ),
          ),
        ),
      ),
    );
  }

  void performOperation(int originalNumIndex, int secondNumIndex, int opIndex) {
    int a = currentNums[originalNumIndex];
    int b = currentNums[secondNumIndex];
    currentNums[originalNumIndex] = NONUMBER;
    int newValue = switch (opIndex) {
      == 0 => a + b,
      == 1 => a-b,
      == 2 => a * b,
      == 3 => (a/b).floor(),
      _ => NONUMBER,
    };
    currentNums[secondNumIndex] = newValue;
  }

  Widget emptySpace() {
    return const Padding(
      padding: EdgeInsets.all(15),
      child: SizedBox(
        width: 170,
        height: 170,
      )
    );
  }

}