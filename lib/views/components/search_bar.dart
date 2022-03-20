import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String) onSearchSubmit;
  final Function() onTapCancel;
  final String hintText;

  const CustomSearchBar(
      {Key? key,
      required this.searchController,
      required this.onSearchSubmit,
      required this.onTapCancel,
      required this.hintText})
      : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(1, 8), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildSearchField(),
          // GestureDetector(
          //     onTap: widget.onTapSetting, child: const Icon(Icons.settings))
        ],
      ),
    );
  }

  Widget buildSearchField() {
    return Expanded(
      child: TextFormField(
        controller: widget.searchController,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          hintText: widget.hintText,
          filled: true,
          prefixIcon: const Icon(
            Icons.search,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: widget.onSearchSubmit,
      ),
    );
  }

  void clearSearch() {
    widget.onTapCancel.call();
    widget.searchController.clear();
    FocusScope.of(context).unfocus();
  }
}
