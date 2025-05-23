import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:wisdom_herbs/contact/dark_pass.dart';
import 'package:wisdom_herbs/screen/detail_herbs.dart';
// import 'package:wisdom_herbs/screen/drawer_menu.dart';

class PageHerbsList extends StatefulWidget {
  const PageHerbsList({super.key});

  @override
  State<PageHerbsList> createState() => _PageHerbsListState();
}

class _PageHerbsListState extends State<PageHerbsList> {
  final logger = Logger();
  final ScrollController _scrollController = ScrollController();
  String? firestorePassword;
  bool isLoading = true;
  List<QueryDocumentSnapshot> docs = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    firestorePassword =
        await DarkPass.fetchPasswordFromFirestore(context: context);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการสมุนไพร"),
        backgroundColor: Colors.green,
        leading: IconButton(
        icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("Herbs").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                docs = snapshot.data!.docs
                  ..sort((a, b) => (a['namethai'] as String)
                      .compareTo(b['namethai'] as String));

                if (docs.isEmpty) {
                  return const Center(child: Text('ไม่พบข้อมูล'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final imgList =
                        (doc['img'] as List<dynamic>?)?.cast<String>();
                    return Card(
                      elevation: 8,
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 5),
                      child: ListTile(
                        // leading: imgList != null && imgList.isNotEmpty
                        //     ? Image.network(imgList[0])
                        //     : null,
                        leading: imgList != null && imgList.isNotEmpty
                            ? SizedBox(
                                width: 60, // กำหนดความกว้างที่ต้องการ
                                height: 60, // กำหนดความสูงที่ต้องการ
                                child: Image.network(
                                  imgList[0],
                                  fit: BoxFit
                                      .cover, // ทำให้ภาพขยายและครอบคลุมพื้นที่ทั้งหมด
                                ),
                              )
                            : const SizedBox(
                                width: 60,
                                height: 60,
                                child: Icon(Icons.image,
                                    color:
                                        Colors.grey), // แสดงไอคอนแทนหากไม่มีรูป
                              ),
                        title: Text(
                          doc.id, // Use doc.id to display the document ID
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(doc['scientificName']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailHerbs(id: doc.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
