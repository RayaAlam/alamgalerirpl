// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:flutter_uilogin/widget/pin_card.dart';
//
// class SearchScreen extends StatelessWidget {
//   const SearchScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Data dummy untuk search results
//     final List<Map<String, dynamic>> searchResults = [
//       {
//         'imageUrl': 'https://picsum.photos/id/11/400/500',
//         'title': 'Search Result 1',
//         'height': 250.0,
//       },
//       {
//         'imageUrl': 'https://picsum.photos/id/12/400/300',
//         'title': 'Search Result 2',
//         'height': 200.0,
//       },
//       // Add more items as needed
//     ];
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             floating: true,
//             backgroundColor: Colors.black,
//             title: Container(
//               height: 40,
//               decoration: BoxDecoration(
//                 color: Colors.grey[800],
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Search',
//                   prefixIcon: Icon(Icons.search, color: Colors.grey),
//                   border: InputBorder.none,
//                   hintStyle: TextStyle(color: Colors.grey),
//                 ),
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//           SliverPadding(
//             padding: EdgeInsets.symmetric(horizontal: 8),
//             sliver: SliverMasonryGrid.count(
//               crossAxisCount: 2,
//               mainAxisSpacing: 8,
//               crossAxisSpacing: 8,
//               itemBuilder: (context, index) {
//                 return PinCard(
//                   imageUrl: searchResults[index % searchResults.length]['imageUrl'],
//                   title: searchResults[index % searchResults.length]['title'],
//                   height: searchResults[index % searchResults.length]['height'],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
