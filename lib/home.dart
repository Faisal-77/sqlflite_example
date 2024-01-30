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
  int selectedIndex = -1;
  Future<List<Map>> readData() async {
    List<Map> response = await sqlDb.readDate("SELECT * FROM dogs");
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dogs Database'
        ,style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: dogName,
              decoration: const InputDecoration(
                  hintText: 'Dog Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ))),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dogAge,
              keyboardType: TextInputType.number,
              maxLength: 2,
              decoration: const InputDecoration(
                  hintText: 'Dog Age',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ))),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      //
                      String name = dogName.text.trim();
                      String age = dogAge.text.trim();
                      if (name.isNotEmpty && age.isNotEmpty) {
                        setState(() {
                          sqlDb.insertDate(
                            "INSERT INTO 'dogs' ('dogname', 'dogage') VALUES ('$name', '$age')",
                          );
                        });
                        dogName.clear();
                        dogAge.clear();
                      }
                      //
                    },
                    child: const Text('Add')),
                ElevatedButton(
                  onPressed: () {
                    String name = dogName.text.trim();
                    String age = dogAge.text.trim();
                    int id = selectedIndex;
                    if (name.isNotEmpty && age.isNotEmpty) {
                      setState(() {
                        sqlDb.updateDate(
                            "UPDATE dogs SET dogage = '$age', dogname = '$name' WHERE id = $id");
                        dogName.clear();
                        dogAge.clear();
                      });
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder(
                builder:
                    (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error loading data'),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No dogs found...',style: TextStyle(fontSize: 28,color: Colors.grey),),
                        );
                      } else {
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
                                    icon:
                                        Icon(Icons.pets, color: Colors.white))),
                            title: Text( snapshot.data![index]['dogname'], style: TextStyle(fontSize: 20),),
                            subtitle: Text(snapshot.data![index]['dogage'],),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    dogName.text =
                                        snapshot.data![index]['dogname'];
                                    dogAge.text =
                                        snapshot.data![index]['dogage'];
                                    setState(() {
                                      selectedIndex =
                                          snapshot.data![index]['id'];
                                    });
                                  },
                                  icon: const Icon(Icons.edit,
                                      color: Color.fromRGBO(187, 134, 252, 1)),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _deleteDog(snapshot.data![index]['id']),
                                  icon: const Icon(Icons.delete, color: Colors.red),
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
            )
          ],
        ),
      ),
    );
  }

  Future _deleteDog(int id) async {
    setState(() {
      sqlDb.deleteDate("DELETE FROM 'dogs' WHERE id = $id");
    });
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
}
