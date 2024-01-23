import 'package:flutter/material.dart';
import 'package:sqlflite_f_app/sqlfliteDB.dart';

TextEditingController dogName = TextEditingController();
TextEditingController dogAge = TextEditingController();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SqlDb sqlDb = SqlDb();

  Future<List<Map>> readData() async {
    List<Map> response = await sqlDb.readDate("SELECT * FROM dogs");
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          "Dog Database",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        )),
        backgroundColor: const Color.fromRGBO(98, 0, 238, 1),
        elevation: 5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(1, 135, 134, 0.3),
        ),
        child: FutureBuilder(
          builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: Color.fromRGBO(98, 0, 238, 1),
                          child: IconButton(
                              onPressed: () => _showDetails(
                                    snapshot.data![index]['dogname'],
                                    snapshot.data![index]['dogage'],
                                  ),
                              icon: Icon(Icons.pets, color: Colors.white))),
                      title: IconButton(
                        onPressed: () =>
                            _deleteDog(snapshot.data![index]['id']),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _editDog(
                              snapshot.data![index]['id'],
                              snapshot.data![index]['dogname'],
                              snapshot.data![index]['dogage'],
                            ),
                            icon: const Icon(Icons.edit,
                                color: Color.fromRGBO(187, 134, 252, 1)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          future: readData(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          _addNewDog();
        },
      ),
    );
  }

  Future _showDetails(dogName, dogAge) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Show Details"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  margin: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    "Dog Name: $dogName",
                    style: TextStyle(fontSize: 22),
                  )),
              Container(
                  margin: const EdgeInsets.only(bottom: 15.0),
                  child:
                      Text("Dog Age: $dogAge", style: TextStyle(fontSize: 22))),
            ])));
  }

  Future _addNewDog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Add new dog"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 15.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Dog Name",
                    filled: true,
                    fillColor: Color.fromRGBO(211, 211, 211, 1),
                  ),
                  controller: dogName,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Dog Age",
                    filled: true,
                    fillColor: Color.fromRGBO(211, 211, 211, 1),
                  ),
                  controller: dogAge,
                ),
              ),
            ],
          ),
          actions: [
            MaterialButton(
              color: const Color.fromRGBO(187, 134, 252, 1),
              onPressed: () {
                String dogName1 = dogName.text;
                String dogAge1 = dogAge.text;
                setState(() {
                  sqlDb.insertDate(
                    "INSERT INTO 'dogs' ('dogname', 'dogage') VALUES ('$dogName1', '$dogAge1')",
                  );
                });
                dogName.clear();
                dogAge.clear();
                Navigator.of(context).pop();
              },
              child: const Text("Insert Data"),
            ),
          ],
        ),
      );

  Future _editDog(int id, String currentName, String currentAge) {
    dogName.text = currentName;
    dogAge.text = currentAge;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Dog"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 15.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: "Dog Name",
                  filled: true,
                  fillColor: Color.fromRGBO(211, 211, 211, 1),
                ),
                controller: dogName,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: "Dog Age",
                  filled: true,
                  fillColor: Color.fromRGBO(211, 211, 211, 1),
                ),
                controller: dogAge,
              ),
            ),
          ],
        ),
        actions: [
          MaterialButton(
            color: const Color.fromRGBO(187, 134, 252, 1),
            onPressed: () {
              String dogName1 = dogName.text;
              String dogAge1 = dogAge.text;
              setState(() {
                sqlDb.updateDate(
                  "UPDATE dogs SET 'dogage' = '$dogAge1' ,'dogname' = '$dogName1' WHERE id = $id",
                );
              });

              dogName.clear();
              dogAge.clear();
              Navigator.of(context).pop();
            },
            child: const Text("Update Data"),
          ),
        ],
      ),
    );
  }

  Future _deleteDog(int id) async {
    setState(() {
      sqlDb.deleteDate("DELETE FROM 'dogs' WHERE id = $id");
    });
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFloatingActionButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      label: const Icon(
        Icons.add,
      ),
      backgroundColor: const Color.fromRGBO(187, 134, 252, 1),
      shape: const CircleBorder(),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}
