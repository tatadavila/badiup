import 'package:badiup/models/admin_model.dart';
import 'package:badiup/models/customer_model.dart';
import 'package:badiup/models/user_setting_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badiup/models/user_model.dart';
import 'package:badiup/constants.dart' as Constants;

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
User currentSignedInUser;

Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final FirebaseUser user = await _auth.signInWithCredential(credential);

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  // add user to DB, user email as document ID
  currentSignedInUser = Customer(
      name: user.displayName,
      //role: 0, //RoleType.customer,
      //setting: UserSetting(pushNotifications: false),
      created: DateTime.now().toUtc(),
  );
  await Firestore.instance.collection(Constants.DBCollections.customers).document(user.email).setData(
    currentSignedInUser.toMap()
  );

  return 'signInWithGoogle succeeded: $user';
}

void signOutGoogle() async{
  final FirebaseUser currentUser = await _auth.currentUser();
  await googleSignIn.signOut();
  print('$currentUser signed out');
}