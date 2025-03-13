import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> pin;

  const DetailScreen({
    required this.pin,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String? currentUserId = currentUser?.uid;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.5),
              BlendMode.softLight,
            ),
          ),
        ),
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 1),
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 1),
                    ),
                    child: Icon(Icons.delete, color: Colors.white, size: 20),
                  ),
                  onPressed: () async {
                    if (currentUserId != pin['user']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Anda tidak dapat menghapus postingan user lain',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Color(0xFF2A2A2A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              'Konfirmasi Hapus',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'Apakah Anda yakin ingin menghapus postingan ini?',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(
                                  'Batal',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  'Hapus',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        await FirebaseFirestore.instance
                            .collection('posts')
                            .doc(pin['id'])
                            .delete();

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Postingan berhasil dihapus',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Terjadi kesalahan: $e',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
              expandedHeight: 500,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: pin['id'],
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(pin['imageUrl']),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pin['title'],
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[800],
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 16),
                          FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection("users")
                                .doc(pin["user"])
                                .get(),
                            builder: (context, snapshot) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Posted by',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white60,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  snapshot.data != null
                                      ? snapshot.data?.get("username")
                                      : "Loading...",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





// class DetailScreen extends StatelessWidget {
//   final Map<String, dynamic> pin;
//
//   const DetailScreen({
//     required this.pin,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final User? currentUser = FirebaseAuth.instance.currentUser;
//     final String? currentUserId = currentUser?.uid;
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             backgroundColor: Colors.transparent,
//             leading: IconButton(
//               icon: Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.5),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.arrow_back, color: Colors.white),
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//             actions: [
//               IconButton(
//                 icon: Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.5),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(Icons.delete, color: Colors.white),
//                 ),
//                 onPressed: () async {
//                   // Check if current user is the post owner
//                   if (currentUserId != pin['user']) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                             'Anda tidak dapat menghapus postingan user lain'),
//                         backgroundColor: Colors.red,
//                         duration: Duration(seconds: 2),
//                         behavior: SnackBarBehavior.floating,
//                         margin: EdgeInsets.all(16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     );
//                     return;
//                   }
//
//                   try {
//                     // Tampilkan dialog konfirmasi
//                     bool? confirm = await showDialog<bool>(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AlertDialog(
//                           backgroundColor: Colors.grey[900],
//                           title: Text(
//                             'Konfirmasi Hapus',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                           content: Text(
//                             'Apakah Anda yakin ingin menghapus postingan ini?',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(false),
//                               child: Text(
//                                 'Batal',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(true),
//                               child: Text(
//                                 'Hapus',
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//
//                     // Jika user mengkonfirmasi
//                     if (confirm == true) {
//                       // Hapus dokumen dari Firestore
//                       await FirebaseFirestore.instance
//                           .collection('posts')
//                           .doc(pin['id'])
//                           .delete();
//
//                       // Kembali ke halaman sebelumnya
//                       Navigator.pop(context);
//
//                       // Tampilkan snackbar sukses
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Postingan berhasil dihapus'),
//                           backgroundColor: Colors.green,
//                           behavior: SnackBarBehavior.floating,
//                           margin: EdgeInsets.all(16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       );
//                     }
//                   } catch (e) {
//                     // Tampilkan snackbar error jika terjadi kesalahan
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Terjadi kesalahan: $e'),
//                         backgroundColor: Colors.red,
//                         behavior: SnackBarBehavior.floating,
//                         margin: EdgeInsets.all(16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ],
//             expandedHeight: 400,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Image.network(
//                 pin['imageUrl'],
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Container(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     pin['title'],
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         backgroundColor: Colors.grey[800],
//                         child: Icon(Icons.person, color: Colors.white),
//                       ),
//                       SizedBox(width: 12),
//                       FutureBuilder(
//                           future: FirebaseFirestore.instance
//                               .collection("users")
//                               .doc(pin["user"])
//                               .get(),
//                           builder: (context, snapshot) => Text(
//                                 snapshot.data != null
//                                     ? snapshot.data?.get("username")
//                                     : "Loading...",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.white,
//                                 ),
//                               )),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildActionButton(IconData icon, String label) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.white),
//         SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(color: Colors.white),
//         ),
//       ],
//     );
//   }
// }
