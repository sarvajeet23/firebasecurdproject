import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _products = FirebaseFirestore.instance.collection('products');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_rounded),
        onPressed: () => _create(),
      ),
      appBar: AppBar(title: const Text("Firebas Flutter Project")),
      body: StreamBuilder(
        stream: _products.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];
                  return ListTile(
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(documentSnapshot['price']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _update(documentSnapshot),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => _delete(documentSnapshot.id),
                          icon: const Icon(Icons.delete),
                        )
                      ],
                    ),
                  );
                });
          } else {
            return const Center(child: Text("No Products Available"));
          }
        },
      ),
    );
  }

  var nameTextController = TextEditingController();
  var priceTextController = TextEditingController();
  _update(DocumentSnapshot<Object?> documentSnapshot) {
    if (documentSnapshot != null) {
      nameTextController.text = documentSnapshot['name'];
      priceTextController.text = documentSnapshot['price'];
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameTextController,
              decoration: const InputDecoration(
                  labelText: 'Product Title', hintText: 'Enter product name'),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: priceTextController,
              decoration: const InputDecoration(
                  labelText: 'Product price', hintText: 'Enter product price'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  if (priceTextController.text != null) {
                    await _products.doc(documentSnapshot.id).update({
                      'name': nameTextController.text,
                      'price': priceTextController.text
                    });
                    nameTextController.text = '';
                    priceTextController.text = '';
                    Navigator.pop(context);
                  }
                },
                child: const Text('Update')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  //
  Future<void> _create() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameTextController,
              decoration: const InputDecoration(
                  labelText: 'Product Title', hintText: 'Enter product name'),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: priceTextController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Product price', hintText: 'Enter product price'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  if (priceTextController.text != null) {
                    await _products.add({
                      'name': nameTextController.text,
                      'price': priceTextController.text
                    });

                    // await _products.doc("sona").set({
                    //   'name': nameTextController.text,
                    //   'price': priceTextController.text
                    // });
                    nameTextController.text = '';
                    priceTextController.text = '';
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add New Product')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(String productId) async {
    await _products.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Product deleted succesfully"),
      dismissDirection: DismissDirection.up,
      backgroundColor: Colors.green,
    ));
  }
}
