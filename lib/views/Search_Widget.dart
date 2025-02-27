import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants.dart';
import 'Date_Search_Field.dart';

class SearchWidget extends StatefulWidget {
  final String title;

  const SearchWidget({super.key, this.title = ''});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Constants().padding_20,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        spacing: 30,
        children: <Widget>[
          if (widget.title.isNotEmpty)
            Text(
              widget.title,
              style: GoogleFonts.abel(fontSize: 40),
            ),
          buildSearchBar(context, _fromController, 'From'),
          buildSearchBar(context, _toController, 'To'),
          const DateSearchField(),
          ElevatedButton(onPressed: null, child: Text('Search')),
        ],
      ),
    );
  }

  TextField buildSearchBar(
    BuildContext context,
    TextEditingController controller,
    String labelText,
  ) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        filled: true,
        fillColor: Colors.white60,
        labelStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      style: Theme.of(context).textTheme.headlineSmall,
      controller: controller,
    );
  }
}
