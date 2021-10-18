import 'package:flutter/material.dart';
// import '../helpers/contact_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  @override
  void initState() {
    super.initState();

    Contact c = Contact();
    c.name = 'Leonardo';
    c.email = 'lecesar@gmail.com';
    c.phone = '12312313';
    c.img = 'adadasda';

    helper.saveContact(c);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
