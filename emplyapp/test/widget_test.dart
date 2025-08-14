// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emplyapp/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}


// test/widget_test.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:emplyapp/main.dart';
// import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
// import 'package:firebase_core/firebase_core.dart';

// void main() {
//   // Setup mock Firebase instance
//   setupFirebaseMocks();

//   setUpAll(() async {
//     await Firebase.initializeApp();
//   });

//   testWidgets('Manual Entry Page Initial State', (WidgetTester tester) async {
//     await tester.pumpWidget(MaterialApp(home: ManualEntryPage()));
    
//     // Verify main components exist
//     expect(find.text('Manual Data Entry'), findsOneWidget);
//     expect(find.byType(TypeAheadField), findsOneWidget);
//     expect(find.text('Search state...'), findsOneWidget);
//   });

//   testWidgets('Full Form Submission Flow', (WidgetTester tester) async {
//     final mockFirestore = MockFirebaseFirestore();
    
//     // Mock Firestore data
//     await mockFirestore.collection('regions').doc('TestState').set({});
//     await mockFirestore.collection('regions').doc('TestState')
//       .collection('districts').doc('TestDistrict').set({});
//     await mockFirestore.collection('regions').doc('TestState')
//       .collection('districts').doc('TestDistrict')
//       .collection('blocks').doc('TestBlock').set({});

//     await tester.pumpWidget(MaterialApp(
//       home: ManualEntryPage(firestore: mockFirestore),
//     ));

//     // Test state selection
//     await tester.enterText(find.byType(TypeAheadField).at(0), 'TestState');
//     await tester.pumpAndSettle();
//     await tester.tap(find.text('TestState'));
//     await tester.pumpAndSettle();

//     // Test district selection
//     await tester.enterText(find.byType(TypeAheadField).at(1), 'TestDistrict');
//     await tester.pumpAndSettle();
//     await tester.tap(find.text('TestDistrict'));
//     await tester.pumpAndSettle();

//     // Test block selection
//     await tester.enterText(find.byType(TypeAheadField).at(2), 'TestBlock');
//     await tester.pumpAndSettle();
//     await tester.tap(find.text('TestBlock'));
//     await tester.pumpAndSettle();

//     // Enter office name and submit
//     await tester.enterText(find.byType(TextField), 'Test Office');
//     await tester.tap(find.text('Add Office'));
//     await tester.pumpAndSettle();

//     // Verify success message
//     expect(find.text('Office added successfully!'), findsOneWidget);

//     // Verify Firestore write
//     final offices = await mockFirestore
//       .collection('regions').doc('TestState')
//       .collection('districts').doc('TestDistrict')
//       .collection('blocks').doc('TestBlock')
//       .collection('offices').get();

//     expect(offices.docs.length, 1);
//     expect(offices.docs.first.data()?['name'], 'Test Office');
//   });
// }
